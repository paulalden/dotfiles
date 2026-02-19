#!/bin/bash

sketchybar --add item homebrew right \
  --set homebrew \
  icon= \
  update_freq=60 \
  label=? \
  script="$CONFIG_DIR/plugins/homebrew.sh"

sketchybar --subscribe homebrew brew_update
