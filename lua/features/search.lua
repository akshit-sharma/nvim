-- lua/features/search.lua
local M = {}
local registry = require("core.registry")
local schema = require("core.schema")
local vcs = require("core.vcs_utils")

-- Detect the most logical search root based on the hierarchy
local function resolve_search_root(bufnr)
  -- 1. Check if we are in an Oil buffer
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  if bufname:match("oil://") then
    return vim.fn.fnamemodify(bufname:gsub("oil://", ""), ":p")
  end

  -- 2. Check for VCS Root
  -- Note: vcs_utils needs a synchronous check or we use the cached Taskbus value
  -- For the registry spec, we return a function that Telescope will poll.
  local _, vcs_root = vcs.detect_vcs(bufnr)
  if vcs_root then return vcs_root end

  -- 3. Fallback to CWD
  return vim.fn.getcwd()
end

M.setup = function()
  registry.register_feature(schema.TaskID.SEARCH_ROOT, {
    events = { "BufEnter", "DirChanged", "TabEnter" },
    is_heavy = false,
    resolver = function(bufnr)
      return resolve_search_root(bufnr)
    end
  })

  -- Asynchronous File List Caching for O(1) Filename Search
  registry.register_feature(schema.TaskID.FILE_LIST, {
    events = { "User TaskbusUpdate" }, -- Trigger when SEARCH_ROOT changes
    is_heavy = true,                   -- Do not run in massive files
    resolver = function(bufnr)
      local root = require("core.taskbus").get(schema.TaskID.SEARCH_ROOT)
      if root == "" then return nil end

      -- Non-blocking find/fd call to cache files
      -- We return nil here because the actual update happens in the callback
      vim.system({ "fd", "--type", "f", "--strip-cwd-prefix" }, { cwd = root }, function(obj)
        if obj.code == 0 then
          vim.schedule(function()
            require("core.taskbus").set(schema.TaskID.FILE_LIST, vim.split(obj.stdout, "\n"))
          end)
        end
      end)
      return nil
    end
  })
end

return M
