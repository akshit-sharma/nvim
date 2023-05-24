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
