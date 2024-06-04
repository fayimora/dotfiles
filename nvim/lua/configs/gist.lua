local M = {}

M.setup = function()
  require("gist").setup({
    private = true, -- All gists will be private, you won't be prompted again
    clipboard = "+", -- The registry to use for copying the Gist URL
    list = {
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
