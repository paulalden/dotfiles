return {
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
      -- always enable unless `vim.g.lazydev_enabled = false` - this is the default
      enabled = true,
    },
  },
}