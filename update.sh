#!/bin/bash
set -euo pipefail

# Update brew and brew apps (--greedy: also casks that update themselves)
brew update
brew upgrade
brew upgrade --cask --greedy

# Install entries that are missing from the Brewfile of the installation
if [[ -f "$HOME/Brewfile" ]]; then
    brew bundle --file="$HOME/Brewfile" || echo 'Some Brewfile entries could not be installed, see above.'
fi

# Update App Store apps
if command -v mas >/dev/null; then mas upgrade; fi
