-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

-- Path to overriding theme and highlights files
local highlights = require "highlights"

M.ui = {
  hl_override = highlights.override,
  hl_add = highlights.add,

  nvdash = {
    load_on_startup = true,
    -- defaults point at telescope, which is no longer installed
    buttons = {
      { txt = "  Find File", keys = "ff", cmd = "lua Snacks.picker.files()" },
      { txt = "  Recent Files", keys = "fo", cmd = "lua Snacks.picker.recent()" },
      { txt = "󰈭  Find Word", keys = "fg", cmd = "lua Snacks.picker.grep()" },
      { txt = "󱥚  Themes", keys = "th", cmd = "lua require('nvchad.themes').open()" },
      { txt = "  Mappings", keys = "ch", cmd = "NvCheatsheet" },
    },
  },
}

M.base46 = {
  theme = "tokyonight",
  theme_toggle = { "tokyonight", "onedark" },
  integrations = { "trouble", "neogit" },
}

return M
