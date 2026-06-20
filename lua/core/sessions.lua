-- lua/core/sessions.lua
local M = {}

function M.setup()
  local function update_session(is_startup)
    local cwd = vim.fn.getcwd()
    local project_name = vim.fn.fnamemodify(cwd, ":t")
    if project_name == "" then
      project_name = "default"
    end

    -- Sanitize project name to be safe for filenames (replace spaces/special chars with '_')
    local safe_project_name = project_name:gsub("[^%w%.%-]", "_")

    -- 1. Configure Shada (History, jump list, registers, marks)
    local shada_dir = vim.fn.stdpath("state") .. "/shada"
    if vim.fn.isdirectory(shada_dir) == 0 then
      vim.fn.mkdir(shada_dir, "p")
    end
    local shada_path = shada_dir .. "/" .. safe_project_name .. ".shada"

    -- If not startup, save current shada first
    if not is_startup then
      pcall(vim.cmd, "wshada")
    end

    vim.opt.shadafile = shada_path

    -- If not startup, read the new shada file
    if not is_startup then
      pcall(vim.cmd, "rshada!")
    end

    -- 2. Configure Undo (Persistent undo history)
    local undo_dir = vim.fn.stdpath("state") .. "/undo/" .. safe_project_name
    if vim.fn.isdirectory(undo_dir) == 0 then
      vim.fn.mkdir(undo_dir, "p")
    end
    vim.opt.undodir = undo_dir
    vim.opt.undofile = true
  end

  -- Initialize on startup
  update_session(true)

  -- Update dynamically when changing directory
  vim.api.nvim_create_autocmd("DirChanged", {
    pattern = "*",
    callback = function()
      update_session(false)
    end,
  })
end

return M
