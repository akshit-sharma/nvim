-- lua/features/lsp_status.lua
local taskbus = require('core.taskbus')
local ids = require('core.schema').TaskID
local M = {}

local function update_bus()
  -- 1. Check for Active Clients
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    taskbus.set(ids.LSP, "")
    return
  end

  -- 2. Fetch Native 0.10 Progress
  -- This is a non-blocking check of the internal LSP state
  local progress = vim.lsp.status()
  local names = {}
  for _, c in ipairs(clients) do table.insert(names, c.name) end
  local client_names = "[" .. table.concat(names, ",") .. "]"

  if progress ~= "" then
    taskbus.set(ids.LSP, client_names .. "  " .. progress)
  else
    taskbus.set(ids.LSP, client_names .. " ") -- Simple checkmark when idle
  end

  taskbus.set(ids.LSP, msg)
end

function M.setup()
  local group = vim.api.nvim_create_augroup("LspBusUpdater", { clear = true })

  -- Listen to LSP events: Progress, Attach, and Detach
  vim.api.nvim_create_autocmd({ "LspProgress", "LspAttach", "LspDetach", "BufEnter" }, {
    group = group,
    callback = function()
      -- Move to the next frame to avoid blocking the current one
      vim.schedule(update_bus)
    end
  })
end

return M
