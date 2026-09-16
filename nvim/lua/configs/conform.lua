local web_formatters = { "biome", "prettierd", stop_after_first = true }
local web_with_oxfmt = { "oxfmt", "biome", "prettierd", stop_after_first = true }

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
    astro = web_formatters,
    css = web_with_oxfmt,
    html = web_with_oxfmt,
    javascript = web_with_oxfmt,
    javascriptreact = web_with_oxfmt,
    typescript = web_with_oxfmt,
    typescriptreact = web_with_oxfmt,
    json = { "oxfmt", "biome", stop_after_first = true },
    jsonc = { "oxfmt", "biome", stop_after_first = true },
    markdown = web_with_oxfmt,
    mdx = web_with_oxfmt,
    yaml = web_with_oxfmt,
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
