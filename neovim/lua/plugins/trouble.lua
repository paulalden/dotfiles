return {
  "folke/trouble.nvim",
  cmd = { "Trouble" },
  opts = {
    modes = {
      lsp = {
        win = { position = "right" },
      },
      symbols = { -- Configure symbols mode
        win = {
          type = "split", -- split window
          relative = "win", -- relative to current window
          position = "right", -- right side
          size = 0.3, -- 30% of the window
        },
      },
    },
  },
  keys = {
    { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics" },
    { "<leader>xd", "<cmd>Trouble diagnostics toggle<cr>", desc = "[D]iagnostics" },
    { "<leader>xD", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer [D]iagnostics" },
    { "<leader>xs", "<cmd>Trouble symbols toggle<cr>", desc = "[S]ymbols" },
    { "<leader>xt", "<cmd>Trouble lsp toggle<cr>", desc = "[T]oggle References" },
    { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "[L]ocation List" },
    { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "[Q]uickfix List" },
    {
      "[q",
      function()
        if require("trouble").is_open() then
          require("trouble").prev({ skip_groups = true, jump = true })
        else
          local ok, err = pcall(vim.cmd.cprev)
          if not ok then
            vim.notify(err, vim.log.levels.ERROR)
          end
        end
      end,
      desc = "Previous Trouble/Quickfix Item",
    },
    {
      "]q",
      function()
        if require("trouble").is_open() then
          require("trouble").next({ skip_groups = true, jump = true })
        else
          local ok, err = pcall(vim.cmd.cnext)
          if not ok then
            vim.notify(err, vim.log.levels.ERROR)
          end
        end
      end,
      desc = "Next Trouble/Quickfix Item",
    },
  },
}