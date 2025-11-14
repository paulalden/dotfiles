vim.lsp.enable({ "lua_ls", "ruby_lsp", "bashls" })

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

    -- Unset 'formatexpr'
    -- vim.bo[args.buf].formatexpr = nil
    -- Unset 'omnifunc'
    -- vim.bo[args.buf].omnifunc = nil
    -- Unmap K
    -- vim.keymap.del("n", "K", { buffer = args.buf })
    -- Disable document colors
    -- vim.lsp.document_color.enable(false, args.buf)
  end,
})