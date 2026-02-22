#!/bin/bash

source "$CONFIG_DIR/scripts/config.sh"

export PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:$PATH"
export HOMEBREW_DOWNLOAD_CONCURRENCY=8

PINNED=$(/opt/homebrew/bin/brew list --pinned --quiet 2>/dev/null)
if [ -n "$PINNED" ]; then
  OUTDATED=$(/opt/homebrew/bin/brew outdated --quiet 2>/dev/null | grep -vxF "$PINNED")
else
  OUTDATED=$(/opt/homebrew/bin/brew outdated --quiet 2>/dev/null)
fi

COUNT=$(echo "$OUTDATED" | grep -c .)

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

# Remove old popup items
sketchybar --remove '/homebrew.pkg\..*/' 2>/dev/null

# Add popup items for each outdated package
if [ "$COUNT" -gt 0 ]; then
  INDEX=0
  while IFS= read -r pkg; do
    if [ -n "$pkg" ]; then
      sketchybar --add item "homebrew.pkg.$INDEX" popup.homebrew \
        --set "homebrew.pkg.$INDEX" \
        icon= \
        icon.color=$YELLOW \
        icon.font="$FONT:Bold:14.0" \
        icon.padding_left=10 \
        label="$pkg" \
        label.font="$FONT:Regular:13.0" \
        label.color=$FG \
        label.padding_right=10
      INDEX=$((INDEX + 1))
    fi
  done <<< "$OUTDATED"
fi