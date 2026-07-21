#!/usr/bin/env bash
# MessageDisplay hook: prepend a dim [HH:MM:SS] timestamp to Claude's message
# as it renders. Runs once per streamed chunk, so it must stay cheap: a single
# jq call, local time from `date`, nothing over the network.
#
# Payload handling (defensive against two possible schemas):
#   - Streaming:      {"index": N, "delta": "<chunk>"}  -> stamp only when N == 0
#   - Whole message:  {"message_text": "<text>"}        -> stamp once
# On anything else we emit nothing, so Claude Code renders the text unchanged.
#
# Debug: set CLAUDE_TIMESTAMPS_DEBUG=1 to append raw payloads to
#   ~/.claude/timestamps-debug.log  (used to confirm the real field names).

input=$(cat)

if [ -n "${CLAUDE_TIMESTAMPS_DEBUG:-}" ]; then
  printf '%s\n' "$input" >>"${HOME}/.claude/timestamps-debug.log"
fi

stamp=$(date +%H:%M:%S)

# Build the dim-styled prefix in bash so the jq program stays free of literal
# escape bytes. $'\033' is a single ESC char; jq re-encodes it as  in its
# JSON output and Claude Code renders it back to a real escape.
esc=$'\033'
prefix="${esc}[2m[${stamp}]${esc}[0m "

printf '%s' "$input" | jq -c --arg prefix "$prefix" '
  if (.delta != null) then
    {hookSpecificOutput: {hookEventName: "MessageDisplay",
      displayContent: (if (.index // 0) == 0 then $prefix + .delta else .delta end)}}
  elif (.message_text != null) then
    {hookSpecificOutput: {hookEventName: "MessageDisplay",
      displayContent: ($prefix + .message_text)}}
  else
    empty
  end
' 2>/dev/null
