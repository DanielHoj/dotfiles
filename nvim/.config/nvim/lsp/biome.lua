return {
  cmd = { "biome", "lsp-proxy" },
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
    "biome.json",
    "biome.jsonc",
    ".biome.json",
    ".biome.jsonc",
    ".git",
  },
  settings = {
    -- Configuration will be picked up from biome.json or biome.jsonc
  },
  single_file_support = true,
}
