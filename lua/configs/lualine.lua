return function()
  local ok, navic = pcall(require, 'nvim-navic')
  if not ok then
    vim.notify('lualine: navic not found', vim.log.levels.WARN)
  end
  local location = function()
    return navic.get_location()
  end
  local available = function()
    if ok then
      return navic and navic.is_available()
    else
      return false
    end
  end
  local function getWindowId()
    return vim.fn.win_getid()
  end
  require'lualine'.setup {
    options = {
      theme = 'onedark',
      section_separators = '',
      component_separators = '|',
    },
    sections = {
      lualine_a = {
        {'branch', fmt = function(str) return (str ~= "main" and str or ' ') end },
      },
      lualine_b = {
        'diff',
      },
      lualine_c = {
        'aerial'
      },

      lualine_x = {
      },
      lualine_y = {
        { 'encoding', fmt = function(str) return (str ~= "utf-8" and str or "") end },
      },
      lualine_z = {
        'location',
        'progress',
        separator = nil,
      },
    },
    winbar = {
      lualine_a = { getWindowId },
      lualine_c = {
        { location, cond = available },
      },
      lualine_x = { 'diagnostics' },
      lualine_y = {
        {'filetype', icon_only = true}
      },
      lualine_z = { 'filename' },
    },
    inactive_winbar = {
      lualine_a = { getWindowId },
      lualine_x = { 'diagnostics' },
      lualine_z = { 'filename' },
    },
  }
end
