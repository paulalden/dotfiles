#!/bin/bash

source "$CONFIG_DIR/scripts/config.sh"

POPUP_CLICK_SCRIPT='sketchybar --set $NAME popup.drawing=toggle'

sketchybar --add item homebrew right \
  --set homebrew \
  icon= \
  update_freq=300 \
  label=? \
  popup.height=30 \
  popup.background.color=$BG \
  popup.background.border_color=$MAGENTA_40 \
  popup.background.border_width=2 \
  popup.background.corner_radius=4 \
  click_script="$POPUP_CLICK_SCRIPT" \
  script="$CONFIG_DIR/plugins/homebrew.sh" \
  --subscribe homebrew mouse.clicked