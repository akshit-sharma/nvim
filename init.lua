-- ==========================================================================
-- 1. ARCHITECTURAL CORE (Load first to prevent glitching)
-- ==========================================================================

-- Load the static schema (Prevents typos/silent failures)
-- This must be available for all subsequent modules
local schema = require('core.schema')

-- Initialize the Global Performance Guard
-- This sets vim.b.perf_mode BEFORE plugins or filetypes load
require('core.perf').setup()

-- Initialize the Registry
-- This handles safe execution of heavy features
local registry = require('core.registry')

-- ==========================================================================
-- 2. PLUGIN MANAGEMENT (Lazy.nvim)
-- ==========================================================================

local lazyroot = vim.fn.stdpath("data") .. "/nvimbenchmark/57_nvim_low/lazy"
local lazypath = lazyroot .. "/lazy.nvim"

---@diagnostic disable-next-line:undefined-field
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.mkdir(lazyroot, "p")
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  root = lazyroot,
  spec = {
    { import = "plugins" },
  },
  install = { colorscheme = { "retrobox" } },
  checker = { enabled = false },
})

-- ==========================================================================
-- 3. CORE SETTINGS & FEATURES
-- ==========================================================================

-- Standard Options (Line numbers, etc.)
require('core.options')
require('core.keymaps').setup()

-- Initialize High-Performance Features
-- These utilize the registry to respect the Global Perf Guard
require('core.folding').setup()
require('core.features_init')

-- LSP and UI Components
require('lsp')
require('ui.statusline').setup()
require('ui.tabline').setup()
require('ui.winbar').setup()

-- ==========================================================================
-- 4. THEME & FINAL POLISH
-- ==========================================================================
require('ui.highlights').setup()
vim.cmd("colorscheme retrobox")
