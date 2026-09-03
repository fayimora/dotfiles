local M = {}

function M.setup()
  require("nvim-treesitter-textobjects").setup {
    select = { lookahead = true },
    move = { set_jumps = true },
  }

  local select = require "nvim-treesitter-textobjects.select"
  local move = require "nvim-treesitter-textobjects.move"

  local function map_select(keys, query, desc)
    vim.keymap.set({ "x", "o" }, keys, function()
      select.select_textobject(query, "textobjects")
    end, { desc = desc })
  end

  local function map_move(keys, method, query, desc, query_group)
    vim.keymap.set({ "n", "x", "o" }, keys, function()
      move[method](query, query_group or "textobjects")
    end, { desc = desc })
  end

  for _, mapping in ipairs {
    { "a=", "@assignment.outer", "Select outer part of an assignment" },
    { "i=", "@assignment.inner", "Select inner part of an assignment" },
    { "l=", "@assignment.lhs", "Select left hand side of an assignment" },
    { "r=", "@assignment.rhs", "Select right hand side of an assignment" },
    { "aa", "@parameter.outer", "Select outer part of a parameter/argument" },
    { "ia", "@parameter.inner", "Select inner part of a parameter/argument" },
    { "ai", "@conditional.outer", "Select outer part of a conditional" },
    { "ii", "@conditional.inner", "Select inner part of a conditional" },
    { "al", "@loop.outer", "Select outer part of a loop" },
    { "il", "@loop.inner", "Select inner part of a loop" },
    { "af", "@call.outer", "Select outer part of a function call" },
    { "if", "@call.inner", "Select inner part of a function call" },
    { "am", "@function.outer", "Select outer part of a method/function definition" },
    { "im", "@function.inner", "Select inner part of a method/function definition" },
    { "ac", "@class.outer", "Select outer part of a class" },
    { "ic", "@class.inner", "Select inner part of a class" },
    { "at", "@element.outer", "Select outer part of a tag" },
    { "it", "@element.inner", "Select inner part of a tag" },
  } do
    map_select(unpack(mapping))
  end

  for _, mapping in ipairs {
    { "]f", "goto_next_start", "@call.outer", "Next function call start" },
    { "]m", "goto_next_start", "@function.outer", "Next method/function def start" },
    { "]c", "goto_next_start", "@class.outer", "Next class start" },
    { "]i", "goto_next_start", "@conditional.outer", "Next conditional start" },
    { "]l", "goto_next_start", "@loop.outer", "Next loop start" },
    { "]s", "goto_next_start", "@local.scope", "Next scope", "locals" },
    { "]z", "goto_next_start", "@fold", "Next fold", "folds" },
    { "]F", "goto_next_end", "@call.outer", "Next function call end" },
    { "]M", "goto_next_end", "@function.outer", "Next method/function def end" },
    { "]C", "goto_next_end", "@class.outer", "Next class end" },
    { "]I", "goto_next_end", "@conditional.outer", "Next conditional end" },
    { "]L", "goto_next_end", "@loop.outer", "Next loop end" },
    { "[f", "goto_previous_start", "@call.outer", "Prev function call start" },
    { "[m", "goto_previous_start", "@function.outer", "Prev method/function def start" },
    { "[c", "goto_previous_start", "@class.outer", "Prev class start" },
    { "[i", "goto_previous_start", "@conditional.outer", "Prev conditional start" },
    { "[l", "goto_previous_start", "@loop.outer", "Prev loop start" },
    { "[F", "goto_previous_end", "@call.outer", "Prev function call end" },
    { "[M", "goto_previous_end", "@function.outer", "Prev method/function def end" },
    { "[C", "goto_previous_end", "@class.outer", "Prev class end" },
    { "[I", "goto_previous_end", "@conditional.outer", "Prev conditional end" },
    { "[L", "goto_previous_end", "@loop.outer", "Prev loop end" },
  } do
    map_move(unpack(mapping))
  end
end

return M
