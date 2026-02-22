#!/bin/sh

source "$CONFIG_DIR/scripts/config.sh"

# The volume_change event supplies a $INFO
# variable in which the current volume
# percentage is passed to the script.

if [ "$SENDER" = "volume_change" ]; then
  VOLUME="$INFO"

  COLOR=$(color_for_value "$VOLUME" 70 $RED 20 $ORANGE 1 $GREEN 0 $FG)

  case "$VOLUME" in
  [7-9][0-9] | 100)    ICON="󰕾" ;;
  [2-6][0-9])          ICON="󰖀" ;;
  [1-9] | [1-1][0-9])  ICON="󰕿" ;;
  *)                    ICON="󰝟" ;;
  esac

  sketchybar --set "$NAME" \
    icon="$ICON" \
    label="$VOLUME%" \
    icon.font="$FONT:Bold:19.0" \
    icon.color=$COLOR \
    label.color=$COLOR
fi
