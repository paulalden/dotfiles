#!/usr/bin/env bash

# SketchyBar Nord colours. The base palette is NOT duplicated here: it is
# sourced from the single source of truth — tmux/config/nord.conf — and
# reformatted to SketchyBar's 0xAARRGGBB. Only SketchyBar-specific roles,
# opacity variants and derived shades are defined locally, so the shared
# palette can never drift out of sync.

# shellcheck source=/dev/null
source "$HOME/.config/tmux/config/nord.conf"   # gives $bg, $red, $grey9, … as "#rrggbb"

export FONT="Hack Nerd Font Mono"

# Backgrounds (base + opacity variants derived from $bg)
export BG_LIGHT=0xff353b49            # sketchybar-only shade
export BG="0xff${bg#\#}"
export BG_80="0xcc${bg#\#}"
export BG_60="0x99${bg#\#}"
export BG_40="0x66${bg#\#}"

export BLACK=0xff000000
export FG=0xff999797                  # sketchybar text — a role colour, not palette fg
# export FG=0xff616d85

export RED="0xff${red#\#}"
export ORANGE="0xff${orange#\#}"
export ORANGE_WASHED=0xffdfac9c       # sketchybar-only shade
export YELLOW="0xff${yellow#\#}"
export BLUE="0xff${blue#\#}"
export LBLUE="0xff${lblue#\#}"
export GREEN="0xff${green#\#}"
export CYAN="0xff${cyan#\#}"

export MAGENTA_DARK=0xff9d6b93        # sketchybar-only shades
export MAGENTA_DARK_40=0x669d6b93
export MAGENTA="0xff${magenta#\#}"
export MAGENTA_80="0xcc${magenta#\#}"
export MAGENTA_60="0x99${magenta#\#}"
export MAGENTA_40="0x66${magenta#\#}"
export MAGENTA_LIGHT=0xffcbb1c7
export PINK="0xff${pink#\#}"

export GREY1="0xff${grey1#\#}"
export GREY2="0xff${grey2#\#}"
export GREY3="0xff${grey3#\#}"
export GREY4="0xff${grey4#\#}"
export GREY5="0xff${grey5#\#}"
export GREY6="0xff${grey6#\#}"
export GREY7="0xff${grey7#\#}"
export GREY8="0xff${grey8#\#}"
export GREY9="0xff${grey9#\#}"
export GREY10="0xff${grey10#\#}"
export GREY11="0xff${grey11#\#}"
export GREY12="0xff${grey12#\#}"
export GREY13="0xff${grey13#\#}"
export GREY14="0xff${grey14#\#}"
export GREY15="0xff${grey15#\#}"
export GREY16="0xff${grey16#\#}"
export GREY17="0xff${grey17#\#}"
export GREY18="0xff${grey18#\#}"
export GREY19="0xff${grey19#\#}"
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
