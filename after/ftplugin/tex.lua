-- Define the keymap in Lua
local function setup_tex_keymap()
  vim.api.nvim_set_keymap('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, noremap = true })
  vim.api.nvim_set_keymap('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, noremap = true })
    -- vim.keymap.set('n', 'j', 'gj', { nowait = true, silent = true })
    -- vim.keymap.set('n', 'k', 'gk', { nowait = true, silent = true })
end

setup_tex_keymap()
-- -- Auto-apply the keymap when editing TeX files
-- vim.cmd([[
--     augroup TeXKeymap
--         autocmd!
--         autocmd FileType tex lua setup_tex_keymap()
--     augroup END
-- ]])

