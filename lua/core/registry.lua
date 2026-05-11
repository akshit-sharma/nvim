local M = {}
local schema = require("core.schema")
local taskbus = require("core.taskbus")

-- Buffer-local flag for performance mode
M.is_massive = function(bufnr)
  return vim.b[bufnr or 0].perf_mode == true
end

---@param id string Use schema.TaskID
---@param spec {resolver: function, events: string[], is_heavy: boolean}
function M.register_feature(id, spec)
  for _, event in ipairs(spec.events) do
    local event_name = event
    local pattern = nil

    -- Handle "User MyEvent" syntax
    if event:match("^User%s+") then
      event_name = "User"
      pattern = event:gsub("^User%s+", "")
    end

    vim.api.nvim_create_autocmd(event_name, {
      group = vim.api.nvim_create_augroup("Feature_" .. id .. "_" .. event, { clear = true }),
      pattern = pattern,
      callback = function(ev)
        if spec.is_heavy and M.is_massive(ev.buf) then
          return
        end

        vim.schedule(function()
          if not vim.api.nvim_buf_is_valid(ev.buf) then return end
          local result = spec.resolver(ev.buf)
          if result then
            taskbus.set(id, result)
          end
        end)
      end,
    })
  end
end
return M
