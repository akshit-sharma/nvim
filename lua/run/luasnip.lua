local nvimDir = vim.fn.stdpath('config') .. '/'
require('luasnip.loaders.from_lua').load({ paths = nvimDir .. 'LuaSnip' })
