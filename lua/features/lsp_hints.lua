local taskbus = require('core.taskbus')
local ids = require('core.schema').TaskID
local M = {}

local function update_hints()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })

  if #clients == 0 then
    taskbus.set(ids.HINTS_DOCS, "")
    taskbus.set(ids.HINTS_PARAMS, "")
    taskbus.set(ids.HINTS_COMPL, "")
    return
  end

  -- 1. Check for Documentation (Hover) availability
  -- We check if any attached client supports hover
  local has_hover = false
  for _, client in ipairs(clients) do
    if client:supports_method("textDocument/hover") then
      has_hover = true; break
    end
  end
  taskbus.set(ids.HINTS_DOCS, has_hover and "󰈙" or "")

  -- 2. Check for Signature Help (Parameter Hints)
  -- This usually triggers when inside parentheses
  local params_available = false
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local before_cursor = line:sub(1, col)

  if before_cursor:match("%(.-$") then
    for _, client in ipairs(clients) do
      if client:supports_method("textDocument/signatureHelp") then
        params_available = true; break
      end
    end
  end
  taskbus.set(ids.HINTS_PARAMS, params_available and "󰏪" or "")

  -- 3. Check for Completion Availability
  -- Passive check: if we are typing a word or after a dot/arrow
  local can_complete = false
  if before_cursor:match("[%w_‚åÜ%.]$") then
    can_complete = true
  end
  taskbus.set(ids.HINTS_COMPL, can_complete and "󱐌" or "")
end

function M.setup()
  local group = vim.api.nvim_create_augroup("LspPassiveHints", { clear = true })

  -- Trigger on cursor movement (debounced by updatetime) or text changes
  vim.api.nvim_create_autocmd({ "CursorHold", "CursorMovedI", "InsertCharPre" }, {
    group = group,
    callback = function()
      vim.schedule(update_hints)
    end
  })
end

return M
