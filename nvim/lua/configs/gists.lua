-- Gists via the `gh` CLI + Snacks picker (replaces gist.nvim + telescope)
local M = {}

local function gist_url(id)
  return "https://gist.github.com/" .. id
end

M.defaults = {
  limit = 20, -- number of gists to fetch
}

--- Parse `gh gist list` TSV output into snacks picker items
local function gist_items(limit)
  local out = vim.fn.systemlist { "gh", "gist", "list", "--limit", tostring(limit) }
  if vim.v.shell_error ~= 0 then
    Snacks.notify.error("Could not list gists. Is `gh` installed and authenticated?", { title = "Gists" })
    return {}
  end
  local items = {}
  for _, line in ipairs(out) do
    -- id <tab> description <tab> file count <tab> visibility <tab> updated
    local fields = vim.split(line, "\t", { plain = true })
    if #fields >= 5 then
      local id, desc, files, visibility, updated = fields[1], fields[2], fields[3], fields[4], fields[5]
      items[#items + 1] = {
        text = table.concat({ desc, files, id }, " "), -- what the fuzzy matcher filters on
        gist_id = id,
        desc = desc ~= "" and desc or "(no description)",
        files = files,
        visibility = visibility,
        updated = updated,
        resolve = function(item)
          local content = vim.fn.system { "gh", "gist", "view", item.gist_id }
          item.preview = { text = content, ft = "markdown" }
        end,
      }
    end
  end
  return items
end

--- Open a gist file in a real buffer; `:w` pushes changes back to GitHub
local function edit_file(id, name, content)
  local buf = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_buf_set_name(buf, ("gist://%s/%s"):format(id, name))
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(content, "\n", { plain = true }))
  vim.bo[buf].buftype = "acwrite"
  vim.bo[buf].swapfile = false
  vim.bo[buf].modified = false
  local ft = vim.filetype.match { filename = name }
  if ft then
    vim.bo[buf].filetype = ft
  end
  vim.api.nvim_create_autocmd("BufWriteCmd", {
    buffer = buf,
    callback = function()
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      local body = vim.json.encode { files = { [name] = { content = table.concat(lines, "\n") } } }
      local res = vim.system({ "gh", "api", "gists/" .. id, "-X", "PATCH", "--input", "-" }, { stdin = body }):wait()
      if res.code ~= 0 then
        Snacks.notify.error("Failed to update gist:\n" .. (res.stderr or ""), { title = "Gists" })
      else
        vim.bo[buf].modified = false
        Snacks.notify("Updated " .. gist_url(id), { title = "Gists" })
      end
    end,
  })
  vim.api.nvim_win_set_buf(0, buf)
end

--- Edit a gist: fetches contents, picks a file if there are several
function M.edit(id)
  local out = vim.fn.system { "gh", "api", "gists/" .. id }
  if vim.v.shell_error ~= 0 then
    Snacks.notify.error("Could not fetch gist " .. id, { title = "Gists" })
    return
  end
  local data = vim.json.decode(out)
  local names = vim.tbl_keys(data.files or {})
  table.sort(names)
  if #names == 0 then
    Snacks.notify.error("Gist has no files", { title = "Gists" })
  elseif #names == 1 then
    edit_file(id, names[1], data.files[names[1]].content)
  else
    vim.ui.select(names, { prompt = "Gist file to edit" }, function(choice)
      if choice then
        edit_file(id, choice, data.files[choice].content)
      end
    end)
  end
end

--- List your gists: <cr> edits in a buffer (`:w` syncs back),
--- <c-b> opens in browser, <c-y> yanks the URL
---@param opts? { limit?: number }
function M.list(opts)
  opts = vim.tbl_extend("force", M.defaults, opts or {})
  Snacks.picker.pick {
    title = "Gists",
    items = gist_items(opts.limit),
    preview = "preview",
    format = function(item)
      return {
        { Snacks.picker.util.align(item.desc, 50), "SnacksPickerLabel" },
        { " " },
        {
          Snacks.picker.util.align(item.visibility, 8),
          item.visibility == "public" and "SnacksPickerGitStatusAdded" or "SnacksPickerComment",
        },
        { " " },
        { item.files, "SnacksPickerComment" },
      }
    end,
    confirm = function(picker, item)
      picker:close()
      if item then
        M.edit(item.gist_id)
      end
    end,
    actions = {
      yank_url = function(_, item)
        if item then
          vim.fn.setreg("+", gist_url(item.gist_id))
          Snacks.notify("Yanked " .. gist_url(item.gist_id), { title = "Gists" })
        end
      end,
      browse = function(picker, item)
        if item then
          picker:close()
          vim.ui.open(gist_url(item.gist_id))
        end
      end,
    },
    win = {
      input = {
        keys = {
          ["<c-y>"] = { "yank_url", mode = { "n", "i" } },
          ["<c-b>"] = { "browse", mode = { "n", "i" } },
        },
      },
    },
  }
end

--- Create a secret gist from the whole buffer, or the given :'<,'> range
function M.create(cmd_opts)
  local lines
  if cmd_opts and cmd_opts.range and cmd_opts.range > 0 then
    lines = vim.api.nvim_buf_get_lines(0, cmd_opts.line1 - 1, cmd_opts.line2, false)
  else
    lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  end
  local filename = vim.fn.expand "%:t"
  if filename == "" then
    filename = "snippet.txt"
  end
  vim.ui.input({ prompt = "Gist description: " }, function(desc)
    if desc == nil then
      return -- cancelled
    end
    local cmd = { "gh", "gist", "create", "--filename", filename }
    if desc ~= "" then
      vim.list_extend(cmd, { "--desc", desc })
    end
    cmd[#cmd + 1] = "-" -- read contents from stdin; gists are secret by default
    local out = vim.fn.system(cmd, table.concat(lines, "\n") .. "\n")
    if vim.v.shell_error ~= 0 then
      Snacks.notify.error("Failed to create gist:\n" .. out, { title = "Gists" })
      return
    end
    local url = out:match "https://gist%.github%.com/%S+" or vim.trim(out)
    vim.fn.setreg("+", url) -- same clipboard behaviour as the old gist.nvim config
    Snacks.notify("Created gist (URL copied): " .. url, { title = "Gists" })
  end)
end

function M.setup()
  vim.api.nvim_create_user_command("GistsList", function(o)
    -- :GistsList        -> default limit (10)
    -- :GistsList 25     -> fetch 25
    M.list { limit = tonumber(o.args) or nil }
  end, { nargs = "?", desc = "List your gists (gh + snacks)" })
  vim.api.nvim_create_user_command("GistCreate", function(o)
    M.create(o)
  end, { range = true, desc = "Create a secret gist from buffer/selection" })
end

return M
