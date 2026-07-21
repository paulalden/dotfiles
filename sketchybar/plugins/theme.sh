#!/usr/bin/env bash
# theme — updates the theme item icon to match the current theme file

THEME_FILE="$HOME/.config/theme"
CURRENT=$(cat "$THEME_FILE" 2>/dev/null || echo "nord")

if [ "$CURRENT" = "2049" ]; then
  ICON="󰌵"
else
  ICON="󰌶"
fi

sketchybar --set theme icon="$ICON"
