return {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "json",
    "jsonc",
    "tsx"
  },
  root_markers = {
    "package.json",
    ".git",
  },
  single_file_support = true,
}
