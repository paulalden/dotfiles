import type { Register } from 'claude-code'

// Nord, from dotfiles tmux/config/nord.conf.
const PROSE = '#c895bf' // Kitty's bright magenta (color13)
const PROMPT = '#88c0d0' // cyan
const TOOL = '#616d85'
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

// The drawing refuses control characters other than tab and newline, so
// colour codes are removed whole, then any stray control byte.
const stripControl = (text: string): string =>
  text
    // eslint-disable-next-line no-control-regex
    .replace(/\u001b\[[0-9;:]*[A-Za-z]/g, '')
    // eslint-disable-next-line no-control-regex
    .replace(/[\u0000-\u0008\u000b-\u001f\u007f-\u009f]/g, '')

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
  // Claude's own words: the engine's own drawing, so the theme's colours
  // apply, with a line down the left and one along the bottom carrying the
  // time at its right end. No top line: whatever is above, such as your
  // message's bottom line, closes it off.
  on('ui.render', { component: 'AssistantMessage' }, async ($, e, next) => {
    if (e.props.isSummary) {
      return next(e)
    }

    const { Box, Text } = $.ui.resolve(e)
    const stamp = STAMP.exec(e.props.text)
    const body = stamp ? e.props.text.slice(stamp[0].length) : e.props.text
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
    if (!MINE.has(e.props.origin.kind)) {
      return next(e)
    }

    const { Box, Text } = $.ui.resolve(e)
    const drawn = await next(e)

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

  // Bash output: the first few lines in grey. Other tools draw as usual.
  on('ui.render', { component: 'ToolResult' }, ($, e, next) => {
    if (e.props.tool !== 'Bash') {
      return next(e)
    }

    const lines = bashLines(e.props.output)

    if (lines === null) {
      return next(e)
    }

    const { Box, Text } = $.ui.resolve(e)
    const shown = lines.slice(0, MAX_RESULT_LINES)
    const hidden = lines.length - shown.length

    return (
      <Box flexDirection="column" paddingLeft={2}>
        {shown.map((line, i) => (
          <Text key={String(i)} color={TOOL}>
            {oneLine(line, 120)}
          </Text>
        ))}
        {hidden > 0 ? <Text color={TOOL}>… +{hidden} lines</Text> : null}
      </Box>
    )
  })
}
