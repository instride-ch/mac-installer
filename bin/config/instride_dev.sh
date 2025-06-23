# Settings only for instride/Developers

#"Disable smart quotes and smart dashes as they are annoying when typing code"
# ToDo: Only for instride/developers
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

#"Showing all filename extensions in Finder by default"
# ToDo: Only for instride/developers
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

#"Disabling the warning when changing a file extension"
# ToDo: Only for instride/developers
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

#"Enabling Safari's debug menu"
# ToDo: Only instride/developers?
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

#"Enabling the Develop menu and the Web Inspector in Safari"
# ToDo: Only instride/developers?
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" -bool true

#"Adding a context menu item for showing the Web Inspector in web views"
# ToDo: Only instride/developers?
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true
