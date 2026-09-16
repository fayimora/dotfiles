local web_formatters = { "oxfmt", "biome", "prettierd", stop_after_first = true }

local options = {
  formatters = {
    biome = { require_cwd = true },
    prettierd = { require_cwd = true },
    oxfmt = {
      require_cwd = true,
      cwd = require("conform.util").root_file {
        ".oxfmtrc.json",
        ".oxfmtrc.jsonc",
        "oxfmt.config.ts",
        "oxfmt.config.mts",
      },
    },
  },

  formatters_by_ft = {
    astro = { "biome", "prettierd", stop_after_first = true },
    css = web_formatters,
    html = web_formatters,
    javascript = web_formatters,
    javascriptreact = web_formatters,
    typescript = web_formatters,
    typescriptreact = web_formatters,
    json = web_formatters,
    jsonc = web_formatters,
    markdown = web_formatters,
    mdx = web_formatters,
    yaml = web_formatters,
    go = { "gofmt" },
    lua = { "stylua" },
    sh = { "shfmt" },
    rust = { "rustfmt", lsp_format = "fallback" },
  },

  format_on_save = {
    async = false,
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

require("conform").setup(options)
