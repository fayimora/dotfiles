local M = {}

M.setup = function()
  require("noice").setup({
    routes = {
      {
        filter = {
          event = "msg_show",
          kind = "",
          find = "written",
        },
        opts = { skip = true },
      },
    },
  })
end

return M
