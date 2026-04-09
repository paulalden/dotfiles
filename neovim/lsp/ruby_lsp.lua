local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.general = capabilities.general or {}
capabilities.general.positionEncodings = { "utf-8" }

return {
  cmd = { vim.fn.trim(vim.fn.system("rbenv which ruby-lsp")) },
  cmd_env = {
    BUNDLE_GEMFILE = vim.fn.expand("~/.config/nvim/ruby-lsp/Gemfile"),
  },
  root_markers = { "Gemfile", ".git", "." },
  filetypes = { "ruby" },
  capabilities = capabilities,
  offset_encoding = "utf-8",
  init_options = {
    formatter = "auto",
    linters = { "rubocop" },
    codeLens = true,
  },
  handlers = {
    ["textDocument/documentHighlight"] = function() end,
  },
}