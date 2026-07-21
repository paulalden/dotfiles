#!/usr/bin/env bash

# The $NAME variable is passed from sketchybar and holds the name of
# the item invoking this script:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting
#
# https://www.cyberciti.biz/faq/linux-unix-formatting-dates-for-display/

sketchybar --set "$NAME" icon="" label="$(date '+%H:%M')"
