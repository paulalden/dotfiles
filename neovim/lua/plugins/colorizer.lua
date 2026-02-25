return {
  "catgoose/nvim-colorizer.lua",
  ft = { "lua", "sh" },
  config = function()
    require("colorizer").setup({
      "lua",
      "sh",
    })
  end,
}
