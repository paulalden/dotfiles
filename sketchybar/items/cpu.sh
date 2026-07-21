#!/usr/bin/env bash
# cpu — CPU usage item; driven by plugins/cpu.sh on a 5s timer

sketchybar --add item cpu right --set cpu \
  update_freq=5 \
  script="$CONFIG_DIR/plugins/cpu.sh"