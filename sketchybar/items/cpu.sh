#!/bin/bash

sketchybar --add item cpu right --set cpu \
  update_freq=10 \
  script="$CONFIG_DIR/plugins/cpu.sh"
