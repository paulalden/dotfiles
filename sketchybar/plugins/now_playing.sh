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

# Fall back to Spotify AppleScript if nowplaying-cli returned nothing
if [ -z "$TITLE" ] || [ "$TITLE" = "null" ]; then
  if pgrep -x Spotify > /dev/null; then
    STATE=$(osascript -e 'tell application "Spotify" to player state as string' 2>/dev/null)
    TITLE=$(osascript -e 'tell application "Spotify" to name of current track as string' 2>/dev/null)
    ARTIST=$(osascript -e 'tell application "Spotify" to artist of current track as string' 2>/dev/null)
  fi
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
