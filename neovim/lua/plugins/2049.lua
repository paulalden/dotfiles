return {
  dir = "~/Personal/Repos/2049.nvim",
  lazy = false,
  priority = 1000,
  enabled = false,
  config = function()
    require("2049").setup({})
    vim.cmd.colorscheme("2049")
  end,
}