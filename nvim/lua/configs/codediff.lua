local M = {}

M.setup = function()
  require("codediff").setup {
    explorer = {
      position = "left", -- "left" or "bottom"
      width = 30, -- Width when position is "left" (columns)
      height = 10, -- Height when position is "bottom" (lines)
      indent_markers = true, -- Show indent markers in tree view (│, ├, └)
      icons = {
        folder_closed = "", -- Nerd Font folder icon (customize as needed)
        folder_open = "", -- Nerd Font folder-open icon
      },
      view_mode = "list", -- "list" or "tree"
      file_filter = {
        ignore = {}, -- Glob patterns to hide (e.g., {"*.lock", "dist/*"})
      },
    },
  }
end

return M
