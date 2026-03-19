#!/bin/bash

export FONT="Hack Nerd Font Mono"

# https://felixkratz.github.io/SketchyBar/config/tricks#color-picker
export BG_LIGHT=0xff2d1a38
export BG=0xff1e1228
export BG_80=0xcc1e1228
export BG_60=0x991e1228
export BG_40=0x661e1228
export FG=0xffc8d0e0
export BLACK=0xff020204
export RED=0xffbf616a
export ORANGE=0xffd08770
export ORANGE_WASHED=0xffdfac9c
export YELLOW=0xffebcb8b
export BLUE=0xff5568a0
export LBLUE=0xff6a80b8
export GREEN=0xffa3be8c
export CYAN=0xff6a8ab0
export MAGENTA_DARK=0xff8a3070
export MAGENTA_DARK_40=0x668a3070
export MAGENTA=0xffd65a9a
export MAGENTA_80=0xccd65a9a
export MAGENTA_60=0x99d65a9a
export MAGENTA_40=0x66d65a9a
export MAGENTA_LIGHT=0xffe06090
export PINK=0xffe06090
export GREY1=0xffd8e0f0
export GREY2=0xffc8d0e0
export GREY3=0xffb8c0d0
export GREY4=0xffa0a8c0
export GREY5=0xff9098b0
export GREY6=0xff7a80a0
export GREY7=0xff6a7090
export GREY8=0xff5a6080
export GREY9=0xff4a5070
export GREY10=0xff3d4060
export GREY11=0xff302848
export GREY12=0xff2d1a38
export GREY13=0xff251535
export GREY14=0xff160c1e
export GREY15=0xff120a18
export GREY16=0xff0e0814
export GREY17=0xff0a0610
export GREY18=0xff06040a
export GREY19=0xff020204
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
