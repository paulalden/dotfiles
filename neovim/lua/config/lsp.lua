vim.lsp.enable({ "lua_ls", "ruby_lsp", "bashls" })

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
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