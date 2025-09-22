return {
  "m4xshen/hardtime.nvim",
  lazy = false,
  dependencies = { "MunifTanjim/nui.nvim" },
  opts = {},
  config = function()
    require("hardtime").setup({
      enabled = false,
    })
  end,
}
