local web_formatters = { "oxfmt", "biome", "prettierd", stop_after_first = true, lsp_format = "never" }
local oxfmt_or_prettierd = { "oxfmt", "prettierd", stop_after_first = true, lsp_format = "never" }

local options = {
  default_format_opts = {
    timeout_ms = 1000,
    lsp_format = "fallback",
  },

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
    astro = { "prettierd", lsp_format = "never" },
    css = web_formatters,
    html = oxfmt_or_prettierd,
    javascript = web_formatters,
    javascriptreact = web_formatters,
    typescript = web_formatters,
    typescriptreact = web_formatters,
    json = web_formatters,
    jsonc = web_formatters,
    markdown = oxfmt_or_prettierd,
    mdx = oxfmt_or_prettierd,
    yaml = oxfmt_or_prettierd,
    go = { "gofmt" },
    lua = { "stylua" },
    sh = { "shfmt" },
    rust = { "rustfmt" },
  },

  format_on_save = {},
}

require("conform").setup(options)
