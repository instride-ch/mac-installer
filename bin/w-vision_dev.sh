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
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$HOME/.bashrc"
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
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
cp "$BASE"brewfiles/Brewfile ~/Brewfile
cat "$BASE"brewfiles/Brewfile.w-vision_dev >> ~/Brewfile

# install brew apps
notify '🍺 Installing brew apps'
brew bundle

# install nvm
if [[ ! "$(command -v nvm)" ]]; then
    notify '🌶 Installing node version manager'
    /usr/bin/ruby -e "$(curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash)";

    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi

notify '✅ Installing latest LTS Node.js version'
nvm install --lts
nvm use --lts

# install Yarn
notify '💪 Installing Yarn'
brew install yarn --ignore-dependencies

# install Composer
if [[ ! "$(composer -v)" ]]; then
    notify '💪 Installing Composer'
    /usr/bin/ruby -e "$(curl -o composer.phar -sS https://getcomposer.org/download/1.10.16/composer.phar)";
# ToDo: Composer v2
#    /usr/bin/ruby -e "$(curl -sS https://getcomposer.org/installer | php)";

    sudo mv composer.phar /usr/local/bin/
    notify 'alias composer="php /usr/local/bin/composer.phar"' >>~/.bash_profile
fi

# install git
brew install git

# ToDo: PHP 7.4/8.0

notify '✅ Software by brew should be installed by now'

notify '💪 Setting some Mac settings'
$CONFIG/base.sh
$CONFIG/w-vision_dev.sh

notify '🙏 Ready for take off! Please install the copied software in the folder "ToInstall".'
