#!/usr/bin/env bash
# camera — camera-in-use item; camera.sh polls every 3s, hidden by default

sketchybar --add item camera right \
  --set camera \
  update_freq=3 \
  script="$PLUGIN_DIR/camera.sh" \
  drawing=off
