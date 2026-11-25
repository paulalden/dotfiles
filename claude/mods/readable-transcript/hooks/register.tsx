import type { Register } from 'claude-code'

// Nord, from dotfiles tmux/config/nord.conf. Claude Code draws in 256-colour
// mode under tmux, where a hex colour becomes its nearest palette entry, so
// each is a palette slot that kitty/kitty.conf sets to the exact colour.
const PROSE = 'ansi256(19)' // #c895bf, Kitty's bright magenta (color13)
const PROMPT = 'ansi256(20)' // #88c0d0, cyan
const TOOL = 'ansi256(21)' // #616d85, grey10
// Red stays hex, drawn as its nearest palette entry. Not slot 22: Claude Code
// draws the background of added diff lines with it.
const ERROR = '#bf616a'

// More rows than any one block draws, or columns wider than any pane; the
// extra is clipped. Thin lines throughout: a thick ▌ beside thin ones clashed.
// tmux/scripts/copy-clean.pl strips these from copied text, so keep it in step.
const BAR = Array(400).fill('│').join('\n')
const FLOOR = '─'.repeat(400)

// Your own messages: typed here, or sent from the phone or web app.
const MINE = new Set(['composer', 'bridge'])
const MAX_COMMAND = 100
const MAX_RESULT_LINES = 3

