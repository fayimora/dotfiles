local function has_config(patterns)
  return function(bufnr)
    local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
    return vim.fs.find(patterns, { upward = true, path = dir })[1]
  end
end

local function is_yarn_pnp(dir)
  return vim.fs.find(".pnp.cjs", { upward = true, path = dir, type = "file" })[1] ~= nil
end

local function find_bin(bin_name)
  return function(self, ctx)
    local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(ctx.buf))

    if is_yarn_pnp(dir) then
      return "yarn"
    end

    local node_modules = vim.fs.find("node_modules", { upward = true, path = dir, type = "directory" })[1]
    if node_modules then
      local bin = node_modules .. "/.bin/" .. bin_name
      if vim.fn.executable(bin) == 1 then
        return bin
      end
    end

    vim.notify(bin_name .. " not in node_modules - run install", vim.log.levels.WARN)
    return bin_name
  end
end

local function make_args(bin_name, args)
  return function(self, ctx)
    local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(ctx.buf))
    if is_yarn_pnp(dir) then
      return vim.list_extend({ bin_name }, args)
    end
    return args
  end
end

local has_biome = has_config({ "biome.json", "biome.jsonc" })
local has_prettier = has_config({ ".prettierrc", ".prettierrc.json", ".prettierrc.js", "prettier.config.js", "prettier.config.mjs" })

local function web_formatters(bufnr)
  if has_biome(bufnr) then
    return { "biome" }
  elseif has_prettier(bufnr) then
    return { "prettier" }
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

  formatters = {
    biome = {
      command = find_bin("biome"),
      args = make_args("biome", { "format", "--stdin-file-path", "$FILENAME" }),
    },
    prettier = {
      command = find_bin("prettier"),
      args = make_args("prettier", { "--stdin-filepath", "$FILENAME" }),
    },
  },

  format_on_save = {
    async = false,
    timeout_ms = 1000,
    lsp_fallback = true,
  },
}

require("conform").setup(options)
