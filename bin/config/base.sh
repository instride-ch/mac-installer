### Variables
SRC=/Volumes/recycling/_install_macbooks    # src path for manual software
DEST=~/MacInstaller/ToInstall               # destination path for manual software

### Connect network share (with AppleScript)
osascript <<EOF
set theResponse to display dialog "Username for network share:" default answer "" with icon note buttons {"Continue"} default button "Continue"
--> {button returned:"Continue", text returned:""}
mount volume "smb://" & (text returned of theResponse) & "@fs03.wopa.int/recycling"
mount volume "smb://" & (text returned of theResponse) & "@fs03.wopa.int/"
EOF

### Config
#"Disabling system-wide resume"
defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false

#"Disabling automatic termination of inactive apps"
defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

#"Allow text selection in Quick Look"
defaults write com.apple.finder QLEnableTextSelection -bool TRUE

#"Disabling OS X Gate Keeper"
#"(You'll be able to install any app you want from here on, not just Mac App Store apps)"
# ToDo: Do we want to disable it?
sudo spctl --master-disable
sudo defaults write /var/db/SystemPolicy-prefs.plist enabled -string no
defaults write com.apple.LaunchServices LSQuarantine -bool false

#"Expanding the save panel by default"
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

#"Automatically quit printer app once the print jobs complete"
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

#"Saving to disk (not to iCloud) by default"
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

#"Check for software updates daily, not just once per week"
# ToDo: How we want to deal with that?
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

#"Enabling full keyboard access for all controls (e.g. enable Tab in modal dialogs)"
# ToDo: Check if this makes sense - is disabled on my macbook
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

#"Disabling press-and-hold for keys in favor of a key repeat"
# ToDo: Do we want that? - is enabled on my macbook
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

#"Setting trackpad & mouse speed to a reasonable number"
# ToDo: Check if this makes sense
defaults write -g com.apple.trackpad.scaling 2
defaults write -g com.apple.mouse.scaling 2.5

#"Enabling subpixel font rendering on non-Apple LCDs"
# ToDo: check out
defaults write NSGlobalDomain AppleFontSmoothing -int 2

#"Showing icons for hard drives, servers, and removable media on the desktop"
# ToDo: design question
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true

#"Avoiding the creation of .DS_Store files on network volumes"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

#"Enabling snap-to-grid for icons on the desktop and in other icon views"
# ToDo: Remove?
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

#"Enabling UTF-8 ONLY in Terminal.app and setting the Pro theme by default"
# ToDo: Check
defaults write com.apple.terminal StringEncodings -array 4
defaults write com.apple.Terminal "Default Window Settings" -string "Pro"
defaults write com.apple.Terminal "Startup Window Settings" -string "Pro"

#"Preventing Time Machine from prompting to use new hard drives as backup volume"
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

#"Speeding up wake from sleep to 24 hours from an hour"
# http://www.cultofmac.com/221392/quick-hack-speeds-up-retina-macbooks-wake-from-sleep-os-x-tips/
sudo pmset -a standbydelay 86400

#"Disable annoying backswipe in Chrome"
defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false

#"Setting screenshots location to ~/Desktop"
defaults write com.apple.screencapture location -string "$HOME/Desktop"

#"Setting screenshot format to PNG"
defaults write com.apple.screencapture type -string "png"

#"Disabling Safari's thumbnail cache for History and Top Sites"
defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2

#"Making Safari's search banners default to Contains instead of Starts With"
defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false

#"Removing useless icons from Safari's bookmarks bar"
defaults write com.apple.Safari ProxiesInBookmarksBar "()"

#"Allow hitting the Backspace key to go to the previous page in history"
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled -bool true

#"Disable 'natural' (Lion-style) scrolling"
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Don’t automatically rearrange Spaces based on most recent use
# ToDo: Needed?
defaults write com.apple.dock mru-spaces -bool false


### Install software without brew
# Sonos controller
mkdir -p $DEST/sonos_controller/ && cp -R $SRC/sonos_controller/ $DEST/sonos_controller/
# Citrix Workspace
mkdir -p $DEST/workspace_v2104_citrix/ && cp -R $SRC/workspace_v2104_citrix/ $DEST/workspace_v2104_citrix/
# Dock plist
mkdir -p $DEST/dock_plist/ && cp -R $SRC/dock_plist/ $DEST/dock_plist/
# Dockspaces
mkdir -p $DEST/dock_spaces/ && cp -R $SRC/dock_spaces/ $DEST/dock_spaces/
# DefenderForBusiness
mkdir -p $DEST/DefenderForBusiness/ && cp -R $SRC/DefenderForBusiness/ $DEST/DefenderForBusiness/

killall Finder

## open folder in finder
open $DEST
