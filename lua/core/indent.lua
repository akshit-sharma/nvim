local registry = require("core.registry")
local ids = require("core.schema").TaskID

local M = {}

-- Our "Ideal" Project Standards
local standards = {
  yaml     = { size = 2, expand = true },
  python   = { size = 4, expand = true },
  lua      = { size = 2, expand = true },
  makefile = { size = 8, expand = false },
}

function M.detect_and_apply(buf)
  if not buf or not vim.api.nvim_buf_is_valid(buf) then return end
  -- 1. Detection Logic (O(1) lookahead)
  -- We check the first 100 lines to see what the file is actually doing
  local lines = vim.api.nvim_buf_get_lines(buf, 0, 100, false)
  local detected_tab = false
  local detected_space = false
  local space_count = 0

  for _, line in ipairs(lines) do
    if line:match("^\t") then detected_tab = true break end
    local spaces = line:match("^(  +)")
    if spaces then
      detected_space = true
      space_count = #spaces
      break
    end
  end

  -- 2. Setup the Buffer
  local ft = vim.bo[buf].filetype
  local std = standards[ft] or { size = 2, expand = true }

  -- Apply: If detected, use it. Otherwise, use standard.
  vim.bo[buf].shiftwidth = (detected_space and space_count > 0) and space_count or std.size
  vim.bo[buf].expandtab  = detected_tab and false or (detected_space and true or std.expand)
  vim.bo[buf].tabstop    = std.size -- Keep visual tab width consistent

  -- 3. The "Visual Alert" System (Request: Different symbols for non-standard)
  local is_mismatch = false
  if detected_space and space_count ~= std.size then is_mismatch = true end
  if detected_tab and std.expand == true then is_mismatch = true end

  if is_mismatch then
    -- High-visibility symbols for "Dirty" files
    vim.opt_local.listchars = {
      tab = "¬ ",
      trail = "×",
      lead = "·",
      extends = "»",
      precedes = "«",
    }
    return "MISMATCH: " .. (detected_tab and "Tabs" or space_count .. "sp")
  end

  -- Standard symbols for "Clean" files
  vim.opt_local.listchars = { tab = "  ", trail = "·" }
  return (vim.bo[buf].expandtab and "Spaces: " or "Tabs: ") .. vim.bo[buf].shiftwidth
end

function M.smart_format()
  local bufnr = vim.api.nvim_get_current_buf()

  -- 1. Check LSP Support
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  local has_lsp = false
  for _, client in ipairs(clients) do
    if client.supports_method("textDocument/formatting") then
      has_lsp = true
      break
    end
  end

  if has_lsp then
    vim.lsp.buf.format({ async = true })
    return
  end

  -- 2. Check for preconfigured command (buffer-local variable)
  if vim.b.formatter_cmd then
    vim.cmd("'<,'>!" .. vim.b.formatter_cmd)
    return
  end

  -- 3. Default to cleanup logic
  local cleanup = require("core.cleanup")
  cleanup.run_on_visual_range()
  -- Fallback to standard vim indentation after cleaning
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("=", true, false, true), "n", false)
end

function M.setup()
  registry.register_feature(ids.INDENT, {
    is_heavy = false,
    events = { "BufReadPost", "FileType" },
    resolver = function(buf)
      return M.detect_and_apply(buf)
    end,
  })
  vim.keymap.set("v", "=", function()
    M.smart_format()
  end, { desc = "Smart Format/Indent Selection" })
end

return M
