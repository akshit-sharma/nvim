-- lua/core/vcs_utils.lua
local M = {}

-- Supported VCS types and their identifying root markers
local vcs_config = {
  git = { root = ".git", branch_cmd = { "git", "branch", "--show-current" } },
  hg  = { root = ".hg",  branch_cmd = { "hg", "branch" } },
  jj  = { root = ".jj",  branch_cmd = { "jj", "log", "--no-graph", "-r", "@", "-T", "bookmarks" } },
}

--- Detects which VCS backend is active for a given buffer
---@param bufnr number
---@return string|nil vcs_type, string|nil root_path
local function detect_vcs(bufnr)
  local file_path = vim.api.nvim_buf_get_name(bufnr)
  if file_path == "" then return nil, nil end

  for type, cfg in pairs(vcs_config) do
    local root = vim.fs.root(file_path, cfg.root)
    if root then
      return type, root
    end
  end
  return nil, nil
end

--- Asynchronously fetches the current branch/bookmark name.
---@param bufnr number
---@param callback fun(branch: string)
function M.get_branch(bufnr, callback)
  local vcs_type, _ = detect_vcs(bufnr)
  if not vcs_type or not callback then return end

  vim.system(vcs_config[vcs_type].branch_cmd, { text = true }, function(obj)
    if obj.code == 0 and obj.stdout then
      local branch = vim.trim(obj.stdout)
      vim.schedule(function()
        callback(branch ~= "" and branch or "no-branch")
      end)
    end
  end)
end

--- Asynchronously fetches the 'base' version of the file from the VCS index.
---@param bufnr number
---@param callback fun(content: string)
function M.get_base_content(bufnr, callback)
  local vcs_type, root = detect_vcs(bufnr)
  if not vcs_type or not root or not callback then return end

  local file_path = vim.api.nvim_buf_get_name(bufnr)
  local relative_path = vim.fs.make_relative(file_path, root)

  local cmd_map = {
    git = { "git", "show", "HEAD:" .. relative_path },
    hg  = { "hg", "cat", file_path },
    jj  = { "jj", "cat", file_path, "-r", "@-" }, -- Cat from parent of working copy
  }

  vim.system(cmd_map[vcs_type], { text = true }, function(obj)
    if obj.code == 0 and obj.stdout then
      vim.schedule(function()
        callback(obj.stdout)
      end)
    end
  end)
end

return M
