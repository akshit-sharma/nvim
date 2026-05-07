local M = {}

local max_lines = 5000
local max_size = 1024 * 1024

function M.setup()
  local group = vim.api.nvim_create_augroup("GlobalPerfGuard", { clear = true })

  -- PART 1: The Initial Detector
  -- Runs once per buffer to set the permanent "Performance Mode" flag
  vim.api.nvim_create_autocmd("BufReadPre", {
    group = group,
    callback = function(ev)
      local size = vim.fn.getfsize(ev.match)
      if size > max_size or vim.api.nvim_buf_line_count(ev.buf) > max_lines then
        vim.b[ev.buf].perf_mode = true

        -- Permanent baseline for this buffer
        vim.opt_local.foldmethod = "manual"
        vim.opt_local.undofile = false
        vim.cmd("syntax off")
      end
    end,
  })

  -- PART 2: The UI Controller (Zero-Glitch relative numbers)
  -- This manages settings that are Window-local, ensuring they 
  -- only "stutter" in the active window, and never in massive files.
  vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "FocusGained" }, {
    group = group,
    callback = function(ev)
      if vim.b[ev.buf].perf_mode then
        vim.opt_local.relativenumber = false
        vim.opt_local.number = true
        return
      end

      -- Enable only for normal code buffers
      if vim.bo[ev.buf].buftype == "" then
        vim.opt_local.relativenumber = true
      end
    end,
  })

  vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave", "FocusLost" }, {
    group = group,
    callback = function()
      -- Kill relative numbers in background splits to save GPU/CPU cycles
      vim.opt_local.relativenumber = false
    end,
  })
end

return M
