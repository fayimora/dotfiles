---@type MappingsTable
local M = {}

M.general = {
	n = {
		[";"] = { ":", "enter command mode", opts = { nowait = true } },
    ["<leader>gg"] = { "<cmd> LazyGit<cr>", "Open LazyGit" },
	},
}

M.disabled = {
	n = {
		-- ["<leader>h"] = "",
		-- ["<leader>v"] = "",

		["<C-h>"] = "",
		["<C-j>"] = "",
		["<C-k>"] = "",
		["<C-l>"] = "",

		-- ["<Up>"] = "",
		-- ["<Down>"] = "",
		-- ["<Left>"] = "",
		-- ["<Right>"] = "",
	},
}

M.telescope = {
	n = {
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
		["<leader>fd"] = { "<cmd>Telescope lsp_document_diagnostics<cr>", "find document diagnostics" },
		["<leader>fr"] = { "<cmd>Telescope lsp_references<cr>", "find references" },
		["<leader>fn"] = { "<cmd>Telescope lsp_document_symbols<cr>", "find document symbols" },
		["<leader>fl"] = { "<cmd>Telescope lsp_document_symbols<cr>", "find workspace symbols" },
		["<leader>fp"] = { "<cmd>Telescope lsp_document_symbols<cr>", "find project symbols" },
		["<leader>fa"] = { "<cmd>Telescope lsp_code_actions<cr>", "find code actions" },
		["<leader>fe"] = { "<cmd>Telescope lsp_workspace_diagnostics<cr>", "find workspace diagnostics" },
	},
}
--
-- more keybinds!

return M
