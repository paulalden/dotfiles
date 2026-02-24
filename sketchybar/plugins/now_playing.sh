#!/bin/bash

source "$CONFIG_DIR/scripts/config.sh"

TITLE=""
ARTIST=""
STATE=""

# Try nowplaying-cli first (works with any media source)
TITLE=$(nowplaying-cli get title 2>/dev/null)
if [ -n "$TITLE" ] && [ "$TITLE" != "null" ]; then
  ARTIST=$(nowplaying-cli get artist 2>/dev/null)
  STATE=$(nowplaying-cli get playbackRate 2>/dev/null)
  [ "$ARTIST" = "null" ] && ARTIST=""
  [ "$STATE" != "0" ] && STATE="playing" || STATE="paused"
fi

if [ -z "$TITLE" ] || [ "$TITLE" = "null" ]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

if [ "$STATE" = "playing" ]; then
  ICON="󰐊"
else
  ICON="󰏤"
fi

LABEL="$TITLE"
if [ -n "$ARTIST" ]; then
  LABEL="$ARTIST — $TITLE"
fi

sketchybar --set "$NAME" \
  drawing=on \
  icon="$ICON" \
  icon.color="$FG" \
  label="$LABEL"
