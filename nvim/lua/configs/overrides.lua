local M = {}

M.treesitter = {
  ensure_installed = {
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
    "lua",
    "markdown",
    "markdown_inline",
    "python",
    "regex",
    "rust",
    "scala",
    "toml",
    "tsx",
    "typescript",
    "vim",
    "yaml",
    "zig",
  },
  -- autotag = {
  --   enable = true,
  -- },
  highlight = {
    enable = true,
    disable = { "dockerfile" },
  },
  indent = {
    enable = true,
    -- disable = {
    --   "python"
    -- },
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<C-@>",
      node_incremental = "<C-@>",
      scope_incremental = false,
      node_decremental = "<BS>", -- BS stands for Backspace
    },
    -- keymaps = {
    --   init_selection = "gnn",
    --   node_incremental = "gnn",
    --   scope_incremental = false,
    --   node_decremental = "gnm",
    -- },
  },
}

M.mason = {
  ensure_installed = {
    "astro-language-server",
    -- lua stuff
    "lua-language-server",
    "stylua",

    -- web dev stuff
    "biome",
    "css-lsp",
    "html-lsp",
    "typescript-language-server",
    "prettierd",
    -- "eslint",
    "tailwindcss-language-server",

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
