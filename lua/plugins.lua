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

local ok_notify, _ = pcall(require, 'notify')
if ok_notify then
  require('configs.notify')()
  require('run.notify')()
end

local config = function(name, notify)
  local config_path = string.format('configs.%s', name)
  if not config_path then
    local errorMsg = string.format('error loading %s', config_path)
    notify(errorMsg, vim.log.level.ERROR, {title=name})
    return function() end
  end
  return require(config_path)
end

local run = function(name, notify)
  local run_path = string.format('run.%s', name)
  if not run_path then
    local errorMsg = string.format('error loading %s', run_path)
    notify(errorMsg, vim.log.level.ERROR, {title=name})
    return function() end
  end
  return require(run_path)
end

local draculaColorScheme = false

local packer_bootstrap = fresh_install()
local packer = R('packer')

local function mainComputer()
  local hostname = vim.fn.hostname()
  if hostname == nil then return false end
  if not vim.env.MAIN_COMPUTERS then return false end
  local mainComputers = vim.split(vim.env.MAIN_COMPUTERS, ', ')
  for _, computer in ipairs(mainComputers) do
    if computer == hostname then return true end
  end
  return vim.tbl_contains(mainComputers, hostname)
end

packer.startup({function(use)
  use 'wbthomason/packer.nvim'
  use 'nvim-lua/plenary.nvim'
  if draculaColorScheme then
    use { 'Mofiqul/dracula.nvim', config = config('dracula'), }
    use { 'themercorp/themer.lua', }
  else
    use { 'Mofiqul/dracula.nvim', }
    use { 'themercorp/themer.lua', config = config('themer'), }
  end
  use 'ryanoasis/vim-devicons'
  use { 'rcarriga/nvim-notify', config=config('notify') }
  --use { 'vigoux/notifier.nvim', config=config('notifier'), }

  use { 'folke/which-key.nvim', config = config('which-key'), }

  use {
    'nvim-treesitter/nvim-treesitter',
    run = function()
      local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
      ts_update()
    end,
    config = config('nvim-treesitter')
  }

  use {
    'nvim-treesitter/nvim-treesitter-textobjects',
    after = { 'nvim-treesitter' },
    requires = { 'nvim-treesitter/nvim-treesitter' },
  }

  use {
    'm-demare/hlargs.nvim',
    config = config('hlargs'),
    after = { 'nvim-treesitter' },
    requires = { 'nvim-treesitter/nvim-treesitter' },
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
      {'rmagatti/goto-preview', config = config('goto-preview')},
    },
    config = config('telescope'),
    run = run('telescope'),
  }
  --use {
  --  after = { 'telescope.nvim' },
  --  config = config('goto-preview'),
  --}

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
      { 'j-hui/fidget.nvim', config = config('fidget'), tag = "legacy" },
      { 'kosayoda/nvim-lightbulb', config = config('lightbulb') },
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

  use { 'lervag/vimtex', config = config('vimtex') }

  use { 'numToStr/Comment.nvim', config = config('Comment') }

  use { 'MunifTanjim/nui.nvim' }

  use { 'akinsho/toggleterm.nvim', tag = '*', config = config('toggleterm'), }

  use { 'chrisgrieser/nvim-spider' }

  use { 'gelguy/wilder.nvim', config = config('wilder'), }

  use { 'tversteeg/registers.nvim', config = config('registers'), }

  use { 'gw31415/nvim-tetris' }

  use { 'jim-fx/sudoku.nvim', cmd='Sudoku', config=config('sudoku'), }

  use { 'lukas-reineke/indent-blankline.nvim', config = config('indent-blankline'), }

--  use { 'vigoux/ltex-ls.nvim', requires='neovim/nvim-lspconfig', config = config('ltex-ls'), }

  if mainComputer() then
    use {
      'p00f/cphelper.nvim',
    }

    use {
      'xeluxee/competitest.nvim',
      requires = 'MunifTanjim/nui.nvim',
      config = function() require'competitest'.setup() end
    }

    use {
      'Dhanus3133/Leetbuddy.nvim',
      requires = {
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope.nvim',
      },
      config = config('leetbuddy'),
    }
  end

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
