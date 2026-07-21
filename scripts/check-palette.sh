#!/usr/bin/env bash

# Nord palette single-source-of-truth guard (run locally or in CI).
#
# Rule: no file may carry a wholesale COPY of the core palette. Using one or
# two colours as roles in a tool-specific format (fzfrc, an exported Alfred
# theme, a borders invocation) is fine — those formats can't source shell, and
# zsh configs must not source nord.conf at all (its $fg/$bg names would clobber
# zsh's colors module arrays). A file matching >= THRESHOLD distinct core
# values is a mirror and fails the build. The canonical palette and kitty's
# own terminal themes (a separate concern) are exempt, as are the alternative
# 2049/evergreen theme families.

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

THRESHOLD=4
CORE=(bf616a d08770 ebcb8b 5e81ac a3be8c 88c0d0 b48ead 74819a 464f62 2e3440 6c86a1 929cb0)

fail=0
while IFS= read -r file; do
  # Skip dangling symlinks and non-regular files (e.g. .tool-versions points
  # into $HOME, which doesn't exist on a CI runner).
  [ -f "$file" ] || continue
  count=0
  for hex in "${CORE[@]}"; do
    if grep -qi "$hex" "$file"; then
      count=$((count + 1))
    fi
  done
  if [ "$count" -ge "$THRESHOLD" ]; then
    echo "MIRROR: $file spells out $count core Nord values — consume nord.conf instead" >&2
    fail=1
  fi
done < <(git ls-files \
  ':!tmux/config/nord.conf' \
  ':!kitty/themes/' \
  ':!*2049*' \
  ':!*evergreen*' \
  ':!scripts/check-palette.sh')
# (this script is excluded: it necessarily names the values it hunts)

if [ "$fail" -ne 0 ]; then
  echo "" >&2
  echo "FAIL: palette copied outside tmux/config/nord.conf (threshold: $THRESHOLD distinct values)." >&2
  exit 1
fi

echo "palette OK: no file mirrors the core Nord palette"
