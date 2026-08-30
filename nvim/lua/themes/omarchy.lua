local colors_path = vim.fn.expand "~/.local/state/omarchy/current/theme/colors.toml"

local fallback = {
  mode = "dark",
  accent = "#7aa2f7",
  selection = "#2f3549",
  muted = "#414868",
  background = "#1a1b26",
  dark_background = "#16161e",
  darker_background = "#111218",
  lighter_background = "#24283b",
  foreground = "#c0caf5",
  dark_foreground = "#565f89",
  light_foreground = "#a9b1d6",
  bright_foreground = "#d5d6db",
  red = "#f7768e",
  yellow = "#e0af68",
  orange = "#ff9e64",
  green = "#9ece6a",
  cyan = "#7dcfff",
  blue = "#7aa2f7",
  magenta = "#bb9af7",
  brown = "#b98d7b",
  bright_red = "#ff899d",
  bright_yellow = "#ebcb8b",
  bright_green = "#73daca",
  bright_cyan = "#b4f9f8",
  bright_blue = "#80a8fd",
  bright_magenta = "#c7a9ff",
}

local function read_palette()
  local palette = vim.deepcopy(fallback)
  local file = io.open(colors_path, "r")

  if not file then
    return palette
  end

  for line in file:lines() do
    local key, value = line:match '^%s*([%w_]+)%s*=%s*"([^"%s]+)"'

    if key == "mode" and (value == "dark" or value == "light") then
      palette.mode = value
    elseif key and value and value:match "^#%x%x%x%x%x%x$" then
      palette[key] = value
    end
  end

  file:close()
  return palette
end

local c = read_palette()
local M = {}

M.base_30 = {
  white = c.foreground,
  darker_black = c.dark_background,
  black = c.background,
  black2 = c.darker_background,
  one_bg = c.lighter_background,
  one_bg2 = c.selection,
  one_bg3 = c.muted,
  grey = c.muted,
  grey_fg = c.dark_foreground,
  grey_fg2 = c.light_foreground,
  light_grey = c.light_foreground,
  red = c.red,
  baby_pink = c.bright_red,
  pink = c.bright_magenta,
  line = c.selection,
  green = c.green,
  vibrant_green = c.bright_green,
  nord_blue = c.bright_blue,
  blue = c.blue,
  yellow = c.yellow,
  sun = c.bright_yellow,
  purple = c.magenta,
  dark_purple = c.bright_magenta,
  teal = c.cyan,
  orange = c.orange,
  cyan = c.bright_cyan,
  statusline_bg = c.dark_background,
  lightbg = c.lighter_background,
  pmenu_bg = c.accent,
  folder_bg = c.accent,
}

M.base_16 = {
  base00 = c.background,
  base01 = c.dark_background,
  base02 = c.selection,
  base03 = c.muted,
  base04 = c.dark_foreground,
  base05 = c.foreground,
  base06 = c.light_foreground,
  base07 = c.bright_foreground,
  base08 = c.red,
  base09 = c.orange,
  base0A = c.yellow,
  base0B = c.green,
  base0C = c.cyan,
  base0D = c.blue,
  base0E = c.magenta,
  base0F = c.brown,
}

M.type = c.mode
M = require("base46").override_theme(M, "omarchy")

return M
