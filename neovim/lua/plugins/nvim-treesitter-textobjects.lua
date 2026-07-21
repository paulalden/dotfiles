-- treesitter-textobjects: select/move/swap keymaps for functions, classes etc.
return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  branch = "main",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    require("nvim-treesitter-textobjects").setup({
      select = {
        lookahead = true,
        include_surrounding_whitespace = true,
      },
      move = {
        set_jumps = true,
      },
    })

    local select = require("nvim-treesitter-textobjects.select")
    local move = require("nvim-treesitter-textobjects.move")
    local swap = require("nvim-treesitter-textobjects.swap")

    -- select
    local select_map = {
      ["af"] = "@function.outer",
      ["if"] = "@function.inner",
      ["ac"] = "@class.outer",
      ["ic"] = "@class.inner",
      ["ab"] = "@block.outer",
      ["ib"] = "@block.inner",
    }
    for lhs, query in pairs(select_map) do
      vim.keymap.set({ "x", "o" }, lhs, function()
        select.select_textobject(query, "textobjects")
      end)
    end

    -- swap
    vim.keymap.set("n", "]a", function()
      swap.swap_next("@parameter.inner")
    end)
    vim.keymap.set("n", "[a", function()
      swap.swap_previous("@parameter.inner")
    end)

    -- move: goto next start
    vim.keymap.set({ "n", "x", "o" }, "]f", function()
      move.goto_next_start("@function.outer", "textobjects")
    end)
    vim.keymap.set({ "n", "x", "o" }, "]c", function()
      move.goto_next_start("@class.outer", "textobjects")
    end)
    vim.keymap.set({ "n", "x", "o" }, "]s", function()
      move.goto_next_start("@local.scope", "locals")
    end)
    vim.keymap.set({ "n", "x", "o" }, "]z", function()
      move.goto_next_start("@fold", "folds")
    end)

    -- move: goto next end
    vim.keymap.set({ "n", "x", "o" }, "]F", function()
      move.goto_next_end("@function.outer", "textobjects")
    end)
    vim.keymap.set({ "n", "x", "o" }, "]C", function()
      move.goto_next_end("@class.outer", "textobjects")
    end)

    -- move: goto previous start
    vim.keymap.set({ "n", "x", "o" }, "[f", function()
      move.goto_previous_start("@function.outer", "textobjects")
    end)
    vim.keymap.set({ "n", "x", "o" }, "[c", function()
      move.goto_previous_start("@class.outer", "textobjects")
    end)

    -- move: goto previous end
    vim.keymap.set({ "n", "x", "o" }, "[F", function()
      move.goto_previous_end("@function.outer", "textobjects")
    end)
    vim.keymap.set({ "n", "x", "o" }, "[C", function()
      move.goto_previous_end("@class.outer", "textobjects")
    end)
  end,
}
