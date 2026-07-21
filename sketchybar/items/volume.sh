#!/usr/bin/env bash

sketchybar --add item volume right \
  --set volume \
  script="$CONFIG_DIR/plugins/volume.sh" \
  --subscribe volume volume_change
