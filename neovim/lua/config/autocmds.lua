local function augroup(name)
  return vim.api.nvim_create_augroup("local_" .. name, { clear = true })
end

-- Highlight when yanking (copying) text Try it with `yap` in normal mode - See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    (vim.hl or vim.highlight).on_yank()
  end,
})

-- Wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Prevent IndentLine from hiding ``` in markdown files
vim.api.nvim_create_autocmd({ "FileType" }, {
  group = augroup("editing"),
  pattern = { "markdown" },
  callback = function()
    vim.g["indentLine_enabled"] = 0
    vim.g["markdown_syntax_conceal"] = 0
  end,
})

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- Close different buffers with `q`
vim.api.nvim_create_autocmd("FileType", {
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

-- Adjust how text is formatted
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = augroup("formatting"),
  pattern = "*",
  callback = function()
    vim.cmd("set formatoptions-=cro")
  end,
})

-- Make it easier to close man-files when opened inline
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("man_unlisted"),
  pattern = { "man" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
  end,
})

-- Run resize methods when window size is changes
vim.api.nvim_create_autocmd("VimResized", {
  group = augroup("general"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()

    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- Fix conceallevel for json files
vim.api.nvim_create_autocmd({ "FileType" }, {
  group = augroup("json_conceal"),
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

local colorizer_loaded, _ = pcall(require, "colorizer")
if colorizer_loaded then
  vim.api.nvim_create_autocmd("FileType", {
    group = augroup("colorizer"),
    pattern = "lazy",
    callback = function()
      vim.cmd("ColorizerDetachFromBuffer")
    end,
  })
end

-- Ruby --
-- Set Active Admin .arb files to be ruby files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = augroup("ruby"),
  pattern = "*.html.arb,*.html.slim",
  callback = function()
    vim.cmd("setfiletype ruby")
  end,
})

-- SHKD --
-- Set Active Admin .arb files to be ruby files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = augroup("_skhd"),
  pattern = "skhdrc",
  callback = function()
    vim.cmd("setfiletype bash")
  end,
})

-- Show dashboard when all buffers are closed
-- vim.api.nvim_create_autocmd("BufDelete", {
--   callback = function()
--     vim.schedule(function()
--       local listed_bufs = vim.tbl_filter(function(buf)
--         return vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted
--       end, vim.api.nvim_list_bufs())
--
--       if #listed_bufs == 0 then
--         require("snacks").dashboard.open()
--       end
--     end)
--   end,
--   group = vim.api.nvim_create_augroup("maat", { clear = true }),
-- })