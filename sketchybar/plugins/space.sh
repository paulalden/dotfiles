#!/bin/sh

source "$CONFIG_DIR/scripts/config.sh"
source "$CONFIG_DIR/scripts/icon_map_fn.sh"

pgrep -x yabai > /dev/null || exit 0

# Extract space index from item name (space.1 -> 1)
SID=$(echo "$NAME" | cut -d'.' -f2)

# Query yabai for windows in this space and build app icon string
APPS=$(yabai -m query --windows --space "$SID" 2>/dev/null | python3 -c "
import sys, json
try:
    windows = json.load(sys.stdin)
    seen = set()
    apps = []
    for w in windows:
        app = w.get('app', '')
        if app and app not in seen and not w.get('is-minimized', False):
            seen.add(app)
            apps.append(app)
    print('\n'.join(apps))
except:
    pass
")

ICON_STRIP=""
while IFS= read -r app; do
  if [ -n "$app" ]; then
    icon_map "$app"
    ICON_STRIP+="${icon_result} "
  fi
done <<< "$APPS"

# Trim trailing space
ICON_STRIP=$(echo "$ICON_STRIP" | sed 's/ $//')

COLOR=$MAGENTA_DARK

if [ -n "$ICON_STRIP" ]; then
  LABEL_PADDING=10
else
  LABEL_PADDING=5
fi

if [ "$SELECTED" = true ]; then
  sketchybar --set "$NAME" \
    background.drawing=on \
    background.color=$COLOR \
    label="$ICON_STRIP" \
    label.padding_right=$LABEL_PADDING \
    label.color=$BG \
    icon.color=$BG
else
  sketchybar --set "$NAME" \
    background.drawing=on \
    background.color=$GREY16 \
    label="$ICON_STRIP" \
    label.padding_right=$LABEL_PADDING \
    label.color=$MAGENTA_DARK \
    icon.color=$MAGENTA_DARK
fi
