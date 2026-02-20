#!/bin/bash

source "$CONFIG_DIR/scripts/config.sh"

export PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:$PATH"
export HOMEBREW_DOWNLOAD_CONCURRENCY=8

PINNED=$(/opt/homebrew/bin/brew list --pinned --quiet 2>/dev/null)
if [ -n "$PINNED" ]; then
  COUNT=$(/opt/homebrew/bin/brew outdated --quiet 2>/dev/null | grep -vxF "$PINNED" | wc -l | tr -d ' ')
else
  COUNT=$(/opt/homebrew/bin/brew outdated --quiet 2>/dev/null | wc -l | tr -d ' ')
fi

COLOR=$RED

case "${COUNT}" in
[3-5][0-9])
  COLOR=$RED
  ;;
[1-2][0-9])
  COLOR=$ORANGE
  ;;
[1-9])
  COLOR=$YELLOW
  ;;
*)
  COLOR=$FG
  ;;
esac

sketchybar --set "$NAME" icon= label="$COUNT" icon.color="$COLOR" label.color="$COLOR"