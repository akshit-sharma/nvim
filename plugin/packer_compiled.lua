-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

_G._packer = _G._packer or {}
_G._packer.inside_compile = true

local time
local profile_info
local should_profile = false
if should_profile then
  local hrtime = vim.loop.hrtime
  profile_info = {}
  time = function(chunk, start)
    if start then
      profile_info[chunk] = hrtime()
    else
      profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
    end
  end
else
  time = function(chunk, start) end
end

local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end
  if threshold then
    table.insert(results, '(Only showing plugins that took longer than ' .. threshold .. ' ms ' .. 'to load)')
  end

  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/home/akshit/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?.lua;/home/akshit/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?/init.lua;/home/akshit/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?.lua;/home/akshit/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/home/akshit/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s), name, _G.packer_plugins[name])
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  LuaSnip = {
    loaded = true,
    path = "/home/akshit/.local/share/nvim/site/pack/packer/start/LuaSnip",
    url = "https://github.com/L3MON4D3/LuaSnip"
  },
  ["aerial.nvim"] = {
    config = { "\27LJ\2\n\1\0\1\a\0\v\0\0196\1\0\0009\1\1\0019\1\2\1'\3\3\0'\4\4\0'\5\5\0005\6\6\0=\0\a\6B\1\5\0016\1\0\0009\1\1\0019\1\2\1'\3\3\0'\4\b\0'\5\t\0005\6\n\0=\0\a\6B\1\5\1K\0\1\0\1\0\0\24<cmd>AerialNext<CR>\6}\vbuffer\1\0\0\24<cmd>AerialPrev<CR>\6{\6n\bset\vkeymap\bvimN\1\0\4\0\6\0\t6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0003\3\3\0=\3\5\2B\0\2\1K\0\1\0\14on_attach\1\0\0\0\nsetup\vaerial\frequire\0" },
    loaded = true,
    path = "/home/akshit/.local/share/nvim/site/pack/packer/start/aerial.nvim",
    url = "https://github.com/stevearc/aerial.nvim"
  },
  ["cmp-nvim-lsp"] = {
    loaded = true,
    path = "/home/akshit/.local/share/nvim/site/pack/packer/start/cmp-nvim-lsp",
    url = "https://github.com/hrsh7th/cmp-nvim-lsp"
  },
  ["lsp-zero.nvim"] = {
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/akshit/.local/share/nvim/site/pack/packer/opt/lsp-zero.nvim",
    url = "https://github.com/VonHeikemen/lsp-zero.nvim"
  },
  ["lualine.nvim"] = {
    config = { "\27LJ\2\n&\0\1\2\0\2\0\6\6\0\0\0X\1\2\f\1\0\0X\1\1'\1\1\0L\1\2\0\6 \tmain&\0\1\2\0\2\0\6\6\0\0\0X\1\2\f\1\0\0X\1\1'\1\1\0L\1\2\0\5\nutf-8Ú\3\1\0\a\0\28\0%6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\0025\3\a\0005\4\6\0=\4\b\0035\4\f\0005\5\t\0003\6\n\0=\6\v\5>\5\1\4=\4\r\0035\4\14\0=\4\15\0035\4\16\0=\4\17\0034\4\3\0005\5\18\0003\6\19\0=\6\v\5>\5\1\0045\5\20\0>\5\2\4=\4\21\0035\4\22\0=\4\23\3=\3\24\0025\3\26\0005\4\25\0=\4\15\3=\3\27\2B\0\2\1K\0\1\0\vwinbar\1\0\0\1\2\0\0\nnavic\rsections\14lualine_z\1\3\0\0\rlocation\rprogress\14lualine_y\1\2\2\0\rfiletype\14icon_only\2\fcolored\2\0\1\2\0\0\rencoding\14lualine_x\1\2\0\0\15diagnostic\14lualine_c\1\2\0\0\vaerial\14lualine_b\1\3\0\0\0\tdiff\bfmt\0\1\2\0\0\vbranch\14lualine_a\1\0\0\1\2\0\0\rfilename\foptions\1\0\0\1\0\3\25component_separators\6|\ntheme\fonedark\23section_separators\5\nsetup\flualine\frequire\0" },
    loaded = true,
    path = "/home/akshit/.local/share/nvim/site/pack/packer/start/lualine.nvim",
    url = "https://github.com/nvim-lualine/lualine.nvim"
  },
  ["mason-lspconfig.nvim"] = {
    loaded = true,
    path = "/home/akshit/.local/share/nvim/site/pack/packer/start/mason-lspconfig.nvim",
    url = "https://github.com/williamboman/mason-lspconfig.nvim"
  },
  ["mason.nvim"] = {
    loaded = true,
    path = "/home/akshit/.local/share/nvim/site/pack/packer/start/mason.nvim",
    url = "https://github.com/williamboman/mason.nvim"
  },
  ["nvim-cmp"] = {
    loaded = true,
    path = "/home/akshit/.local/share/nvim/site/pack/packer/start/nvim-cmp",
    url = "https://github.com/hrsh7th/nvim-cmp"
  },
  ["nvim-lightbulb"] = {
    loaded = true,
    path = "/home/akshit/.local/share/nvim/site/pack/packer/start/nvim-lightbulb",
    url = "https://github.com/kosayoda/nvim-lightbulb"
  },
  ["nvim-lspconfig"] = {
    loaded = true,
    path = "/home/akshit/.local/share/nvim/site/pack/packer/start/nvim-lspconfig",
    url = "https://github.com/neovim/nvim-lspconfig"
  },
  ["nvim-navic"] = {
    loaded = true,
    path = "/home/akshit/.local/share/nvim/site/pack/packer/start/nvim-navic",
    url = "https://github.com/SmiteshP/nvim-navic"
  },
  ["nvim-treesitter"] = {
    after = { "lsp-zero.nvim" },
    config = { "\27LJ\2\nb\0\2\5\0\4\1\14\a\0\0\0X\2\b6\2\1\0009\2\2\0029\2\3\2\18\4\1\0B\2\2\2*\3\0\0\0\3\2\0X\2\2+\2\1\0X\3\1+\2\2\0L\2\2\0\24nvim_buf_line_count\bapi\bvim\bcpp \6å\b\1\0\6\0'\0+6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\0025\3\6\0003\4\a\0=\4\b\3=\3\t\0025\3\n\0005\4\v\0=\4\f\3=\3\r\0025\3\16\0005\4\14\0005\5\15\0=\5\f\4=\4\17\0035\4\18\0005\5\19\0=\5\20\0045\5\21\0=\5\22\4=\4\23\0035\4\24\0005\5\25\0=\5\26\0045\5\27\0=\5\28\0045\5\29\0=\5\30\0045\5\31\0=\5 \4=\4!\0035\4\"\0005\5#\0=\5$\4=\4%\3=\3&\2B\0\2\1K\0\1\0\16textobjects\16lsp_interop\25peek_definition_code\1\0\2\15<leader>df\20@function.outer\15<leader>dF\17@class.outer\1\0\2\venable\2\vborder\tnone\tmove\22goto_previous_end\1\0\2\a[]\17@class.outer\a[M\20@function.outer\24goto_previous_start\1\0\2\a[m\20@function.outer\a[[\17@class.outer\18goto_next_end\1\0\2\a][\17@class.outer\a]M\20@function.outer\20goto_next_start\1\0\2\a]m\20@function.outer\a]]\17@class.outer\1\0\2\venable\2\14set_jumps\2\tswap\18swap_previous\1\0\1\14<leader>A\21@parameter.inner\14swap_next\1\0\1\14<leader>a\21@parameter.inner\1\0\1\venable\2\vselect\1\0\0\1\0\4\aac\17@class.outer\aif\20@function.inner\aic\17@class.inner\aaf\20@function.outer\1\0\2\14lookahead\2\venable\2\26incremental_selection\fkeymaps\1\0\4\21node_incremental\bgrn\22scope_incremental\bgrc\19init_selection\bgnn\21node_decremental\bgrm\1\0\1\venable\2\14highlight\fdisable\0\1\0\2\venable\2&additional_vim_regex_highlighting\1\21ensure_installed\1\0\1\17auto_install\2\1\19\0\0\tbash\6c\fcomment\ncmake\bcpp\tcuda\tglsl\tjava\15javascript\tjson\thtml\blua\trust\vpython\15typescript\bvim\vvimdoc\tyaml\nsetup\28nvim-treesitter.configs\frequire\0" },
    loaded = true,
    only_config = true,
    path = "/home/akshit/.local/share/nvim/site/pack/packer/start/nvim-treesitter",
    url = "https://github.com/nvim-treesitter/nvim-treesitter"
  },
  ["nvim-web-devicons"] = {
    loaded = true,
    path = "/home/akshit/.local/share/nvim/site/pack/packer/start/nvim-web-devicons",
    url = "https://github.com/nvim-tree/nvim-web-devicons"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/home/akshit/.local/share/nvim/site/pack/packer/start/packer.nvim",
    url = "https://github.com/wbthomason/packer.nvim"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/home/akshit/.local/share/nvim/site/pack/packer/start/plenary.nvim",
    url = "https://github.com/nvim-lua/plenary.nvim"
  },
  ["refactoring.nvim"] = {
    loaded = true,
    path = "/home/akshit/.local/share/nvim/site/pack/packer/start/refactoring.nvim",
    url = "https://github.com/ThePrimeagen/refactoring.nvim"
  },
  ["symbols-outline.nvim"] = {
    config = { "\27LJ\2\n=\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\20symbols-outline\frequire\0" },
    loaded = true,
    path = "/home/akshit/.local/share/nvim/site/pack/packer/start/symbols-outline.nvim",
    url = "https://github.com/simrat39/symbols-outline.nvim"
  },
  ["telescope-file-browser.nvim"] = {
    loaded = true,
    path = "/home/akshit/.local/share/nvim/site/pack/packer/start/telescope-file-browser.nvim",
    url = "https://github.com/nvim-telescope/telescope-file-browser.nvim"
  },
  ["telescope-fzf-native.nvim"] = {
    loaded = true,
    path = "/home/akshit/.local/share/nvim/site/pack/packer/start/telescope-fzf-native.nvim",
    url = "https://github.com/nvim-telescope/telescope-fzf-native.nvim"
  },
  ["telescope-luasnip.nvim"] = {
    loaded = true,
    path = "/home/akshit/.local/share/nvim/site/pack/packer/start/telescope-luasnip.nvim",
    url = "https://github.com/benfowler/telescope-luasnip.nvim"
  },
  ["telescope-packer.nvim"] = {
    loaded = true,
    path = "/home/akshit/.local/share/nvim/site/pack/packer/start/telescope-packer.nvim",
    url = "https://github.com/nvim-telescope/telescope-packer.nvim"
  },
  ["telescope-symbols.nvim"] = {
    loaded = true,
    path = "/home/akshit/.local/share/nvim/site/pack/packer/start/telescope-symbols.nvim",
    url = "https://github.com/nvim-telescope/telescope-symbols.nvim"
  },
  ["telescope.nvim"] = {
    config = { "\27LJ\2\në\5\0\0\n\0#\0<6\0\0\0006\2\1\0'\3\2\0B\0\3\0037\1\3\0007\0\4\0006\0\4\0\14\0\0\0X\0\66\0\5\0009\0\6\0'\2\a\0'\3\b\0B\0\3\1K\0\1\0+\0\0\0006\1\0\0006\3\1\0'\4\t\0B\1\3\3\15\0\1\0X\3\29\0\n\2X\3\56\3\5\0009\3\6\3'\5\v\0'\6\b\0B\3\3\0016\3\1\0'\5\f\0B\3\2\0027\3\r\0006\3\3\0009\3\14\0036\4\3\0009\4\15\0045\6\26\0005\a\16\0005\b\17\0=\b\18\a5\b\21\0005\t\19\0=\0\20\t=\t\22\b5\t\23\0=\0\20\t=\t\24\b=\b\25\a=\a\27\0065\a\29\0005\b\28\0=\b\30\a5\b \0005\t\31\0=\t!\b=\b\"\a=\a\14\6B\4\2\1K\0\1\0\vaerial\17show_nesting\1\0\0\1\0\3\tyaml\2\6_\1\tjson\2\bfzf\1\0\0\1\0\4\14case_mode\15smart_case\25override_file_sorter\2\28override_generic_sorter\2\nfuzzy\2\rdefaults\1\0\0\rmappings\6n\1\0\0\6i\1\0\0\n<C-t>\1\0\0\17path_display\1\2\0\0\nsmart\1\0\2\18prompt_prefix\b>> \20selection_caret\nð \nsetup\15extensions\22TELESCOPE_BUILTIN\22telescope.builtinS\"folke/trouble.nvim\" not available, for use in \"nvim-telescope/nvim-telescope\"\22open_with_trouble\ftrouble\nerror2\"nvim-telescope/telescope.nvim\" not available\vnotify\bvim\17OK_TELESCOPE\14TELESCOPE\14telescope\frequire\npcall\0" },
    loaded = true,
    path = "/home/akshit/.local/share/nvim/site/pack/packer/start/telescope.nvim",
    url = "https://github.com/nvim-telescope/telescope.nvim"
  },
  ["themer.lua"] = {
    config = { "\27LJ\2\nµ\1\0\0\5\0\n\0\r6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\5\0005\4\4\0=\4\6\0035\4\a\0=\4\b\3=\3\t\2B\0\2\1K\0\1\0\vstyles\20variableBuiltIn\1\0\1\nstyle\vitalic\20functionBuiltIn\1\0\0\1\0\1\nstyle\vitalic\1\0\1\16colorscheme\16monokai_pro\nsetup\vthemer\frequire\0" },
    loaded = true,
    path = "/home/akshit/.local/share/nvim/site/pack/packer/start/themer.lua",
    url = "https://github.com/themercorp/themer.lua"
  },
  ["trouble.nvim"] = {
    loaded = true,
    path = "/home/akshit/.local/share/nvim/site/pack/packer/start/trouble.nvim",
    url = "https://github.com/folke/trouble.nvim"
  },
  ["vim-devicons"] = {
    loaded = true,
    path = "/home/akshit/.local/share/nvim/site/pack/packer/start/vim-devicons",
    url = "https://github.com/ryanoasis/vim-devicons"
  },
  ["vim-fetch"] = {
    loaded = true,
    path = "/home/akshit/.local/share/nvim/site/pack/packer/start/vim-fetch",
    url = "https://github.com/wsdjeg/vim-fetch"
  },
  ["vista.vim"] = {
    loaded = true,
    path = "/home/akshit/.local/share/nvim/site/pack/packer/start/vista.vim",
    url = "https://github.com/liuchengxu/vista.vim"
  }
}

