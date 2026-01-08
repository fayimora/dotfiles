local function has_config(patterns)
  return function(bufnr)
    local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
    return vim.fs.find(patterns, { upward = true, path = dir })[1]
  end
end

local has_biome = has_config({ "biome.json", "biome.jsonc" })
local has_prettier = has_config({ ".prettierrc", ".prettierrc.json", ".prettierrc.js", "prettier.config.js", "prettier.config.mjs" })

local function web_formatters(bufnr)
  if has_biome(bufnr) then
    return { "biome" }
  elseif has_prettier(bufnr) then
    return { "prettierd" }
  end
  return {}
end

local options = {
  formatters_by_ft = {
    css = web_formatters,
    html = web_formatters,
    javascript = web_formatters,
    javascriptreact = web_formatters,
    typescript = web_formatters,
    typescriptreact = web_formatters,
    json = web_formatters,
    markdown = web_formatters,
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
