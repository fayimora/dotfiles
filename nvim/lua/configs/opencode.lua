local M = {}

M.setup = function()
  local opencode_pane_id = nil
  local opencode_visible = false

  local function pane_exists()
    if not opencode_pane_id then
      return false
    end
    local check = vim.fn.system("tmux has-session -t " .. opencode_pane_id .. " 2>/dev/null; echo $?")
    if vim.trim(check) == "0" then
      return true
    end
    opencode_pane_id = nil
    opencode_visible = false
    return false
  end

  local function start()
    if pane_exists() and opencode_visible then
      return
    end

    if pane_exists() then
      -- Bring the hidden pane back into the current window
      vim.fn.system("tmux join-pane -h -l 35% -s " .. opencode_pane_id)
    else
      -- Create a new pane
      local result = vim.fn.system "tmux split-window -h -p 35 -P -F '#{pane_id}' 'opencode --port'"
      opencode_pane_id = vim.trim(result)
    end
    opencode_visible = true
  end

  local function stop()
    if not pane_exists() then
      return
    end
    -- Send C-c for clean shutdown, then kill the pane
    vim.fn.system("tmux send-keys -t " .. opencode_pane_id .. " C-c")
    vim.defer_fn(function()
      vim.fn.system("tmux kill-pane -t " .. opencode_pane_id)
      opencode_pane_id = nil
      opencode_visible = false
    end, 500)
  end

  local function toggle()
    if not pane_exists() then
      start()
    elseif opencode_visible then
      -- Hide the pane into a background window (keeps process alive)
      vim.fn.system("tmux break-pane -d -s " .. opencode_pane_id)
      opencode_visible = false
    else
      -- Bring it back
      vim.fn.system("tmux join-pane -h -l 35% -s " .. opencode_pane_id)
      opencode_visible = true
    end
  end

  vim.g.opencode_opts = {
    server = {
      start = start,
      stop = stop,
      toggle = toggle,
    },
  }

  -- Required for `opts.events.reload`.
  vim.o.autoread = true
end

return M
