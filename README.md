# dotfiles

My MacOS focused development environment dotfiles.

## Installation

### Fresh macOS Setup

```bash
# 1. Clone the repo
git clone https://github.com/YOUR_USER/dotfiles.git ~/Personal/repos/dotfiles
cd ~/Personal/repos/dotfiles

# 2. Run the install script — it does everything else
./install
```

`./install` handles the rest:

- **Installs Homebrew and dotbot** if they're missing.
- **Runs monitoring-software detection** before touching anything.
- **Asks about window management** — yabai, skhd, sketchybar, and borders
  need special macOS permissions and partial SIP disabling, so they're an
  explicit y/N prompt (with their own Brewfile and dotbot config).
- **Symlinks everything** via dotbot, installs the Brewfile packages,
  clones TPM and installs the tmux plugins, and applies macOS defaults.

### Post-Install

- **Open a new terminal** to load the ZSH configuration.
- **Neovim plugins** auto-install on the first `nvim` launch.

### Requirements

- macOS (Apple Silicon, paths assume `/opt/homebrew/`)
- Xcode Command Line Tools (`xcode-select --install`)
- SSH key at `~/.ssh/id_rsa` (optional, for git/GitHub)
- `~/secrets.sh` for private environment variables (optional)

## Applications

- Nord Color Scheme
- Homebrew

* Yabai WM & SKHD
* Sketchybar
* Kitty
* Tmux
* Neovim
  - Ruby development focused
  - LSP
  - Treesitter
  - Snacks
  - Git

- Ranger
- Bat

* ZSH
* FZF
* Pure ZSH prompt
* LazyGit

## Screenshots

