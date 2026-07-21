#!/usr/bin/env bash

# Set per-display top padding. Both builtin panels share one UUID, so the
# hostname picks the builtin value; externals get the sketchybar height.
# Called from yabairc at startup and from the display_added/display_removed
# signals — one copy of the logic instead of three.
#
# Check UUID with: yabai -m query --displays | python3 -m json.tool
# Check hostname with: scutil --get LocalHostName

BUILTIN_UUID="37D8832A-2D66-02CA-B9F7-8F30A301B230"

HOSTNAME_16INCH="Pauls-Examtrack-MacBook-Pro"   # MacBook Pro 16" (notch)
HOSTNAME_13INCH="PaulM1"                        # MacBook Pro 13" (no notch)

EXTERNAL_TOP_PADDING=52 # external monitor
TOP_PADDING_16INCH=20   # MacBook Pro 16" (notch)
TOP_PADDING_13INCH=50   # MacBook Pro 13"

case "$(scutil --get LocalHostName)" in
  "$HOSTNAME_16INCH") BUILTIN_TOP_PADDING=$TOP_PADDING_16INCH ;;
  "$HOSTNAME_13INCH") BUILTIN_TOP_PADDING=$TOP_PADDING_13INCH ;;
  *) BUILTIN_TOP_PADDING=$EXTERNAL_TOP_PADDING ;;
esac

yabai -m query --displays 2>/dev/null | jq -r '.[] | [.index, .uuid] | @tsv' \
  | while IFS=$(printf '\t') read -r index uuid; do
    [ "$uuid" = "$BUILTIN_UUID" ] && top=$BUILTIN_TOP_PADDING || top=$EXTERNAL_TOP_PADDING
    yabai -m config --display "$index" top_padding "$top"
  done
