# macOS settings, applied after the software installation

###############################################################################
# All roles                                                                   #
###############################################################################

function defaults_base() {
    local plist="$HOME/Library/Preferences/com.apple.finder.plist" view

    notify '💪 Setting some Mac settings'

    #"Disabling system-wide resume"
    set_default NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false

    #"Disabling automatic termination of inactive apps"
    set_default NSGlobalDomain NSDisableAutomaticTermination -bool true

    #"Disabling OS X Gate Keeper"
    #"(You'll be able to install any app you want from here on, not just Mac App Store apps)"
    remember gatekeeper "$(spctl --status 2>&1 || true)"
    sudo spctl --master-disable || true
    set_default com.apple.LaunchServices LSQuarantine -bool false
    # Since macOS 15 "Anywhere" has to be confirmed manually
    if (( $(sw_vers -productVersion | cut -d. -f1) >= 15 )); then
        open 'x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension'
        MANUAL_STEPS+=('Privacy & Security: set "Allow applications from" to "Anywhere"')
    fi

    #"Expanding the save panel by default"
    set_default NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    set_default NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
    set_default NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

    #"Automatically quit printer app once the print jobs complete"
    set_default com.apple.print.PrintingPrefs "Quit When Finished" -bool true

    #"Saving to disk (not to iCloud) by default"
    set_default NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

    #"Showing icons for hard drives, servers, and removable media on the desktop"
    set_default com.apple.finder ShowExternalHardDrivesOnDesktop -bool true

    #"Avoiding the creation of .DS_Store files on network volumes"
    set_default com.apple.desktopservices DSDontWriteNetworkStores -bool true

    #"Enabling snap-to-grid for icons on the desktop and in other icon views"
    # (keys do not exist on a fresh account, so add them if Set fails)
    for view in DesktopViewSettings FK_StandardViewSettings StandardViewSettings; do
        backup_plist_value "$plist" ":$view:IconViewSettings:arrangeBy"
        /usr/libexec/PlistBuddy -c "Set :$view:IconViewSettings:arrangeBy grid" "$plist" 2>/dev/null && continue
        /usr/libexec/PlistBuddy -c "Add :$view dict" "$plist" 2>/dev/null || true
        /usr/libexec/PlistBuddy -c "Add :$view:IconViewSettings dict" "$plist" 2>/dev/null || true
        /usr/libexec/PlistBuddy -c "Add :$view:IconViewSettings:arrangeBy string grid" "$plist" 2>/dev/null || true
    done

    #"Enabling UTF-8 ONLY in Terminal.app and setting the Pro theme by default"
    set_default com.apple.terminal StringEncodings -array 4
    set_default com.apple.Terminal "Default Window Settings" -string "Pro"
    set_default com.apple.Terminal "Startup Window Settings" -string "Pro"

    #"Preventing Time Machine from prompting to use new hard drives as backup volume"
    set_default com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

    #"Disable annoying backswipe in Chrome"
    set_default com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false

    #"Setting screenshots location to ~/Desktop"
    set_default com.apple.screencapture location -string "$HOME/Desktop"

    #"Setting screenshot format to PNG"
    set_default com.apple.screencapture type -string "png"

    #"Disable 'natural' (Lion-style) scrolling"
    set_default NSGlobalDomain com.apple.swipescrolldirection -bool false

    # Don’t automatically rearrange Spaces based on most recent use
    set_default com.apple.dock mru-spaces -bool false
}

###############################################################################
# instride Dev & UX                                                           #
###############################################################################

function defaults_developer() {
    #"Disable smart quotes and smart dashes as they are annoying when typing code"
    set_default NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
    set_default NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

    #"Showing all filename extensions in Finder by default"
    set_default NSGlobalDomain AppleShowAllExtensions -bool true

    #"Disabling the warning when changing a file extension"
    set_default com.apple.finder FXEnableExtensionChangeWarning -bool false

    #"Adding a context menu item for showing the Web Inspector in web views"
    set_default NSGlobalDomain WebKitDeveloperExtras -bool true

    # Safari is sandboxed, its settings can not be written from the terminal
    MANUAL_STEPS+=('Safari: Settings → Advanced → enable "Show features for web developers"')
}
