#!/usr/bin/env zsh

# Disable startup sound.
sudo nvram StartupMute=%01

# Play feedback when volume is changed.
defaults write -g "com.apple.sound.beep.feedback" -int 1

###########
## Mouse ##
###########

# Adjust the tracking speed.
defaults write -g com.apple.mouse.scaling -float "1"

# Enable secondary click on the right side.
defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseButtonMode TwoButton
defaults write com.apple.AppleMultitouchMouse.plist MouseButtonMode TwoButton 

# Enable smart zoom.
defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseOneFingerDoubleTapGesture -int 1
defaults write com.apple.AppleMultitouchMouse MouseOneFingerDoubleTapGesture -int 1

##########
## Dock ##
##########

# Downsize the Dock.
defaults write com.apple.dock tilesize -int 48

# Remove all applications from the Dock.
defaults write com.apple.dock persistent-apps -array
defaults write com.apple.dock persistent-others -array

# Automatically hide the Dock.
defaults write com.apple.dock autohide -int 1

# Restart the Dock for the changes above to take effect.
killall Dock
