-- ts-comments: treesitter-aware commentstring tweaks (nvim 0.10+)
return {
  "folke/ts-comments.nvim",
  opts = {},
  event = "VeryLazy",
  enabled = vim.fn.has("nvim-0.10.0") == 1,
}
