local M = {}

local function parse_args(args)
  local parsed = { router_type = "browse" }

  for arg in args:gmatch "%S+" do
    local key, value = arg:match "^(%w+)=(.+)$"
    if key == "remote" or key == "file" or key == "rev" then
      parsed[key] = value
    else
      parsed.router_type = arg
    end
  end

  return parsed
end

local function run_link(command_opts, remote)
  local parsed = parse_args(command_opts.args)
  local actions = require "gitlinker.actions"

  require("gitlinker").link {
    action = command_opts.bang and actions.system or actions.clipboard,
    router_type = parsed.router_type,
    remote = remote or parsed.remote,
    file = parsed.file,
    rev = parsed.rev,
    lstart = command_opts.line1,
    lend = command_opts.line2,
  }
end

local function get_remotes()
  local buffer_path = vim.api.nvim_buf_get_name(0)
  local cwd = vim.fs.root(buffer_path ~= "" and buffer_path or vim.fn.getcwd(), ".git")

  if not cwd then
    vim.notify("GitLink: not inside a Git repository", vim.log.levels.ERROR)
    return
  end

  local names = vim.fn.systemlist { "git", "-C", cwd, "remote" }
  if vim.v.shell_error ~= 0 or #names == 0 then
    vim.notify("GitLink: no Git remotes found", vim.log.levels.ERROR)
    return
  end

  local remotes = {}
  for _, name in ipairs(names) do
    local url = vim.fn.systemlist { "git", "-C", cwd, "remote", "get-url", name }
    if vim.v.shell_error == 0 then
      table.insert(remotes, { name = name, url = url[1] })
    end
  end

  if #remotes == 0 then
    vim.notify("GitLink: failed to read Git remote URLs", vim.log.levels.ERROR)
    return
  end

  return remotes
end

local function select_remote(command_opts)
  local parsed = parse_args(command_opts.args)
  if parsed.remote then
    run_link(command_opts, parsed.remote)
    return
  end

  local remotes = get_remotes()
  if not remotes then
    return
  end
  if #remotes == 1 then
    run_link(command_opts, remotes[1].name)
    return
  end

  vim.ui.select(remotes, {
    prompt = "Select Git remote",
    format_item = function(remote)
      return string.format("%s (%s)", remote.name, remote.url)
    end,
  }, function(remote)
    if remote then
      run_link(command_opts, remote.name)
    end
  end)
end

function M.setup(opts)
  require("gitlinker").setup(opts)
  vim.api.nvim_create_user_command("GitLink", select_remote, {
    nargs = "*",
    range = true,
    bang = true,
    desc = "Yank or open a Git link with remote selection",
  })
end

return M
