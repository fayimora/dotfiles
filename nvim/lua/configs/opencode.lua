local M = {}

M.setup = function()
  local opencode_pane_id = nil
  local opencode_visible = false

  local function preserve_view(fn)
    local win = vim.api.nvim_get_current_win()
    local view = vim.fn.winsaveview()

    fn()

    local function restore()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_call(win, function()
          vim.fn.winrestview(view)
        end)
      end
    end

    -- Restore on every VimResized until we clean up (tmux resize can fire multiple)
    local group = vim.api.nvim_create_augroup("opencode_preserve_view", { clear = true })
    vim.api.nvim_create_autocmd("VimResized", {
      group = group,
      callback = restore,
    })

    -- Final restore + cleanup after resize events settle
    vim.defer_fn(function()
      pcall(vim.api.nvim_del_augroup_by_name, "opencode_preserve_view")
      restore()
    end, 300)
  end

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

    preserve_view(function()
      if pane_exists() then
        -- Bring the hidden pane back into the current window (-d keeps focus on current pane)
        vim.fn.system("tmux join-pane -d -h -l 35% -s " .. opencode_pane_id)
      else
        -- Create a new pane (-d keeps focus on current pane)
        local result = vim.fn.system "tmux split-window -d -h -p 35 -P -F '#{pane_id}' 'opencode --port'"
        opencode_pane_id = vim.trim(result)
      end
      opencode_visible = true
    end)
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
      preserve_view(function()
        -- Hide the pane into a background window (keeps process alive)
        vim.fn.system("tmux break-pane -d -s " .. opencode_pane_id)
        opencode_visible = false
      end)
    else
      preserve_view(function()
        -- Bring it back (-d keeps focus on current pane)
        vim.fn.system("tmux join-pane -d -h -l 35% -s " .. opencode_pane_id)
        opencode_visible = true
      end)
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
