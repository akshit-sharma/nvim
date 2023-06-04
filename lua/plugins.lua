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
  local config_path = string.format('configs.%s', name)
  return require(config_path)
end

local run = function(name)
  local run_path = string.format('run.%s', name)
  return require(run_path)
end

local packer_bootstrap = fresh_install()
local packer = R('packer')
packer.startup({function(use)
  use 'wbthomason/packer.nvim'
  use 'nvim-lua/plenary.nvim'
  use { 'themercorp/themer.lua', config = config('themer'), }
  use 'ryanoasis/vim-devicons'
  use { 'rcarriga/nvim-notify', config=config('notify'), run=run('notify')}
  use { 'vigoux/notifier.nvim', config=config('notifier'), }

  use {
    'nvim-treesitter/nvim-treesitter',
    run = function()
      local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
      ts_update()
    end,
    config = config('nvim-treesitter')
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
      {'ThePrimeagen/refactoring.nvim'}, --, config = config('refactoring')},
    },
    config = config('telescope'),
    run = run('telescope'),
  }

  use {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v2.x',
    requires = {
      -- LSP Support
      { 'neovim/nvim-lspconfig' },             -- Required
      { 'williamboman/mason.nvim', run = run('mason') }, -- Optional
      { 'williamboman/mason-lspconfig.nvim' }, -- Optional

      -- Autocompletion
      { 'hrsh7th/nvim-cmp' },     -- Required
      { 'hrsh7th/cmp-nvim-lsp' }, -- Required
      { 'L3MON4D3/LuaSnip' },     -- Required

      { 'weilbith/nvim-code-action-menu', cmd = 'CodeActionMenu' },
      { 'j-hui/fidget.nvim' },
      { 'kosayoda/nvim-lightbulb' },
      { 'ray-x/lsp_signature.nvim' },
      { 'simrat39/symbols-outline.nvim', config = config('symbols-outline') },
      { 'liuchengxu/vista.vim' },
    },
    run = run('lsp-zero'),
  }

  use {
    'rickhowe/spotdiff.vim',
    requires = {
      'rickhowe/diffchar.vim'
    },
  }

  use {
    'zbirenbaum/copilot.lua',
    cmd = "Copilot",
    event = 'InsertEnter',
    config = config('zbirenbaum-copilot')
  }
  use {
    'zbirenbaum/copilot-cmp',
    after = { 'copilot.lua' },
    config = config('copilot-cmp')
  }

  use { 'wsdjeg/vim-fetch' }
  use { 'stevearc/aerial.nvim', config = config('aerial'),  }
  use { 'SmiteshP/nvim-navic', requires = { 'neovim/nvim-lspconfig' } }
  use {
    'nvim-lualine/lualine.nvim',
    config = config('lualine'),
    requires = { 'nvim-tree/nvim-web-devicons' },
    after = { 'nvim-navic' },
  }
  --use { 'lervag/vimtex', config = config('vimtex') }

  use { 'MunifTanjim/nui.nvim' }

  use {
    'akinsho/toggleterm.nvim',
    tag = '*',
    config = config('toggleterm'),
  }

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
