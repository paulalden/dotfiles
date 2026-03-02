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
    if client.supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
    end

    -- Highlight references of symbol under cursor
    if client.supports_method("textDocument/documentHighlight") then
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
    if client.supports_method("textDocument/codeLens") then
      vim.lsp.codelens.refresh()
      vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
        buffer = ev.buf,
        callback = vim.lsp.codelens.refresh,
      })
    end

    local opts = { buffer = ev.buf, silent = true }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)

    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

    -- - grr — references
    -- - gra — code actions
    -- - grn — rename
    -- - gri — implementation
    -- - K — hover (already default since 0.10)
    -- - gO — document symbols
    -- - <C-s> (insert) — signature help
  end,
})
