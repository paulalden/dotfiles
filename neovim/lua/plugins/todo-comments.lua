-- Highlight todo, notes, etc in comments
return {
  "folke/todo-comments.nvim",
  cmd = { "TodoTrouble" },
  event = { "BufReadPost", "BufWritePost", "BufNewFile" },
  opts = {},
  -- stylua: ignore
  keys = {
    { "]t", function() require("todo-comments").jump_next() end, desc = "Todo: Next Comment" },
    { "[t", function() require("todo-comments").jump_prev() end, desc = "Todo: Previous Comment" },
    { "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "[T]odo" },
    { "<leader>xT", "<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>", desc = "[T]odo/Fix/Fixme" },
  },
}
