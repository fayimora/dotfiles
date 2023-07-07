---@type MappingsTable
local M = {}

M.general = {
	n = {
		[";"] = { ":", "enter command mode", opts = { nowait = true } },
    ["<leader>gg"] = { "<cmd> LazyGit<cr>", "Open LazyGit" },
    ["<leader>lg"] = { "<cmd> LazyGit<cr>", "Open LazyGit" },
    ["gk"] = {"<cmd> lua vim.lsp.buf.hover()<cr>", "Show Documentation"},
		["gK"] = { "<cmd>lua vim.lsp.buf.signature_help()<cr>", "LSP signature help" },
    ["<leader>cf"] = { "<cmd>lua vim.lsp.buf.format()<cr>", "LSP formatting" }
	},
}

M.disabled = {
	n = {
		["<leader>h"] = "",
		["<leader>v"] = "",
		-- ["gi"] = "",

		-- ["<C-h>"] = "",
		-- ["<C-j>"] = "",
		-- ["<C-k>"] = "",
		-- ["<C-l>"] = "",

		-- ["<Up>"] = "",
		-- ["<Down>"] = "",
		-- ["<Left>"] = "",
		-- ["<Right>"] = "",
	},
}

M.telescope = {
	n = {
		["gws"] = { "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", "find project symbols" },
    ["gi"] = {"<cmd>Telescope lsp_implementations<cr>", "Goto Implementation"},
    ["gd"] = {"<cmd>Telescope lsp_definitions<cr>", "Goto Definition"},

		["<leader>ca"] = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "code actions" },
		["<leader>cr"] = { "<cmd>lua vim.lsp.buf.rename()<cr>", "LSP rename" },
		["<leader>ff"] = { "<cmd>Telescope find_files<cr>", "find files" },
		["<leader>fg"] = { "<cmd>Telescope live_grep<cr>", "find in files" },
		["<leader>fb"] = { "<cmd>Telescope buffers<cr>", "find buffers" },
		["<leader>fh"] = { "<cmd>Telescope help_tags<cr>", "find help" },
		["<leader>fo"] = { "<cmd>Telescope oldfiles<cr>", "find old files" },
		["<leader>fm"] = { "<cmd>Telescope marks<cr>", "find marks" },
		["<leader>fq"] = { "<cmd>Telescope quickfix<cr>", "find quickfix" },
		["<leader>fs"] = { "<cmd>Telescope spell_suggest<cr>", "find spell suggestions" },
		["<leader>fc"] = { "<cmd>Telescope colorscheme<cr>", "find colorscheme" },
		["<leader>ft"] = { "<cmd>Telescope treesitter<cr>", "find treesitter" },
		["<leader>fw"] = { "<cmd>Telescope grep_string<cr>", "find word under cursor" },
		["<leader>fd"] = { "<cmd>TroubleToggle<cr>", "find document diagnostics" },
		["<leader>fr"] = { "<cmd>Telescope lsp_references<cr>", "find references" },
		["<leader>fn"] = { "<cmd>Telescope lsp_document_symbols<cr>", "find document symbols" },
		["<leader>fp"] = { "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", "find project symbols" },
		["<leader>fe"] = { "<cmd>Telescope lsp_workspace_diagnostics<cr>", "find workspace diagnostics" },
    ["<leader>mc"] = {"<cmd>Telescope metals commands<cr>", "Metals window"},
	},
}
--
-- more keybinds!

return M
