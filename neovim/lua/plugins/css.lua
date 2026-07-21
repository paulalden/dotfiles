-- nvim-treesitter: add css/scss parsers to ensure_installed
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "css", "scss" })
      end
    end,
  },
}
