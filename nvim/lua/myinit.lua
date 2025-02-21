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

vim.opt_global.shortmess:remove "F"

vim.diagnostic.config {
  severity_sort = true,
  update_in_insert = true,
  virtual_text = false,
}

vim.filetype.add {
  -- Detect and assign filetype based on the extension of the filename
  extension = {
    mdx = "mdx",
    log = "log",
    conf = "conf",
    env = "dotenv",
    http = "http",
  },
  -- Detect and apply filetypes based on the entire filename
  filename = {
    [".env"] = "dotenv",
    ["env"] = "dotenv",
    ["tsconfig.json"] = "jsonc",
  },
  -- Detect and apply filetypes based on certain patterns of the filenames
  pattern = {
    -- match filenames like .envrc, .envrc.private
    ["%.envrc%.[%w_.-]+"] = "sh",
    -- INFO: Match filenames like - ".env.example", ".env.local" and so on
    ["%.env%.[%w_.-]+"] = "dotenv",
  },
}

vim.opt.scrolloff = 5
vim.opt.sidescrolloff = 5

-- vim.api.nvim_set_hl(0, "CmpItemKindSupermaven", { fg = "#6CC644" })
