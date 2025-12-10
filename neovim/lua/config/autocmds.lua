local autocmd = vim.api.nvim_create_autocmd
local function augroup(name)
  return vim.api.nvim_create_augroup("local_" .. name, { clear = true })
end

-------------------------------------------------------------------------------
-- FILE BEHAVIOR
-------------------------------------------------------------------------------
-- Check if we need to reload the file when it changed
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- Notify when file is reloaded automatically
autocmd("FileChangedShellPost", {
  callback = function()
    vim.notify("File reloaded automatically", vim.log.levels.INFO, { title = "nvim" })
  end,
  group = augroup("file_reload"),
  desc = "Notify user when file is reloaded automatically",
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
autocmd({ "BufWritePre" }, {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-------------------------------------------------------------------------------
-- VISUAL FEEDBACK
-------------------------------------------------------------------------------
-- Highlight when yanking (copying) text
-- Try it with `yap` in normal mode - See `:help vim.highlight.on_yank()`
autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    (vim.hl or vim.highlight).on_yank()
  end,
})

-- Dynamic Search Highlighting
-- Automatically hides search highlights while typing (insert mode)
-- and shows them again in normal or visual modes
autocmd("ModeChanged", {
  pattern = "*",
  callback = function()
    local mode = vim.fn.mode()
    if mode:match("i") then
      vim.opt.hlsearch = false -- Hide highlights while typing
    else
      vim.opt.hlsearch = true -- Show them when navigating or searching
    end
  end,
  group = augroup("search_highlight"),
  desc = "Toggle search highlight visibility by mode",
})

-------------------------------------------------------------------------------
-- BUFFER MANAGEMENT
-------------------------------------------------------------------------------
-- Close different buffers with `q`
autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "PlenaryTestPopup",
    "checkhealth",
    "dbout",
    "gitsigns-blame",
    "grug-far",
    "help",
    "lspinfo",
    "neotest-output",
    "neotest-output-panel",
    "neotest-summary",
    "notify",
    "qf",
    "spectre_panel",
    "startuptime",
    "tsplayground",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set("n", "q", function()
        vim.cmd("close")
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = "Quit buffer",
      })
    end)
  end,
})

-- Make it easier to close man-files when opened inline
autocmd("FileType", {
  group = augroup("man_unlisted"),
  pattern = { "man" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
  end,
})

-------------------------------------------------------------------------------
-- EDITOR BEHAVIOR
-------------------------------------------------------------------------------
-- Adjust how text is formatted
autocmd("BufWinEnter", {
  group = augroup("formatting"),
  pattern = "*",
  callback = function()
    vim.cmd("set formatoptions-=cro")
  end,
})

-- Run resize methods when window size changes
autocmd("VimResized", {
  group = augroup("general"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-------------------------------------------------------------------------------
-- FILETYPE: TEXT FILES
-------------------------------------------------------------------------------
-- Wrap and check for spell in text filetypes
autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown", "md" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_gb"
  end,
})

-- Auto-save markdown files on change
autocmd({ "TextChanged", "InsertLeave" }, {
  group = augroup("autosave_markdown"),
  pattern = "*.md",
  callback = function()
    if vim.bo.modified then
      vim.cmd("silent! write")
    end
  end,
  desc = "Auto-save markdown files",
})

-------------------------------------------------------------------------------
-- FILETYPE: MARKDOWN
-------------------------------------------------------------------------------
-- Prevent IndentLine from hiding ``` in markdown files
autocmd({ "FileType" }, {
  group = augroup("markdown"),
  pattern = { "markdown" },
  callback = function()
    vim.g["indentLine_enabled"] = 0
    vim.g["markdown_syntax_conceal"] = 0
  end,
})

-------------------------------------------------------------------------------
-- FILETYPE: JSON
-------------------------------------------------------------------------------
-- Fix conceallevel for json files
autocmd({ "FileType" }, {
  group = augroup("json_conceal"),
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

-------------------------------------------------------------------------------
-- FILETYPE: RUBY
-------------------------------------------------------------------------------
-- Set Active Admin .arb files and slim files to be ruby files
autocmd({ "BufRead", "BufNewFile" }, {
  group = augroup("ruby"),
  pattern = "*.html.arb,*.html.slim",
  callback = function()
    vim.cmd("setfiletype ruby")
  end,
})

-------------------------------------------------------------------------------
-- FILETYPE: SKHD
-------------------------------------------------------------------------------
-- Set skhdrc files to bash filetype
autocmd({ "BufRead", "BufNewFile" }, {
  group = augroup("skhd"),
  pattern = "skhdrc",
  callback = function()
    vim.cmd("setfiletype bash")
  end,
})

-------------------------------------------------------------------------------
-- PLUGIN: COLORIZER
-------------------------------------------------------------------------------
local colorizer_loaded, _ = pcall(require, "colorizer")
if colorizer_loaded then
  autocmd("FileType", {
    group = augroup("colorizer"),
    pattern = "lazy",
    callback = function()
      vim.cmd("ColorizerDetachFromBuffer")
    end,
  })
end