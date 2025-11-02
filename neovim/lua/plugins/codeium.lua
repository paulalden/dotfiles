return {
  {
    "Exafunction/codeium.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "saghen/blink.cmp", priority = 51 },
    },
    config = function()
      require("codeium").setup({
        enable_cmp_source = false,
      })
    end,
  },
}