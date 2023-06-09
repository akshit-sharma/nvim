local terminalBufIDs = {}
local terminalCreates = {}
local lastUsedBuffer = nil

local Split = require('nui.split')
local Popup = require('nui.popup')

local event = require('nui.utils.autocmd').event

local split = Split({
  relative = 'editor',
  position = 'bottom',
  size = 20,
})

split:on(event.WinClosed, function()
  split:hide()
end)

local popup = Popup({
  enter = true,
  focusable = true,
  border = {
    style = 'rounded',
    text = {
      top = "Float Terminal",
      top_align = "center",
    },
  },
  position = '50%',
  size = {
    width = "80%",
    height = "60%",
  },
})

popup:on(event.WinClosed, function()
  popup:hide()
end)

---@diagnostic disable-next-line: unused-local
local function postTermBuf(bufID)
  vim.cmd('startinsert')
end

local terminalInitialization = function(termBufID)
  terminalCreates[termBufID] = postTermBuf
  vim.cmd('terminal')
  local envFile = 'env/bin/activate'
  if vim.fn.filereadable(envFile) == 1 then
    vim.fn.chansend(vim.b.terminal_job_id, 'source ' .. envFile .. '\n')
  end
  postTermBuf(termBufID)
end

local function createBuffer()
  local terminalBufID = vim.api.nvim_create_buf(false, true)
  if terminalBufID == 0 then
    return nil, false
  end
  table.insert(terminalBufIDs, terminalBufID)
  terminalCreates[terminalBufID] = terminalInitialization
  return terminalBufID, true
end

local function validBuffer(newTerm)
  if newTerm == true then
    local bufferID, _ = createBuffer()
    return bufferID, terminalCreates[bufferID]
  end
  for i = #terminalBufIDs, 1, -1 do
    if terminalBufIDs[i] == nil or not vim.api.nvim_buf_is_valid(terminalBufIDs[i]) then
      if lastUsedBuffer ~= terminalBufIDs[i] then
        lastUsedBuffer = nil
      end
      terminalCreates[terminalBufIDs[i]] = postTermBuf
      table.remove(terminalBufIDs, i)
    else
      return terminalBufIDs[i], terminalCreates[terminalBufIDs[i]]
    end
  end
  local bufferID, _ = createBuffer()
  return bufferID, terminalCreates[bufferID]
end

local createNuiHandler = function(nuiComponent)
  local visibility = false
  local initialized = false
  local hide = function()
    if visibility == true then
      nuiComponent:hide()
      visibility = false
    end
    return -1
  end
  return hide, function(bufferID, winID)
    nuiComponent.bufnr = bufferID
    if initialized == true and visibility == true and winID ~= nuiComponent.winid then
      vim.fn.win_gotoid(nuiComponent.winid)
      return nuiComponent.winid
    end
    if initialized == true and visibility == true then
      return hide()
    end
    if initialized == true then
        nuiComponent:show()
    end
    if initialized == false then
        initialized = true
        nuiComponent:mount()
    end
    visibility = true
    return nuiComponent.winid
  end
end

local splitHide, splitHandler  = createNuiHandler(split)
local popupHide, popupHandler = createNuiHandler(popup)

function ToggleSplitWin(newTab)
  popupHide()
  local curWin = vim.api.nvim_get_current_win()
  local bufId, termCallback = validBuffer(newTab)
  splitHandler(bufId, curWin)
  termCallback(bufId)
end

function ToggleFloatWin(newTab)
  splitHide()
  local curWin = vim.api.nvim_get_current_win()
  local bufId, termCallback = validBuffer(newTab)
  popupHandler(bufId, curWin)
  termCallback(bufId)
end

-- Map the key combination <C-j> in normal mode
KM('n', '<C-j>', '<Cmd>lua ToggleSplitWin(false)<CR>', NOREMAP_SILENT)
KM('n', '<C-\\><C-s>', '<Cmd>lua ToggleFullScreenTerminal()<CR>', NOREMAP_SILENT)
KM('n', '<C-\\><C-f>', '<Cmd>lua ToggleFloatWin(false)<CR>', NOREMAP_SILENT)

-- Map the key combination <C-j> in terminal mode
KM('t', '<C-j>', '<Cmd>lua ToggleSplitWin(false)<CR>', NOREMAP_SILENT)
KM('t', '<C-\\><C-s>', '<Cmd>lua ToggleFullScreenTerminal()<CR>', NOREMAP_SILENT)
KM('t', '<C-\\><C-f>', '<Cmd>lua ToggleFloatWin(false)<CR>', NOREMAP_SILENT)
KM('t', '<C-\\><C-t>', '<Cmd>lua OpenTerminal(true)<CR>', NOREMAP_SILENT)

-- use make movement from terminal to window same as between windows
KM('t', '<M-w>', '<C-\\><C-n><C-w>', NOREMAP_SILENT)

