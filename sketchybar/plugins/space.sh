#!/bin/sh

source "$CONFIG_DIR/scripts/config.sh"

pgrep -x yabai > /dev/null || exit 0

SID=$(echo "$NAME" | cut -d'.' -f2)
FOCUSED_SPACE=$(yabai -m query --spaces --space 2>/dev/null | jq -r '.index')

if [ "$SID" = "$FOCUSED_SPACE" ]; then
  sketchybar --set "$NAME" \
    background.drawing=on \
    background.color=$FG \
    label.drawing=off \
    icon.color=$BG
else
  sketchybar --set "$NAME" \
    background.drawing=on \
    background.color=$GREY16 \
    label.drawing=off \
    icon.color=$FG
fi
