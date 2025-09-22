return {
  "kelly-lin/ranger.nvim",
  config = function()
    local ranger_nvim = require("ranger-nvim")

    ranger_nvim.setup({
      replace_netrw = true,
      enable_cmds = false,
      keybinds = {
        ["ov"] = ranger_nvim.OPEN_MODE.vsplit,
        ["oh"] = ranger_nvim.OPEN_MODE.split,
        ["<cr>"] = ranger_nvim.OPEN_MODE.tabedit,
        ["or"] = ranger_nvim.OPEN_MODE.rifle,
      },
      ui = {
        border = "rounded",
        height = 0.9,
        width = 0.9,
        x = 0.5,
        y = 0.5,
      },
    })

    vim.keymap.set(
      "n",
      "<leader>se",
      "<cmd>lua require('ranger-nvim').open(true)<cr>",
      { silent = true, desc = "Search [E]xplore" }
    )
  end,
}
