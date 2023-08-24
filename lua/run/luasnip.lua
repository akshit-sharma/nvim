local nvimDir = vim.fn.stdpath('config') .. '/'
vim.notify("loading luasnip from " .. nvimDir .. 'LuaSnip', vim.log.levels.INFO)
require('luasnip.loaders.from_lua').load({ paths = nvimDir .. 'LuaSnip' })
