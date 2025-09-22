---@module "snacks"

-------------------------------------------------------------------------------
-- General Keybindings, not plugin specific
-------------------------------------------------------------------------------
local opts = { silent = true }
local map = vim.keymap.set

-- Turn off arrow keys - force HJKL
map("n", "<UP>", "<NOP>", opts)
map("n", "<DOWN>", "<NOP>", opts)
map("n", "<LEFT>", "<NOP>", opts)
map("n", "<RIGHT>", "<NOP>", opts)

-- Quit all
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })

-- Insert lines above/below without leaving normal mode
map("n", "oo", "o<Esc>k", opts)
map("n", "OO", "O<Esc>j", opts)

-- Alternatives to :w, because I constantly typo it
map({ "i", "n", "v" }, "<c-s>", "<NOP>", opts)
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })

-- Add line break and jump to start
map("n", "<Enter>", "a<Enter><Esc>^", opts)

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

-- Add undo break-points
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

-- better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- commenting
map("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Below" })
map("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Above" })

-------------------------------------------------------------------------------
-- Copy / Paste
-------------------------------------------------------------------------------
-- Use x and Del key for black hole register
map("", "<Del>", '"_x', opts)
map("", "x", '"_x', opts)

-- Paste over selected text
map("v", "p", '"_dP', opts)

-------------------------------------------------------------------------------
-- Escape
-------------------------------------------------------------------------------
-- Map ctrl-c to esc
map("i", "<C-c>", "<esc>", opts)

-- Remove highlighting
map("n", "<esc><esc>", "<esc><cmd>noh<cr><esc>", opts)

-- Escape in normal mode seems to tab
map("n", "<esc>", "<NOP>", opts)

-------------------------------------------------------------------------------
-- Buffers
-------------------------------------------------------------------------------
-- Print the current buffer type
map({ "n", "t", "v", "i", "" }, "<C-x>", "<cmd>echo &filetype<cr>", opts)

-- Copying buffer paths
map("n", "<leader>yr", "<cmd>let @+ = expand('%:~:.')<cr>", { desc = "Relative Path", silent = true })
map("n", "<leader>yf", "<cmd>let @+ = expand('%:p')<cr>", { desc = "Full Path", silent = true })

-- Moving Buffers
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })

-- Switch to other buffer
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })

-- Deleting buffers
map("n", "<c-w>", "<cmd>bd<cr>", { desc = "Delete Buffer" })
map("n", "<leader>bD", "<cmd>:bd<cr>", { desc = "Delete Buffer and Window" })

-------------------------------------------------------------------------------
-- Splits
-------------------------------------------------------------------------------
-- Create splits
map("n", "<leader>\\", "<cmd>vsplit<cr>", { desc = "Vertical Split", silent = true })
map("n", "<leader>-", "<cmd>split<cr>", { desc = "Horizontal Split", silent = true })

-- Resize splits with alt+cursor keys
map({ "n", "i", "v" }, "<A-j>", "<nop>")
map({ "n", "i", "v" }, "<A-k>", "<nop>")
map({ "n", "i", "v" }, "<M-j>", "<nop>")
map({ "n", "i", "v" }, "<M-k>", "<nop>")

map("n", "<M-Up>", ":resize +2<CR>", opts)
map("n", "<M-Down>", ":resize -2<CR>", opts)
map("n", "<M-Left>", ":vertical resize -2<CR>", opts)
map("n", "<M-Right>", ":vertical resize +2<CR>", opts)

-------------------------------------------------------------------------------
-- Terminal
-------------------------------------------------------------------------------
-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-------------------------------------------------------------------------------
-- Navigation
-------------------------------------------------------------------------------
-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
map("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
map("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
map("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
map("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-------------------------------------------------------------------------------
-- Snacks
-------------------------------------------------------------------------------
local loaded, _ = pcall(require, "snacks")
if loaded then
  map("n", "<leader>d", "<cmd>lua Snacks.dashboard.open()<cr>", { desc = "[D]ashboard", silent = true })

  Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
  Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
  Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
  Snacks.toggle.diagnostics():map("<leader>ud")
  Snacks.toggle.line_number():map("<leader>ul")
  Snacks.toggle
    .option("conceallevel", {
      off = 0,
      on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2,
      name = "Conceal Level",
    })
    :map("<leader>uc")
  Snacks.toggle
    .option("showtabline", {
      off = 0,
      on = vim.o.showtabline > 0 and vim.o.showtabline or 2,
      name = "Tabline",
    })
    :map("<leader>uA")
  Snacks.toggle.treesitter():map("<leader>uT")
  Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
  Snacks.toggle.dim():map("<leader>uD")
  Snacks.toggle.animate():map("<leader>ua")
  Snacks.toggle.indent():map("<leader>ug")
  Snacks.toggle.scroll():map("<leader>uS")
  Snacks.toggle.profiler():map("<leader>dpp")
  Snacks.toggle.profiler_highlights():map("<leader>dph")
end

map({ "n", "x" }, "<leader>gB", function()
  Snacks.gitbrowse()
end, { desc = "Git Browse (open)" })
map({ "n", "x" }, "<leader>gY", function()
  Snacks.gitbrowse({
    open = function(url)
      vim.fn.setreg("+", url)
    end,
    notify = false,
  })
end, { desc = "Git Browse (copy)" })
