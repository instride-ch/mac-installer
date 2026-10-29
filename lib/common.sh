# Shared helpers for install.sh (expects SCRIPT_DIR to be set)

###############################################################################
# Variables                                                                   #
###############################################################################

SHARE_HOST=fs03.wopa.int                           # file server for manual software
SHARE_SRC=/Volumes/recycling/_install_macbooks     # src path for manual software
DEST="$SCRIPT_DIR/ToInstall"                       # destination path for manual software
NVM_VERSION=v0.40.8                                # https://github.com/nvm-sh/nvm/releases

# copied from the network share for every role
# shellcheck disable=SC2034  # used by install.sh
BASE_SHARE_ITEMS=(sonos_controller workspace_v2104_citrix dock_plist dock_spaces DefenderForBusiness)

FAILED_PACKAGES=()                                 # brew / mas entries that failed to install
MISSING_ITEMS=()                                   # share items that could not be copied
MANUAL_STEPS=()                                    # hints printed in the summary

###############################################################################
# Logging                                                                     #
###############################################################################

function notify() { echo -e "\n\033[1m$*\033[0m"; }
function warn() { echo -e "\n\033[1;33m⚠️  $*\033[0m"; }
function info() { echo -e "  $*"; }

###############################################################################
# Setup steps                                                                 #
###############################################################################

# Ask for the root password once and keep sudo alive until the script exits
function keep_sudo_alive() {
    notify "Enter root password...\n"
    sudo -v
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
}

# Homebrew needs the Xcode Command Line Tools
function ensure_clt() {
    if xcode-select -p >/dev/null 2>&1; then return 0; fi

    notify '🛠 Installing Xcode Command Line Tools (confirm the dialog)'
    xcode-select --install || true
    until xcode-select -p >/dev/null 2>&1; do sleep 10; done
}

function brew_path() {
    if [[ "$(uname -m)" == arm64 ]]; then echo /opt/homebrew/bin/brew; else echo /usr/local/bin/brew; fi
}

# Install Homebrew if missing and put it on the PATH (now and for future zsh sessions)
function ensure_brew() {
    local brew line
    brew="$(brew_path)"

    if [[ ! -x "$brew" ]]; then
        notify '🌶 Installing Homebrew'
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    line="eval \"\$($brew shellenv)\""
    if ! grep -qsF "$line" "$HOME/.zprofile"; then echo "$line" >> "$HOME/.zprofile"; fi
    eval "$("$brew" shellenv)"
}

# Merge the given brewfiles into ~/Brewfile (used by bin/update.sh later) and install every entry
function install_brewfiles() {
    local brewfile="$HOME/Brewfile" file line
    local re_pkg="^(brew|cask) '([^']+)'" re_mas="^mas '([^']+)', id: ([0-9]+)"

    if [[ -f "$brewfile" ]]; then cp "$brewfile" "$brewfile.bak"; fi
    : > "$brewfile"
    for file in "$@"; do
        cat "$SCRIPT_DIR/brewfiles/$file" >> "$brewfile"
        echo >> "$brewfile"
    done

    notify '🍺 Installing brew apps'
    # read via fd 3, so installers can not swallow the Brewfile from stdin
    while IFS= read -r line <&3; do
        if [[ "$line" =~ $re_pkg ]]; then
            "install_${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
        elif [[ "$line" =~ $re_mas ]]; then
            install_mas "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
        fi
    done 3< "$brewfile"
}

function install_brew() {
    local name="$1" version

    version="$(brew list --formula --versions "$name" 2>/dev/null || true)"
    if [[ -n "$version" ]]; then
        info "✓ $version already installed"
        return 0
    fi

    info "⬇️  Installing $name"
    brew install "$name" || FAILED_PACKAGES+=("$name")
}

function install_cask() {
    local name="$1" app

    if brew list --cask "$name" >/dev/null 2>&1; then
        info "✓ $name already installed"
        return 0
    fi

    # app installed manually (not via Homebrew) -> brew would fail with "already an App at ..."
    while IFS= read -r app; do
        if [[ -d "/Applications/$app" || -d "$HOME/Applications/$app" ]]; then
            info "✓ $name already installed ($app, not managed by Homebrew)"
            return 0
        fi
    done < <(brew info --cask "$name" 2>/dev/null | sed -n 's/^\(.*\.app\) (App)$/\1/p')

    info "⬇️  Installing $name"
    brew install --cask "$name" || FAILED_PACKAGES+=("$name")
}

