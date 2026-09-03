local M = {}

M.treesitter = {
  ensure_installed = {
    "astro",
    "bash",
    "c",
    "css",
    "dockerfile",
    "go",
    "hocon",
    "http",
    "html",
    "java",
    "javascript",
    "json",
    "latex",
    "lua",
    "markdown",
    "markdown_inline",
    "python",
    "regex",
    "rust",
    "scala",
    "sql",
    "toml",
    "tsx",
    "typescript",
    "typst",
    "vim",
    "yaml",
    "zig",
  },
}

M.mason = {
  ensure_installed = {
    -- lua stuff
    "lua-language-server",
    "stylua",

    -- web dev stuff
    "astro-language-server",
    "biome",
    "css-lsp",
    "html-lsp",
    "typescript-language-server",
    "prettierd",
    -- "eslint",
    "tailwindcss-language-server",
    "mdx-analyzer",

    -- c/cpp stuff
    "clangd",
    "clang-format",

    -- other stuff
    "bash-language-server",
    "dockerfile-language-server",
    -- "docker-compose-language-service",
    "jsonnet-language-server",
    "jdtls",
    "helm-ls",
    "gopls",
    -- "pylsp",
    "rust-analyzer",
    "codelldb",
    "yaml-language-server",
    "gh-actions-language-server",
    "zls",
  },
}

-- git support in nvimtree
M.nvimtree = {
  git = {
    enable = true,
  },
  view = {
    side = "right",
    width = 30,
  },

  renderer = {
    highlight_git = true,
    icons = {
      show = {
        git = true,
      },
    },
  },
}

M.base46 = {
  integrations = { "neogit" },
}

return M
