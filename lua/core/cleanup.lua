-- lua/core/cleanup.lua
local registry = require("core.registry")
local ids = require("core.schema").TaskID

local M = {}

--- Scrub all "garbage" whitespace and standardise to hex 20
local function scrub_line(line)
  if not line then return "" end
  -- 1. Convert all Non-Breaking Spaces (160) to standard spaces
  local clean = line:gsub("\160", " ")
  -- 2. Strip trailing whitespace (now all standard spaces)
  return clean:gsub("%s+$", "")
end

function M.clean_range(bufnr, start_row, end_row)
  local lines = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row, false)
  local changed = false

  for i, line in ipairs(lines) do
    local new_line = scrub_line(line)
    if new_line ~= line then
      lines[i] = new_line
      changed = true
    end
  end

  if changed then
    vim.api.nvim_buf_set_lines(bufnr, start_row, end_row, false, lines)
  end
end

function M.setup()
  registry.register_feature(ids.CLEANUP, {
    is_heavy = false,
    events = { "BufWritePre" },
    resolver = function()
      M.clean_range(0, 0, -1)
      return "CLEANED"
    end,
  })

end

function M.run_on_visual_range()
  local s = vim.fn.line("v") - 1
  local e = vim.fn.line(".")
  M.clean_range(0, math.min(s, e - 1), math.max(s + 1, e))
end

return M
