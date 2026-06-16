vim.lsp.enable({
  "lua_ls",
  "ruby_lsp",
  "bashls",
  "yamlls",
  "ts_ls",
  "cssls",
  "html",
  "jsonls",
  "dockerls",
  "eslint",
})

-- Diagnostic display configuration
vim.diagnostic.config({
  virtual_text = {
    spacing = 4,
    prefix = "●",
    severity = { min = vim.diagnostic.severity.WARN },
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.HINT] = " ",
      [vim.diagnostic.severity.INFO] = " ",
    },
  },
  severity_sort = true,
  float = { border = "rounded" },
})

-- Disable LSP semantic highlights once at startup and on colorscheme change
local function disable_semantic_highlights()
  for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
    vim.api.nvim_set_hl(0, group, {})
  end
end

disable_semantic_highlights()
vim.api.nvim_create_autocmd("ColorScheme", { callback = disable_semantic_highlights })

-- Green border/title on LSP hover and other float popups
local colors = require("config.colors").colors
local function style_floats()
  vim.api.nvim_set_hl(0, "FloatBorder", { fg = colors.green })
  vim.api.nvim_set_hl(0, "FloatTitle", { fg = colors.green, bold = true })
end

style_floats()
vim.api.nvim_create_autocmd("ColorScheme", { callback = style_floats })

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end

    -- Populate workspace diagnostics (external plugin)
    pcall(function()
      require("workspace-diagnostics").populate_workspace_diagnostics(client, vim.api.nvim_get_current_buf())
    end)

    -- Enable inlay hints when supported
    if client:supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
    end

    -- Highlight references of symbol under cursor
    if client:supports_method("textDocument/documentHighlight") then
      local highlight_group = vim.api.nvim_create_augroup("local_lsp_highlight_" .. ev.buf, { clear = true })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = ev.buf,
        group = highlight_group,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        buffer = ev.buf,
        group = highlight_group,
        callback = vim.lsp.buf.clear_references,
      })
    end

    -- Code lens refresh when server supports it
    if client:supports_method("textDocument/codeLens") then
      vim.lsp.codelens.enable(true, { bufnr = ev.buf })
    end

    local opts = { buffer = ev.buf, silent = true }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)

    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

    vim.keymap.set("n", "K", function()
      vim.lsp.buf.hover({
        border = "rounded",
        max_width = 80,
        max_height = 20,
        title = " docs · <C-d>/<C-u> scroll · K focus · q close ",
        title_pos = "left",
      })
    end, opts)

    vim.keymap.set("n", "q", function()
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local cfg = vim.api.nvim_win_get_config(win)
        if cfg.relative ~= "" then
          local buf = vim.api.nvim_win_get_buf(win)
          local ft = vim.bo[buf].filetype
          if ft == "markdown" or ft == "lsp-hover" then
            vim.api.nvim_win_close(win, true)
            return
          end
        end
      end
      vim.api.nvim_feedkeys("q", "n", false)
    end, opts)

    local function scroll_hover_or(default_key)
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local cfg = vim.api.nvim_win_get_config(win)
        if cfg.relative ~= "" then
          local buf = vim.api.nvim_win_get_buf(win)
          local ft = vim.bo[buf].filetype
          if ft == "markdown" or ft == "lsp-hover" then
            vim.api.nvim_win_call(win, function()
              vim.cmd("normal! " .. vim.api.nvim_replace_termcodes(default_key, true, false, true))
            end)
            return
          end
        end
      end
      vim.cmd("normal! " .. vim.api.nvim_replace_termcodes(default_key, true, false, true))
    end

    vim.keymap.set("n", "<C-d>", function()
      scroll_hover_or("<C-d>")
    end, opts)
    vim.keymap.set("n", "<C-u>", function()
      scroll_hover_or("<C-u>")
    end, opts)

    -- - grr — references
    -- - gra — code actions
    -- - grn — rename
    -- - gri — implementation
    -- - K — hover (already default since 0.10)
    -- - gO — document symbols
    -- - <C-s> (insert) — signature help
  end,
})
