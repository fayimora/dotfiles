local M = {}

M.treesitter = {
  ensure_installed = {
    "bash",
    "c",
    "css",
    "dockerfile",
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
  },
  -- autotag = {
  --   enable = true,
  -- },
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
    "css-lsp",
    "html-lsp",
    "typescript-language-server",
    "deno",
    "eslint_d",
    "prettier",
    -- "eslint",
    "tailwindcss-language-server",

    -- c/cpp stuff
    "clangd",
    "clang-format",

    -- other stuff
    "bash-language-server",
    "dockerfile-language-server",
    "docker-compose-language-service",
    "jsonnet-language-server",
    "jdtls",
    "helm-ls",
    "gopls",
    "pylsp",
    "rust-analyzer",
    "codelldb",
  },
}

-- git support in nvimtree
M.nvimtree = {
  git = {
    enable = true,
  },
  view = {
    side = "right",
    width = 50,
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
