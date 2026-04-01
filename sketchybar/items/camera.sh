#!/bin/bash

sketchybar --add item camera right \
  --set camera \
  update_freq=3 \
  script="$PLUGIN_DIR/camera.sh" \
  drawing=off
