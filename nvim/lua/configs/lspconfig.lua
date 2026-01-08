local nvlsp = require "nvchad.configs.lspconfig"

local on_attach = nvlsp.on_attach
local capabilities = nvlsp.capabilities

local util = require "lspconfig/util"

nvlsp.defaults()

local gocfg = {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_dir = util.root_pattern("go.work", "go.mod", ".git"),
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
}

local servers = {
  bashls = {},
  html = {},
  cssls = {},
  ts_ls = {},
  clangd = {},
  tailwindcss = {},
  jdtls = {},
  pylsp = {},
  biome = {},
  gopls = gocfg,
  zls = {},
}

for name, config in pairs(servers) do
  if name ~= "jdtls" then
    vim.lsp.enable(name)
    if config then
      vim.lsp.config(name, config)
    end
  end
end
