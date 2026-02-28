#!/usr/bin/env bash

# Fuzzy find and kill a process
pid=$(ps -f -u "$UID" | sed 1d | fzf -m --header 'Select process(es) to kill' | awk '{print $2}')

if [[ -n "$pid" ]]; then
  echo "$pid" | xargs kill -9
fi
