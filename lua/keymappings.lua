vim.g.mapleader = '\\'

KM('n', vim.g.mapleader, '<NOP>')
KM('n', '<Leader>e', ':Lexplore<CR>')

vim.g.copilot_no_tab_map = true

local terminalWindowID = -1
local terminalBufIDs = {}

function IsBufferHidden(bufID)
  local windows = vim.api.nvim_list_wins()
  for _, winID in ipairs(windows) do
    local winBufID = vim.api.nvim_win_get_buf(winID)
    if winBufID == bufID then
      return false
    end
  end
  return true
end

local terminalWindowOptions = {
  relative = 'editor',
  width = vim.api.nvim_get_option('columns'),
  height = 20,
  row = vim.api.nvim_get_option('lines') - 20,
  col = 0,
  focusable = true,
  --style = 'minimal',
}

local lastValidBuffer = function(buffers)
  for i = #buffers, 1, -1 do
    return buffers[i]
  end
end

function OpenTerminal(newTab)
  local initializeTerminal = false
  if #terminalBufIDs == 0 or newTab then
    local terminalBufID = vim.api.nvim_create_buf(true, true)
    if terminalBufID == 0 then
      vim.notify('Failed to create terminal buffer', vim.log.levels.ERROR)
      return
    end
    table.insert(terminalBufIDs, terminalBufID)
    HideTerminal()
    initializeTerminal = true
  end
  local terminalBufID = lastValidBuffer(terminalBufIDs)
  if terminalWindowID ~= -1 and not vim.api.nvim_win_is_valid(terminalWindowID) then
    HideTerminal()
  end
  if terminalWindowID ~= -1 and vim.api.nvim_win_is_valid(terminalWindowID) then
    vim.api.nvim_set_current_win(terminalWindowID)
    vim.cmd('startinsert')
  end
  if terminalWindowID == -1 or not vim.api.nvim_win_is_valid(terminalWindowID) then
    terminalWindowID = vim.api.nvim_open_win(terminalBufID, true, terminalWindowOptions)
    vim.api.nvim_win_set_buf(terminalWindowID, terminalBufID)
    vim.cmd('buffer '.. terminalBufID)
    if initializeTerminal then
      vim.cmd('terminal')
    end
    vim.cmd('startinsert')
  end
end

local terminalBufferRegex = '^term.*bash$'

function HideTerminal()
  local curBufName = vim.fn.bufname('%')
  if string.match(curBufName, terminalBufferRegex) then
    vim.cmd('hide')
  end
end

local fullTerminalFlag = false
function ToggleFullTerminal()
  if fullTerminalFlag then
    HideTerminal()
    OpenTerminal()
  else
    vim.cmd('resize')
  end
  fullTerminalFlag = not fullTerminalFlag
end

-- Map the key combination <C-j> in normal mode
KM('n', '<C-j>', '<Cmd>lua OpenTerminal()<CR>', NOREMAP_SILENT)

-- Map the key combination <C-j> in terminal mode
KM('t', '<C-j>', '<Cmd>lua HideTerminal()<CR>', NOREMAP_SILENT)
KM('t', '<C-\\><C-s>', '<Cmd>lua ToggleFullTerminal()<CR>', NOREMAP_SILENT)
KM('t', '<C-\\><C-t>', '<Cmd>lua OpenTerminal(true)<CR>', NOREMAP_SILENT)

-- use make movement from terminal to window same as between windows
KM('t', '<C-w>h', '<C-\\><C-n><C-w>h', NOREMAP_SILENT)
KM('t', '<C-w>j', '<C-\\><C-n><C-w>j', NOREMAP_SILENT)
KM('t', '<C-w>k', '<C-\\><C-n><C-w>k', NOREMAP_SILENT)
KM('t', '<C-w>l', '<C-\\><C-n><C-w>l', NOREMAP_SILENT)

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
