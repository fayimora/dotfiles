local nvlsp = require "nvchad.configs.lspconfig"

local on_attach = nvlsp.on_attach
local capabilities = nvlsp.capabilities

local lspconfig = require "lspconfig"
local util = require "lspconfig/util"

nvlsp.defaults()

-- if you just want default config for the servers then put them in a table
local servers = { "bashls", "html", "cssls", "ts_ls", "clangd", "tailwindcss", "jdtls", "pylsp", "biome" }

for _, lsp in ipairs(servers) do
  -- if lsp ~= "jdtls" then
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
  -- end
end

lspconfig["gopls"].setup {
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

vim.lsp.enable(servers)
