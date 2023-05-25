local fresh_install = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local config = function(name)
  return string.format('require(\'configs.%s\')', name)
end

local run = function(name)
  return string.format('require(\'run.%s\')', name)
end

local packer_bootstrap = fresh_install()
local packer = R('packer')
packer.startup({function(use)
  use 'wbthomason/packer.nvim'
  use 'nvim-lua/plenary.nvim'
  use 'ryanoasis/vim-devicons'
  --[[
  use {
    'nvim-treesitter/nvim-treesitter',
    run = function()
      local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
      ts_update()
    end,
    config = config('nvim-treesitter')
  }

  use('liuchengxu/vista.vim')
  use {
    'simrat39/symbols-outline.nvim',
    config = function()
      require('symbols-outline').setup()
    end,
  }

  use {
    'nvim-telescope/telescope.nvim', tag = '0.1.1',
    requires = {
      {'nvim-lua/plenary.nvim'},
      {'folke/trouble.nvim'},
      {'nvim-tree/nvim-web-devicons'},
      {'nvim-telescope/telescope-fzf-native.nvim', run = "make" },
      {'nvim-telescope/telescope-file-browser.nvim'},
      {'benfowler/telescope-luasnip.nvim'},
      {'nvim-telescope/telescope-symbols.nvim'},
      {'nvim-telescope/telescope-packer.nvim'},
    },
    run = run('telescope')
  }

  use { 'kosayoda/nvim-lightbulb' }

  use {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v2.x',
    requires = {
      -- LSP Support
      { 'neovim/nvim-lspconfig' },             -- Required
      { 'williamboman/mason.nvim', run = run('mason') }, -- Optional
      {'williamboman/mason-lspconfig.nvim'}, -- Optional

      -- Autocompletion
      {'hrsh7th/nvim-cmp'},     -- Required
      {'hrsh7th/cmp-nvim-lsp'}, -- Required
      {'L3MON4D3/LuaSnip'},     -- Required
    },
    run = run('lsp-zero'),
  }

  use {
    "ThePrimeagen/refactoring.nvim",
    requires = {
      {"nvim-lua/plenary.nvim"},
      {"nvim-treesitter/nvim-treesitter"}
    },
    config = config('refactoring')
  }

  use { 'wsdjeg/vim-fetch' }
  use { 'stevearc/aerial.nvim', config = config('aerial'),  }
  use {
    'SmiteshP/nvim-navic',
    requires = { 'neovim/nvim-lspconfig' }
  }
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'nvim-tree/nvim-web-devicons' },
    config = config('lualine')
  }
  ]]--
  use ({
    'themercorp/themer.lua',
    config = require'configs.themer',
  })

  if packer_bootstrap then
    R('packer').sync()
  end
end,
config = {
  display = {
    open_cmd = 'botright 65vnew \\[packer\\]'
  },
}
})
