#!/usr/bin/env bash

# logging
function notify() { echo -e "\n\033[1m$@\033[0m"; }

# Set the Application folder to the User
export HOMEBREW_CASK_OPTS="--appdir=~/Applications"

notify 'Welcome to w-vision, this script will install the Apps you need'
notify 'in order to be up and running as quickly as possible'

# checks if Apple-ID was used as argument, if not ask for it
if [ $# -eq 0 ]
  then
    notify ' Enter your Apple-ID followed by [ENTER ↵]:'
    read APPLEID
else
    APPLEID=$1
fi

# install homebrew
if [[ ! "$(type -P brew)" ]]; then
    notify '🌶 Installing homebrew'
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)";
fi

# installs bundle Bundle
brew tap Homebrew/bundle
brew install mas

notify '🍎 Signing in with your Apple-ID'
mas signin $APPLEID

notify '❗ Next time you are asked for you password, enter you system password'
notify '❗ NOT the apple store password:'

# restore installed apps
brew bundle

# install nvm
if [[ ! "$(command -v nvm)" ]]; then
    notify '🌶 Installing node version manager'
    /usr/bin/ruby -e "$(curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash)";

    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
fi

notify '✅ Making sure you are using the correct node version'
nvm install 8.9.4
nvm use 8.9.4

# install Yarn
notify '💪 Installing Yarn'
brew install yarn --without-node

# install Composer
if [[ ! "$(composer -v)" ]]; then
    notify '💪 Installing Composer'
    /usr/bin/ruby -e "$(curl -sS https://getcomposer.org/installer | php)";

    sudo mv composer.phar /usr/local/bin/
    echo 'alias composer="php /usr/local/bin/composer.phar"' >>~/.bash_profile
fi

notify '✅ Everything should be installed by now'
notify 'enjoy your freshly installed MAC  @ w-vision'