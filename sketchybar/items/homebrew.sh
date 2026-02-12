#!/bin/bash

sketchybar --add event brew_update \
  --add item homebrew right \
  --set homebrew \
  icon= \
  update_freq=300 \
  label=? \
  script="$CONFIG_DIR/plugins/homebrew.sh"

sketchybar --subscribe homebrew brew_update