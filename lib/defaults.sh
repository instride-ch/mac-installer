# macOS settings, applied after the software installation

###############################################################################
# All roles                                                                   #
###############################################################################

function defaults_base() {
    local plist="$HOME/Library/Preferences/com.apple.finder.plist" view

    notify '💪 Setting some Mac settings'

    #"Disabling system-wide resume"
    defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false

    #"Disabling automatic termination of inactive apps"
    defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

    #"Disabling OS X Gate Keeper"
    #"(You'll be able to install any app you want from here on, not just Mac App Store apps)"
    sudo spctl --master-disable || true
    defaults write com.apple.LaunchServices LSQuarantine -bool false
    # Since macOS 15 "Anywhere" has to be confirmed manually
    if (( $(sw_vers -productVersion | cut -d. -f1) >= 15 )); then
        open 'x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension'
        MANUAL_STEPS+=('Privacy & Security: set "Allow applications from" to "Anywhere"')
    fi

    #"Expanding the save panel by default"
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

    #"Automatically quit printer app once the print jobs complete"
    defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

    #"Saving to disk (not to iCloud) by default"
    defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

    #"Showing icons for hard drives, servers, and removable media on the desktop"
    defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true

    #"Avoiding the creation of .DS_Store files on network volumes"
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

    #"Enabling snap-to-grid for icons on the desktop and in other icon views"
    # (keys do not exist on a fresh account, so add them if Set fails)
    for view in DesktopViewSettings FK_StandardViewSettings StandardViewSettings; do
        /usr/libexec/PlistBuddy -c "Set :$view:IconViewSettings:arrangeBy grid" "$plist" 2>/dev/null && continue
        /usr/libexec/PlistBuddy -c "Add :$view dict" "$plist" 2>/dev/null || true
        /usr/libexec/PlistBuddy -c "Add :$view:IconViewSettings dict" "$plist" 2>/dev/null || true
        /usr/libexec/PlistBuddy -c "Add :$view:IconViewSettings:arrangeBy string grid" "$plist" 2>/dev/null || true
    done

    #"Enabling UTF-8 ONLY in Terminal.app and setting the Pro theme by default"
    defaults write com.apple.terminal StringEncodings -array 4
    defaults write com.apple.Terminal "Default Window Settings" -string "Pro"
    defaults write com.apple.Terminal "Startup Window Settings" -string "Pro"

    #"Preventing Time Machine from prompting to use new hard drives as backup volume"
    defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

    #"Disable annoying backswipe in Chrome"
    defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false

    #"Setting screenshots location to ~/Desktop"
    defaults write com.apple.screencapture location -string "$HOME/Desktop"

    #"Setting screenshot format to PNG"
    defaults write com.apple.screencapture type -string "png"

    #"Disable 'natural' (Lion-style) scrolling"
    defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

    # Don’t automatically rearrange Spaces based on most recent use
    defaults write com.apple.dock mru-spaces -bool false

    #"Disable smart quotes and smart dashes as they are annoying when typing code"
    defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
    defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

    #"Showing all filename extensions in Finder by default"
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true

    #"Disabling the warning when changing a file extension"
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

    #"Adding a context menu item for showing the Web Inspector in web views"
    defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

    # Safari is sandboxed, its settings can not be written from the terminal
    MANUAL_STEPS+=('Safari: Settings → Advanced → enable "Show features for web developers"')
}
