# ToDo: Copy folder to home dir (automatically or manual?) for easier update later??

###############################################################################
# Variables                                                                   #
###############################################################################

CONFIG=../bin/config                   # configuration files directory

###############################################################################

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

# merge & copy correct Brewfile for easier update later
# ToDo/Note: Didn't find an easier way. OK? We could also only use two different brewfiles without merging
cp ../brewfiles/Brewfile ../Brewfile
cat ../brewfiles/Brewfile.wopa_vorstufe >> ../Brewfile

# install brew apps
brew bundle

notify '💪 Setting some Mac settings'
$CONFIG/base.sh
$CONFIG/wopa_vorstufe.sh

notify '✅ Everything should be installed by now'
notify 'enjoy your freshly installed MAC  @ Woche-Pass AG'
