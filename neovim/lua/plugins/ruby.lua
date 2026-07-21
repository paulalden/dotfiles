-- ruby: vim-ruby, endwise, rails, projectionist and neotest-rspec test keymaps
return {
  {
    "vim-ruby/vim-ruby",
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "ruby",
        callback = function()
          vim.opt_local.indentkeys:remove(".")
        end,
      })
    end,
  },
  {
    "tpope/vim-endwise",
    ft = { "ruby", "lua", "sh", "bash", "vim" },
  },
  {
    "tpope/vim-projectionist",
    lazy = true,
  },
  {
    "tpope/vim-rails",
    dependencies = { "tpope/vim-projectionist" },
    ft = { "ruby", "eruby" },
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/nvim-nio",
      "olimorris/neotest-rspec",
    },
    keys = {
      {
        "<leader>tn",
        function()
          require("neotest").run.run()
        end,
        desc = "Test nearest",
      },
      {
        "<leader>tf",
        function()
          require("neotest").run.run(vim.fn.expand("%"))
        end,
        desc = "Test file",
      },
      {
        "<leader>ts",
        function()
          require("neotest").run.run({ suite = true })
        end,
        desc = "Test suite",
      },
      {
        "<leader>to",
        function()
          require("neotest").output.open({ enter = true })
        end,
        desc = "Test output",
      },
      {
        "<leader>tS",
        function()
          require("neotest").summary.toggle()
        end,
        desc = "Test summary",
      },
    },
    opts = function()
      return {
        adapters = {
          require("neotest-rspec"),
        },
      }
    end,
  },
}
