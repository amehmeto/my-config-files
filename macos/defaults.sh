#!/usr/bin/env bash
# macOS preferences — run once after a fresh install
# Some changes require a logout/restart to take effect.

set -euo pipefail

echo "Applying macOS preferences..."

# ---------------------------------------------------------------------------
# Keyboard
# ---------------------------------------------------------------------------
# Fast key repeat rate
defaults write NSGlobalDomain KeyRepeat -int 2
# Short delay until key repeat
defaults write NSGlobalDomain InitialKeyRepeat -int 15
# Enable press-and-hold for accented characters (set false for key repeat)
defaults write -g ApplePressAndHoldEnabled -bool true

# ---------------------------------------------------------------------------
# Dock
# ---------------------------------------------------------------------------
# Auto-hide the Dock
defaults write com.apple.dock autohide -bool true
# Remove the auto-hide delay
defaults write com.apple.dock autohide-delay -float 0
# Speed up the animation when hiding/showing the Dock
defaults write com.apple.dock autohide-time-modifier -float 0.3
# Minimize windows using scale effect
defaults write com.apple.dock mineffect -string "scale"

# ---------------------------------------------------------------------------
# Finder
# ---------------------------------------------------------------------------
# Show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# Show hidden files by default
defaults write com.apple.finder AppleShowAllFiles -bool true
# Show path bar at the bottom
defaults write com.apple.finder ShowPathbar -bool true
# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true
# Default to list view in Finder
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# ---------------------------------------------------------------------------
# Screenshots
# ---------------------------------------------------------------------------
# Save screenshots to ~/Desktop
defaults write com.apple.screencapture location -string "$HOME/Desktop"
# Save screenshots as PNG
defaults write com.apple.screencapture type -string "png"

# ---------------------------------------------------------------------------
# Apply changes
# ---------------------------------------------------------------------------
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true

echo "Done. Some changes may require a logout/restart."
