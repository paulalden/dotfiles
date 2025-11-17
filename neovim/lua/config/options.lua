-- ----------------------------------------------------------------------------
-- PERFORMANCE & STARTUP
-- ----------------------------------------------------------------------------

-- Sync clipboard between OS and Neovim. Schedule after `UiEnter` to reduce startup time
vim.schedule(function()
  vim.opt.clipboard = "unnamedplus"
end)

-- Limit ShaDa file size for faster startup
vim.o.shada = "'100,<50,s10,:1000,/100,@100,h"

-- Enable all filetype plugins and syntax
vim.cmd("filetype plugin indent on")
if vim.fn.exists("syntax_on") ~= 1 then
  vim.cmd("syntax enable")
end

-- ----------------------------------------------------------------------------
-- GLOBAL VARIABLES
-- ----------------------------------------------------------------------------

vim.g.trouble_lualine = true -- Show document symbols from Trouble in lualine
vim.g.snacks_animate = false -- Disable snacks animations
vim.g.ruby_host_prog = "/Users/paul/.asdf/shims/neovim-ruby-host" -- Ruby host for plugins
vim.g.have_nerd_font = true -- Nerd Font support
vim.g.markdown_recommended_style = 0 -- Fix markdown indentation settings

-- ----------------------------------------------------------------------------
-- UNDO & BACKUP FILES
-- ----------------------------------------------------------------------------

vim.opt.undofile = true -- Save undo history
vim.opt.undolevels = 10000 -- Maximum number of changes that can be undone
vim.opt.undoreload = 10000 -- Maximum number lines to save for undo on buffer reload
vim.opt.swapfile = false -- Disable swap files
vim.opt.backup = false -- Disable backup files
vim.opt.writebackup = false -- Disable backup before writing

-- ----------------------------------------------------------------------------
-- UI & APPEARANCE
-- ----------------------------------------------------------------------------

vim.opt.number = true -- Show line numbers
vim.opt.relativenumber = true -- Show relative line numbers
vim.opt.cursorline = true -- Highlight the current line
vim.o.cursorlineopt = "screenline,number" -- Highlight per screen line and number
vim.opt.signcolumn = "yes" -- Always show sign column
vim.opt.colorcolumn = "80,120" -- Show column guides at 80 and 120 characters
vim.opt.ruler = false -- Disable default ruler (use statusline instead)
vim.opt.showmode = false -- Don't show mode (shown in statusline)
vim.opt.showtabline = 0 -- Never show tabline
vim.opt.laststatus = 3 -- Global statusline
vim.opt.termguicolors = true -- Enable 24-bit RGB colors
vim.o.cmdheight = 0 -- Auto-hide command line (reduces UI clutter)
vim.o.helpheight = 10 -- Set help window height
vim.opt.fillchars = { foldopen = "", foldclose = "", fold = " ", foldsep = " ", diff = "╱", eob = " " }
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.list = true -- Show invisible characters

-- ----------------------------------------------------------------------------
-- SEARCH
-- ----------------------------------------------------------------------------

vim.opt.ignorecase = true -- Ignore case in search
vim.opt.smartcase = true -- Don't ignore case when pattern has uppercase
vim.o.incsearch = true -- Show search matches while typing
vim.o.infercase = true -- Infer case in built-in completion
vim.opt.grepformat = "%f:%l:%c:%m" -- Format for grep results
vim.opt.grepprg = "rg --vimgrep" -- Use ripgrep for grepping
vim.opt.inccommand = "nosplit" -- Preview incremental substitute

-- ----------------------------------------------------------------------------
-- COMPLETION
-- ----------------------------------------------------------------------------

vim.o.completeopt = "menuone,noselect,fuzzy,nosort" -- Completion behavior
vim.o.pumheight = 8 -- Popup menu height
vim.o.pumblend = 0 -- Popup menu transparency (0 = opaque)

-- ----------------------------------------------------------------------------
-- EDITING & INDENTATION
-- ----------------------------------------------------------------------------

vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.tabstop = 2 -- Number of spaces a tab counts for
vim.opt.shiftwidth = 2 -- Size of an indent
vim.opt.shiftround = true -- Round indent to multiple of shiftwidth
vim.opt.smartindent = true -- Smart autoindenting on new lines
vim.o.autoindent = true -- Copy indent from current line when starting new line
vim.opt.breakindent = true -- Enable break indent for wrapped lines
vim.o.breakindentopt = "list:-1" -- Add padding for lists when wrapped
vim.opt.formatoptions = "jcroqlnt" -- Format options
vim.o.formatoptions = "rqnl1j" -- Improve comment editing

-- ----------------------------------------------------------------------------
-- WRAPPING & SCROLLING
-- ----------------------------------------------------------------------------

vim.opt.wrap = true -- Enable line wrapping
vim.opt.linebreak = true -- Wrap lines at convenient points
vim.opt.smoothscroll = true -- Smooth scrolling for wrapped lines
vim.opt.scrolloff = 4 -- Minimum lines above/below cursor
vim.opt.sidescrolloff = 8 -- Minimum columns left/right of cursor
vim.opt.mousescroll = "ver:1,hor:0" -- Mouse scroll behavior

-- ----------------------------------------------------------------------------
-- SPLITS & WINDOWS
-- ----------------------------------------------------------------------------

vim.opt.splitbelow = true -- Horizontal splits open below
vim.opt.splitright = true -- Vertical splits open to the right
vim.opt.splitkeep = "screen" -- Keep text on same screen line when opening splits
vim.opt.winminwidth = 5 -- Minimum window width
vim.o.winborder = "rounded" -- Use rounded borders in floating windows

-- ----------------------------------------------------------------------------
-- FOLDING
-- ----------------------------------------------------------------------------

vim.opt.foldlevel = 99
vim.opt.foldmethod = "indent"

-- ----------------------------------------------------------------------------
-- BEHAVIOR & MISCELLANEOUS
-- ----------------------------------------------------------------------------

vim.opt.mouse = "a" -- Enable mouse support in all modes
vim.opt.autowrite = true -- Automatically write file when switching buffers
vim.o.hidden = true -- Allow hidden buffers with unsaved changes
vim.opt.confirm = false -- Don't confirm before exiting modified buffer
vim.opt.virtualedit = "block" -- Allow cursor beyond end of line in visual block mode
vim.opt.timeoutlen = 300 -- Time to wait for mapped sequence (for which-key)
vim.opt.updatetime = 200 -- Faster CursorHold events and swap file writing
vim.opt.jumpoptions = "view" -- How jumping affects view
vim.opt.sessionoptions = {
  "buffers",
  "curdir",
  "tabpages",
  "winsize",
  "help",
  "globals",
  "skiprtp",
  "folds",
}

-- Only set clipboard if not in SSH (for OSC 52 integration)
vim.opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus"

vim.opt.conceallevel = 0 -- Show concealed text (e.g., `` in markdown)
vim.opt.whichwrap:append("<>[]hl") -- Allow h,l,<Left>,<Right> to move to prev/next line
vim.o.iskeyword = "@,48-57,_,192-255,-" -- Characters that form keywords (includes dash)
vim.opt.fixendofline = false -- Don't add missing end-of-file newline
vim.o.spelloptions = "camel" -- Treat camelCase as separate words for spell checking
vim.opt.spelllang = { "en" } -- Spell check language
vim.opt.diffopt = "filler,internal,closeoff,algorithm:histogram,context:5,linematch:60,algorithm:histogram"

-- ----------------------------------------------------------------------------
-- COMMAND LINE & WILDMENU
-- ----------------------------------------------------------------------------

vim.opt.wildmode = "longest:full,full" -- Command-line completion behavior
vim.o.shortmess = "CFOSWaco" -- Disable verbose completion messages

-- ----------------------------------------------------------------------------
-- STATUS COLUMN
-- ----------------------------------------------------------------------------

local loaded, _ = pcall(require, "snacks")
if loaded then
  vim.opt.statuscolumn = [[%!v:lua.require'snacks.statuscolumn'.get()]]
end

-- ----------------------------------------------------------------------------
-- COMMAND ABBREVIATIONS
-- ----------------------------------------------------------------------------

-- Prevent common typos when saving/quitting
vim.cmd([[
  cnoreabbrev Wq wq
  cnoreabbrev wQ wq
  cnoreabbrev WQ wq
  cnoreabbrev W w
  cnoreabbrev Q q
]])