time([[Defining packer_plugins]], false)
-- Config for: symbols-outline.nvim
time([[Config for symbols-outline.nvim]], true)
try_loadstring("\27LJ\2\n=\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\20symbols-outline\frequire\0", "config", "symbols-outline.nvim")
time([[Config for symbols-outline.nvim]], false)
-- Config for: nvim-treesitter
time([[Config for nvim-treesitter]], true)
try_loadstring("\27LJ\2\nb\0\2\5\0\4\1\14\a\0\0\0X\2\b6\2\1\0009\2\2\0029\2\3\2\18\4\1\0B\2\2\2*\3\0\0\0\3\2\0X\2\2+\2\1\0X\3\1+\2\2\0L\2\2\0\24nvim_buf_line_count\bapi\bvim\bcpp \6å\b\1\0\6\0'\0+6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\0025\3\6\0003\4\a\0=\4\b\3=\3\t\0025\3\n\0005\4\v\0=\4\f\3=\3\r\0025\3\16\0005\4\14\0005\5\15\0=\5\f\4=\4\17\0035\4\18\0005\5\19\0=\5\20\0045\5\21\0=\5\22\4=\4\23\0035\4\24\0005\5\25\0=\5\26\0045\5\27\0=\5\28\0045\5\29\0=\5\30\0045\5\31\0=\5 \4=\4!\0035\4\"\0005\5#\0=\5$\4=\4%\3=\3&\2B\0\2\1K\0\1\0\16textobjects\16lsp_interop\25peek_definition_code\1\0\2\15<leader>df\20@function.outer\15<leader>dF\17@class.outer\1\0\2\venable\2\vborder\tnone\tmove\22goto_previous_end\1\0\2\a[]\17@class.outer\a[M\20@function.outer\24goto_previous_start\1\0\2\a[m\20@function.outer\a[[\17@class.outer\18goto_next_end\1\0\2\a][\17@class.outer\a]M\20@function.outer\20goto_next_start\1\0\2\a]m\20@function.outer\a]]\17@class.outer\1\0\2\venable\2\14set_jumps\2\tswap\18swap_previous\1\0\1\14<leader>A\21@parameter.inner\14swap_next\1\0\1\14<leader>a\21@parameter.inner\1\0\1\venable\2\vselect\1\0\0\1\0\4\aac\17@class.outer\aif\20@function.inner\aic\17@class.inner\aaf\20@function.outer\1\0\2\14lookahead\2\venable\2\26incremental_selection\fkeymaps\1\0\4\21node_incremental\bgrn\22scope_incremental\bgrc\19init_selection\bgnn\21node_decremental\bgrm\1\0\1\venable\2\14highlight\fdisable\0\1\0\2\venable\2&additional_vim_regex_highlighting\1\21ensure_installed\1\0\1\17auto_install\2\1\19\0\0\tbash\6c\fcomment\ncmake\bcpp\tcuda\tglsl\tjava\15javascript\tjson\thtml\blua\trust\vpython\15typescript\bvim\vvimdoc\tyaml\nsetup\28nvim-treesitter.configs\frequire\0", "config", "nvim-treesitter")
time([[Config for nvim-treesitter]], false)
-- Config for: telescope.nvim
time([[Config for telescope.nvim]], true)
try_loadstring("\27LJ\2\në\5\0\0\n\0#\0<6\0\0\0006\2\1\0'\3\2\0B\0\3\0037\1\3\0007\0\4\0006\0\4\0\14\0\0\0X\0\66\0\5\0009\0\6\0'\2\a\0'\3\b\0B\0\3\1K\0\1\0+\0\0\0006\1\0\0006\3\1\0'\4\t\0B\1\3\3\15\0\1\0X\3\29\0\n\2X\3\56\3\5\0009\3\6\3'\5\v\0'\6\b\0B\3\3\0016\3\1\0'\5\f\0B\3\2\0027\3\r\0006\3\3\0009\3\14\0036\4\3\0009\4\15\0045\6\26\0005\a\16\0005\b\17\0=\b\18\a5\b\21\0005\t\19\0=\0\20\t=\t\22\b5\t\23\0=\0\20\t=\t\24\b=\b\25\a=\a\27\0065\a\29\0005\b\28\0=\b\30\a5\b \0005\t\31\0=\t!\b=\b\"\a=\a\14\6B\4\2\1K\0\1\0\vaerial\17show_nesting\1\0\0\1\0\3\tyaml\2\6_\1\tjson\2\bfzf\1\0\0\1\0\4\14case_mode\15smart_case\25override_file_sorter\2\28override_generic_sorter\2\nfuzzy\2\rdefaults\1\0\0\rmappings\6n\1\0\0\6i\1\0\0\n<C-t>\1\0\0\17path_display\1\2\0\0\nsmart\1\0\2\18prompt_prefix\b>> \20selection_caret\nð \nsetup\15extensions\22TELESCOPE_BUILTIN\22telescope.builtinS\"folke/trouble.nvim\" not available, for use in \"nvim-telescope/nvim-telescope\"\22open_with_trouble\ftrouble\nerror2\"nvim-telescope/telescope.nvim\" not available\vnotify\bvim\17OK_TELESCOPE\14TELESCOPE\14telescope\frequire\npcall\0", "config", "telescope.nvim")
time([[Config for telescope.nvim]], false)
-- Config for: aerial.nvim
time([[Config for aerial.nvim]], true)
try_loadstring("\27LJ\2\n\1\0\1\a\0\v\0\0196\1\0\0009\1\1\0019\1\2\1'\3\3\0'\4\4\0'\5\5\0005\6\6\0=\0\a\6B\1\5\0016\1\0\0009\1\1\0019\1\2\1'\3\3\0'\4\b\0'\5\t\0005\6\n\0=\0\a\6B\1\5\1K\0\1\0\1\0\0\24<cmd>AerialNext<CR>\6}\vbuffer\1\0\0\24<cmd>AerialPrev<CR>\6{\6n\bset\vkeymap\bvimN\1\0\4\0\6\0\t6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0003\3\3\0=\3\5\2B\0\2\1K\0\1\0\14on_attach\1\0\0\0\nsetup\vaerial\frequire\0", "config", "aerial.nvim")
time([[Config for aerial.nvim]], false)
-- Config for: lualine.nvim
time([[Config for lualine.nvim]], true)
try_loadstring("\27LJ\2\n&\0\1\2\0\2\0\6\6\0\0\0X\1\2\f\1\0\0X\1\1'\1\1\0L\1\2\0\6 \tmain&\0\1\2\0\2\0\6\6\0\0\0X\1\2\f\1\0\0X\1\1'\1\1\0L\1\2\0\5\nutf-8Ú\3\1\0\a\0\28\0%6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\0025\3\a\0005\4\6\0=\4\b\0035\4\f\0005\5\t\0003\6\n\0=\6\v\5>\5\1\4=\4\r\0035\4\14\0=\4\15\0035\4\16\0=\4\17\0034\4\3\0005\5\18\0003\6\19\0=\6\v\5>\5\1\0045\5\20\0>\5\2\4=\4\21\0035\4\22\0=\4\23\3=\3\24\0025\3\26\0005\4\25\0=\4\15\3=\3\27\2B\0\2\1K\0\1\0\vwinbar\1\0\0\1\2\0\0\nnavic\rsections\14lualine_z\1\3\0\0\rlocation\rprogress\14lualine_y\1\2\2\0\rfiletype\14icon_only\2\fcolored\2\0\1\2\0\0\rencoding\14lualine_x\1\2\0\0\15diagnostic\14lualine_c\1\2\0\0\vaerial\14lualine_b\1\3\0\0\0\tdiff\bfmt\0\1\2\0\0\vbranch\14lualine_a\1\0\0\1\2\0\0\rfilename\foptions\1\0\0\1\0\3\25component_separators\6|\ntheme\fonedark\23section_separators\5\nsetup\flualine\frequire\0", "config", "lualine.nvim")
time([[Config for lualine.nvim]], false)
-- Config for: themer.lua
time([[Config for themer.lua]], true)
try_loadstring("\27LJ\2\nµ\1\0\0\5\0\n\0\r6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\5\0005\4\4\0=\4\6\0035\4\a\0=\4\b\3=\3\t\2B\0\2\1K\0\1\0\vstyles\20variableBuiltIn\1\0\1\nstyle\vitalic\20functionBuiltIn\1\0\0\1\0\1\nstyle\vitalic\1\0\1\16colorscheme\16monokai_pro\nsetup\vthemer\frequire\0", "config", "themer.lua")
time([[Config for themer.lua]], false)
-- Load plugins in order defined by `after`
time([[Sequenced loading]], true)
vim.cmd [[ packadd lsp-zero.nvim ]]
time([[Sequenced loading]], false)

_G._packer.inside_compile = false
if _G._packer.needs_bufread == true then
  vim.cmd("doautocmd BufRead")
end
_G._packer.needs_bufread = false

if should_profile then save_profiles() end

end)

if not no_errors then
  error_msg = error_msg:gsub('"', '\\"')
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
