-- lua/ui/statusline.lua
local M = {}
local taskbus = require("core.taskbus")
local ids = require("core.schema").TaskID

local cache = { val = "", t = 0, dirty = true }
local REFRESH_MS = 50 -- Fast refresh for responsive mode changes

local modes = {
  ['n']      = { 'NORMAL',  'ModeNormal' },
  ['no']     = { 'O-PENDING', 'ModeNormal' },
  ['nov']    = { 'O-PENDING', 'ModeNormal' },
  ['noV']    = { 'O-PENDING', 'ModeNormal' },
  ['no\22']  = { 'O-PENDING', 'ModeNormal' },
  ['niI']    = { 'NORMAL',  'ModeNormal' },
  ['niR']    = { 'NORMAL',  'ModeNormal' },
  ['niV']    = { 'NORMAL',  'ModeNormal' },
  ['v']      = { 'VISUAL',  'ModeVisual' },
  ['vs']     = { 'VISUAL',  'ModeVisual' },
  ['V']      = { 'V-LINE',  'ModeVisual' },
  ['Vs']     = { 'V-LINE',  'ModeVisual' },
  ['\22']    = { 'V-BLOCK', 'ModeVisual' },
  ['\22s']   = { 'V-BLOCK', 'ModeVisual' },
  ['s']      = { 'SELECT',  'ModeSelect' },
  ['S']      = { 'S-LINE',  'ModeSelect' },
  ['\19']    = { 'S-BLOCK', 'ModeSelect' },
  ['i']      = { 'INSERT',  'ModeInsert' },
  ['ic']     = { 'INSERT',  'ModeInsert' },
  ['ix']     = { 'INSERT',  'ModeInsert' },
  ['R']      = { 'REPLACE', 'ModeReplace' },
  ['Rc']     = { 'REPLACE', 'ModeReplace' },
  ['Rx']     = { 'REPLACE', 'ModeReplace' },
  ['Rv']     = { 'V-REPLACE', 'ModeReplace' },
  ['Rvc']    = { 'V-REPLACE', 'ModeReplace' },
  ['Rvx']    = { 'V-REPLACE', 'ModeReplace' },
  ['c']      = { 'COMMAND', 'ModeCommand' },
  ['cv']     = { 'EX',      'ModeCommand' },
  ['ce']     = { 'EX',      'ModeCommand' },
  ['r']      = { 'PROMPT',  'ModeNormal' },
  ['rm']     = { 'MORE',    'ModeNormal' },
  ['r?']     = { 'CONFIRM', 'ModeNormal' },
  ['!']      = { 'SHELL',   'ModeCommand' },
  ['t']      = { 'TERMINAL','ModeInsert' },
}

local function get_mode()
  local m = vim.api.nvim_get_mode().mode
  local mode_info = modes[m] or { m, 'ModeNormal' }
  return string.format("%%#%s# %s %%*", mode_info[2], mode_info[1])
end

local function get_file_path()
  local buftype = vim.bo.buftype
  if buftype == "terminal" then
    return "Terminal"
  end

  local file_path = vim.api.nvim_buf_get_name(0)
  if file_path == "" then
    return "[No Name]"
  end

  return vim.fn.fnamemodify(file_path, ":~:.")
end

function M.get()
  local now = vim.uv.now()
  if not cache.dirty and (now - cache.t) < REFRESH_MS then
    return cache.val
  end

  local workspace = taskbus.get(ids.WORKSPACE) or ""
  local vcs       = taskbus.get(ids.VCS) or ""
  local diff      = taskbus.get(ids.DIFF) or ""
  local diags     = taskbus.get(ids.DIAGS) or ""

  -- Clean up empty and placeholder VCS results
  if vcs == " ..." or vcs == " " or vcs == "" then vcs = nil end
  if workspace == "" then workspace = nil end
  if diff == "" then diff = nil end
  if diags == "" then diags = nil end

  -- Left-aligned elements starting with Mode
  local left_parts = { get_mode() }
  if workspace then table.insert(left_parts, workspace) end
  if vcs then table.insert(left_parts, vcs) end
  if diff then table.insert(left_parts, diff) end

  -- Right-aligned elements
  local right_parts = {}
  if diags then table.insert(right_parts, diags) end
  
  local filetype = vim.bo.filetype
  if filetype ~= "" then
    table.insert(right_parts, string.format(" %s", filetype))
  end
  table.insert(right_parts, "%l:%c")

  local middle_part = get_file_path()

  cache.val = table.concat({
    table.concat(left_parts, " │ "),
    " %=", -- Spacer
    middle_part,
    " %=", -- Spacer
    table.concat(right_parts, " │ "),
    " "
  })

  cache.t = now
  cache.dirty = false
  return cache.val
end

function M.setup()
  vim.o.laststatus = 3
  vim.o.statusline = "%!v:lua.require('ui.statusline').get()"

  local group = vim.api.nvim_create_augroup("StatuslineRefresh", { clear = true })

  -- Invalidate cache when tasks update
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "TaskbusUpdate",
    callback = function() cache.dirty = true end,
  })

  -- Invalidate cache on buffer/window entry and redraw
  vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
    group = group,
    callback = function()
      cache.dirty = true
      vim.cmd("redrawstatus")
    end,
  })

  -- Invalidate cache on Mode changes and redraw immediately
  vim.api.nvim_create_autocmd("ModeChanged", {
    group = group,
    callback = function()
      cache.dirty = true
      vim.cmd("redrawstatus")
    end,
  })
end

return M
