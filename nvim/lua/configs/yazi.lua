local M = {}

M.keys = {
  {
    "<leader>-",
    mode = { "n", "v" },
    "<cmd>Yazi<cr>",
    desc = "Open yazi at the current file",
  },
  {
    "<leader>cw",
    "<cmd>Yazi cwd<cr>",
    desc = "Open the file manager in nvim's working directory",
  },
  {
    "<c-up>",
    "<cmd>Yazi toggle<cr>",
    desc = "Resume the last yazi session",
  },
}

M.opts = {
  open_for_directories = false,
  keymaps = {
    show_help = "<f1>",
  },
}

M.init = function()
  -- Mark netrw as loaded so it's not loaded at all.
  -- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
  vim.g.loaded_netrwPlugin = 1
end

return M
