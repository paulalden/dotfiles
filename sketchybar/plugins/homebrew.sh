#!/bin/bash

source "$CONFIG_DIR/scripts/config.sh"

CACHE_FILE="/tmp/homebrew-outdated-count"
MAX_AGE=1800 # 30 minutes

# Refresh cache in background if stale or missing
if [[ ! -f "$CACHE_FILE" ]] || [[ $(($(date +%s) - $(stat -f %m "$CACHE_FILE"))) -gt $MAX_AGE ]]; then
  ("$CONFIG_DIR/scripts/update_homebrew_cache.sh" &)
fi

# Read from cache file if it exists
if [[ -f "$CACHE_FILE" ]]; then
  COUNT=$(cat "$CACHE_FILE")
else
  COUNT=0
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

sketchybar --set $NAME icon= label="$COUNT" icon.color=$COLOR label.color=$COLOR