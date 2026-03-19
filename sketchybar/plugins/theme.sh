#!/bin/sh

THEME_FILE="$HOME/.config/theme"
CURRENT=$(cat "$THEME_FILE" 2>/dev/null || echo "nord")

if [ "$CURRENT" = "2049" ]; then
  ICON="󰌵"
else
  ICON="󰌶"
fi

sketchybar --set theme icon="$ICON"
