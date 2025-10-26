vim.lsp.config["bashls"] = {
  cmd = { "bash-language-server", "start" },
  filetypes = { "sh" },
  single_file_support = true,
  settings = {
    bashIde = {
      explainshellEndpoint = "https://explainshell.com",
      shellcheckPath = "shellcheck",
      globPattern = "**/*@(.sh|.inc|.bash|.command)",
    },
  },
}