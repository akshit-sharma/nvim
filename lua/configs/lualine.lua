return function()
  require'lualine'.setup {
    options = {
      theme = 'onedark',
      section_separators = '',
      component_separators = '|',
    },
    sections = {
      lualine_a = {
        'filename'
      },
      lualine_b = {
        {'branch', fmt = function(str) return (str ~= "main" and str or ' ') end },
        'diff',
      },
      lualine_c = {
        'aerial'
      },

      lualine_x = { 'diagnostic' },
      lualine_y = {
        { 'encoding', fmt = function(str) return (str ~= "utf-8" and str or "") end },
        { 'filetype', icon_only = true, colored = true },
      },
      lualine_z = {
        'location',
        'progress',
        separator = nil,
      },
    },
    winbar = {
      lualine_c = {
        'navic',
        color_correction = nil,
        navic_opts = nil
      }
    }
  }
end
