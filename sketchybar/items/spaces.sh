#!/usr/bin/env bash
# spaces — numbered space indicator items; space.sh plugin on space/app events

SPACE_COUNT=$(yabai -m query --spaces 2>/dev/null | jq 'length')

for sid in $(seq 1 "${SPACE_COUNT:-9}")
do
  space=(
    space="$sid"
    icon="$sid"
    icon.padding_left=14
    icon.padding_right=14
    icon.align=center
    label.drawing=off
    background.color="$TRANSPARENT"
    background.padding_left=0
    background.padding_right=5
    background.corner_radius=3
    background.height=22
    icon.font="$FONT:Bold:14.0"
    script="$PLUGIN_DIR/space.sh"
    click_script="yabai -m space --focus $sid"
  )
  sketchybar --add space space."$sid" left --set space."$sid" "${space[@]}" ignore_association=on
  sketchybar --subscribe space."$sid" mouse.clicked space_change space_windows_change front_app_switched
done