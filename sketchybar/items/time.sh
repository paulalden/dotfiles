#!/usr/bin/env bash

sketchybar --add item time right \
  --set time update_freq=10 \
  script="$CONFIG_DIR/plugins/time.sh"
