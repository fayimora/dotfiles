local M = {}

local colors_path = vim.fn.expand "~/.local/state/omarchy/current/theme/colors.toml"
local signature_path = vim.g.base46_cache .. "omarchy.sha256"

local function read_file(path)
  local file = io.open(path, "rb")

  if not file then
    return ""
  end

  local content = file:read "*a"
  file:close()
  return content
end

local function signature()
  return vim.fn.sha256(read_file(colors_path))
end

local function read_compiled_signature()
  return vim.trim(read_file(signature_path))
end

local function write_compiled_signature(value)
  vim.fn.mkdir(vim.g.base46_cache, "p")
  vim.fn.writefile({ value }, signature_path)
end

local function cache_exists()
  return vim.uv.fs_stat(vim.g.base46_cache .. "defaults") ~= nil
    and vim.uv.fs_stat(vim.g.base46_cache .. "statusline") ~= nil
end

local function is_active()
  return require("nvconfig").base46.theme == "omarchy"
end

local function compile(value)
  package.loaded["themes.omarchy"] = nil
  require("base46").compile()
  write_compiled_signature(value)
end

local function reload(value)
  package.loaded["themes.omarchy"] = nil
  require("base46").load_all_highlights()
  write_compiled_signature(value)
end

function M.setup()
  if not is_active() then
    return
  end

  M.current_signature = signature()

  if not cache_exists() or read_compiled_signature() ~= M.current_signature then
    local ok, err = pcall(compile, M.current_signature)

    if not ok then
      vim.notify("Could not compile Omarchy theme: " .. err, vim.log.levels.ERROR)
    end
  end

  local group = vim.api.nvim_create_augroup("OmarchyThemeSync", { clear = true })

  vim.api.nvim_create_autocmd("FocusGained", {
    group = group,
    callback = function()
      if not is_active() then
        return
      end

      local next_signature = signature()

      if next_signature == M.current_signature then
        return
      end

      local ok, err = pcall(reload, next_signature)

      if ok then
        M.current_signature = next_signature
      else
        vim.notify("Could not reload Omarchy theme: " .. err, vim.log.levels.ERROR)
      end
    end,
  })
end

return M
