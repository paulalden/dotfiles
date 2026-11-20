import type { Register } from 'claude-code'

// Nord, from dotfiles tmux/config/nord.conf.
const PROSE = '#c895bf' // Kitty's bright magenta (color13)
const TOOL = '#616d85'
const ERROR = '#bf616a'

const RULE = '='.repeat(69)
// More rows than any one reply block draws; the extra rows are clipped.
const BAR = Array(400).fill('▌').join('\n')
const MAX_COMMAND = 100
const MAX_RESULT_LINES = 3

// The timestamps plugin prefixes a reply with a dim "[HH:MM:SS] " written as
// ANSI codes. Draw it as a dim Text instead of literal escape text.
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
  // apply, wrapped with a bright accent bar.
  on('ui.render', { component: 'AssistantMessage' }, async ($, e, next) => {
    if (e.props.isSummary) {
      return next(e)
    }

    const { Box, Text } = $.ui.resolve(e)
    const stamp = STAMP.exec(e.props.text)
    const body = stamp ? e.props.text.slice(stamp[0].length) : e.props.text
    const drawn = await next({ ...e, props: { ...e.props, text: body } })

    return (
      <Box flexDirection="column" paddingLeft={2} marginTop={stamp ? 1 : 0}>
        {/* A column of glyphs pinned to the block's top and bottom, so every
            line gets one; the rows past the block's height are clipped. */}
        <Box
          position="absolute"
          top={0}
          bottom={0}
          left={0}
          width={1}
          overflow="hidden"
        >
          <Text color={PROSE}>{BAR}</Text>
        </Box>
        {/* The engine's drawing opens with its own blank line. */}
        {stamp ? (
          <Text dimColor>
            {stamp[1]} {RULE}
          </Text>
        ) : null}
        {drawn}
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
