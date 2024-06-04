local overrides = require("custom.configs.overrides")

---@type NvPluginSpec[]
local plugins = {

  -- Override plugin definition options

  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = true },
    },
    dependencies = {
      -- format & linting
      {
        "jose-elias-alvarez/null-ls.nvim",
        config = function()
          require("custom.configs.null-ls")
        end,
      },
    },
    config = function()
      require("plugins.configs.lspconfig")
      require("custom.configs.lspconfig")
    end, -- Override to setup mason-lspconfig
  },

  -- override plugin configs
  {
    "williamboman/mason.nvim",
    opts = overrides.mason,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = overrides.treesitter,
  },

  {
    "windwp/nvim-ts-autotag",
    event = "VeryLazy",
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = overrides.nvimtree,
  },

  -- Install a plugin
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    config = function()
      require("better_escape").setup()
    end,
  },

  {
    "scalameta/nvim-metals",
    dependencies = {
      "nvim-lua/popup.nvim",
      "mfussenegger/nvim-dap",
    },
    ft = { "scala", "sbt", "sc" },
    config = function()
      require("custom.configs.metals")
    end,
  },

  -- {
  --   "zbirenbaum/copilot.lua",
  --   event = "InsertEnter",
  --   opts = overrides.copilot,
  -- },

  {
    "supermaven-inc/supermaven-nvim",
    event = "InsertEnter",
    config = function()
      require("supermaven-nvim").setup({
        keymaps = {
          accept_suggestion = "<Tab>",
          clear_suggestion = "<C-]>",
          accept_word = "<C-j>",
        },
        ignore_filetypes = { cpp = true },
        color = {
          suggestion_color = "#ffffff",
          cterm = 244,
        },
        disable_inline_completion = false, -- disables inline completion for use with cmp
        disable_keymaps = false,       -- disables built in keymaps for more manual control
      })
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    -- dependencies = {
    --   {
    --     "zbirenbaum/copilot-cmp",
    --     config = function()
    --       require("copilot_cmp").setup({})
    --     end,
    --   },
    -- },
    opts = {
      sources = {
        { name = "nvim_lsp",   group_index = 2 },
        -- { name = "copilot",  group_index = 2 },
        { name = "supermaven", group_index = 2 },
        { name = "luasnip",    group_index = 2 },
        { name = "buffer",     group_index = 2 },
        { name = "nvim_lua",   group_index = 2 },
        { name = "path",       group_index = 2 },
      },
    },
  },

  {
    "kdheepak/lazygit.nvim",
    cmd = "LazyGit",
  },

  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end,
  },

  {
    "dstein64/vim-startuptime",
    cmd = "StartupTime",
  },

  {
    "Wansmer/treesj",
    -- keys = { '<space>m', '<space>j', '<space>s' },
    config = function()
      require("treesj").setup({ --[[ your config ]]
      })
    end,
  },

  {
    "kevinhwang91/nvim-bqf",
    event = "VeryLazy",
    opts = {},
  },

  {
    "f-person/git-blame.nvim",
    event = "VeryLazy",
  },

  {
    "folke/trouble.nvim",
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
  },

  {
    "nvim-telescope/telescope.nvim",
    opts = {
      extensions_list = { "themes", "terms", "fzf" },
      pickers = {
        resume = {},
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
      },
    },
    dependencies = {
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
      {
        "nvim-telescope/telescope-live-grep-args.nvim",
        -- This will not install any breaking changes.
        -- For major updates, this must be adjusted manually.
        version = "^1.0.0",
      },
    },
  },

  {
    "folke/todo-comments.nvim",
    event = "BufRead",
    config = function()
      require("custom.configs.todo").setup()
    end,
  },

  {
    "aserowy/tmux.nvim",
    keys = require("custom.configs.tmux").keys,
    config = function()
      require("custom.configs.tmux").setup()
    end,
  },

  {
    "junegunn/fzf",
    event = "VeryLazy",
    run = function()
      vim.fn["fzf#install"]()
    end,
  },

  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump({
            search = {
              mode = function(str)
                return "\\<" .. str
              end,
            },
          })
        end,
        desc = "Flash",
      },
      {
        "S",
        mode = { "n", "o", "x" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
      {
        "r",
        mode = "o",
        function()
          require("flash").remote()
        end,
        desc = "Remote Flash",
      },
      {
        "R",
        mode = { "o", "x" },
        function()
          require("flash").treesitter_search()
        end,
        desc = "Flash Treesitter Search",
      },
      {
        "<c-s>",
        mode = { "c" },
        function()
          require("flash").toggle()
        end,
        desc = "Toggle Flash Search",
      },
    },
  },

  {
    "nvimdev/lspsaga.nvim",
    event = "LspAttach",
    config = function()
      require("lspsaga").setup({
        win_width = 50,
      })
    end,
  },
  {
    "Rawnly/gist.nvim",
    cmd = { "GistCreate", "GistCreateFromFile", "GistsList" },
    -- config = true,
    config = function()
      require("custom.configs.gist").setup()
    end,
  },
  -- `GistsList` opens the selected gif in a terminal buffer,
  -- nvim-unception uses neovim remote rpc functionality to open the gist in an actual buffer
  -- and prevents neovim buffer inception
  {
    "samjwill/nvim-unception",
    lazy = false,
    init = function()
      vim.g.unception_block_while_host_edits = true
    end,
  },

  {
    "mg979/vim-visual-multi",
    lazy = false,
  },

  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    lazy = false,
    config = function()
      require("Comment").setup({
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      })
    end,
  },

  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    dependencies = {
      "sindrets/diffview.nvim",
    },
    config = function()
      require("neogit").setup()
      dofile(vim.g.base46_cache .. "neogit")
    end,
  },

  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      -- add any options here
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      require("custom.configs.noice").setup()
    end,
  },

  -- To make a plugin not be loaded
  -- {
  --   "NvChad/nvim-colorizer.lua",
  --   enabled = false
  -- },

  -- All NvChad plugins are lazy-loaded by default
  -- For a plugin to be loaded, you will need to set either `ft`, `cmd`, `keys`, `event`, or set `lazy = false`
  -- If you want a plugin to load on startup, add `lazy = false` to a plugin spec, for example
  -- {
  --   "mg979/vim-visual-multi",
  --   lazy = false,
  -- }
}

return plugins
