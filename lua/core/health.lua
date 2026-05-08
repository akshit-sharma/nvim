local M = {}
local schema = require("core.schema")

function M.check()
  vim.health.start("System Integrity")

  -- The engine simply loops through categories (essentials, lsp, custom, etc.)
  for category, tool_list in pairs(schema.Tools) do
    vim.health.start("Category: " .. category:upper())
    
    for bin, desc in pairs(tool_list) do
      if vim.fn.executable(bin) == 1 then
        vim.health.ok(bin .. " is installed")
      else
        -- If it's in 'essentials', make it an ERROR. Otherwise, a WARN.
        local report = (category == "essentials") and vim.health.error or vim.health.warn
        report(bin .. " is missing", { "Required for: " .. desc })
      end
    end
  end
end

return M
