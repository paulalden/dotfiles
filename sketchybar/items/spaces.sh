#!/bin/sh

SPACE_COUNT=$(yabai -m query --spaces 2>/dev/null | python3 -c "import sys,json; print(len(json.load(sys.stdin)))")

for sid in $(seq 1 "${SPACE_COUNT:-9}")
do
  space=(
    space="$sid"
    icon="$sid"
    icon.padding_left=10
    icon.padding_right=5
    icon.align=center
    label.font="sketchybar-app-font:Regular:14.0"
    label.padding_left=2
    label.padding_right=0
    label.align=center
    label.color="$GREEN"
    label.y_offset=-1
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
  sketchybar --subscribe space."$sid" mouse.clicked space_windows_change front_app_switched
done
