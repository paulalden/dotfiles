#!/usr/bin/env bash
# time — clock item; driven by plugins/time.sh on a 10s timer

sketchybar --add item time right \
  --set time update_freq=10 \
  script="$CONFIG_DIR/plugins/time.sh"
