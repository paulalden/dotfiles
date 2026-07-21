#!/usr/bin/env bash

# Config reload for the prefix-r binding. Shows a full-width magenta flash
# FIRST, then re-sources the config — so the status bar's reflow (status-justify
# and the window/clock formats being re-applied) happens hidden behind the
# message. The flash right-pads to the client width so message-style (magenta
# bg) paints the whole bar, text sitting left.

msg="${1:- tmux.conf sourced }"
w=$(tmux display -p '#{client_width}')
tmux display-message -d 1900 "$(printf '%-*s' "$w" "$msg")"
tmux source-file ~/.config/tmux/tmux.conf
