-- nvim-colorizer: highlight colour codes in lua/sh; detaches from lazy buffers
return {
  "catgoose/nvim-colorizer.lua",
  ft = { "lua", "sh" },
  config = function()
    require("colorizer").setup({
      "lua",
      "sh",
    })

    -- Detach colorizer from lazy plugin manager buffers
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "lazy",
      callback = function()
        vim.cmd("ColorizerDetachFromBuffer")
      end,
    })
  end,
}
