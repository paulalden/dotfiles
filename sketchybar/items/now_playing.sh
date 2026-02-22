#!/bin/bash

source "$CONFIG_DIR/scripts/config.sh"

sketchybar --add item now_playing center \
  --set now_playing \
  icon="󰎈" \
  icon.color=$FG \
  icon.font="$FONT:Bold:14.0" \
  label.color=$FG \
  label.font="$FONT:Bold:14.0" \
  label.max_chars=40 \
  update_freq=3 \
  script="$PLUGIN_DIR/now_playing.sh" \
  --subscribe now_playing media_change
