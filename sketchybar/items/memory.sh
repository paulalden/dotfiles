#!/bin/bash

sketchybar --add item memory right --set memory \
  update_freq=5 \
  script="$CONFIG_DIR/plugins/memory.sh"
