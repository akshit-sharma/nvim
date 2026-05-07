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

return M
