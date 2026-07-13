require "nvchad.mappings"

local map = vim.keymap.set

-- General mappings
map("n", "0", "^", { desc = "go to first character" })
map("n", "^", "0", { desc = "go to start of line" })
map("n", ";", ":", { desc = "enter command mode" })
map("n", "<leader>dd", "<cmd>lua vim.diagnostic.open_float()<cr>", { desc = "Open float" })

-- Git mappings
map("n", "<leader>gg", function()
  Snacks.lazygit()
end, { desc = "Lazygit" })
map("n", "<leader>gl", function()
  Snacks.lazygit.log()
end, { desc = "Lazygit repository log" })
map("n", "<leader>gf", function()
  Snacks.lazygit.log_file()
end, { desc = "Lazygit current file log" })
map("n", "<leader>gnh", "<cmd>Gitsigns next_hunk<cr>", { desc = "Gitsigns next hunk" })
map("n", "<leader>gph", "<cmd>Gitsigns prev_hunk<cr>", { desc = "Gitsigns previous hunk" })

-- Lsp mappings
map("n", "gk", "<cmd>lua vim.lsp.buf.hover()<cr>", { desc = "show documentaion" })
map("n", "gK", "<cmd>lua vim.lsp.buf.signature_help()<cr>", { desc = "LSP signature help" })
map("n", "<leader>cr", "<cmd>lua vim.lsp.buf.rename()<cr>", { desc = "LSP rename" })
map("n", "<leader>cf", "<cmd>lua conform.format()<cr>", { desc = "LSP formatting" })

-- Lspsaga mappings
map("n", "gp", "<cmd>Lspsaga peek_definition<cr>", { desc = "Peek definition" })
map("n", "gt", "<cmd>Lspsaga goto_type_definition<cr>", { desc = "Goto type definition" })
map("n", "<leader>ca", "<cmd>Lspsaga code_action<cr>", { desc = "code actions" })
map("n", "<leader>ci", function() Snacks.picker.lsp_incoming_calls() end, { desc = "find incoming calls" })
map("n", "<leader>co", function() Snacks.picker.lsp_outgoing_calls() end, { desc = "find outgoing calls" })
map("n", "<leader>tt", "<cmd>Lspsaga term_toggle<cr>", { desc = "Toggle Terminal" })
map({ "n", "t" }, "<A-t>", "<cmd>Lspsaga term_toggle<cr>", { desc = "Toggle Lspsaga terminal" })

-- Picker mappings (snacks.nvim)
-- grep tips: `pattern -- --iglob=*.lua` passes extra rg args,
-- <c-g> toggles live-grep <-> fuzzy-refine of current results
map("n", "<leader>fg", function() Snacks.picker.grep() end, { desc = "grep in files" })
map({ "n", "x" }, "<leader>fw", function() Snacks.picker.grep_word() end, { desc = "find word under cursor" })
map("n", "<leader>fz", function() Snacks.picker.lines() end, { desc = "find in current buffer" })
map("n", "<leader>fq", function() Snacks.picker.qflist() end, { desc = "find quickfix" })
-- default lsp_symbols filter already excludes variables
map("n", "<leader>fds", function() Snacks.picker.lsp_symbols() end, { desc = "find document symbols" })
map("n", "<leader>mc", function() require("metals").commands() end, { desc = "Metals commands" })
map("n", "gws", function() Snacks.picker.lsp_workspace_symbols() end, { desc = "find project symbols" })
map("n", "gi", function() Snacks.picker.lsp_implementations() end, { desc = "Goto Implementation" })
map("n", "gd", function() Snacks.picker.lsp_definitions() end, { desc = "Goto Definition" })
map("n", "<leader>fr", function() Snacks.picker.resume() end, { desc = "Resume pickers" })

-- NvChad default mappings that pointed at telescope
map("n", "<leader>ff", function() Snacks.picker.files() end, { desc = "find files" })
map("n", "<leader>fa", function() Snacks.picker.files { hidden = true, ignored = true } end, { desc = "find all files" })
map("n", "<leader>fb", function() Snacks.picker.buffers() end, { desc = "find buffers" })
map("n", "<leader>fh", function() Snacks.picker.help() end, { desc = "help pages" })
map("n", "<leader>fo", function() Snacks.picker.recent() end, { desc = "recent files" })
map("n", "<leader>ma", function() Snacks.picker.marks() end, { desc = "find marks" })
map("n", "<leader>gt", function() Snacks.picker.git_status() end, { desc = "git status" })
pcall(vim.keymap.del, "n", "<leader>pt") -- NvChad telescope terms picker (telescope removed)
pcall(vim.keymap.del, "n", "<leader>cm") -- NvChad telescope git commits picker (telescope removed)

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

