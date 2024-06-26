---@type ChadrcConfig
local M = {}

-- Path to overriding theme and highlights files
local highlights = require "highlights"

M.ui = {
  theme = "onedark",
  theme_toggle = { "onedark", "one_light" },
  telescope = { style = "bordered" },

  hl_override = highlights.override,
  hl_add = highlights.add,

  nvdash = {
    load_on_startup = true
  },

  statusline = {
    theme = "vscode_colored",
  },

}

M.base46 = {
  integrations = { "trouble", "notify", "neogit" },
}

-- M.plugins = "plugins"

-- check core.mappings for table structure
-- M.mappings = require "mappings"

return M