// The timestamps plugin prefixes a reply with a dim "[HH:MM:SS] " written as
// ANSI codes. Take it off the text and draw the time in the reply's bottom
// line instead.
// eslint-disable-next-line no-control-regex
const STAMP = /^\u001b\[2m(\[\d{2}:\d{2}:\d{2}\])\u001b\[0m ?/

// Replies held back while they are written, by the id their chunks carry,
// and replies stopped with Esc, by the id their drawing carries. A reload
// empties both; it comes when a turn ends, when no reply is being written.
const held = new Map<string, string>()
const stopped = new Map<string, string>()

// The drawing refuses control characters other than tab and newline, so
// colour codes are removed whole, then any stray control byte.
const stripControl = (text: string): string =>
  text
    // eslint-disable-next-line no-control-regex
    .replace(/\u001b\[[0-9;:]*[A-Za-z]/g, '')
    // eslint-disable-next-line no-control-regex
    .replace(/[\u0000-\u0008\u000b-\u001f\u007f-\u009f]/g, '')

// A reply stopped with Esc gets no last chunk, so Claude Code draws it with
// empty text: use what was held back. One reply is written at a time, so it
// is the one held last.
const recover = (requestId: string): string => {
  const kept = stopped.get(requestId)

  if (kept !== undefined) {
    return kept
  }

  const last = [...held.keys()].pop()

  if (last === undefined) {
    return ''
  }

  const text = held.get(last) ?? ''
  held.delete(last)
  stopped.set(requestId, text)

  return text
}

const oneLine = (value: unknown, max: number): string => {
  const raw = typeof value === 'string' ? value : (JSON.stringify(value) ?? '')
  const flat = stripControl(raw).replace(/\s+/g, ' ').trim()

  return flat.length > max ? `${flat.slice(0, max - 1)}…` : flat
}

const summary = (input: unknown): string => {
  const fields = (input ?? {}) as Record<string, unknown>
  const main =
    fields.command ??
    fields.file_path ??
    fields.pattern ??
    fields.path ??
    fields.url ??
    fields.description ??
    input

  return oneLine(main, MAX_COMMAND)
}

const bashLines = (output: unknown): string[] | null => {
  const result = output as { stdout?: unknown; stderr?: unknown } | null

  if (!result || typeof result.stdout !== 'string') {
    return null
  }

  const stderr = typeof result.stderr === 'string' ? result.stderr : ''

  return `${result.stdout}\n${stderr}`
    .split('\n')
    .map(line => line.trimEnd())
    .filter(Boolean)
}

export const register: Register = on => {
  // While a reply is written, Claude Code draws it its own way, with a ⏺ and
  // no lines, and hands it to the hook below only once it is complete, so it
  // jumped. Hold every chunk back and show the whole reply with the last
  // one, so it is drawn once. Beneath this, the timestamps plugin puts the
  // time on the first chunk.
  on('classic.MessageDisplay', async ($, e, next) => {
    const result = await next(e)
    const text =
      (held.get(e.message_id) ?? '') + (result.displayContent ?? e.delta)

    if (!e.final) {
      held.set(e.message_id, text)

      return { ...result, displayContent: '' }
    }

    held.delete(e.message_id)

    return { ...result, displayContent: text }
  })

  // Claude's own words: the engine's own drawing, so the theme's colours
  // apply, with a line down the left and one along the bottom carrying the
  // time at its right end. No top line: whatever is above, such as your
  // message's bottom line, closes it off.
  on('ui.render', { component: 'AssistantMessage' }, async ($, e, next) => {
    const { Box, Text } = $.ui.resolve(e)

    // The text Claude wrote between tool calls, collapsed to one row: the
    // line alone, over its ⏺, with no bottom line.
    if (e.props.isSummary) {
      const drawn = await next(e)

      return (
        <Box flexDirection="column" marginTop={-1}>
          {drawn}
          <Box
            position="absolute"
            top={1}
            bottom={0}
            left={0}
            width={1}
            overflow="hidden"
          >
            <Text color={PROSE}>{BAR}</Text>
          </Box>
        </Box>
      )
    }

    const text = e.props.text || recover(e.requestId)
    const stamp = STAMP.exec(text)
    // A rewritten text may hold no control characters.
    const body = stripControl(stamp ? text.slice(stamp[0].length) : text)
    const time = stamp?.[1]?.slice(1, -1)
    const drawn = await next({ ...e, props: { ...e.props, text: body } })

    return (
      <Box flexDirection="column">
        {/* Pulled up over the blank line the engine's drawing opens with,
            so the text starts on the row after whatever is above it. */}
        <Box flexDirection="column" marginTop={-1}>
          {drawn}
          {/* A column of glyphs pinned to the block's top and bottom, so
              every line gets one; the rows past its height are clipped.
              Drawn after the text, so it paints over the engine's ⏺ in the
              first column, as your messages' line does their ❯. */}
          <Box
            position="absolute"
            top={1}
            bottom={0}
            left={0}
            width={1}
            overflow="hidden"
          >
            <Text color={PROSE}>{BAR}</Text>
          </Box>
        </Box>
        {/* The line fills what the time leaves: in a Box of its own, so it
            breaks at that Box's end rather than moving below, and is
            clipped. The time's Box keeps its width. */}
        <Box flexDirection="row" height={1}>
          <Box width={0} flexGrow={1} height={1} overflow="hidden">
            <Text color={PROSE}>└{FLOOR}</Text>
          </Box>
          {time ? (
            <Box flexShrink={0} marginX={1}>
              <Text dimColor>{time}</Text>
            </Box>
          ) : null}
          {time ? (
            <Box flexShrink={0}>
              <Text color={PROSE}>─</Text>
            </Box>
          ) : null}
        </Box>
      </Box>
    )
  })

  // Your own messages: a line down the left and along the bottom, so they
  // stand out from Claude's replies.
  on('ui.render', { component: 'UserMessage' }, async ($, e, next) => {
    const { Box, Text } = $.ui.resolve(e)
    const drawn = await next(e)

    // Anything else, such as a background task's notification: as the
    // engine draws it, with a blank row after, as a reply starts on the row
    // after whatever is above it.
    if (!MINE.has(e.props.origin.kind)) {
      return (
        <Box flexDirection="column" marginBottom={1}>
          {drawn}
        </Box>
      )
    }

    return (
      <Box flexDirection="column">
        <Box flexDirection="column">
          {drawn}
          {/* Drawn after the row, so it paints over the engine's ❯ in the
              first column; the border replaces it. Starts below the blank
              line the engine's drawing opens with. */}
          <Box
            position="absolute"
            top={1}
            bottom={0}
            left={0}
            width={1}
            overflow="hidden"
          >
            <Text color={PROMPT}>{BAR}</Text>
          </Box>
        </Box>
        <Box height={1} overflow="hidden">
          <Text color={PROMPT}>└{FLOOR}</Text>
        </Box>
      </Box>
    )
  })

  // Tool calls: one quiet grey line. ctrl+o still shows the full row.
  on('ui.render', { component: 'ToolUse' }, ($, e, next) => {
    if (e.props.isExpanded) {
      return next(e)
    }

    const { Text } = $.ui.resolve(e)
    const { tool, isRunning, isErrored, isInterrupted } = e.props
    const color = isErrored || isInterrupted ? ERROR : TOOL
    const suffix = isRunning ? ' …' : isInterrupted ? ' (interrupted)' : ''

    return (
      <Text color={color}>
        {tool}({summary(e.props.input)}){suffix}
      </Text>
    )
  })

  // Tool output, with a blank row after it, as a reply starts on the row
  // after whatever is above it. Bash output: the first few lines in grey.
  // Other tools draw as usual.
  on('ui.render', { component: 'ToolResult' }, async ($, e, next) => {
    const { Box, Text } = $.ui.resolve(e)
    const lines = e.props.tool === 'Bash' ? bashLines(e.props.output) : null

    if (lines === null) {
      return (
        <Box flexDirection="column" marginBottom={1}>
          {await next(e)}
        </Box>
      )
    }

    const shown = lines.slice(0, MAX_RESULT_LINES)
    const hidden = lines.length - shown.length

    return (
      <Box flexDirection="column" paddingLeft={2} marginBottom={1}>
        {shown.map((line, i) => (
          <Text key={String(i)} color={TOOL}>
            {oneLine(line, 120)}
          </Text>
        ))}
        {hidden > 0 ? <Text color={TOOL}>… +{hidden} lines</Text> : null}
      </Box>
    )
  })

  // Reads, searches and listings in a row, drawn as one line ("Read 2
  // files"): the same blank row after. Expanded, each call is its own row,
  // and the result above already has it.
  on('ui.render', { component: 'ToolGroup' }, async ($, e, next) => {
    if (e.props.isExpanded) {
      return next(e)
    }

    const { Box } = $.ui.resolve(e)

    return (
      <Box flexDirection="column" marginBottom={1}>
        {await next(e)}
      </Box>
    )
  })
}
