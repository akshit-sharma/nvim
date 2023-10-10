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

-- vim.lsp.set_log_level('debug')

local lsp = require("lsp-zero").preset({})

local attach = function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})

  local opts = {buffer = bufnr}
  local bind = vim.keymap.set

  bind('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  bind('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  bind('n', '<leader>fm', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
  bind('v', '<leader>fm', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
  bind('v', '<leader>ca', '<cmd>lua vim.lsp.buf.range_code_action()<CR>', opts)

  -- lsp.default_keymaps({buffer = bufnr, preserve_mappings = false})
end

lsp.on_attach(attach)

lsp.extend_cmp()

local cmp = require('cmp')

cmp.setup({
  mapping = {
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-k>'] = cmp.mapping.confirm({
      -- behavior = cmp.ConfirmBehavior.Insert,
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
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'copilot' },
    { name = 'luasnip' },
    { name = 'path' },
  }, {
    { name = 'buffer' },
  }),
})

function ReadSpellFile(filename)
  local filepath = vim.fn.stdpath('config') .. '/spell/ltex.' .. filename .. '.txt'
  local words = {}
  if vim.fn.filereadable(filepath) ~= 1 then
    return words
  end
  for word in io.open(filepath, "r"):lines() do
    table.insert(words, word)
  end
  return words
end

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
    ltex = function()
      require'lspconfig'.ltex.setup({
        on_attach = function(client, bufnr)
          lsp.default_keymaps({buffer = bufnr, preserve_mappings = false})
          require'ltex_extra'.setup {
            load_langs = "en-US",
            path = vim.fn.stdpath('config') .. '/spell',
          }
        end,
        settings = {
          ltex = {
            language = "en-US",
            dictionary = {
              ["en-US"] = ReadSpellFile('dictionary.en-US'),
            },
            disabledRules = {
              ["en-US"] = ReadSpellFile('disabledRules.en-US'),
            },
            hiddenFalsePositives = {
              ["en-US"] = ReadSpellFile('hiddenFalsePositives.en-US'),
            },
          },
        },
      })
    end,
  },
})

lsp.set_sign_icons({
  error = '✘',
  warn = '▲',
  hint = '⚑',
  info = ''
})

lsp.setup()

