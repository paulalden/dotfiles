#!/bin/bash

source "$CONFIG_DIR/scripts/config.sh"

POPUP_OFF='sketchybar --set theme popup.drawing=off'
POPUP_CLICK_SCRIPT='sketchybar --set $NAME popup.drawing=toggle'

theme_icon=(
  icon="󰌶"
  icon.font="$FONT:Bold:18.0"
  icon.color=$FG
  label.drawing=off
  popup.height=35
  popup.background.color=$BG
  popup.background.border_color=$MAGENTA_40
  popup.background.border_width=2
  popup.background.corner_radius=4
  popup.align=right
  click_script="$POPUP_CLICK_SCRIPT"
)

theme_nord=(
  icon="󰌶"
  label="Nord"
  click_script="$CONFIG_DIR/scripts/theme_switcher.sh nord; $POPUP_OFF"
)

theme_2049=(
  icon="󰌵"
  label="2049"
  click_script="$CONFIG_DIR/scripts/theme_switcher.sh 2049; $POPUP_OFF"
)

theme_evergreen=(
  icon="󰌵"
  label="Evergreen"
  click_script="$CONFIG_DIR/scripts/theme_switcher.sh evergreen; $POPUP_OFF"
)

sketchybar --add item theme right \
  --set theme "${theme_icon[@]}" \
  \
  --add item theme.nord popup.theme \
  --set theme.nord "${theme_nord[@]}" \
  \
  --add item theme.2049 popup.theme \
  --set theme.2049 "${theme_2049[@]}" \
  \
  --add item theme.evergreen popup.theme \
  --set theme.evergreen "${theme_evergreen[@]}"
