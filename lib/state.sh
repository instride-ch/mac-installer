# Remembers the original state before the installer changes something and reverts it.
# Only the first install run is recorded, so running the installer twice keeps the original values.
# Brew packages and the Homebrew PATH entry in ~/.zprofile are not reverted.

STATE_DIR="$HOME/.macinstaller"                    # backup of the original state
SSH_MARK_BEGIN='# >>> macinstaller >>>'
SSH_MARK_END='# <<< macinstaller <<<'

###############################################################################
# Backup                                                                      #
###############################################################################

# Save a flag or value once
function remember() {
    mkdir -p "$STATE_DIR"
    if [[ ! -e "$STATE_DIR/$1" ]]; then printf '%s' "${2-}" > "$STATE_DIR/$1"; fi
}
function remembered() { [[ -e "$STATE_DIR/$1" ]]; }

# Save a copy of a file (or that it did not exist) once
function backup_file() {
    mkdir -p "$STATE_DIR"
    if [[ -e "$STATE_DIR/$2" || -e "$STATE_DIR/$2.absent" ]]; then return 0; fi
    if [[ -f "$1" ]]; then cp -p "$1" "$STATE_DIR/$2"; else touch "$STATE_DIR/$2.absent"; fi
}

# Same as `defaults write`, but remembers the previous value first
function set_default() {
    local domain="$1" key="$2" type value
    shift 2

    mkdir -p "$STATE_DIR"
    if ! grep -qsF "$domain"$'\t'"$key"$'\t' "$STATE_DIR/defaults.tsv"; then
        if type="$(defaults read-type "$domain" "$key" 2>/dev/null)"; then
            type="${type#Type is }"
            value="$(defaults read "$domain" "$key" | base64)"
        else
            type=absent value=
        fi
        printf '%s\t%s\t%s\t%s\n' "$domain" "$key" "$type" "$value" >> "$STATE_DIR/defaults.tsv"
    fi

    defaults write "$domain" "$key" "$@"
}

# Remember a PlistBuddy value (path like :A:B:C) before it gets changed
function backup_plist_value() {
    local plist="$1" path="$2" value

    mkdir -p "$STATE_DIR"
    if grep -qsF "$plist"$'\t'"$path"$'\t' "$STATE_DIR/plist.tsv"; then return 0; fi
    value="$(/usr/libexec/PlistBuddy -c "Print $path" "$plist" 2>/dev/null || echo __absent__)"
    printf '%s\t%s\t%s\n' "$plist" "$path" "$value" >> "$STATE_DIR/plist.tsv"
}

###############################################################################
# Revert                                                                      #
###############################################################################

function restore_file() {
    if [[ -e "$STATE_DIR/$2" ]]; then
        cp -p "$STATE_DIR/$2" "$1"
        info "↩︎ restored $1"
    elif [[ -e "$STATE_DIR/$2.absent" ]]; then
        rm -f "$1"
        info "↩︎ removed $1"
    fi
}

function revert_defaults() {
    local domain key type value

    if [[ ! -f "$STATE_DIR/defaults.tsv" ]]; then return 0; fi
    while IFS=$'\t' read -r domain key type value <&3; do
        value="$(base64 -D <<< "$value")"
        case "$type" in
        absent)  defaults delete "$domain" "$key" 2>/dev/null || true                 ;;
        boolean) if [[ "$value" == 1 ]]; then value=true; else value=false; fi
                 defaults write "$domain" "$key" -bool "$value"                       ;;
        integer) defaults write "$domain" "$key" -int "$value"                        ;;
        float)   defaults write "$domain" "$key" -float "$value"                      ;;
        string)  defaults write "$domain" "$key" -string "$value"                     ;;
        # array / dictionary: `defaults read` prints old-style plist, which `defaults write` parses
        *)       defaults write "$domain" "$key" "$value"                             ;;
        esac
        info "↩︎ $domain $key"
    done 3< "$STATE_DIR/defaults.tsv"
}

function revert_plist_values() {
    local plist path value

    if [[ ! -f "$STATE_DIR/plist.tsv" ]]; then return 0; fi
    while IFS=$'\t' read -r plist path value <&3; do
        if [[ "$value" == __absent__ ]]; then
            /usr/libexec/PlistBuddy -c "Delete $path" "$plist" 2>/dev/null || true
        else
            /usr/libexec/PlistBuddy -c "Set $path $value" "$plist" 2>/dev/null || true
        fi
        info "↩︎ $path"
    done 3< "$STATE_DIR/plist.tsv"
}

function revert_gatekeeper() {
    if remembered gatekeeper && grep -q enabled "$STATE_DIR/gatekeeper"; then
        sudo spctl --master-enable
        info '↩︎ Gatekeeper enabled'
    fi
}

function revert_node() {
    local nvm_dir="$HOME/.nvm" path version

    if remembered nvm_installed; then
        rm -rf "$nvm_dir"
        if [[ -f "$HOME/.zshrc" ]]; then sed -i '' '/NVM_DIR/d' "$HOME/.zshrc"; fi
        if remembered zshrc.absent && [[ ! -s "$HOME/.zshrc" ]]; then rm -f "$HOME/.zshrc"; fi
        info '↩︎ removed nvm and all Node.js versions'
    elif remembered node_versions; then
        # only remove versions the installer added
        for path in "$nvm_dir"/versions/node/*; do
            [[ -d "$path" ]] || continue
            version="${path##*/}"
            if ! grep -qxF "$version" "$STATE_DIR/node_versions"; then
                rm -rf "$path"
                info "↩︎ removed Node.js $version"
            fi
        done
        restore_file "$nvm_dir/alias/default" nvm_alias_default
    fi
}

function revert_git() {
    local answer key="$HOME/.ssh/id_ed25519"

    if remembered git_name_set; then git config --global --unset user.name || true; info '↩︎ git user.name'; fi
    if remembered git_email_set; then git config --global --unset user.email || true; info '↩︎ git user.email'; fi

    if [[ -f "$HOME/.ssh/config" ]]; then
        sed -i '' "/^$SSH_MARK_BEGIN\$/,/^$SSH_MARK_END\$/d" "$HOME/.ssh/config"
    fi

    if remembered ssh_key_created && [[ -f "$key" ]]; then
        read -r -n1 -p "Delete the SSH key $key created by the installer? It may be registered on GitHub / GitLab. [y/N] " answer; echo
        if [[ "$answer" =~ ^[Yy]$ ]]; then
            ssh-add -d "$key" 2>/dev/null || true
            rm -f "$key" "$key.pub"
            info "↩︎ removed $key"
        fi
    fi
}

# Undo everything the installer changed, except brew packages
function revert_all() {
    if [[ ! -d "$STATE_DIR" ]]; then
        notify "Nothing to revert: no backup found in $STATE_DIR"
        return 0
    fi

    keep_sudo_alive
    notify '↩️  Reverting changes (brew packages stay installed)'
    revert_defaults
    revert_plist_values
    revert_gatekeeper
    restore_file "$HOME/Brewfile" Brewfile
    revert_node
    revert_git
    rm -rf "$DEST"
    restart_ui

    rm -rf "$STATE_DIR"
    notify '✅ Reverted. Log out and in again to apply all settings.'
}
