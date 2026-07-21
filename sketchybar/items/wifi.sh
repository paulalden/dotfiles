#!/usr/bin/env bash

wifi=(
  padding_right=7
  label.width=0
  icon="󰖪"
  script="$CONFIG_DIR/plugins/wifi.sh"
)

sketchybar --add item wifi right \
  --set wifi "${wifi[@]}" \
  --subscribe wifi wifi_change mouse.clicked
