---
description: Show a timestamped timeline of the current Claude Code session
argument-hint: "[count]"
allowed-tools: Bash
---

Run exactly this command with the Bash tool, then show its raw stdout inside one
fenced code block with no commentary before or after:

    bash "${CLAUDE_PLUGIN_ROOT}/scripts/timeline.sh" $ARGUMENTS

If the command prints nothing, say that no session transcript was found.
