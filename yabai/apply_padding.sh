#!/usr/bin/env bash

# Set per-display top padding. Both builtin panels share one UUID, so the
# hostname picks the builtin value; externals get the sketchybar height.
# Called from yabairc at startup and from the display_added/display_removed/
# space_created signals — one copy of the logic instead of three.
#
# yabai has no --display selector for `config`, only --space, so this walks
# each display's spaces and sets the padding on every one of them.
#
# This is the only place top padding is set — yabairc leaves it out because
# per-space values would override it anyway.
#
# Check UUID with: yabai -m query --displays | python3 -m json.tool
# Check hostname with: scutil --get LocalHostName

BUILTIN_UUID="37D8832A-2D66-02CA-B9F7-8F30A301B230"

HOSTNAME_16INCH="Pauls-Examtrack-MacBook-Pro"   # MacBook Pro 16" (notch)
HOSTNAME_13INCH="PaulM1"                        # MacBook Pro 13" (no notch)

EXTERNAL_TOP_PADDING=52 # sketchybar height (32) + gap (20)
TOP_PADDING_16INCH=20   # MacBook Pro 16" — menubar/notch already excluded
TOP_PADDING_13INCH=52   # MacBook Pro 13" — menubar auto-hidden, so clear sketchybar

case "$(scutil --get LocalHostName)" in
  "$HOSTNAME_16INCH") BUILTIN_TOP_PADDING=$TOP_PADDING_16INCH ;;
  "$HOSTNAME_13INCH") BUILTIN_TOP_PADDING=$TOP_PADDING_13INCH ;;
  *) BUILTIN_TOP_PADDING=$EXTERNAL_TOP_PADDING ;;
esac

yabai -m query --displays 2>/dev/null \
  | jq -r '.[] | .uuid as $uuid | .spaces[] | [$uuid, .] | @tsv' \
  | while IFS=$(printf '\t') read -r uuid space; do
    [ "$uuid" = "$BUILTIN_UUID" ] && top=$BUILTIN_TOP_PADDING || top=$EXTERNAL_TOP_PADDING
    yabai -m config --space "$space" top_padding "$top"
  done
