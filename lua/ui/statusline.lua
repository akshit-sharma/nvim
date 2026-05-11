-- lua/ui/statusline.lua
local M = {}
local taskbus = require("core.taskbus")
local ids = require("core.schema").TaskID

local cache = { val = "", t = 0, dirty = true }
local REFRESH_MS = 100 -- Faster refresh for the statusline

function M.get()
  local now = vim.uv.now()
  if not cache.dirty and (now - cache.t) < REFRESH_MS then
    return cache.val
  end

  local workspace = taskbus.get(ids.WORKSPACE)
  local vcs       = taskbus.get(ids.VCS)
  local diff      = taskbus.get(ids.DIFF)
  local diags     = taskbus.get(ids.DIAGS)

  cache.val = table.concat({
    " ", workspace,
    " | ", vcs,
    " | ", diff,
    " %= ", -- Spacer to center-align
    " %f ", -- File path
    " %= ", -- Spacer to right-align
    " ", diags,
    " | %l:%c ", -- Line:Column
  })

  cache.t = now
  cache.dirty = false
  return cache.val
end

function M.setup()
  vim.o.laststatus = 3
  vim.o.statusline = "%!v:lua.require('ui.statusline').get()"

  -- Invalidate cache when tasks update
  vim.api.nvim_create_autocmd("User", {
    pattern = "TaskbusUpdate",
    callback = function() cache.dirty = true end,
  })
end

return M
