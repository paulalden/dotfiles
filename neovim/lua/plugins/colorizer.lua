return {
  "catgoose/nvim-colorizer.lua",
  config = function()
    require("colorizer").setup({
      "lua",
      "sh",
    })
  end,
}
