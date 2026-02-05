#!/bin/bash

# Updates the homebrew outdated count cache
# Run this via cron or after brew upgrade

CACHE_FILE="/tmp/homebrew-outdated-count"

/opt/homebrew/bin/brew outdated --quiet | wc -l | tr -d ' ' > "$CACHE_FILE"

# Trigger sketchybar update
sketchybar --trigger brew_update 2>/dev/null
