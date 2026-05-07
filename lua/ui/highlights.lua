-- lua/ui/highlights.lua
local M = {}

function M.setup()
  local is_dark = vim.o.background == "dark"

  -- Define Palettes (Based on Retrobox/Gruvbox logic)
  local colors = {
    dark = {
      green  = "#b8bb26",
      red    = "#fb4934",
      yellow = "#fabd2f",
      blue   = "#83a598",
      gray   = "#928374", -- For separators
      bg_alt = "#3c3836",
      fg_alt = "#a89984",
    },
    light = {
      green  = "#79740e",
      red    = "#9d0006",
      yellow = "#b57614",
      blue   = "#076678",
      gray   = "#7c6f64", -- For separators
      bg_alt = "#ebdbb2",
      fg_alt = "#928374",
    }
  }

  local p = is_dark and colors.dark or colors.light

  -- 1. Status & Winbar (VCS, Treesitter)
  vim.api.nvim_set_hl(0, "WinbarTSOk",      { fg = p.green, bold = true })
  vim.api.nvim_set_hl(0, "WinbarTSFail",    { fg = p.red })
  vim.api.nvim_set_hl(0, "WinbarGitAdd",    { fg = p.green })
  vim.api.nvim_set_hl(0, "WinbarGitChange", { fg = p.blue })
  vim.api.nvim_set_hl(0, "WinbarGitDelete", { fg = p.red })

  -- 2. Breadcrumbs & Winbar Elements
  -- This makes the '>' separator subtle and the filename stand out
  vim.api.nvim_set_hl(0, "WinBarSeparator", { fg = p.gray })
  vim.api.nvim_set_hl(0, "WinBarFile",      { fg = p.blue, bold = true })

  -- 3. Diagnostics (Sync with Winbar labels)
  vim.api.nvim_set_hl(0, "StatuslineError", { fg = p.red, bold = true })
  vim.api.nvim_set_hl(0, "StatuslineWarn",  { fg = p.yellow, bold = true })
  vim.api.nvim_set_hl(0, "StatuslineInfo",  { fg = p.blue })
  vim.api.nvim_set_hl(0, "StatuslineHint",  { fg = p.fg_alt })

  -- 4. Tabline (Unique Path Highlighting)
  -- Active tab gets the main blue color; inactive stays gray
  vim.api.nvim_set_hl(0, "TabLineSel", { fg = p.blue, bg = p.bg_alt, bold = true })
  vim.api.nvim_set_hl(0, "TabLine",    { fg = p.fg_alt, bg = "NONE" })

  -- 5. Folding (Zero-Glitch Contrast)
  vim.api.nvim_set_hl(0, "Folded", { bg = p.bg_alt, fg = p.fg_alt, italic = true })
end

-- Ensure highlights persist across colorscheme changes
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    M.setup()
  end,
})

return M
