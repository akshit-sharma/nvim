local M = {}

M.TaskID = setmetatable({
  VCS      = "vcs",
  DIAGS    = "diagnostics",
  FOLDING  = "folding",
  WORKSPACE  = "workspace",
  DIFF       = "diff",
  TS_STATUS  = "treesitter_status",
  BREADCRUMBS = "breadcrumbs",
  LSP         = "lsp_status",
}, {
  __index = function(_, k)
    error(string.format("!! ARCHITECT ERROR: TaskID '%s' is not defined in schema !!", k))
  end,
  __newindex = function()
    error("!! ARCHITECT ERROR: TaskID table is read-only!!", 2)
  end
})

M.Tools = {
  essentials = {
    git = "Plugin management and version control tracking.",
    make = "Required for compiling Treesitter parsers and C++ projects.",
  },
  lsp = {
    clangd = "C/C++ language intelligence and navigation.",
    ["lua-language-server"] = "Lua development and Neovim API completion.",
  },
  -- Placeholder for other categories that can be extended
  formatters = {},
  debuggers = {},
}

return M
