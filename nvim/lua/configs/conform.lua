local options = {
  formatters_by_ft = {
    css = { "prettier" },
    go = { "gofmt" },
    html = { "prettier" },
    javascript = { "prettierd", "prettier", stop_after_first = true },
    javascriptreact = { "prettierd", "prettier", stop_after_first = true },
    json = { "prettier" },
    lua = { "stylua" },
    markdown = { "prettier" },
    python = { "isort", "black" },
    -- scala = { "scalafmt" },
    sh = { "beautysh", "shfmt" },
    typescript = { "prettierd", "prettier", stop_after_first = true },
    typescriptreact = { "prettierd", "prettier", stop_after_first = true },
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
