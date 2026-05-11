-- lua/ui/winbar.lua
local M = {}
local taskbus = require("core.taskbus")
local ids = require("core.schema").TaskID

-- SCOPE FIX: Must be top-level local for visibility in all functions
local cache = { val = "", t = 0, dirty = true }
local REFRESH_MS = 100

function M.get()
  if vim.b.perf_mode then return "" end

  local now = vim.uv.now()
  if not cache.dirty and (now - cache.t) < REFRESH_MS then
    return cache.val
  end

  local breadcrumbs = taskbus.get(ids.BREADCRUMBS)
  local diags       = taskbus.get(ids.DIAGS_ICONS)
  local ts_status   = taskbus.get(ids.TS_STATUS)
  local lsp_status  = taskbus.get(ids.LSP)

  local h_doc   = taskbus.get(ids.HINTS_DOCS)
  local h_param = taskbus.get(ids.HINTS_PARAMS)
  local h_compl = taskbus.get(ids.HINTS_COMPL)
  local hints = string.format("%%#WinbarHints#%s%s%s%%*", h_doc, h_param, h_compl)

  local file_path = vim.fn.expand("%:t")
  local devicons_ok, devicons = pcall(require, "nvim-web-devicons")
  local f_icon = devicons_ok and devicons.get_icon(file_path, vim.fn.expand("%:e"), { default = true }) or ""

  local left = string.format(" %%#WinBarFile#%s %s%%*", f_icon, file_path)
  if breadcrumbs ~= "" then
    left = left .. " %#WinBarSeparator#>%* " .. breadcrumbs
  end

  cache.val = table.concat({
    left,
    "%=",
    hints,
    " ",
    lsp_status,
    " | ",
    diags,
    " ", ts_status,
    " %p%% ",
    " %l:%c ",
  })

  cache.t = now
  cache.dirty = false
  return cache.val
end

function M.setup()
  vim.o.winbar = "%!v:lua.require('ui.winbar').get()"

  vim.api.nvim_create_autocmd({ "CursorHold", "User" }, {
    group = vim.api.nvim_create_augroup("WinbarRefresh", { clear = true }),
    callback = function(ev)
      -- Invalidate cache on cursor pause or data update
      if ev.event == "CursorHold" or ev.pattern == "TaskbusUpdate" then
        cache.dirty = true
        vim.cmd("redrawstatus")
      end
    end,
  })
end

return M
