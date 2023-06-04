

local terminalWindowID = -1
local mainWindowID = -1
local terminalBufIDs = {}
local terminalCreates = {}

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
  height = 18,
  row = vim.api.nvim_get_option('lines') - 20,
  col = 0,
  focusable = true,
  --style = 'minimal',
}

local lastValidBuffer = function(buffers)
  for i = #buffers, 1, -1 do
    if buffers[i] == nil or not vim.api.nvim_buf_is_valid(buffers[i]) then
      terminalCreates[buffers[i]] = false
      table.remove(buffers, i)
    else
      return buffers[i], terminalCreates[buffers[i]]
    end
  end
  local bufferID, _ = CreateBuffer()
  return bufferID, terminalCreates[bufferID]
end

function CreateBuffer()
  HideTerminal()
  local terminalBufID = vim.api.nvim_create_buf(false, true)
  if terminalBufID == 0 then
    return nil, false
  end
  table.insert(terminalBufIDs, terminalBufID)
  terminalCreates[terminalBufID] = true
  return terminalBufID, true
end

function OpenTerminal(newTab)
  local terminalBufID = nil
  local initializeTerminal = false
  if newTab then
    terminalBufID, initializeTerminal = CreateBuffer()
  end
  if not initializeTerminal then
    terminalBufID, initializeTerminal = lastValidBuffer(terminalBufIDs)
  end
  if initializeTerminal then
    vim.notify('terminalBufID: '..terminalBufID .. ' with initTab')
  else
    vim.notify('terminalBufID: '..terminalBufID .. ' without initTab')
  end
  if terminalWindowID ~= -1 and vim.api.nvim_win_is_valid(terminalWindowID) then
    --vim.cmd('resize ' .. terminalWindowOptions.row)
    vim.api.nvim_set_current_win(terminalWindowID)
    vim.cmd('startinsert')
  end
  if terminalWindowID == -1 or not vim.api.nvim_win_is_valid(terminalWindowID) then
    --vim.cmd('resize ' .. terminalWindowOptions.row - 1)
    --vim.notify('should have resized main window')
    terminalWindowID = vim.api.nvim_open_win(terminalBufID, true, terminalWindowOptions)
    vim.api.nvim_win_set_buf(terminalWindowID, terminalBufID)
    vim.cmd('buffer '.. terminalBufID)
    if initializeTerminal then
      vim.cmd('terminal')
      ---@diagnostic disable-next-line: need-check-nil
      terminalCreates[terminalBufID] = false
    end
    vim.cmd('startinsert')
  end
end

local terminalBufferRegex = '^term.*bash$'

function HideTerminal()
  --[[
  local curBufName = vim.fn.bufname('%')
  if string.match(curBufName, terminalBufferRegex) then
    vim.cmd('hide')
  end
  ]]--
  if terminalWindowID ~= -1 and vim.api.nvim_win_is_valid(terminalWindowID) then
    vim.api.nvim_win_hide(terminalWindowID)
--    vim.cmd('resize ' .. (vim.api.nvim_get_option('lines') - 1))
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

