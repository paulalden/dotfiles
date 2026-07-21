-- windsurf.nvim: Codeium AI completion; cmp source disabled (used via blink)
return {
  {
    "Exafunction/windsurf.nvim",
    event = "InsertEnter",
    config = function()
      require("codeium").setup({
        enable_cmp_source = false,
      })
    end,
  },
}
