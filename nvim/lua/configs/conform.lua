local options = {
  formatters_by_ft = {
    css = { "biome-check", "prettierd", stop_after_first = true },
    go = { "gofmt" },
    html = { "biome-check", "prettierd", stop_after_first = true },
    javascript = { "biome-check", "prettierd", stop_after_first = true },
    javascriptreact = { "biome-check", "prettierd", stop_after_first = true },
    typescript = { "biome-check", "prettierd", stop_after_first = true },
    typescriptreact = { "biome-check", "prettierd", stop_after_first = true },
    json = { "biome-check", "prettier", stop_after_first = true },
    lua = { "stylua" },
    markdown = { "prettier" },
    sh = { "shfmt" },
    yaml = { "prettierd" },
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
