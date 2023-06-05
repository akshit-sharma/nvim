
-- learn from https://github.com/s1n7ax/nvim-terminal/

local Split = require('nui.split')
--local event = require('nui.utils.autocmd').event

local split_options = {
  relative = 'editor',
  position = 'bottom',
  size = '20%',
}

local terminalWindowID = -1
local terminalBufIDs = {}
local terminalCreates = {}
local split = nil

local createBuffer = function()
  local terminalBufID = vim.api.nvim_create_buf(false, true)
  if terminalBufID == 0 then
    return nil, false
  end
  table.insert(terminalBufIDs, terminalBufID)
  terminalCreates[terminalBufID] = true
  return terminalBufID, true
end

local lastValidBuffer = function(buffers)
  for i = #buffers, 1, -1 do
    if buffers[i] == nil or not vim.api.nvim_buf_is_valid(buffers[i]) then
      terminalCreates[buffers[i]] = false
      table.remove(buffers, i)
    else
      return buffers[i], terminalCreates[buffers[i]]
    end
  end
  local bufferID, _ = createBuffer()
  return bufferID, terminalCreates[bufferID]
end

function OpenTerminal(newTab)
  if split == nil then
    split = Split:new(split_options)
    split:mount()
  else
    split:show()
  end
  terminalWindowID = split.winid
  local bufferID, created = lastValidBuffer(terminalBufIDs)
  vim.notify('bufferID: ' .. bufferID .. ' split buffer ' .. split.bufnr)
  split.bufnr = bufferID
  vim.notify('bufferID: ' .. bufferID .. ' split buffer ' .. split.bufnr)
--  split:on(event.BufLeave, function()
--    split:unmount()
--  end)
end

function HideTerminal()
  if terminalWindowID ~= -1 or not vim.api.nvim_win_is_valid(terminalWindowID) then
    split:hide()
    --split:unmount()
    terminalWindowID = -1
  end
end

-- Map the key combination <C-j> in normal mode
KM('n', '<C-j>', '<Cmd>lua OpenTerminal()<CR>', NOREMAP_SILENT)

-- Map the key combination <C-j> in terminal mode
KM('t', '<C-j>', '<Cmd>lua HideTerminal()<CR>', NOREMAP_SILENT)
KM('t', '<C-\\><C-s>', '<Cmd>lua ToggleFullTerminal()<CR>', NOREMAP_SILENT)
KM('t', '<C-\\><C-t>', '<Cmd>lua OpenTerminal(true)<CR>', NOREMAP_SILENT)

