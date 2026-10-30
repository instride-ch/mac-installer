#!/bin/bash
# "sh script.sh" runs bash in POSIX mode, which has no process substitution
if [[ -o posix ]]; then exec /bin/bash "$0" "$@"; fi
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # repository root
source "$SCRIPT_DIR/lib/common.sh"

# Run a step, remember it if it fails and continue with the next one
function step() {
    notify "$*"
    "$@" || FAILED_COMMANDS+=("$*")
}

# some casks need sudo to upgrade (e.g. docker-desktop, dropbox, libreoffice)
keep_sudo_alive

# Update brew and brew apps (--greedy: also casks that update themselves)
step brew update
step brew upgrade
step brew upgrade --cask --greedy

# Install entries that are missing from the Brewfile of the installation
if [[ -f "$HOME/Brewfile" ]]; then step brew bundle --file="$HOME/Brewfile"; fi

# Update App Store apps
if command -v mas >/dev/null; then step mas upgrade; fi

if (( ${#FAILED_COMMANDS[@]} )); then
    warn 'Failed (check the errors above, then run these commands yourself):'
    for command in "${FAILED_COMMANDS[@]}"; do echo "  $command"; done
    exit 1
fi

notify '✅ Everything is up to date'
