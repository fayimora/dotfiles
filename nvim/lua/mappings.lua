require "nvchad.mappings"

local map = vim.keymap.set

-- General mappings
map("n", "0", "^", { desc = "go to first character" })
map("n", "^", "0", { desc = "go to start of line" })
map("n", ";", ":", { desc = "enter command mode" })
map("n", "<leader>dd", "<cmd>lua vim.diagnostic.open_float()<cr>", { desc = "Open float" })

-- Git mappings
map("n", "<leader>gg", "<cmd> Neogit<cr>", { desc = "open lazygit" })
map("n", "<leader>lg", "<cmd> LazyGit<cr>", { desc = "open lazygit" })
map("n", "<leader>gnh", "<cmd> Gitsigns next_hunk<cr>", { desc = "Gitsigns next hunk" })
map("n", "<leader>gph", "<cmd> Gitsigns prev_hunk<cr>", { desc = "Gitsigns previous hunk" })

-- Lsp mappings
map("n", "gk", "<cmd>lua vim.lsp.buf.hover()<cr>", { desc = "show documentaion" })
map("n", "gK", "<cmd>lua vim.lsp.buf.signature_help()<cr>", { desc = "LSP signature help" })
map("n", "<leader>cr", "<cmd>lua vim.lsp.buf.rename()<cr>", { desc = "LSP rename" })
map("n", "<leader>cf", "<cmd>lua conform.format()<cr>", { desc = "LSP formatting" })

-- Lspsaga mappings
map("n", "gp", "<cmd>Lspsaga peek_definition<cr>", { desc = "LSP signature help" })
map("n", "gt", "<cmd>Lspsaga goto_type_definition<cr>", { desc = "LSP signature help" })
map("n", "<leader>ca", "<cmd>Lspsaga code_action<cr>", { desc = "code actions" })
map("n", "<leader>ci", "<cmd>Lspsaga incoming_calls<cr>", { desc = "incoming calls" })
map("n", "<leader>tt", "<cmd>:Lspsaga term_toggle<cr>", { desc = "Toggle Terminal" })

-- M.telescope = {
-- 	n = {
-- 		["<leader>ft"] = { "<cmd>Telescope treesitter<cr>", "find treesitter" },
-- 		["<leader>fr"] = { "<cmd>Telescope lsp_references<cr>", "find references" },
-- 	},
-- }

-- Telescope mappings
map("n", "<leader>fg", "<cmd>Telescope live_grep_args<cr>", { desc = "grep in files" })
map("n", "<leader>fw", "<cmd>Telescope grep_string<cr>", { desc = "find word under cursor" })
map("n", "<leader>fz", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "telescope find in current buffer" })
map("n", "<leader>fq", "<cmd>Telescope quickfix<cr>", { desc = "find quickfix" })
map("n", "<leader>mc", "<cmd>Telescope metals commands<cr>", { desc = "Metals window" })
map("n", "gws", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", { desc = "find project symbols" })
map("n", "gi", "<cmd>Telescope lsp_implementations<cr>", { desc = "Goto Implementation" })
map("n", "gd", "<cmd>Telescope lsp_definitions<cr>", { desc = "Goto Definition" })
map("n", "<leader>fr", "<cmd>Telescope resume<cr>", { desc = "Resume pickers" })

-- Trouble mappings
map("n", "<leader>fd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "find document diagnostics" })
map("n", "<leader>xX", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })
map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer Diagnostics (Trouble)" })
map(
  "n",
  "<leader>cs",
  "<cmd>Trouble symbols toggle focus=true pinned=true win.relative=win win.position=right<cr>",
  { desc = "Symbols (Trouble)" }
)
map(
  "n",
  "<leader>cl",
  "<cmd>Trouble lsp toggle focus=true win.position=right pinned=true win.relative=win<cr>",
  { desc = "LSP Definitions / references / ... (Trouble)" }
)
map("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>", { desc = "Location List (Trouble)" })
map("n", "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix List (Trouble)" })

-- nvimtree
map("n", "<C-n>", "<cmd>NvimTreeToggle<CR>", { desc = "nvimtree toggle window" })
map("n", "<leader>e", "<cmd>NvimTreeFocus<CR>", { desc = "nvimtree focus window" })

-- tmux.nvim
map("n", "<C-h>", '<cmd>lua require("tmux").move_left()<cr>', { desc = "tmux move left" })
map("n", "<C-l>", '<cmd>lua require("tmux").move_right()<cr>', { desc = "tmux move right" })
map("n", "<C-j>", '<cmd>lua require("tmux").move_bottom()<cr>', { desc = "tmux move down" })
map("n", "<C-k>", '<cmd>lua require("tmux").move_top()<cr>', { desc = "tmux move up" })

-- vim-easy-align
map("n", "ga", "<Plug>(EasyAlign)", { desc = "EasyAlign" })
map("x", "ga", "<Plug>(EasyAlign)", { desc = "EasyAlign" })

--nvchad/menu
-- Keyboard users
vim.keymap.set("n", "<C-t>", function()
  require("menu").open "default"
end, {})

-- mouse users + nvimtree users!
vim.keymap.set("n", "<RightMouse>", function()
  vim.cmd.exec '"normal! \\<RightMouse>"'

  local options = vim.bo.ft == "NvimTree" and "nvimtree" or "default"
  require("menu").open(options, { mouse = true })
end, {})

-- lazygit Toggle
map({ "n", "t" }, "<A-g>", function()
  require("nvchad.term").toggle {
    pos = "float",
    id = "lazygit",
    float_ops = { width = 0.7, height = 0.7 },
    cmd = "lazygit",
  }
end, { desc = "lazygit Toggle" })