map("n", "<C-n>", "<cmd>NvimTreeToggle<cr>", { desc = "nvimtree toggle window" })
-- map("n", "<leader>e", "<cmd>NvimTreeFocus<CR>", { desc = "nvimtree focus window" })
map("n", "<leader>e", nvimTreeFocusOrToggle, { desc = "nvimtree focus window" })

-- vim-easy-align
map("n", "ga", "<Plug>(EasyAlign)", { desc = "EasyAlign" })
map("x", "ga", "<Plug>(EasyAlign)", { desc = "EasyAlign" })

--nvchad/menu
-- Keyboard users
map("n", "<C-t>", function()
  require("menu").open "default"
end, {})

-- mouse users + nvimtree users!
map("n", "<RightMouse>", function()
  vim.cmd [[normal! \<RightMouse>]]

  local options = vim.bo.ft == "NvimTree" and "nvimtree" or "default"
  require("menu").open(options, { mouse = true })
end, {})

-- lazygit Toggle
map({ "n", "t" }, "<A-g>", function()
  Snacks.lazygit()
end, { desc = "lazygit Toggle" })

-- Nvim DAP
map("n", "<leader>dl", "<cmd>lua require'dap'.step_into()<cr>", { desc = "Debugger step into" })
map("n", "<leader>dj", "<cmd>lua require'dap'.step_over()<cr>", { desc = "Debugger step over" })
map("n", "<leader>dk", "<cmd>lua require'dap'.step_out()<cr>", { desc = "Debugger step out" })
map("n", "<leader>dc", "<cmd>lua require'dap'.continue()<cr>", { desc = "Debugger continue" })
map("n", "<leader>db", "<cmd>lua require'dap'.toggle_breakpoint()<cr>", { desc = "Debugger toggle breakpoint" })
-- map(
--   "n",
--   "<leader>dd",
--   "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<cr>",
--   { desc = "Debugger set conditional breakpoint" }
-- )
map("n", "<leader>de", "<cmd>lua require'dap'.terminate()<cr>", { desc = "Debugger reset" })
map("n", "<leader>dr", "<cmd>lua require'dap'.run_last()<cr>", { desc = "Debugger run last" })

-- rustaceanvim
map("n", "<leader>dt", "<cmd>lua vim.cmd('RustLsp testables')<cr>", { desc = "Debugger testables" })

-- opencode
map({ "n", "x" }, "<leader>oa", function()
  require("opencode").ask("@this: ", { submit = true })
end, { desc = "Ask opencode" })
map({ "n", "x" }, "<leader>os", function()
  require("opencode").select()
end, { desc = "Execute opencode action…" })
map({ "n", "t" }, "<leader>ot", function()
  require("opencode").toggle()
end, { desc = "Toggle opencode" })

map({ "n", "x" }, "go", function()
  return require("opencode").operator "@this "
end, { desc = "Add range to opencode", expr = true })
map("n", "goo", function()
  return require("opencode").operator "@this " .. "_"
end, { desc = "Add line to opencode", expr = true })

-- pi-mono
map("n", "<leader>pp", "<cmd>PiSend<cr>")
map("n", "<leader>ps", "<cmd>PiSendSelection<cr>")
map("n", "<leader>pb", "<cmd>PiSendBuffer<cr>")
map("n", "<leader>pi", "<cmd>PiPing<cr>")
map("n", "<leader>pf", "<cmd>PiSendFile<cr>")

map("n", "<leader>pa", "<cmd>PiAsk<cr>", { desc = "Ask pi" })
map("v", "<leader>pa", "<cmd>PiAskSelection<cr>", { desc = "Ask pi (selection)" })

-- map("n", "<S-C-u>", function()
--   require("opencode").command "session.half.page.up"
-- end, { desc = "Scroll opencode up" })
-- map("n", "<S-C-d>", function()
--   require("opencode").command "session.half.page.down"
-- end, { desc = "Scroll opencode down" })

-- You may want these if you stick with the opinionated "<C-a>" and "<C-x>" above — otherwise consider "<leader>o…".
-- map("n", "+", "<C-a>", { desc = "Increment under cursor", noremap = true })
-- map("n", "-", "<C-x>", { desc = "Decrement under cursor", noremap = true })
