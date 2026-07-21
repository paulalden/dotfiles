-- diffview: git diff viewer; 'dv' toggles the Diffview window
return {
  {
    "sindrets/diffview.nvim",
    keys = {
      {
        "dv",
        function()
          if next(require("diffview.lib").views) == nil then
            vim.cmd("DiffviewOpen")
          else
            vim.cmd("DiffviewClose")
          end
        end,
        desc = "Toggle Diffview window",
      },
    },
  },
}
