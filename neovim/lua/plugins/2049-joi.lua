return {
  dir = "~/Personal/Repos/joi.nvim",
  name = "joi",
  lazy = false,
  priority = 1000,
  endabled = false,
  config = function()
    require("joi").setup()
  end,
}