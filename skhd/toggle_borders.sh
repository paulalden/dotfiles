#!/bin/bash

current_state=$(borders -q 2>/dev/null)
if [ "$current_state" == "on" ]; then
  borders active_color=0x00000000 inactive_color=0x00000000 width=0.0 2>/dev/null
else
  borders active_color=0xffcbb1c7 inactive_color=0xff2e3440 width=5.0 2>/dev/null
fi
