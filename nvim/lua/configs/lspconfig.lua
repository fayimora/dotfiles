local on_attach = require("nvchad.configs.lspconfig").on_attach
local capabilities = require("nvchad.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"
local util = require "lspconfig/util"

-- if you just want default config for the servers then put them in a table
local servers = { "bashls", "html", "cssls", "ts_ls", "clangd", "tailwindcss", "jdtls", "python-lsp-server" }

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
