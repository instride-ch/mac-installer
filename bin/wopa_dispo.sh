#!/bin/bash

###############################################################################
# Variables                                                                   #
###############################################################################

BASE=~/MacInstaller/                         # base directory
CONFIG=~/MacInstaller/bin/config             # configuration files directory

###############################################################################

# logging
function notify() { echo -e "\n\033[1m$@\033[0m"; }

# Entering as Root
notify "Enter root password...\n"
sudo -v

# Keep alive Root
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# install homebrew
if [[ ! "$(type -P brew)" ]]; then
    notify '🌶 Installing homebrew'
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# installs bundle Bundle
brew tap Homebrew/bundle
brew install mas

# Not working ATM: https://github.com/mas-cli/mas/issues/164
# Get Apple ID
#notify ' Enter your Apple-ID followed by [ENTER ↵]:'
#read -e APPLEID
#notify '🍎 Signing in with your Apple-ID'
#mas signin $APPLEID

# merge & copy correct Brewfile for easier update later
cp "$BASE"brewfiles/Brewfile "$BASE"Brewfile
cat "$BASE"brewfiles/Brewfile.w-vision_pl >> "$BASE"Brewfile

# install brew apps
brew bundle

notify '💪 Setting some Mac settings'
$CONFIG/base.sh
$CONFIG/wopa_dispo.sh

notify '✅ Everything should be installed by now'
notify 'enjoy your freshly installed MAC  @ Woche-Pass AG'
