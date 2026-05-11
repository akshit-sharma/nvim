
if vim.loader then
  vim.loader.enable()
end

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
vim.opt.rtp:prepend(lazypath)

-- git clone --filter=blob:none --branch=stable https://github.com/folke/lazy.nvim.git ~/.config/57_nvim_low
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.mkdir(lazyroot, "p")
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath
  })
  lazy = require('lazy')
end


require('lazy').setup({
  root = lazyroot,
  spec = {
    { import = "plugins" },
  },
  install = { colorscheme = { "retrobox" } },
  checker = { enabled = false },
  performance = {
    cache = { enabled = true },
    reset_packpath = true, -- Faster than scanning the default packpath
    rtp = {
      -- Disable unused builtin plugins to save scan time
      disabled_plugins = {
        "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin",
      },
    },
  },
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

vim.schedule(function()
  require('core.features_init')
  require('core.cleanup').setup()
  require('core.indent').setup()
  require('ui.statusline').setup()
  require('ui.tabline').setup()
  require('ui.winbar').setup()
  require('lsp').setup()

  local schema = require('core.schema')
  local has_config, user_tools = pcall(require, "configs.tools")
  if has_config then
    schema.Tools = vim.tbl_deep_extend("force", schema.Tools, user_tools)
  end
end)

-- ==========================================================================
-- 4. THEME & FINAL POLISH
-- ==========================================================================
require('ui.highlights').setup()
vim.cmd("colorscheme retrobox")

