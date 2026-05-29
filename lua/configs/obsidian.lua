-- lua/configs/obsidian.lua
return {
  workspaces = {
    {
      name = "work",
      path = vim.fn.expand("~/obsidian"),
    },
  },
  daily_notes = {
    folder = "dailies",
    date_format = "%Y-%m-%d",
    alias_format = "%B %d, %Y",
  },
  templates = {
    folder = "templates",
    date_format = "%Y-%m-%d",
    time_format = "%H:%M",
    substitutions = {
      -- 2026 Tracking: Renders year and the strict week metric
      week_string = function()
        return os.date("%Y-W%W") -- Generates "2026-W22"
      end,
      -- Computes exact calendar date boundaries for the note headers
      week_dates = function()
        local day_num = tonumber(os.date("%w"))
        if day_num == 0 then day_num = 7 end -- Normalize Sunday
        local m_time = os.time() - ((day_num - 1) * 86400)
        local s_time = m_time + (6 * 86400)
        return os.date("%Y-%m-%d", m_time) .. " to " .. os.date("%Y-%m-%d", s_time)
      end
    }
  }
}
