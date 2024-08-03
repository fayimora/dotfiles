local M = {}

M.setup = function()
  require("noice").setup {
    messages = {
      enabled = false,
    },
    lsp = {
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
      },
      hover = {
        enabled = false,
      },
      signature = {
        enabled = false,
      },
    },
    routes = {
      {
        filter = {
          event = "msg_show",
          kind = "",
          find = "written",
        },
        opts = { skip = true },
      },

      -- always route any messages with more than 20 lines to the split view
      {
        view = "split",
        filter = { event = "msg_show", min_height = 20 },
      },
    },
  }
end

return M
