#!/usr/bin/env bash
# date — date item; driven by plugins/date.sh on a 10s timer

sketchybar --add item date right \
  --set date \
  update_freq=10 \
  script="$CONFIG_DIR/plugins/date.sh"
