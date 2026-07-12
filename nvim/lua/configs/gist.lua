local M = {}

M.setup = function()
  require("gist").setup({
    clipboard = "+", -- The registry to use for copying the Gist URL
    platform = "github",
    platforms = {
      github = {
        private = true, -- Create secret gists by default
        list = {
          limit = 20,
        },
      },
    },
    list = {
      use_multiplexer = false,
      -- If there are multiple files in a gist you can scroll them,
      -- with vim-like bindings n/p next previous
      mappings = {
        next_file = "<C-n>",
        prev_file = "<C-p>",
      },
    },
  })
end

return M
