local registry = require("core.registry")
local ids = require("core.schema").TaskID

local M = {}

-- 1. Organized Icon Registry
local Config = {
  icons = {
    namespace = "󰅩 ",
    class     = "󱞎 ",
    struct    = "󱞎 ",
    func      = "󰊕 ",
    comment   = "󰅺 ",
    default   = "󰁂 ",
  },
  -- Use a list of pairs to maintain priority in matching
  matchers = {
    { pattern = "^namespace", kind = "namespace" },
    { pattern = "^class",     kind = "class" },
    { pattern = "^struct",    kind = "struct" },
    { pattern = "^def",       kind = "func" },    -- Python
    { pattern = "^function",  kind = "func" },    -- Lua/C++
    { pattern = ".*%(.*%)",   kind = "func" },    -- Detects anything with parens as a function
  }
}

function _G.custom_fold_text()
  local start = vim.v.foldstart
  local line_count = vim.v.foldend - start + 1
  local line = vim.api.nvim_buf_get_lines(0, start - 1, start, false)[1]
  if not line then return "" end

  -- Dynamic Comment Detection
  local cms = vim.bo.commentstring:gsub("%%s", ""):gsub("%s", "")
  local cleaned = line:gsub("^%s*", "")
    :gsub("%s*{%s*$", "")
    :gsub("%s*=%s*{%s*$", "") -- Cleans up 'std::vector a = {'
    :gsub("%s*;%s*$", "")

  local kind = "default"

  -- Check for Comments
  if cleaned:find("^" .. vim.pesc(cms)) or cleaned:find("^/%*") then
    kind = "comment"
    cleaned = cleaned:gsub("^" .. vim.pesc(cms) .. "%s*", ""):gsub("^/%*%s*", "")
  else
    -- Match Keywords
    for _, m in ipairs(Config.matchers) do
      if cleaned:match(m.pattern) then
        kind = m.kind
        break
      end
    end
  end

  local icon = Config.icons[kind] or Config.icons.default
  local suffix = string.format(" ⋯ [%d lines]", line_count)

  -- Add specific labels for clarity
  if kind == "comment" then
    return icon .. " DOCS: " .. cleaned .. suffix
  end

  return icon .. " " .. cleaned .. suffix
end

local function apply_folds(buf)
  if not buf or not vim.api.nvim_buf_is_valid(buf) then return end
  if vim.b[buf].perf_mode then return end

  local ft = vim.bo[buf].filetype
  local supported = { "cpp", "c", "python", "lua" }
  if not vim.tbl_contains(supported, ft) then return end

  local win = vim.fn.bufwinid(buf)
  if win == -1 then return end

  vim.wo[win].foldmethod = "expr"
  vim.wo[win].foldexpr = "v:lua.vim.treesitter.foldexpr()"

  vim.wo[win].foldtext = "v:lua.custom_fold_text()"

  vim.wo[win].foldenable = true
  vim.wo[win].foldlevel = 0
end

function M.setup()
  registry.register_feature(ids.FOLDING, {
    is_heavy = true,
    events = { "FileType", "BufWinEnter" },
    resolver = function(buf)
      apply_folds(buf)
    end,
  })
end

return M
