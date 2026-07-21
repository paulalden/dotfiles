#!/usr/bin/env bash
# brightness — shows brightness % and icon on brightness_change events

source "$CONFIG_DIR/scripts/config.sh"

# The volume_change event supplies a $INFO
# variable in which the current volume
# percentage is passed to the script.

if [ "$SENDER" = "brightness_change" ]; then
  BRIGHTNESS="$INFO"

  case "$BRIGHTNESS" in
  [7-9][0-9] | 100)
    ICON="󰃠"
    COLOR=$MAGENTA
    ;;
  [3-6][0-9])
    ICON="󰃝"
    COLOR=$MAGENTA
    ;;
  [1-9] | [1-2][0-9])
    ICON="󰃟"
    COLOR=$MAGENTA
    ;;
  *)
    ICON="󰃞"
    COLOR=$MAGENTA
    ;;
  esac

  sketchybar --set "$NAME" \
    icon="$ICON" \
    label="$BRIGHTNESS%" \
    icon.font="$FONT:Bold:27.0" \
    icon.color=$COLOR \
    label.color=$COLOR
fi