# Mac App Store apps (you have to be signed in to the App Store)
function install_mas() {
    local name="$1" id="$2"

    if awk -v id="$id" '$1 == id { found = 1 } END { exit !found }' <<< "$(mas list 2>/dev/null)"; then
        info "✓ $name already installed"
        return 0
    fi

    info "⬇️  Installing $name (App Store)"
    mas install "$id" || FAILED_PACKAGES+=("$name")
}

# Install nvm and the latest LTS Node.js version
function setup_node() {
    export NVM_DIR="$HOME/.nvm"

    if [[ -s "$NVM_DIR/nvm.sh" ]]; then
        info '✓ nvm already installed'
    else
        notify '🌶 Installing node version manager'
        touch "$HOME/.zshrc"
        curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh" | PROFILE="$HOME/.zshrc" bash
    fi

    # nvm does not support errexit/nounset
    set +eu
    # shellcheck source=/dev/null
    source "$NVM_DIR/nvm.sh"
    notify '✅ Installing latest LTS Node.js version'
    nvm install --lts
    nvm alias default 'lts/*'
    set -eu
}

# Set the git identity and optionally create an SSH key
function setup_git() {
    local name email answer key="$HOME/.ssh/id_ed25519"

    name="$(git config --global user.name || true)"
    email="$(git config --global user.email || true)"
    if [[ -z "$name" ]]; then
        read -r -p 'Git user name (e.g. Jane Doe): ' name
        git config --global user.name "$name"
    fi
    if [[ -z "$email" ]]; then
        read -r -p 'Git e-mail: ' email
        git config --global user.email "$email"
    fi

    if [[ -f "$key" ]]; then return 0; fi

    read -r -n1 -p "Create an SSH key for $email? [y/N] " answer; echo
    if [[ ! "$answer" =~ ^[Yy]$ ]]; then return 0; fi

    mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
    ssh-keygen -t ed25519 -C "$email" -f "$key"
    if ! grep -qs UseKeychain "$HOME/.ssh/config"; then
        printf 'Host *\n  AddKeysToAgent yes\n  UseKeychain yes\n  IdentityFile ~/.ssh/id_ed25519\n' >> "$HOME/.ssh/config"
    fi
    ssh-add --apple-use-keychain "$key" || warn 'Could not add the SSH key to the agent'
    pbcopy < "$key.pub"
    MANUAL_STEPS+=('Your SSH public key is in the clipboard: add it to GitHub / GitLab')
}

# Connect the network share (with AppleScript); fails if the software folder is not reachable
function mount_share() {
    notify '📂 Connecting network share'
    osascript <<EOF || true
set theResponse to display dialog "Username for network share:" default answer "" with icon note buttons {"Continue"} default button "Continue"
--> {button returned:"Continue", text returned:""}
mount volume "smb://" & (text returned of theResponse) & "@$SHARE_HOST/recycling"
mount volume "smb://" & (text returned of theResponse) & "@$SHARE_HOST/"
EOF

    if [[ ! -d "$SHARE_SRC" ]]; then
        warn "Network share not available: $SHARE_SRC"
        return 1
    fi
}

# Copy software that is not available via brew to ToInstall
function copy_from_share() {
    local item

    notify '📦 Copying software from the network share'
    mkdir -p "$DEST"
    for item in "$@"; do
        if [[ -d "$SHARE_SRC/$item" ]] && mkdir -p "$DEST/$item" && cp -R "$SHARE_SRC/$item/" "$DEST/$item/"; then
            continue
        fi
        MISSING_ITEMS+=("$item")
    done
}

# Restart the apps that only read their settings on launch
function restart_ui() {
    killall Finder Dock SystemUIServer 2>/dev/null || true
}

function print_summary() {
    local step

    if (( ${#FAILED_PACKAGES[@]} )); then
        warn "Failed to install: ${FAILED_PACKAGES[*]}"
        MANUAL_STEPS+=("Check the errors above and re-run: brew bundle --file=$HOME/Brewfile")
    fi

    if (( ${#MISSING_ITEMS[@]} )); then
        warn "Not copied from the network share: ${MISSING_ITEMS[*]}"
        MANUAL_STEPS+=("Get the missing items from smb://$SHARE_HOST/recycling/_install_macbooks")
    fi

    if (( ${#MANUAL_STEPS[@]} )); then
        notify '📝 Manual steps:'
        for step in "${MANUAL_STEPS[@]}"; do echo "  - $step"; done
    fi

    notify '🙏 Ready for take off! Please install the copied software in the folder "ToInstall".'
    if [[ -d "$DEST" ]]; then open "$DEST"; fi
}
