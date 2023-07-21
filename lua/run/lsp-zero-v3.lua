if not pcall(require, 'cmp') then
  vim.notify("cmp not found", vim.log.levels.ERROR)
  return
end

if not pcall(require, 'lsp-zero') then
  vim.notify("lsp-zero not found", vim.log.levels.ERROR)
  return
end

if not pcall(require, 'mason') then
  vim.notify("mason not found", vim.log.levels.ERROR)
  return
end

if not pcall(require, 'mason-lspconfig') then
  vim.notify("mason-lspconfig not found", vim.log.levels.ERROR)
  return
end

if not pcall(require, 'lspconfig') then
  vim.notify("lspconfig not found", vim.log.levels.ERROR)
  return
end

vim.lsp.set_log_level('debug')

local lsp = require("lsp-zero").preset({})

local attach = function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr, preserve_mappings = false})
end

lsp.on_attach(attach)

lsp.extend_cmp()

local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()

cmp.setup({
  mapping = {
    ['<C-k>'] = cmp.mapping.confirm({
      -- behavio = cmp.ConfirmBehavior.Insert,
      select = true
    }),
    ['<C-x><C-k>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = true
    }),
    ['<C-x><C-n>'] = cmp.mapping(function(fallback)
      local status_ok, luasnip = pcall(require, 'luasnip')
      if status_ok and luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
    ['<C-x><C-p>'] = cmp.mapping(function(fallback)
      local status_ok, luasnip = pcall(require, 'luasnip')
      if status_ok and luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  },
})

require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = {
    'clangd',
    'cmake',
    'html',
    'jdtls',
    'ltex',
    'lua_ls',
    'pyright',
    'rust_analyzer',
    'tsserver',
    'vimls',
    'vimls',
    'volar',
    'yamlls',
  },
  handlers = {
    lsp.default_setup,
    lua_ls = function()
      require'lspconfig'.lua_ls.setup(lsp.nvim_lua_ls())
    end,
  },
})

lsp.setup()

