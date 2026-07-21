#!/usr/bin/env bash
# battery — shows battery % and charge icon; runs on 60s timer and power events

source "$CONFIG_DIR/scripts/config.sh"

PERCENTAGE="$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)"
CHARGING="$(pmset -g batt | grep 'AC Power')"

if [ "$PERCENTAGE" = "" ]; then
  exit 0
fi

FONT_SIZE=15

COLOR=$(color_for_value "$PERCENTAGE" 80 $GREEN 60 $YELLOW 30 $ORANGE 0 $RED)

if [[ "$CHARGING" != "" ]]; then
  case "${PERCENTAGE}" in
  9[0-9] | 100) ICON="󱊦" ;;
  [6-8][0-9])   ICON="󱊥" ;;
  [3-5][0-9])   ICON="󱊥" ;;
  [1-2][0-9])   ICON="󱊤" ;;
  *)            ICON="󰢟" ;;
  esac
  FONT_SIZE=23
else
  case "${PERCENTAGE}" in
  [8-9][0-9] | 100) ICON="󱊣" ;;
  [6-7][0-9])       ICON="󱊢" ;;
  [3-5][0-9])       ICON="󱊢" ;;
  [1-2][0-9])       ICON="󱊡" ;;
  *)                ICON="󰂎" ;;
  esac
fi

# The item invoking this script (name $NAME) will get its icon and label
# updated with the current battery status
sketchybar --set "$NAME" \
  icon="$ICON" \
  label="${PERCENTAGE}%" \
  icon.font="Hack Nerd Font Mono:Bold:$FONT_SIZE.0" \
  icon.color=$COLOR \
  label.color=$COLOR
