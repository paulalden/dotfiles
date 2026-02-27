vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.lazy")
require("config.keymaps")
require("config.autocmds")

-- Defer LSP and health setup until after UI renders
vim.api.nvim_create_autocmd("UIEnter", {
  once = true,
  callback = function()
    require("config.lsp")
    require("config.health")
  end,
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et