#!/usr/bin/env bash

sketchybar --add item date right \
  --set date \
  update_freq=10 \
  script="$CONFIG_DIR/plugins/date.sh"
