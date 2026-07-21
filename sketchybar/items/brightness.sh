#!/usr/bin/env bash
# brightness — brightness item; plugins/brightness.sh on brightness_change

sketchybar --add item brightness right \
  --set brightness \
  script="$CONFIG_DIR/plugins/brightness.sh" \
  --subscribe brightness brightness_change
