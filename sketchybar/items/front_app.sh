#!/usr/bin/env bash
# front_app — focused-app item; plugins/front_app.sh on front_app_switched

source "$CONFIG_DIR/scripts/config.sh"

# https://www.josean.com/posts/sketchybar-setup
sketchybar --add item front_app left \
  --set front_app background.color=$TRANSPARENT \
  icon.color=$FG \
  icon.font="sketchybar-app-font:Regular:15.0" \
  label.color=$FG \
  label.font="$FONT:Bold:12.0" \
  script="$PLUGIN_DIR/front_app.sh" \
  --subscribe front_app front_app_switched
