local M = {}

M.treesitter = {
  ensure_installed = {
    "vim",
    "lua",
    "html",
    "css",
    "javascript",
    "typescript",
    "tsx",
    "c",
    "markdown",
    "markdown_inline",
    "json",
    "yaml",
    "toml",
    "bash",
    "python",
    "java",
    "scala",
  },
  autotag = {
    enable = true,
  },
  indent = {
    enable = true,
    -- disable = {
    --   "python"
    -- },
  },
}

M.mason = {
  ensure_installed = {
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

M.copilot = {
  -- Possible configurable fields can be found on:
  -- https://github.com/zbirenbaum/copilot.lua#setup-and-configuration
  suggestion = {
    enable = false,
  },
  panel = {
    enable = false,
  },
}

return M
