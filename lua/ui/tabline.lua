-- lua/ui/tabline.lua
local M = {}

-- Helper: Get Icon and Unique Name
local function get_buffer_label(bufnr, all_buffers)
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == "" then return " [No Name]", "" end

  local filename = vim.fn.fnamemodify(path, ":t")
  local label = filename

  -- 1. Check for duplicates to provide unique context
  local count = 0
  for _, other_buf in ipairs(all_buffers) do
    if vim.fn.fnamemodify(vim.api.nvim_buf_get_name(other_buf), ":t") == filename then
      count = count + 1
    end
  end

  -- If duplicate found, show 'folder/file.cpp' instead of just 'file.cpp'
  if count > 1 then
    label = vim.fn.fnamemodify(path, ":h:t") .. "/" .. filename
  end

  -- 2. Get Web DevIcon (Optional: Requires nvim-web-devicons plugin)
  local has_devicons, devicons = pcall(require, "nvim-web-devicons")
  local icon = ""
  if has_devicons then
    local ext = vim.fn.fnamemodify(path, ":e")
    icon = devicons.get_icon(filename, ext, { default = true }) .. " "
  end

  return label, icon
end

function M.get()
  local parts = {}
  local current_buf = vim.api.nvim_get_current_buf()
  
  if not vim.t.tab_buffers then vim.t.tab_buffers = {} end

  -- 1. Filter and Clean
  local active_list = {}
  for _, b in ipairs(vim.t.tab_buffers) do
    if vim.api.nvim_buf_is_valid(b) and vim.bo[b].buflisted then
      table.insert(active_list, b)
    end
  end
  vim.t.tab_buffers = active_list

  -- 2. LEFT SIDE: Sequenced Buffers with Unique Names
  for i, bufnr in ipairs(active_list) do
    local name, icon = get_buffer_label(bufnr, active_list)
    local mod = vim.bo[bufnr].modified and " ●" or ""
    
    -- Highlight active
    local hl = (bufnr == current_buf) and "%#TabLineSel#" or "%#TabLine#"
    
    -- Structure: [Index] [Icon] [Name] [Mod]
    table.insert(parts, string.format("%s %d: %s%s%s ", hl, i, icon, name, mod))
  end

  table.insert(parts, "%#TabLineFill#%=")

  -- 3. RIGHT SIDE: Tabpages
  local tabs = vim.api.nvim_list_tabpages()
  if #tabs > 1 then
    local current_tab = vim.api.nvim_get_current_tabpage()
    for i, tabpage in ipairs(tabs) do
      local hl = (tabpage == current_tab) and "%#TabLineSel#" or "%#TabLine#"
      table.insert(parts, string.format("%s Tab %d ", hl, i))
    end
  end

  return table.concat(parts)
end

function M.setup()
  vim.o.showtabline = 2
  vim.o.tabline = "%!v:lua.require('ui.tabline').get()"

  vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
      local bufnr = vim.api.nvim_get_current_buf()
      if vim.bo[bufnr].buflisted and vim.bo[bufnr].buftype == "" then
        local tab_bufs = vim.t.tab_buffers or {}
        if not vim.tbl_contains(tab_bufs, bufnr) then
          table.insert(tab_bufs, bufnr)
          vim.t.tab_buffers = tab_bufs
        end
      end
    end
  })
end

return M
