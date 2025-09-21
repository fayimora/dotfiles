local options = {
  formatters_by_ft = {
    css = { "biome-check", "prettierd" },
    go = { "gofmt" },
    html = { "biome-check", "prettierd" },
    javascript = { "biome-check", "prettierd" },
    javascriptreact = { "biome-check", "prettierd" },
    typescript = { "biome-check", "prettierd" },
    typescriptreact = { "biome-check", "prettierd" },
    json = { "biome-check", "prettier" },
    lua = { "stylua" },
    markdown = { "prettier" },
    sh = { "shfmt" },
    yaml = { "prettier" },
    rust = { "rustfmt", lsp_format = "fallback" },
  },
  format_on_save = {
    -- These options will be passed to conform.format()
    async = false,
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

require("conform").setup(options)
