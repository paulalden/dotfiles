#!/usr/bin/env bash
# battery — battery item; plugins/battery.sh on 60s timer + power events

sketchybar --add item battery right \
  --set battery \
  update_freq=60 \
  script="$PLUGIN_DIR/battery.sh" \
  --subscribe battery system_woke power_source_change
