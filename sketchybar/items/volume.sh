#!/usr/bin/env bash
# volume — volume item; plugins/volume.sh reacts to volume_change events

sketchybar --add item volume right \
  --set volume \
  script="$CONFIG_DIR/plugins/volume.sh" \
  --subscribe volume volume_change
