-- NvChad defaults: capabilities + on_init via vim.lsp.config("*", ...),
-- on_attach via a global LspAttach autocmd, and lua_ls setup.
require("nvchad.configs.lspconfig").defaults()

local util = require "lspconfig.util"

local function typescript_sdk(_, config)
  local tsdk = util.get_typescript_server_path(config.root_dir)
  local has_server_library = tsdk ~= ""
    and (
      vim.uv.fs_stat(vim.fs.joinpath(tsdk, "typescript.js"))
      or vim.uv.fs_stat(vim.fs.joinpath(tsdk, "tsserverlibrary.js"))
    )

  if not has_server_library then
    tsdk = vim.fs.joinpath(
      vim.fn.stdpath "data",
      "mason",
      "packages",
      "typescript-language-server",
      "node_modules",
      "typescript",
      "lib"
    )
  end

  config.init_options = config.init_options or {}
  config.init_options.typescript = config.init_options.typescript or {}
  config.init_options.typescript.tsdk = tsdk
end

-- Note: jdtls is intentionally absent (handled by nvim-metals for java),
-- and rust_analyzer is managed by rustaceanvim.
local servers = {
  astro = { before_init = typescript_sdk },
  bashls = {},
  biome = {},
  clangd = {},
  cssls = {},
  html = {},
  mdx_analyzer = { before_init = typescript_sdk },
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
