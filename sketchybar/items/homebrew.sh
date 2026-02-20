#!/bin/bash

sketchybar --add item homebrew right \
  --set homebrew \
  icon= \
  update_freq=300 \
  label=? \
  script="$CONFIG_DIR/plugins/homebrew.sh"