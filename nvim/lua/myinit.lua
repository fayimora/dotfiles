-- local autocmd = vim.api.nvim_create_autocmd

-- Auto resize panes when resizing nvim window
-- autocmd("VimResized", {
--   pattern = "*",
--   command = "tabdo wincmd =",
-- })

local hocon_group = vim.api.nvim_create_augroup("hocon", { clear = true })
vim.api.nvim_create_autocmd(
  { "BufNewFile", "BufRead" },
  { group = hocon_group, pattern = "*/resources/*.conf", command = "set ft=hocon" }
)

vim.filetype.add {
  extension = {
    ["http"] = "http",
  },
}

vim.opt_global.shortmess:remove "F"
