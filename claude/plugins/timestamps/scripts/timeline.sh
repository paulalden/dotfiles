#!/usr/bin/env bash
# Print a timestamped timeline of the current Claude Code session.
#
# Reads the newest transcript JSONL for the current working directory's project
# and formats each typed user message and each Claude text message with its
# local-time timestamp. Pure jq; nothing leaves this machine.
#
# Usage: timeline.sh [count]   (default: last 40 entries)

set -euo pipefail

count="${1:-40}"
case "$count" in
  '' | *[!0-9]*) count=40 ;;
esac

# Claude Code stores transcripts under ~/.claude/projects/<mangled-cwd>/, where
# the cwd has every non-alphanumeric character replaced with '-'.
slug=$(printf '%s' "$PWD" | sed 's/[^A-Za-z0-9]/-/g')
proj="${HOME}/.claude/projects/${slug}"

transcript=$(ls -t "${proj}"/*.jsonl 2>/dev/null | head -n 1 || true)
if [ -z "$transcript" ]; then
  echo "No transcript found for $PWD (looked in ${proj})." >&2
  exit 0
fi

jq -r '
  select(.type == "user" or .type == "assistant")
  | select(.timestamp != null)
  | (.timestamp
      | sub("\\.[0-9]+Z$"; "Z")
      | fromdateiso8601
      | localtime
      | strftime("%H:%M:%S")) as $t
  | if .type == "user" then
      (if (.message.content | type) == "string"
        then "\($t)  you     \((.message.content | gsub("\n"; " "))[0:100])"
        else empty end)
    else
      (.message.content[]?
        | select(.type == "text" and (.text | length) > 0)
        | "\($t)  claude  \((.text | gsub("\n"; " "))[0:100])")
    end
' "$transcript" | tail -n "$count"
