return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason.nvim",
      { "williamboman/mason-lspconfig.nvim", config = function() end },
    },
    opts = function()
      local ret = {
        diagnostics = {
          underline = true,
          update_in_insert = false,
          virtual_text = {
            spacing = 4,
            source = "if_many",
            prefix = "●",
            -- this will set set the prefix to a function that returns the diagnostics icon based on the severity
            -- this only works on a recent 0.10.0 build. Will be set to "●" when not supported
            -- prefix = "icons",
          },
          severity_sort = true,
          signs = {
            text = {
              [vim.diagnostic.severity.ERROR] = require("config.icons").diagnostics.Error,
              [vim.diagnostic.severity.WARN] = require("config.icons").diagnostics.Warn,
              [vim.diagnostic.severity.HINT] = require("config.icons").diagnostics.Hint,
              [vim.diagnostic.severity.INFO] = require("config.icons").diagnostics.Info,
            },
          },
        },
        inlay_hints = {
          enabled = true,
          exclude = { "vue" },
        },
        codelens = {
          enabled = false,
        },
        capabilities = {
          workspace = {
            fileOperations = {
              didRename = true,
              willRename = true,
            },
          },
        },
        format = {
          formatting_options = nil,
          timeout_ms = nil,
        },
        servers = {
          lua_ls = {
            settings = {
              Lua = {
                diagnostics = {
                  globals = { "vim" },
                },
                workspace = {
                  checkThirdParty = false,
                },
                codeLens = {
                  enable = true,
                },
                completion = {
                  callSnippet = "Replace",
                },
                doc = {
                  privateName = { "^_" },
                },
                hint = {
                  enable = true,
                  setType = false,
                  paramType = true,
                  paramName = "Disable",
                  semicolon = "Disable",
                  arrayIndex = "Disable",
                },
              },
            },
          },
          ruby_lsp = {
            mason = false,
            cmd = { vim.fn.expand("~/.asdf/shims/ruby-lsp") },
            root_dir = function(fname)
              return require("lspconfig").util.root_pattern("Gemfile", ".git")(fname) or vim.fn.getcwd()
            end,
            formatter = "none",
          },
        },
      }

      return ret
    end,
  },

  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "[M]ason" } },
    build = ":MasonUpdate",
    opts_extend = { "ensure_installed" },
    opts = {
      ensure_installed = {
        "stylua",
        "shfmt",
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)
    end,
  },
}