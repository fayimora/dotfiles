-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

-- Path to overriding theme and highlights files
local highlights = require "highlights"

M.ui = {
  telescope = { style = "bordered" },

  hl_override = highlights.override,
  hl_add = highlights.add,

  nvdash = {
    load_on_startup = true,
  },

  statusline = {
    theme = "vscode_colored",
  },
}

M.base46 = {
  theme = "tokyodark",
  theme_toggle = { "tokyodark", "onedark" },
  integrations = { "trouble", "notify", "neogit" },
}

return M
