local opts = { silent = true }
local map = vim.keymap.set

-------------------------------------------------------------------------------
-- DISABLED KEYS
-------------------------------------------------------------------------------
-- Turn off arrow keys - force HJKL
map("n", "<UP>", "<NOP>", opts)
map("n", "<DOWN>", "<NOP>", opts)
map("n", "<LEFT>", "<NOP>", opts)
map("n", "<RIGHT>", "<NOP>", opts)

-------------------------------------------------------------------------------
-- EDITOR BEHAVIOR
-------------------------------------------------------------------------------
-- Quit all
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })

-- Alternatives to :w, because I constantly typo it
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })

-- Insert lines above/below without leaving normal mode
map("n", "oo", "o<Esc>k", opts)
map("n", "OO", "O<Esc>j", opts)

-- Add line break and jump to start
map("n", "<Enter>", "a<Enter><Esc>^", opts)

-- Add undo break-points
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

-------------------------------------------------------------------------------
-- SEARCH
-------------------------------------------------------------------------------
-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

-------------------------------------------------------------------------------
-- TEXT EDITING
-------------------------------------------------------------------------------
-- Better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Commenting
map("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Below" })
map("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Above" })

-- Read the highlighted block
map("v", "<leader>zs", ":w !say<CR>", { desc = "Say selected text", silent = true })

-------------------------------------------------------------------------------
-- COPY / PASTE / REGISTERS
-------------------------------------------------------------------------------
-- Use x and Del key for black hole register
map("", "<Del>", '"_x', opts)
map("", "x", '"_x', opts)

-- Paste over selected text
map("v", "p", '"_dP', opts)

-------------------------------------------------------------------------------
-- ESCAPE AND HIGHLIGHTING
-------------------------------------------------------------------------------
-- Map ctrl-c to esc
map("i", "<C-c>", "<esc>", opts)

-- Remove highlighting
map("n", "<esc><esc>", "<esc><cmd>noh<cr><esc>", opts)

-- Escape in normal mode seems to tab
map("n", "<esc>", "<NOP>", opts)

-------------------------------------------------------------------------------
-- BUFFERS
-------------------------------------------------------------------------------
-- Print the current buffer type
map({ "n", "t", "v", "i", "" }, "<C-x>", "<cmd>echo &filetype<cr>", opts)

-- Copying buffer paths
map("n", "<leader>yr", "<cmd>let @+ = expand('%:~:.')<cr>", { desc = "Relative Path", silent = true })
map("n", "<leader>yf", "<cmd>let @+ = expand('%:p')<cr>", { desc = "Full Path", silent = true })

-- Navigation between buffers
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })

-- Switch to other buffer
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })

-- Deleting buffers
map("n", "<c-w>", "<cmd>bd<cr>", { desc = "Delete Buffer" })
map("n", "<leader>bD", "<cmd>:bd<cr>", { desc = "Delete Buffer and Window" })

-------------------------------------------------------------------------------
-- SPLITS AND WINDOWS
-------------------------------------------------------------------------------
-- Create splits
map("n", "<leader>\\", "<cmd>vsplit<cr>", { desc = "Vertical Split", silent = true })
map("n", "<leader>-", "<cmd>split<cr>", { desc = "Horizontal Split", silent = true })

-- Window navigation - handled by vim-tmux-navigator plugin (tmux.lua)

-- Resize splits with alt+cursor keys
map({ "n", "i", "v" }, "<A-j>", "<nop>")
map({ "n", "i", "v" }, "<A-k>", "<nop>")

map("n", "<M-Up>", ":resize +2<CR>", opts)
map("n", "<M-Down>", ":resize -2<CR>", opts)
map("n", "<M-Left>", ":vertical resize -2<CR>", opts)
map("n", "<M-Right>", ":vertical resize +2<CR>", opts)

-------------------------------------------------------------------------------
-- TERMINAL
-------------------------------------------------------------------------------
-- Exit terminal mode with a shortcut that is easier to discover
-- NOTE: This won't work in all terminal emulators/tmux/etc.
-- Fallback: use <C-\><C-n> to exit terminal mode
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
