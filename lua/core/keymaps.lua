-- lua/core/keymaps.lua
local M = {}

function M.setup()
  -- 1. BUFFER NAVIGATION (Alt + 1-8)
  for i = 1, 8 do
    vim.keymap.set("n", string.format("<A-%d>", i), function()
      local bufs = vim.t.tab_buffers or {}
      if bufs[i] then vim.api.nvim_set_current_buf(bufs[i]) end
    end, { desc = "Jump to buffer index " .. i })
  end

  -- 2. TABPAGE NAVIGATION (t1-t8 and Alt+9/0)
  for i = 1, 8 do
    vim.keymap.set("n", "t" .. i, i .. "gt", { desc = "Switch Layout" })
  end
  vim.keymap.set("n", "<A-9>", ":tabprevious<CR>")
  vim.keymap.set("n", "<A-0>", ":tabnext<CR>")

  -- 3. SCOPED STEPPING (H/L)
  -- These stay inside the current Tab's buffer list
  local function move_scoped(direction)
    local bufs = vim.t.tab_buffers or {}
    local current = vim.api.nvim_get_current_buf()
    for i, bufnr in ipairs(bufs) do
      if bufnr == current then
        local next_idx = (i + direction - 1) % #bufs + 1
        vim.api.nvim_set_current_buf(bufs[next_idx])
        return
      end
    end
  end

  vim.keymap.set("n", "H", function() move_scoped(-1) end, { desc = "Prev Scoped Buffer" })
  vim.keymap.set("n", "L", function() move_scoped(1) end, { desc = "Next Scoped Buffer" })

  -- 4. THE "SMART CLOSE" (leader + x)
  -- Removes buffer from current tab. If it's the last tab holding it, deletes buffer.
  vim.keymap.set("n", "<A-d>", function()
    local bufnr = vim.api.nvim_get_current_buf()
    local tab_bufs = vim.t.tab_buffers or {}

    -- Remove from tab-local list
    local new_list = {}
    for _, b in ipairs(tab_bufs) do
      if b ~= bufnr then table.insert(new_list, b) end
    end
    vim.t.tab_buffers = new_list

    -- Logic: If there are other buffers in this tab, switch to one.
    -- Otherwise, if it's the last buffer in the tab, close the tab or open empty.
    if #new_list > 0 then
      vim.api.nvim_set_current_buf(new_list[#new_list])
    else
      vim.cmd("enew") -- Open empty buffer if list is empty
    end

    -- Optional: Actually delete the buffer from Neovim memory
    -- Only do this if you want it gone globally
    vim.cmd("bdelete " .. bufnr)
  end, { desc = "Smart Close Buffer" })

  -- 5. TAB MANAGEMENT
  vim.keymap.set("n", "<leader>tn", ":tabnew<CR>", { desc = "New Layout" })
  vim.keymap.set("n", "<leader>td", ":tabclose<CR>", { desc = "Close Layout" })

  -- Add to lua/core/keymaps.lua
  vim.keymap.set('n', 'h', function()
    -- foldclosed returns the start line of the fold if closed, else -1
    if vim.fn.foldclosed(vim.fn.line('.')) ~= -1 then
      return 'zO'
    end
    return 'h'
  end, { expr = true, desc = 'Recursive open fold if closed, else move left' })

  vim.keymap.set('n', 'l', function()
    -- foldclosed returns the start line of the fold if closed, else -1
    if vim.fn.foldclosed(vim.fn.line('.')) ~= -1 then
      return 'zO'
    end
    return 'l'
  end, { expr = true, desc = 'Recursive open fold if closed, else move left' })

  local move_opts = { expr = true, silent = true }

  vim.keymap.set('n', 'j', [[v:count == 0 ? 'gj' : 'j']], move_opts)
  vim.keymap.set('n', 'k', [[v:count == 0 ? 'gk' : 'k']], move_opts)
end

return M
