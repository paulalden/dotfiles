vim.lsp.enable({ "lua_ls", "ruby_lsp", "bashls", "yamlls", "ts_ls", "cssls", "html", "jsonls", "dockerls", "eslint" })

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end

    -- NOTE: Disable Semantic Tokens
    local lsp_groups = vim.fn.getcompletion("@lsp", "highlight")
    for _, group in ipairs(lsp_groups) do
      vim.api.nvim_set_hl(0, group, {})
    end

    -- Populate workspace diagnostics (external plugin)
    require("workspace-diagnostics").populate_workspace_diagnostics(client, vim.api.nvim_get_current_buf())

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