return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local null_ls = require("null-ls")

    null_ls.setup({
      debug = false,
      sources = {
        null_ls.builtins.formatting.sql_formatter,
        null_ls.builtins.formatting.prettierd.with({
          filetypes = { "json", "markdown", "yaml" },
        }),
        null_ls.builtins.formatting.rubocop.with({
          command = "rubocop",
          args = { "--autocorrect", "--server", "-f", "quiet", "--stderr", "--stdin", "$FILENAME" },
          to_stdin = true,
        }),

        null_ls.builtins.formatting.stylua.with({
          extra_args = { "--indent-type", "Spaces", "--indent-width", "2" },
          filetypes = { "lua" },
        }),
      },

      -- Format on save (optional)
      on_attach = function(client, bufnr)
        if client.supports_method("textDocument/formatting") then
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,

            callback = function()
              vim.lsp.buf.format({ bufnr = bufnr })
            end,
          })
        end
      end,
    })

    -- Manual formatting keymap
    vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { desc = "Format buffer" })
  end,
}