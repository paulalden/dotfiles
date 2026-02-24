#!/bin/bash

source "$CONFIG_DIR/scripts/config.sh"

POPUP_OFF='sketchybar --set apple.logo popup.drawing=off'
POPUP_CLICK_SCRIPT='sketchybar --set $NAME popup.drawing=toggle'

APPLE=""
PREFERENCES=""
LOCK=""
ACTIVITY="󱎴"

apple_logo=(
  icon=$APPLE
  icon.font="$FONT:Bold:22.0"
  icon.color=$FG
  padding_right=15
  label.drawing=off
  popup.height=35
  border_color=$BG
  popup.background.color=$BG
  popup.background.border_color=$MAGENTA_40
  popup.background.border_width=2
  popup.background.corner_radius=4
  popup.background.y_offset=0
  click_script="$POPUP_CLICK_SCRIPT"
)

apple_prefs=(
  icon=$PREFERENCES
  label="Settings"
  click_script="open -a 'System Settings'; $POPUP_OFF"
)

apple_activity=(
  icon=$ACTIVITY
  label="Activity"
  click_script="open -a 'Activity Monitor'; $POPUP_OFF"
)

apple_lock=(
  icon=$LOCK
  label="Lock Screen"
  click_script="pmset displaysleepnow; $POPUP_OFF"
)

sketchybar --add item apple.logo left \
  --set apple.logo "${apple_logo[@]}" \
  \
  --add item apple.prefs popup.apple.logo \
  --set apple.prefs "${apple_prefs[@]}" \
  \
  --add item apple.activity popup.apple.logo \
  --set apple.activity "${apple_activity[@]}" \
  \
  --add item apple.lock popup.apple.logo \
  --set apple.lock "${apple_lock[@]}"