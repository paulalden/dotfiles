#!/usr/bin/env bash

# Renumber every session's windows so indexes have no gaps.
#
# `renumber-windows on` only compacts indexes when a window is *closed*. A
# tmux-resurrect restore recreates windows at their saved indexes instead, so
# gaps survive across restarts. This is wired to resurrect's post-restore-all
# hook (see options.conf) to compact each session after a restore. Safe to run
# by hand any time to tidy the current windows.

tmux list-sessions -F '#{session_name}' 2>/dev/null | while IFS= read -r session; do
  tmux move-window -r -t "${session}:"
done