![Desktop](https://github.com/user-attachments/assets/998e7a07-f164-481c-9533-9565f5396203)
![Neovim](https://github.com/user-attachments/assets/a7d33132-b177-4d1d-aeff-708ebf29c481)
![Tmux](https://github.com/user-attachments/assets/f547c5f2-7582-4d98-8db1-11e7ac666b34)
![Lazygit](https://github.com/user-attachments/assets/cc4fbde6-da74-4a3a-b668-edab709f1abb)
![Tmux Sessions](https://github.com/user-attachments/assets/97508672-318c-43bc-8088-a1cf721093ad)
![Tmux Search](https://github.com/user-attachments/assets/8adc86ee-50fb-41fe-b7cd-74aa724aae50)


## FZF

FZF commands are available both as shell functions and as tmux popup keybindings.

### Tmux Keybindings

All bindings use the tmux prefix (`Ctrl+Space`). Popup windows display a centered title so you know what you're looking at.

**Popup Apps**

| Binding      | Description           |
| ------------ | --------------------- |
| `prefix + f` | Ranger file manager   |
| `prefix + d` | LazySQL               |
| `prefix + h` | Htop                  |
| `prefix + i` | IRB (Ruby REPL)       |
| `prefix + v` | Cloudflare speed test |

**Tmux** (prefix + t, then second key)

| Binding        | Description                                                              |
| -------------- | ------------------------------------------------------------------------ |
| `prefix + t f` | Find and edit a file (Enter: in popup, Ctrl-S: in pane)                  |
| `prefix + t g` | Live ripgrep search (Enter: in popup, Ctrl-S: in pane)                   |
| `prefix + t p` | Switch to another tmux pane across windows                               |
| `prefix + t e` | Sessionizer - find a project directory and open/switch to a tmux session |
| `prefix + t t` | Toggle the status bar                                                    |

**Claude** (prefix + a, then second key)

| Binding        | Description                                                          |
| -------------- | -------------------------------------------------------------------- |
| `prefix + a a` | Switch between running Claude Code sessions (colour-coded by status) |
| `prefix + a s` | Toggle the Claude sessions sidebar                                   |
| `prefix + a A` | Jump straight to the oldest blocked Claude session                   |

**Git** (prefix + g, then second key)

| Binding        | Description                                              |
| -------------- | -------------------------------------------------------- |
| `prefix + g g` | Lazygit                                                  |
| `prefix + g b` | Git branch switcher (sorted by recent, with log preview) |
| `prefix + g l` | Git log browser (Enter to view diff, Ctrl-O to checkout) |
| `prefix + g s` | Git stash browser (Enter to apply, Ctrl-D to drop)       |

**System & Tools**

| Binding      | Description                                |
| ------------ | ------------------------------------------ |
| `prefix + K` | Fuzzy find and kill a process              |
| `prefix + N` | Browse listening ports and kill the process |

### Shell Functions

| Command      | Description                                   |
| ------------ | --------------------------------------------- |
| `fe [query]` | Find and open a file in `$EDITOR`             |
| `fo [query]` | Find a file - Ctrl-O to `open`, Enter to edit |
| `fcd`        | cd into a directory (including hidden)         |

### Built-in FZF Keybindings

| Binding  | Description                                        |
| -------- | -------------------------------------------------- |
| `Ctrl+R` | Search shell history (Ctrl-Y to copy to clipboard) |
| `Ctrl+T` | Find files/directories with preview                |

## Sketchybar

Custom macOS status bar replacing the system menu bar. Config lives in `sketchybar/`.

### What the bar shows

| Item                                 | Side  | Description                                          |
| ------------------------------------ | ----- | ---------------------------------------------------- |
| Apple logo                           | Left  | Popup menu: Settings, Activity Monitor, Lock Screen  |
| Spaces                               | Left  | One item per yabai space; click to focus it          |
| Front app                            | Left  | Icon and name of the focused application             |
| Time / Date                          | Right | Clock and date                                       |
| Battery / Wifi / Volume / Brightness | Right | System status indicators                             |
| CPU / Memory                         | Right | Usage %, colour shifts green to red with load        |
| Homebrew                             | Right | Outdated package count; click for the list           |
| Camera                               | Right | Red icon, shown only while the camera is streaming   |

### How it works

- **`sketchybarrc`** sets bar appearance, then sources each item from `items/`.
- **`items/*.sh`** declare an item and point it at a plugin script.
- **`plugins/*.sh`** run on a timer or event, updating the item via `sketchybar --set`.
- **Yabai** reloads the bar when spaces are created or destroyed.

### Theming

- **`scripts/config.sh`** sources the active palette, currently `config-nord.sh`.
- **Nord palette** mirrors the canonical colours in `tmux/config/nord.conf`.
- **`scripts/theme_switcher.sh toggle`** switches themes across Sketchybar, Kitty, Tmux, and Neovim.

### Installation

- **Opt-in**: `./install` asks `Install window management tools? (y/N)`.
- **Answering yes** links configs via `install.wm.yaml` and installs `homebrew/Brewfile.wm`.
- **App icons** come from `sketchybar-app-font`, installed automatically.

## Neovim

### Ruby Debugging (DAP)

Debug Ruby files, RSpec tests, and Rails servers directly in Neovim using `nvim-dap` with the `rdbg` adapter (from the `debug` gem). Two debugging UIs are available: `nvim-dap-ui` (multi-panel layout) and `nvim-dap-view` (single-window).

**Prerequisites:**

The `debug` gem must be available in your project. It's already bundled as a dependency of `ruby-lsp`, but you can also add it explicitly:

```ruby
# Gemfile
group :development, :test do
  gem "debug"
end
```

**Keybindings:**

| Binding      | Description                     |
| ------------ | ------------------------------- |
| `<leader>db` | Toggle breakpoint               |
| `<leader>dc` | Start/continue debugging        |
| `<leader>di` | Step into                       |
| `<leader>do` | Step over                       |
| `<leader>dO` | Step out                        |
| `<leader>du` | Toggle DAP UI (multi-panel)     |
| `<leader>dv` | Toggle DAP View (single-window) |
| `<leader>dw` | Add watch expression (DAP View) |

**DAP UI** opens automatically when a debug session starts and closes when it ends. It shows scopes, breakpoints, stacks, watches, and a REPL in a multi-panel layout.

**DAP View** is toggled manually with `<leader>dv`. Switch between sections using the winbar keys:

| Key | Section                                      |
| --- | -------------------------------------------- |
| `S` | Scopes — inspect local/global variables      |
| `W` | Watches — evaluate custom expressions        |
| `B` | Breakpoints — view and manage breakpoints    |
| `T` | Threads — navigate call stacks               |
| `E` | Exceptions — configure exception breakpoints |
| `R` | REPL — interactive debug console             |

Press `g?` inside any section to see all available actions (expand, edit, delete, etc.).

**Debugging Ruby files and RSpec:**

1. Open a Ruby file and set breakpoints with `<leader>db`
2. Start debugging with `<leader>dc` and choose a launch config:
   - **Run current file** — runs `ruby <file>` under the debugger
   - **RSpec - current file** — runs `bundle exec rspec <file>` under the debugger
3. DAP UI opens automatically showing scopes, breakpoints, stacks, and a REPL
4. Step through code with `<leader>di` / `<leader>do` / `<leader>dO`
5. Optionally open DAP View with `<leader>dv` for a focused single-window view

**Debugging a Rails server:**

Rails requires an attach workflow since Puma manages its own process lifecycle:

1. Start Rails with rdbg in a separate terminal or tmux pane:
   ```bash
   bundle exec rdbg --open --port 12345 --nonstop -c -- bin/rails server
   ```
2. Set breakpoints in a controller/model with `<leader>db`
3. Attach with `<leader>dc` → **Attach to Rails server**
4. Hit the route in your browser — Neovim will pause at the breakpoint
5. Step through code and inspect variables in DAP UI or DAP View

### Testing (Neotest)

Run RSpec tests from within Neovim using `neotest` with the `neotest-rspec` adapter.

| Binding      | Description               |
| ------------ | ------------------------- |
| `<leader>tn` | Run nearest test          |
| `<leader>tf` | Run current file          |
| `<leader>ts` | Run full test suite       |
| `<leader>to` | Show test output          |
| `<leader>tS` | Toggle test summary panel |

### Rails Navigation

`vim-rails` provides Rails-aware navigation commands:

| Command               | Description                                      |
| --------------------- | ------------------------------------------------ |
| `:Emodel <name>`      | Jump to a model                                  |
| `:Econtroller <name>` | Jump to a controller                             |
| `:Eview <name>`       | Jump to a view                                   |
| `:Emigration <name>`  | Jump to a migration                              |
| `:A`                  | Jump to alternate file (e.g. model → test)       |
| `:R`                  | Jump to related file (e.g. migration → schema)   |
| `gf`                  | Enhanced go-to-file that understands Rails paths |

## Yabai

The WM needs to add hacks to get it working fully:

- [Partially disable system integrity](https://github.com/koekeishiya/yabai/wiki/Disabling-System-Integrity-Protection)
- [Setup user to run script injection](<https://github.com/koekeishiya/yabai/wiki/Installing-yabai-(latest-release)#macos-big-sur---automatically-load-scripting-addition-on-startup>)

After upgrading Yabai, you need to follow these steps to properly setup application following:

https://github.com/koekeishiya/yabai/wiki/Installing-yabai-(latest-release)#updating-to-the-latest-release

## Claude

Installing claude-code

`~/.claude/settings.json` is symlinked to this repo's `claude/settings.json`
by dotbot — don't put machine secrets there. The API key helper goes in
`~/.claude/settings.local.json` (untracked, merged by Claude Code):

```json
{
  "apiKeyHelper": "~/.claude/anthropic_key.sh"
}
```

Then in `~/.claude/anthropic_key.sh`:

```bash
echo "sk-........."
```

and make it executable with `chmod +x ~/.claude/anthropic_key.sh`.

### Session status in tmux

When Claude Code runs inside a tmux pane, every window shows what its session
is doing — and three keys take you to the one that needs you.

- **Status dot** — coloured dot on the window name (passive).
- **Switcher** — `prefix + a a` fuzzy popup with preview.
- **Sidebar** — `prefix + a s` live left-split monitor.
- **Jump** — `prefix + a A` straight to the oldest blocked session.
- **Banner + notification** — makes sure you don't miss a blocked one.

#### States

One colour language everywhere — the dot at the end of the window title and
the mark in the switcher/sidebar lists:

| State       | Window dot | In lists    | Meaning                                  |
| ----------- | ---------- | ----------- | ---------------------------------------- |
| Blocked     | 🔴         | `●` red     | Needs a click (permission / question)    |
| Working     | 🟡         | `●` yellow  | Claude is processing                     |
| Done        | 🔵         | `●` blue    | Finished, waiting for your next message  |
| Silenced    | —          | `z` grey    | Deferred — quiet until its state changes |
| _(running)_ | —          | `○` grey    | Claude alive, nothing to report          |

- **Per pane** — two Claudes split in one window keep separate states.
- **Rollup** — the window shows its most urgent pane, title bold when blocked.
- **Self-clearing** — the blue "done" dot clears when you focus the pane.

#### Switcher — `prefix + a a`

Fuzzy popup of every running Claude session. Attention-first, then
oldest-first, with ages and a live pane preview. Requires `fzf`.

| Key      | Action                                          |
| -------- | ----------------------------------------------- |
| type     | Fuzzy-filter the list                           |
| `Enter`  | Switch to that session/window/pane              |
| `ctrl-x` | Clear the row's attention marker (list reloads) |
| `ctrl-s` | Silence / unsilence the row (list reloads)      |
| `Esc`    | Close the popup                                 |

#### Jump — `prefix + a A`

- **One key** — switches straight to the oldest blocked session.
- **Skips silenced** sessions; shows a message if nothing is blocked.
- **Also bound** at `prefix + t A`.

#### Sidebar — `prefix + a s`

A 34-column left split monitoring every Claude session live. Same states and
ordering as the switcher, refreshed every 2s. Window-local. Plain bash — no
`fzf` needed; fuzzy search lives in the switcher, one `/` away.

- **Rows** — state glyph, numbered, with `session:window.pane` and age; the
  pane title in grey underneath.
- **Scrolls** — `↑/↓ N more` markers when the list outgrows the pane.

| Key                       | Action                                                 |
| ------------------------- | ------------------------------------------------------ |
| `ctrl-n` / `ctrl-p`       | Move the cursor (arrows and mouse wheel work too)      |
| `Enter` / click / `1`-`9` | Jump to the session and close the sidebar              |
| `j`                       | Jump but keep the sidebar open                         |
| `o`                       | Peek — live preview popup of the pane (any key closes) |
| `s`                       | Silence / unsilence the row                            |
| `x`                       | Clear the row's attention marker without visiting it   |
| `/`                       | Open the fuzzy switcher on top                         |
| `?`                       | Help screen — legend and keys (any key returns)        |
| `q` / `Esc`               | Close the sidebar (`prefix + a s` again works too)     |

#### Silencing

A silenced session is a conscious "not now":

- **Stays listed** — grey `z`, sorted last.
- **Goes quiet** — no banner, no notification, jump key skips it.
- **Un-silences** — press `s` again, or automatically when its state next
  changes.

#### Banner and desktop alerts

- **Banner** — bottom-right `🔔 <name> needs you (<age>)` while blocked.
- **Oldest first**, `+N` when several are waiting.
- **Non-blocking** — you can keep typing; it clears itself once resolved.
- **Escalation** — blocked and off-screen for 60s fires one macOS
  notification (via `osascript`; no dependency).
- **Permission** — grant the terminal Notifications access on first fire.

#### How it works

Claude Code hooks write per-pane tmux options; a per-window rollup draws the
dot:

| Option              | Scope  | Meaning                                     |
| ------------------- | ------ | ------------------------------------------- |
| `@claude_pane_state`| pane   | `working` / `urgent` / `done` (source)      |
| `@claude_since`     | pane   | epoch the current state began (for ages)    |
| `@claude_notified`  | pane   | set once the desktop alert fired            |
| `@claude_alert`     | window | max-severity rollup that renders the dot    |
| `@claude_sidebar`   | pane   | marks a sidebar pane so the toggle finds it |
| `@claude_parked`    | pane   | silenced: listed but quiet until next state |

Each hook calls `claude-notify.sh <state>` for the pane it fires in:

| Hook                                            | State     |
| ----------------------------------------------- | --------- |
| SessionStart, UserPromptSubmit, Pre/PostToolUse | `working` |
| Notification (permission / question)            | `urgent`  |
| Stop                                            | `done`    |
| SessionEnd                                      | _cleared_ |

- **Crash-safe** — a `kill -9`'d Claude never fires `SessionEnd`, so
  `claude-tick.sh` (2s sweep from `status-right`) clears any pane whose tty
  has no live `claude` process.
- **Reconcile-on-read** — the switcher, sidebar, and jump key drop dead
  panes too. Nothing gets stuck.

#### Components

- `claude/settings.json` — registers the hooks (symlinked to `~/.claude/settings.json`).
- `tmux/scripts/claude-lib.sh` — shared helpers (liveness, listing, rollup, styling).
- `tmux/scripts/claude-notify.sh` — the hook target; sets the per-pane state.
- `tmux/scripts/claude-tick.sh` — 2s sweep: cleanup, rollup, escalation, banner.
- `tmux/scripts/claude-jump.sh` — jump to the oldest blocked session.
- `tmux/scripts/claude-clear-done.sh` — clears a `done` marker on `pane-focus-in`.
- `tmux/scripts/fzf-claude.sh` — the switcher popup.
- `tmux/scripts/claude-sidebar.sh` — the sidebar render loop.
- `tmux/scripts/claude-sidebar-toggle.sh` — opens/closes the sidebar split.
- `tmux/scripts/claude-preview.sh` — the sidebar's `o` live-preview popup.
- `tmux/config/theme.conf` — renders the dot and the banner.
- `tmux/config/keybindings.conf` — the `prefix + a a` / `a s` / `a A` bindings.

#### Notes

- **Hooks load at session start** — only Claude sessions started after the
  hooks are in place show a dot; restart existing sessions to pick it up.
- **`fzf`** is needed by the switcher popup only (sidebar and jump key don't).
- **Outside tmux**, desktop notifications still work via
  `preferredNotifChannel: kitty`.
