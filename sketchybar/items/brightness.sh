#!/usr/bin/env bash

sketchybar --add item brightness right \
  --set brightness \
  script="$CONFIG_DIR/plugins/brightness.sh" \
  --subscribe brightness brightness_change
