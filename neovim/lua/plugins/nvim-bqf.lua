-- Better quick list
return {
  "kevinhwang91/nvim-bqf",
  ft = "qf",
  config = function()
    require("bqf").setup({
      auto_enable = true,
      magic_window = true,
      auto_resize_height = true, -- highly recommended enable
      preview = {
        auto_preview = true,
        show_title = false,
        show_scroll_bar = false,
        delay_syntax = 30,
        winblend = 0,
        win_height = 20,
        win_vheight = 20,
        wrap = false,
        buf_label = true,
        border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
        should_preview_cb = function(bufnr)
          local ret = true
          local bufname = vim.api.nvim_buf_get_name(bufnr)
          local fsize = vim.fn.getfsize(bufname)

          -- skip file size greater than 100k
          if fsize > 100 * 1024 then
            ret = false

          -- skip fugitive buffer
          elseif bufname:match("^fugitive://") then
            ret = false
          end

          return ret
        end,
      },
      -- make `drop` and `tab drop` to become preferred
      func_map = {
        drop = "o",
        openc = "O",
        split = "<C-s>",
        tabdrop = "<C-t>",
        -- set to empty string to disable
        tabc = "",
        ptogglemode = "z,",
      },
      filter = {
        fzf = {
          action_for = { ["ctrl-s"] = "split", ["ctrl-t"] = "tab drop" },
          extra_opts = { "--bind", "ctrl-o:toggle-all", "--prompt", "> " },
        },
      },
    })
  end,
}
