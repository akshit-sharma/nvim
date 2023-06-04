vim.g.mapleader = '\\'

KM('n', vim.g.mapleader, '<NOP>')
KM('n', '<C-j>', '<Cmd>ToggleTerm<CR>', NOREMAP_SILENT)
KM('n', '<Leader>e', '<Cmd>Lexplore<CR>')
KM('n', '<C-\\><t>', '<Cmd>TermSelect<CR>', NOREMAP_SILENT)
KM('n', '<C-\\><C-n>', '<Cmd>TerminalNew()<CR>', NOREMAP_SILENT)

KM('t', '<C-j>', '<Cmd>ToggleTerm<CR>', NOREMAP_SILENT)
KM('t', '<C-\\><C-w>', '<C-\\><C-n><C-w>', NOREMAP_SILENT)
KM('t', '<M-w>', '<C-\\><C-n><C-w>', NOREMAP_SILENT)
KM('t', '<C-\\>t', '<Cmd>TermSelect<CR>', NOREMAP_SILENT)
KM('t', '<C-\\>trn', '<Cmd>ToggleTermSetName<CR>', NOREMAP)
KM('t', '<C-\\><C-t>', '<Cmd>TerminalNew()<CR>', NOREMAP_SILENT)

vim.g.copilot_no_tab_map = true

KM('n', '<Leader>v', '<Cmd>Vista!!<CR>')

KM('n', '<Leader>sot', '<Cmd>SymbolsOutline<CR>')
KM('n', '<Leader>soo', '<Cmd>SymbolsOutlineOpen<CR>')
KM('n', '<Leader>soc', '<Cmd>SymbolsOutlineClose<CR>')

KM('n', '<Leader>aa', '<Cmd>AerialToggle!<CR>')

KM("n", "<leader>red", '<Cmd>lua vim.lsp.buf.references({ includeDeclaration = false })<CR>', NOREMAP_SILENT) -- might remove let's see

KM("n", "<leader>bd", '<Cmd>w !diff % -<CR>', NOREMAP_SILENT)

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
