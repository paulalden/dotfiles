#!/usr/bin/env bash
#
# Toggle "developer mode" — yabai + skhd + sketchybar + macOS cosmetic changes.
#
# Usage:
#   devmode.sh on      Start services and apply cosmetic defaults
#   devmode.sh off     Stop services and restore macOS defaults
#   devmode.sh status  Show whether services are running

set -e

if [[ "$(uname)" != "Darwin" ]]; then
  echo "devmode is macOS only."
  exit 1
fi

is_running() {
  pgrep -x "$1" &>/dev/null
}

status() {
  for svc in yabai skhd sketchybar; do
    if is_running "$svc"; then
      echo "  $svc: running"
    else
      echo "  $svc: stopped"
    fi
  done
}

start() {
  echo "==> Starting developer mode..."

  yabai --start-service
  skhd --start-service
  sketchybar --start-service

  # Cosmetic: hide Dock, fast key repeat
  defaults write NSGlobalDomain KeyRepeat -int 2
  defaults write NSGlobalDomain InitialKeyRepeat -int 15
  defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
  defaults write com.apple.dock autohide -bool true
  defaults write com.apple.dock autohide-delay -float 0
  defaults write com.apple.dock autohide-time-modifier -float 0.4
  defaults write com.apple.dock mru-spaces -bool false
  defaults write com.apple.finder AppleShowAllFiles -bool true
  defaults write com.apple.finder ShowPathbar -bool true
  defaults write com.apple.finder ShowStatusBar -bool true
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
  defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
  defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
  killall Dock Finder &>/dev/null || true

  echo "Developer mode ON."
  status
}

stop() {
  echo "==> Stopping developer mode..."

  yabai --stop-service
  skhd --stop-service
  sketchybar --stop-service

  # Restore macOS defaults
  defaults delete NSGlobalDomain KeyRepeat 2>/dev/null || true
  defaults delete NSGlobalDomain InitialKeyRepeat 2>/dev/null || true
  defaults delete NSGlobalDomain ApplePressAndHoldEnabled 2>/dev/null || true
  defaults delete com.apple.dock autohide 2>/dev/null || true
  defaults delete com.apple.dock autohide-delay 2>/dev/null || true
  defaults delete com.apple.dock autohide-time-modifier 2>/dev/null || true
  defaults delete com.apple.dock mru-spaces 2>/dev/null || true
  defaults delete NSGlobalDomain AppleShowAllExtensions 2>/dev/null || true
  defaults delete NSGlobalDomain NSAutomaticSpellingCorrectionEnabled 2>/dev/null || true
  defaults delete NSGlobalDomain NSAutomaticWindowAnimationsEnabled 2>/dev/null || true
  killall Dock Finder &>/dev/null || true

  echo "Developer mode OFF."
  status
}

case "${1:-}" in
  on)     start ;;
  off)    stop ;;
  status) status ;;
  *)
    echo "Usage: devmode.sh {on|off|status}"
    exit 1
    ;;
esac
