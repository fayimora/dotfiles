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
map("n", "<leader>ci", "<cmd>Telescope lsp_incoming_calls<cr>", { desc = "incoming calls" })
map("n", "<leader>tt", "<cmd>:Lspsaga term_toggle<cr>", { desc = "Toggle Terminal" })
vim.keymap.set({ "n", "t" }, "<A-t>", "<cmd>Lspsaga term_toggle<CR>", { desc = "Toggle Lspsaga terminal" })

-- M.telescope = {
-- 	n = {
-- 		["<leader>ft"] = { "<cmd>Telescope treesitter<cr>", "find treesitter" },
-- 		["<leader>fr"] = { "<cmd>Telescope lsp_references<cr>", "find references" },
-- 	},
-- }

-- Telescope mappings
local lga_shortcuts = require "telescope-live-grep-args.shortcuts"

map("n", "<leader>fg", "<cmd>Telescope live_grep_args<cr>", { desc = "grep in files" })
-- map("n", "<leader>fw", "<cmd>Telescope grep_string<cr>", { desc = "find word under cursor" })
map("n", "<leader>fw", lga_shortcuts.grep_word_under_cursor, { desc = "find word under cursor" })

map("n", "<leader>fz", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "telescope find in current buffer" })
map("n", "<leader>fq", "<cmd>Telescope quickfix<cr>", { desc = "find quickfix" })
map(
  "n",
  "<leader>fds",
  "<cmd>Telescope lsp_document_symbols ignore_symbols=variable<cr>",
  { desc = "find document symbols" }
)
map("n", "<leader>mc", "<cmd>Telescope metals commands<cr>", { desc = "Metals window" })
map("n", "gws", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", { desc = "find project symbols" })
map("n", "gi", "<cmd>Telescope lsp_implementations<cr>", { desc = "Goto Implementation" })
map("n", "gd", "<cmd>Telescope lsp_definitions<cr>", { desc = "Goto Definition" })
map("n", "<leader>fr", "<cmd>Telescope resume<cr>", { desc = "Resume pickers" })

-- Trouble mappings
map("n", "<leader>fdd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "find document diagnostics" })
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
local nvimTreeFocusOrToggle = function()
  local nvimTree = require "nvim-tree.api"
  local currentBuf = vim.api.nvim_get_current_buf()
  local currentBufFt = vim.api.nvim_get_option_value("filetype", { buf = currentBuf })
  if currentBufFt == "NvimTree" then
    nvimTree.tree.toggle()
  else
    nvimTree.tree.focus()
  end
end

map("n", "<C-n>", "<cmd>NvimTreeToggle<CR>", { desc = "nvimtree toggle window" })
-- map("n", "<leader>e", "<cmd>NvimTreeFocus<CR>", { desc = "nvimtree focus window" })
map("n", "<leader>e", nvimTreeFocusOrToggle, { desc = "nvimtree focus window" })

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

-- Nvim DAP
map("n", "<Leader>dl", "<cmd>lua require'dap'.step_into()<CR>", { desc = "Debugger step into" })
map("n", "<Leader>dj", "<cmd>lua require'dap'.step_over()<CR>", { desc = "Debugger step over" })
map("n", "<Leader>dk", "<cmd>lua require'dap'.step_out()<CR>", { desc = "Debugger step out" })
map("n", "<Leader>dc", "<cmd>lua require'dap'.continue()<CR>", { desc = "Debugger continue" })
map("n", "<Leader>db", "<cmd>lua require'dap'.toggle_breakpoint()<CR>", { desc = "Debugger toggle breakpoint" })
-- map(
--   "n",
--   "<Leader>dd",
--   "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
--   { desc = "Debugger set conditional breakpoint" }
-- )
map("n", "<Leader>de", "<cmd>lua require'dap'.terminate()<CR>", { desc = "Debugger reset" })
map("n", "<Leader>dr", "<cmd>lua require'dap'.run_last()<CR>", { desc = "Debugger run last" })

-- rustaceanvim
map("n", "<Leader>dt", "<cmd>lua vim.cmd('RustLsp testables')<CR>", { desc = "Debugger testables" })
