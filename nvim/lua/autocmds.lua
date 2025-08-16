require "nvchad.autocmds"

local autocmd = vim.api.nvim_create_autocmd

-- Auto resize panes when resizing nvim window
autocmd("VimResized", {
  pattern = "*",
  callback = function()
    -- vim.defer_fn(function() -- Add slight delay to avoid race conditions
    --   pcall(function() -- Wrap in pcall to prevent errors from breaking it
    --     vim.cmd "tabdo wincmd =" -- Equalize splits in all tabs
    --     vim.cmd "redraw!" -- Force UI update
    --   end)
    -- end, 50) -- 50ms delay

    vim.api.nvim_exec("tabdo wincmd =", false)
    -- vim.cmd "tabdo"
    -- vim.cmd "wincmd ="
  end,
})
