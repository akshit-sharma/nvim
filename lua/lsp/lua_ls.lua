-- lua/lsp/lua_ls.lua
local M = {}

function M.get_context(input)
  local xdg_config = vim.fs.normalize(vim.fn.stdpath("config"))
  local config_base = vim.fs.dirname(xdg_config)
  local benchmark_repo = vim.fs.normalize("~/Projects/nvim-config-benchmark/configs")

  local bufnr = type(input) == "number" and input or 0
  local path_as_opened = vim.fs.normalize(vim.api.nvim_buf_get_name(bufnr))
  if path_as_opened == "" then return vim.loop.cwd() end

  -- 1. ALIAS RECONSTRUCTION
  local path_alias = path_as_opened
  if path_as_opened:find(benchmark_repo, 1, true) then
    local relative_to_repo = path_as_opened:sub(#benchmark_repo + 2)
    path_alias = config_base .. "/" .. relative_to_repo
  end

  local path_real = vim.loop.fs_realpath(path_as_opened) or path_as_opened
  local result_root = nil
  local tier = "NONE"

  -- 2. THE FIXED SEARCH (Anti-Greedy)
  -- We search for the root init.lua specifically. 
  -- In your case, we want the one that is NOT inside a 'lua' folder.
  local anchors = vim.fs.find(function(name, path)
    -- If we find an init.lua, check if its parent directory contains 'lua' or 'core'
    -- This identifies the project root vs a module root.
    if name == "init.lua" then
      local has_core = vim.loop.fs_stat(path .. "/lua")
      return has_core ~= nil
    end
    return name == ".git"
  end, {
      path = vim.fs.dirname(path_alias),
      upward = true,
      stop = config_base
    })

  if anchors[1] then
    result_root = vim.fs.dirname(anchors[1])
    tier = "TIER 1 (Alias Anchor)"
  else
    -- Fallback to the old method for non-benchmark files
    local anchor_real = vim.fs.find({ ".git", "init.lua" }, {
      path = vim.fs.dirname(path_real),
      upward = true
    })[1]
    result_root = anchor_real and vim.fs.dirname(anchor_real) or vim.fs.dirname(path_real)
    tier = "TIER 2 (Real Anchor)"
  end

  return result_root, tier
end

return {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  single_file_support = true,
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      diagnostics = {
        -- This is the specific line that kills the "undefined global vim" error
        globals = { 'vim' },
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
    },
  },
  -- don't think the following function exists.
  on_new_config = function(config, root_dir)
    -- We keep this to handle project-specific library paths if needed,
    -- but the primary 'vim' definition is now in the static settings above.
    config.settings.Lua.workspace.maxPreload = 2000
    config.settings.Lua.workspace.preloadFileSize = 5000
  end,
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local resolved_root, _ = M.get_context(fname)
    local final_root = vim.loop.fs_realpath(resolved_root) or resolved_root
    on_dir(final_root)
  end,
}
