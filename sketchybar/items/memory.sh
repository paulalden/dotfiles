#!/usr/bin/env bash
# memory — memory usage item; driven by plugins/memory.sh on a 10s timer

sketchybar --add item memory right --set memory \
  update_freq=10 \
  script="$CONFIG_DIR/plugins/memory.sh"
