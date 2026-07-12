-- NvChad defaults: capabilities + on_init via vim.lsp.config("*", ...),
-- on_attach via a global LspAttach autocmd, and lua_ls setup.
require("nvchad.configs.lspconfig").defaults()

-- Note: jdtls is intentionally absent (handled by nvim-metals for java),
-- and rust_analyzer is managed by rustaceanvim.
local servers = {
  astro = {},
  bashls = {},
  biome = {},
  clangd = {},
  cssls = {},
  html = {},
  tailwindcss = {},
  ts_ls = {},
  zls = {},

  gopls = {
    root_markers = { "go.work", "go.mod", ".git" },
    settings = {
      gopls = {
        completeUnimported = true,
        usePlaceholders = true,
        analyses = {
          unusedparams = true,
          unreachable = true,
          nilness = true,
          shadow = true,
          unusedwrite = true,
        },
      },
    },
  },
}

for name, config in pairs(servers) do
  if not vim.tbl_isempty(config) then
    vim.lsp.config(name, config)
  end
  vim.lsp.enable(name)
end
