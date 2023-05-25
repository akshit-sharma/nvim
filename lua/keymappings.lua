vim.g.mapleader = '\\'

KM('n', vim.g.mapleader, '<NOP>')
KM('n', '<Leader>e', ':Lexplore<CR>')

vim.g.copilot_no_tab_map = true

local command = 'term://bash'
function TerminalOnce()
  if vim.fn.bufwinnr('$') == 1 then
    vim.cmd('botright 20new | terminal')
  else
    vim.cmd('terminal')
  end
end

KM('n', '<C-j>', ':lua TerminalOnce()', NOREMAP_SILENT)
-- use make movement from terminal to window same as between windows
KM('t', '<C-w>h', '<C-\\><C-n><C-w>h', NOREMAP_SILENT)
KM('t', '<C-w>j', '<C-\\><C-n><C-w>j', NOREMAP_SILENT)
KM('t', '<C-w>k', '<C-\\><C-n><C-w>k', NOREMAP_SILENT)
KM('t', '<C-w>l', '<C-\\><C-n><C-w>l', NOREMAP_SILENT)

KM('n', '<Leader>v', ':Vista!!<CR>')

KM('n', '<Leader>sot', ':SymbolsOutline<CR>')
KM('n', '<Leader>soo', ':SymbolsOutlineOpen<CR>')
KM('n', '<Leader>soc', ':SymbolsOutlineClose<CR>')

KM('n', '<Leader>aa', ':AerialToggle!<CR>')

-- Remaps for the refactoring operations currently offered by the plugin
vim.api.nvim_set_keymap("v", "<leader>re", [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Function')<CR>]], {noremap = true, silent = true, expr = false})
vim.api.nvim_set_keymap("v", "<leader>rf", [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Function To File')<CR>]], {noremap = true, silent = true, expr = false})
vim.api.nvim_set_keymap("v", "<leader>rv", [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Variable')<CR>]], {noremap = true, silent = true, expr = false})
vim.api.nvim_set_keymap("v", "<leader>ri", [[ <Esc><Cmd>lua require('refactoring').refactor('Inline Variable')<CR>]], {noremap = true, silent = true, expr = false})

-- Extract block doesn't need visual mode
vim.api.nvim_set_keymap("n", "<leader>rb", [[ <Cmd>lua require('refactoring').refactor('Extract Block')<CR>]], {noremap = true, silent = true, expr = false})
vim.api.nvim_set_keymap("n", "<leader>rbf", [[ <Cmd>lua require('refactoring').refactor('Extract Block To File')<CR>]], {noremap = true, silent = true, expr = false})

-- Inline variable can also pick up the identifier currently under the cursor without visual mode
vim.api.nvim_set_keymap("n", "<leader>ri", [[ <Cmd>lua require('refactoring').refactor('Inline Variable')<CR>]], {noremap = true, silent = true, expr = false})

-- prompt for a refactor to apply when the remap is triggered
vim.api.nvim_set_keymap(
    "v",
    "<leader>rr",
    ":lua require('refactoring').select_refactor()<CR>",
    { noremap = true, silent = true, expr = false }
)
