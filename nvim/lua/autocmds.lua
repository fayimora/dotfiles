require "nvchad.autocmds"

local autocmd = vim.api.nvim_create_autocmd

autocmd("FileType", {
  pattern = "*",
  callback = function(args)
    if args.match == "dockerfile" then
      vim.treesitter.stop(args.buf)
      return
    end

    local ok, parser = pcall(vim.treesitter.get_parser, args.buf)
    if ok and parser then
      vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

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

    vim.cmd "tabdo wincmd ="
    -- vim.cmd "tabdo"
    -- vim.cmd "wincmd ="
  end,
})
