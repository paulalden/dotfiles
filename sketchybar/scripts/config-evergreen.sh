#!/bin/bash

export FONT="Hack Nerd Font Mono"

# https://felixkratz.github.io/SketchyBar/config/tricks#color-picker
export BG_LIGHT=0xff3a5459
export BG=0xff314a51
export BG_80=0xcc314a51
export BG_60=0x99314a51
export BG_40=0x66314a51
export FG=0xffb7c3b7
export BLACK=0xff0a1215
export RED=0xffbf616a
export ORANGE=0xffd08770
export ORANGE_WASHED=0xffdfac9c
export YELLOW=0xffebcb8b
export BLUE=0xff8fbcbb
export LBLUE=0xff8fbcbb
export GREEN=0xffa3be8c
export CYAN=0xff88c0d0
export MAGENTA_DARK=0xff5c7072
export MAGENTA_DARK_40=0x665c7072
export MAGENTA=0xff8fbcbb
export MAGENTA_80=0xcc8fbcbb
export MAGENTA_60=0x998fbcbb
export MAGENTA_40=0x668fbcbb
export MAGENTA_LIGHT=0xffb7c3b7
export PINK=0xfff8cf6e
export GREY1=0xffdbe1d5
export GREY2=0xffd8e0d5
export GREY3=0xffc7d5c9
export GREY4=0xffb7c3b7
export GREY5=0xffb7c3b7
export GREY6=0xff80918f
export GREY7=0xff80918f
export GREY8=0xff5c7072
export GREY9=0xff566b6e
export GREY10=0xff566b6e
export GREY11=0xff3a5459
export GREY12=0xff3a5459
export GREY13=0xff314a51
export GREY14=0xff243539
export GREY15=0xff1e2e33
export GREY16=0xff1a282d
export GREY17=0xff142025
export GREY18=0xff101a1e
export GREY19=0xff0a1215
export TRANSPARENT=0x00000000

# Usage: color_for_value VALUE THRESHOLD1 COLOR1 THRESHOLD2 COLOR2 ... DEFAULT_COLOR
# Thresholds must be in descending order. Returns first COLOR where VALUE >= THRESHOLD.
color_for_value() {
  local value=$1; shift
  while [ $# -gt 1 ]; do
    local threshold=$1 color=$2; shift 2
    if [ "$value" -ge "$threshold" ]; then
      echo "$color"; return
    fi
  done
  echo "$1"
}
