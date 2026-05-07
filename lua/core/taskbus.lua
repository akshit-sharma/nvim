-- lua/core/taskbus.lua
local M = {}

-- Internal storage for task data
local data = {}

---Retrieve a value from the bus.
---In our architect model, this is a "Poll" operation that is O(1).
function M.get(name)
  return data[name] or ""
end

---Set a value in the bus. 
---Usually called by the 'resolver' in your registry.
function M.set(name, value)
  if data[name] ~= value then
    data[name] = value
    -- Notify the UI that something changed
    vim.api.nvim_exec_autocmds("User", { pattern = "TaskbusUpdate" })
  end
end

return M
