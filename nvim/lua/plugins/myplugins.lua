local overrides = require "configs.overrides"

---@type NvPluginSpec[]
local plugins = {

  -- Override plugin definition options

  { import = "nvchad.blink.lazyspec" },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end, -- Override to setup mason-lspconfig
  },

  { "mason-org/mason.nvim", opts = overrides.mason },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    event = "VeryLazy",
    config = function()
      require("mason-tool-installer").setup {
        ensure_installed = overrides.mason.ensure_installed,
      }
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    opts = overrides.treesitter,
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "master",
    lazy = true,
    config = function()
      require("nvim-treesitter.configs").setup {
        textobjects = {
          select = {
            enable = true,

            -- Automatically jump forward to textobj, similar to targets.vim
            lookahead = true,

            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ["a="] = { query = "@assignment.outer", desc = "Select outer part of an assignment" },
              ["i="] = { query = "@assignment.inner", desc = "Select inner part of an assignment" },
              ["l="] = { query = "@assignment.lhs", desc = "Select left hand side of an assignment" },
              ["r="] = { query = "@assignment.rhs", desc = "Select right hand side of an assignment" },

              ["aa"] = { query = "@parameter.outer", desc = "Select outer part of a parameter/argument" },
              ["ia"] = { query = "@parameter.inner", desc = "Select inner part of a parameter/argument" },

              ["ai"] = { query = "@conditional.outer", desc = "Select outer part of a conditional" },
              ["ii"] = { query = "@conditional.inner", desc = "Select inner part of a conditional" },

              ["al"] = { query = "@loop.outer", desc = "Select outer part of a loop" },
              ["il"] = { query = "@loop.inner", desc = "Select inner part of a loop" },

              ["af"] = { query = "@call.outer", desc = "Select outer part of a function call" },
              ["if"] = { query = "@call.inner", desc = "Select inner part of a function call" },

              ["am"] = { query = "@function.outer", desc = "Select outer part of a method/function definition" },
              ["im"] = { query = "@function.inner", desc = "Select inner part of a method/function definition" },

              ["ac"] = { query = "@class.outer", desc = "Select outer part of a class" },
              ["ic"] = { query = "@class.inner", desc = "Select inner part of a class" },

              ["at"] = { query = "@element.outer", desc = "Select outer part of a tag" },
              ["it"] = { query = "@element.inner", desc = "Select inner part of a tag" },
            },
          },
          -- swap = {
          --   enable = true,
          --   swap_next = {
          --     ["<leader>na"] = "@parameter.inner", -- swap parameters/argument with next
          --     ["<leader>nm"] = "@function.outer", -- swap function with next
          --   },
          --   swap_previous = {
          --     ["<leader>pa"] = "@parameter.inner", -- swap parameters/argument with prev
          --     ["<leader>pm"] = "@function.outer", -- swap function with previous
          --   },
          -- },
          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              ["]f"] = { query = "@call.outer", desc = "Next function call start" },
              ["]m"] = { query = "@function.outer", desc = "Next method/function def start" },
              ["]c"] = { query = "@class.outer", desc = "Next class start" },
              ["]i"] = { query = "@conditional.outer", desc = "Next conditional start" },
              ["]l"] = { query = "@loop.outer", desc = "Next loop start" },

              -- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
              -- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
              ["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
              ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
            },
            goto_next_end = {
              ["]F"] = { query = "@call.outer", desc = "Next function call end" },
              ["]M"] = { query = "@function.outer", desc = "Next method/function def end" },
              ["]C"] = { query = "@class.outer", desc = "Next class end" },
              ["]I"] = { query = "@conditional.outer", desc = "Next conditional end" },
              ["]L"] = { query = "@loop.outer", desc = "Next loop end" },
            },
            goto_previous_start = {
              ["[f"] = { query = "@call.outer", desc = "Prev function call start" },
              ["[m"] = { query = "@function.outer", desc = "Prev method/function def start" },
              ["[c"] = { query = "@class.outer", desc = "Prev class start" },
              ["[i"] = { query = "@conditional.outer", desc = "Prev conditional start" },
              ["[l"] = { query = "@loop.outer", desc = "Prev loop start" },
            },
            goto_previous_end = {
              ["[F"] = { query = "@call.outer", desc = "Prev function call end" },
              ["[M"] = { query = "@function.outer", desc = "Prev method/function def end" },
              ["[C"] = { query = "@class.outer", desc = "Prev class end" },
              ["[I"] = { query = "@conditional.outer", desc = "Prev conditional end" },
              ["[L"] = { query = "@loop.outer", desc = "Prev loop end" },
            },
          },
        },
      }
    end,
  },

  {
    "windwp/nvim-ts-autotag",
    event = "VeryLazy",
    config = function()
      require("nvim-ts-autotag").setup {
        opts = {
          enable_close = true, -- Auto close tags
          enable_rename = true, -- Auto rename pairs of tags
          enable_close_on_slash = true, -- Auto close on trailing </
        },
      }
    end,
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = overrides.nvimtree,
  },

  {
    "mikavilpas/yazi.nvim",
    version = "*", -- use the latest stable version
    event = "VeryLazy",
    dependencies = {
      { "nvim-lua/plenary.nvim", lazy = true },
    },
    keys = require("configs.yazi").keys,
    opts = require("configs.yazi").opts,
    init = require("configs.yazi").init,
  },

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
      "nvim-lua/plenary.nvim",
    },
    ft = { "scala", "sbt", "java" },
    opts = function()
      local metals_config = require("metals").bare_config()
      metals_config.init_options.statusBarProvider = "off"
      metals_config.settings = {
        defaultBspToBuildTool = true,
        excludedPackages = {},
        serverProperties = { "-Xmx3g" },
        serverVersion = "latest.snapshot",
        showImplicitArguments = true,
        showInferredType = true,
        inlayHints = true,
      }

      metals_config.capabilities = require("blink.cmp").get_lsp_capabilities()
      metals_config.on_attach = function(client, bufnr)
        -- your on_attach function
        vim.keymap.set("n", "<leader>ch", function()
          if client.server_capabilities.inlayHintProvider then
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
          else
            vim.notify("Server is not an inlay_hint provider", vim.log.levels.ERROR)
          end
        end, { desc = "Toggle inlay hints" })
      end

      return metals_config
    end,
    config = function(self, metals_config)
      local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = self.ft,
        callback = function()
          require("metals").initialize_or_attach(metals_config)
        end,
        group = nvim_metals_group,
      })
    end,
  },

  {
    "supermaven-inc/supermaven-nvim",
    event = "InsertEnter",
    config = function()
      require("supermaven-nvim").setup {
        keymaps = nil,
        ignore_filetypes = { "cpp" },
        color = {
          suggestion_color = "#ffffff",
          cterm = 244,
        },
        disable_inline_completion = false, -- disables inline completion for use with cmp
        disable_keymaps = false, -- disables built in keymaps for more manual control
      }
    end,
  },

  {
    "lewis6991/gitsigns.nvim",
    event = "User FilePost",
    opts = function()
      return require "configs.gitsigns"
    end,
  },

  {
    "linrongbin16/gitlinker.nvim",
    cmd = { "GitLink", "GitLinkRaw" },
    opts = { command = { name = "GitLinkRaw" } },
    config = function(_, opts)
      require("configs.gitlinker").setup(opts)
    end,
  },

  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup {
        -- Configuration here, or leave empty to use defaults
      }
    end,
  },

  {
    "dstein64/vim-startuptime",
    cmd = "StartupTime",
  },

  {
    "Wansmer/treesj",
    keys = { "<space>mm", "<space>j", "<space>s" },
    config = function()
      require("treesj").setup {}
    end,
  },

  {
    "kevinhwang91/nvim-bqf",
    event = "VeryLazy",
    opts = {},
  },

  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {
      modes = {
        test = {
          mode = "diagnostics",
          preview = {
            type = "split",
            relative = "win",
            position = "right",
            size = 0.3,
          },
        },
      },
    },
  },

  -- NvChad core ships its own telescope spec; disable it (fully replaced by snacks picker)
  { "nvim-telescope/telescope.nvim", enabled = false },

  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      input = {},
      scroll = {},
      terminal = {
        win = {
          position = "float",
          width = 0.7,
          height = 0.7,
          border = "rounded",
        },
      },
      notifier = {
        timeout = 500,
        style = "compact",
        top_down = true,
      },
      picker = {
        layout = {
          backdrop = false,
        },
        actions = {
          -- like the built-in toggle_preview (<a-p>), but for the results list.
          -- simply hiding the list leaves its pane reserved, so swap to an
          -- input-on-top + full-width-preview layout and back instead.
          toggle_list = function(picker)
            if picker._orig_layout then
              picker:set_layout(picker._orig_layout)
              picker._orig_layout = nil
            else
              picker._orig_layout = picker.resolved_layout
              picker:set_layout {
                hidden = { "list" },
                layout = {
                  backdrop = false,
                  box = "vertical",
                  width = 0.8,
                  height = 0.8,
                  border = true,
                  title = "{title} {live} {flags}",
                  { win = "input", height = 1, border = "bottom" },
                  { win = "preview", title = "{preview}", border = "none" },
                },
              }
            end
          end,
        },
        win = {
          input = {
            keys = {
              -- prompt history in normal mode (ported from telescope config)
              ["h"] = "history_back",
              ["l"] = "history_forward",
              ["<a-l>"] = { "toggle_list", mode = { "i", "n" } },
            },
          },
        },
      },
    },
    config = function(_, opts)
      require("snacks").setup(opts)
      require("configs.gists").setup() -- :GistsList / :GistCreate via gh + snacks picker
    end,
  },

  {
    "folke/todo-comments.nvim",
    event = "BufRead",
    config = function()
      require("configs.todo").setup()
    end,
  },

  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
      "TmuxNavigatorProcessList",
    },
    keys = {
      { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
      { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
      { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
      { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
      { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
    },
  },

  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        search = {
          enabled = true,
        },
        char = {
          enabled = true,
          jump_labels = true,
        },
      },
    },
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump {
            search = {
              mode = function(str)
                return "\\<" .. str
              end,
            },
          }
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
      require("lspsaga").setup {
        outline = {
          win_width = 30,
          win_position = "left",
        },
      }
    end,
  },

  {
    -- nvim 0.10+ builtin gc/gcc commenting, made treesitter-aware (tsx, vue, svelte, ...)
    "JoosepAlviste/nvim-ts-context-commentstring",
    event = "VeryLazy",
    opts = { enable_autocmd = false },
    init = function()
      vim.g.skip_ts_context_commentstring_module = true
    end,
    config = function(_, opts)
      require("ts_context_commentstring").setup(opts)
      local get_option = vim.filetype.get_option
      vim.filetype.get_option = function(filetype, option)
        if option == "commentstring" then
          return require("ts_context_commentstring.internal").calculate_commentstring() or get_option(filetype, option)
        end
        return get_option(filetype, option)
      end
    end,
  },

  {
    "esmuellert/codediff.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    cmd = "CodeDiff",
    config = function()
      require("configs.codediff").setup()
    end,
  },

  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      -- add any options here
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("configs.noice").setup()
    end,
  },

  {
    "chrisgrieser/nvim-rip-substitute",
    cmd = "RipSubstitute",
    keys = {
      {
        "<leader>fs",
        function()
          require("rip-substitute").sub()
        end,
        mode = { "n", "x" },
        desc = " rip substitute",
      },
    },
  },

  {
    "junegunn/vim-easy-align",
    event = "VeryLazy",
  },

  { "nvchad/volt", lazy = true },
  { "nvchad/menu", lazy = true },

  {
    "nvzone/typr",
    dependencies = "nvzone/volt",
    opts = {},
    cmd = { "Typr", "TyprStats" },
  },

  {
    "mrcjkb/rustaceanvim",
    version = "^6", -- Recommended
    lazy = false, -- This plugin is already lazy
  },

  {
    "saecki/crates.nvim",
    ft = { "toml" },
    opts = {},
  },

  {
    "OXY2DEV/markview.nvim",
    lazy = false,
  },

  {
    "ziglang/zig.vim",
    ft = "zig",
    init = function()
      vim.g.zig_fmt_autosave = 0 -- conform.nvim owns formatting
    end,
  },

  {
    "carderne/pi-nvim",
    cmd = {
      "Pi",
      "PiSend",
      "PiSendFile",
      "PiSendSelection",
      "PiSendBuffer",
      "PiPing",
      "PiSessions",
    },
    config = function()
      require("pi-nvim").setup()
    end,
  },

  {
    "nickjvandyke/opencode.nvim",
    dependencies = {
      -- Recommended for `ask()` and `select()`. Configured as a top-level spec above.
      "folke/snacks.nvim",
      {
        "e-cal/opencode-tmux.nvim",
        opts = {
          options = "-h",
          focus = false,
          auto_close = false,
          allow_passthrough = false,
          find_sibling = true,
        },
      },
    },
  },
}

return plugins
