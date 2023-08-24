-- Define the keymap in Lua
local function setup_tex_keymap()
  vim.api.nvim_set_keymap('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, noremap = true })
  vim.api.nvim_set_keymap('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, noremap = true })
end

local function setup_cmp()
  if not pcall(require, 'cmp') then
    vim.notify("cmp not found", vim.log.levels.ERROR)
    return
  end
  local cmp = require('cmp')
  cmp.setup({ sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'copilot' },
    { name = 'luasnip' },
    { name = 'omni', option = { disable_omnifuncs = { 'v:lua.vim.lsp.omnifunc' } } },
  }),
  })
end

setup_tex_keymap()
setup_cmp()

