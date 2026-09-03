local overrides = require "configs.overrides"

---@type NvPluginSpec[]
local plugins = {

  -- Override plugin definition options

  { import = "nvchad.blink.lazyspec" },

  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "snacks.nvim", words = { "Snacks" } },
      },
    },
  },

  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      table.insert(opts.sources.default, 1, "lazydev")
      opts.sources.providers = opts.sources.providers or {}
      opts.sources.providers.lazydev = {
        name = "LazyDev",
        module = "lazydev.integrations.blink",
        score_offset = 100,
      }
    end,
  },

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
    branch = "main",
    lazy = false,
    opts = overrides.treesitter,
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
  },

  {
    "davidmh/mdx.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    lazy = false,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    lazy = false,
    config = function()
      require("nvim-treesitter-textobjects").setup {
        select = { lookahead = true },
        move = { set_jumps = true },
      }

      local select = require "nvim-treesitter-textobjects.select"
      local move = require "nvim-treesitter-textobjects.move"

      local function map_select(keys, query, desc)
        vim.keymap.set({ "x", "o" }, keys, function()
          select.select_textobject(query, "textobjects")
        end, { desc = desc })
      end

      local function map_move(keys, method, query, desc, query_group)
        vim.keymap.set({ "n", "x", "o" }, keys, function()
          move[method](query, query_group or "textobjects")
        end, { desc = desc })
      end

      for _, mapping in ipairs {
        { "a=", "@assignment.outer", "Select outer part of an assignment" },
        { "i=", "@assignment.inner", "Select inner part of an assignment" },
        { "l=", "@assignment.lhs", "Select left hand side of an assignment" },
        { "r=", "@assignment.rhs", "Select right hand side of an assignment" },
        { "aa", "@parameter.outer", "Select outer part of a parameter/argument" },
        { "ia", "@parameter.inner", "Select inner part of a parameter/argument" },
        { "ai", "@conditional.outer", "Select outer part of a conditional" },
        { "ii", "@conditional.inner", "Select inner part of a conditional" },
        { "al", "@loop.outer", "Select outer part of a loop" },
        { "il", "@loop.inner", "Select inner part of a loop" },
        { "af", "@call.outer", "Select outer part of a function call" },
        { "if", "@call.inner", "Select inner part of a function call" },
        { "am", "@function.outer", "Select outer part of a method/function definition" },
        { "im", "@function.inner", "Select inner part of a method/function definition" },
        { "ac", "@class.outer", "Select outer part of a class" },
        { "ic", "@class.inner", "Select inner part of a class" },
        { "at", "@element.outer", "Select outer part of a tag" },
        { "it", "@element.inner", "Select inner part of a tag" },
      } do
        map_select(unpack(mapping))
      end

      for _, mapping in ipairs {
        { "]f", "goto_next_start", "@call.outer", "Next function call start" },
        { "]m", "goto_next_start", "@function.outer", "Next method/function def start" },
        { "]c", "goto_next_start", "@class.outer", "Next class start" },
        { "]i", "goto_next_start", "@conditional.outer", "Next conditional start" },
        { "]l", "goto_next_start", "@loop.outer", "Next loop start" },
        { "]s", "goto_next_start", "@local.scope", "Next scope", "locals" },
        { "]z", "goto_next_start", "@fold", "Next fold", "folds" },
        { "]F", "goto_next_end", "@call.outer", "Next function call end" },
        { "]M", "goto_next_end", "@function.outer", "Next method/function def end" },
        { "]C", "goto_next_end", "@class.outer", "Next class end" },
        { "]I", "goto_next_end", "@conditional.outer", "Next conditional end" },
        { "]L", "goto_next_end", "@loop.outer", "Next loop end" },
        { "[f", "goto_previous_start", "@call.outer", "Prev function call start" },
        { "[m", "goto_previous_start", "@function.outer", "Prev method/function def start" },
        { "[c", "goto_previous_start", "@class.outer", "Prev class start" },
        { "[i", "goto_previous_start", "@conditional.outer", "Prev conditional start" },
        { "[l", "goto_previous_start", "@loop.outer", "Prev loop start" },
        { "[F", "goto_previous_end", "@call.outer", "Prev function call end" },
        { "[M", "goto_previous_end", "@function.outer", "Prev method/function def end" },
        { "[C", "goto_previous_end", "@class.outer", "Prev class end" },
        { "[I", "goto_previous_end", "@conditional.outer", "Prev conditional end" },
        { "[L", "goto_previous_end", "@loop.outer", "Prev loop end" },
      } do
        map_move(unpack(mapping))
      end
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
      win = {
        width = 0.95,
        height = 0.95,
      },
      input = {},
      gitbrowse = {},
      scroll = {},
      terminal = {
        win = {
          position = "float",
          width = 0.7,
          height = 0.7,
          border = "rounded",
        },
      },
      lazygit = {
        win = {
          height = 0.95,
          width = 0.95,
        },
      },
      notifier = {
        timeout = 1000,
        style = "compact",
        top_down = true,
      },
      picker = {
        layout = {
          layout = {
            backdrop = false,
            width = 0.95,
            height = 0.95,
          },
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

      -- :GitLink [what] yanks a permalink to the clipboard, :GitLink! opens it
      -- in the browser (replaces gitlinker.nvim; multi-remote selection is built in)
      vim.api.nvim_create_user_command("GitLink", function(cmd)
        local yank
        if not cmd.bang then
          yank = function(url)
            vim.fn.setreg("+", url)
            Snacks.notify("Yanked " .. url, { title = "Git Browse" })
          end
        end
        Snacks.gitbrowse.open {
          what = cmd.args ~= "" and cmd.args or "permalink",
          line_start = cmd.line1,
          line_end = cmd.line2,
          open = yank,
          notify = cmd.bang,
        }
      end, {
        nargs = "?",
        range = true,
        bang = true,
        complete = function()
          return { "permalink", "file", "branch", "commit", "repo" }
        end,
        desc = "Yank a git link (! to open in browser)",
      })
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
    -- dir = vim.fn.expand("~/Code/oss/pi-nvim"), -- local checkout while the session picker changes are upstreamed
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
      require("pi-nvim").setup {
        -- session_scope = "cwd",
        -- select_session_on_send = true,
      }
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
