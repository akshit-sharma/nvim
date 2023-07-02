local terminalBufIDs = {}
local terminalCreates = {}

local lastUsedBuffer = nil

local Split = require('nui.split')
local Popup = require('nui.popup')
local Menu = require('nui.menu')

local autocmd = require('nui.utils.autocmd')
local event = require('nui.utils.autocmd').event

local split = Split({
  relative = 'editor',
  position = 'bottom',
  size = 20,
})

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

---@diagnostic disable-next-line: unused-local
local function postTermBuf(bufID)
  vim.notify('called postTermBuf', vim.log.levels.INFO)
  --vim.cmd('startinsert')
end

local function removeColors(expr)
  expr = vim.fn.substitute(expr, '01;32m', '', 'g')
  expr = vim.fn.substitute(expr, '01;34m', '', 'g')
  expr = vim.fn.substitute(expr, '00m', '', 'g')
  expr = vim.fn.substitute(expr, '033', '', 'g')
  expr = vim.fn.substitute(expr, '\\\\[', '', 'g')
  expr = vim.fn.substitute(expr, '\\\\]', '', 'g')
  return expr
end

local function computeCommandPrefix(expr, currentDir)
  if expr == nil then
    expr = vim.env.PS1
  end
  if currentDir == nil then
    currentDir = vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
  end

  local cmd_prefix = expr
  cmd_prefix = vim.fn.substitute(expr, '${debian_chroot:+($debian_chroot)}', '', 'g')
  cmd_prefix = removeColors(cmd_prefix)
  cmd_prefix = vim.fn.substitute(cmd_prefix, '\\\\u', vim.env.USER, 'g')
  cmd_prefix = vim.fn.substitute(cmd_prefix, '\\\\h', vim.loop.os_gethostname(), 'g')
  cmd_prefix = vim.fn.substitute(cmd_prefix, '\\\\W', currentDir, 'g')
  cmd_prefix = vim.fn.substitute(cmd_prefix, '\\\\\\$', '$', 'g')
  --cmd_prefix = vim.fn.substitute(cmd_prefix, '\\\\$', '$', 'g')

  return cmd_prefix
end

local terminalInitialization = function(termBufID)
  terminalCreates[termBufID] = postTermBuf
  vim.cmd('terminal')
  local envFile = 'env/bin/activate'
  if vim.fn.filereadable(envFile) == 1 then
    vim.fn.chansend(vim.b.terminal_job_id, 'source ' .. envFile .. '\n')
  end
  --postTermBuf(termBufID)
end

local function createBuffer()
  local terminalBufID = vim.api.nvim_create_buf(false, true)
  if terminalBufID == 0 then
    vim.notify('Failed to create terminal buffer', vim.log.levels.ERROR)
    return nil, nil
  end
  table.insert(terminalBufIDs, terminalBufID)
  autocmd.buf.define(terminalBufID, event.BufEnter, function()
    vim.notify('BufEnter from buf autocmd', vim.log.levels.INFO)
    terminalInitialization(terminalBufID)
  end, {once=true})
  --[[
  autocmd.buf.define(terminalBufID, event.TermOpen, function()
    vim.notify('TermOpen from buf autocmd', vim.log.levels.INFO)
    --vim.cmd('startinsert')
  end, {once=true})
  ]]--
  terminalCreates[terminalBufID] = postTermBuf -- terminalInitialization
  return terminalBufID, terminalCreates[terminalBufID]
end

local function validBufferIndex(i)
  if terminalBufIDs[i] == nil or not vim.api.nvim_buf_is_valid(terminalBufIDs[i]) then
    terminalCreates[terminalBufIDs[i]] = postTermBuf
    table.remove(terminalBufIDs, i)
    return false
  end
  return true
end

local function bufferChooser(newTerm)
  if newTerm == true then
    local bufferID, _ = createBuffer()
    lastUsedBuffer = bufferID
    return bufferID, terminalCreates[bufferID]
  end
  if lastUsedBuffer ~= nil and vim.api.nvim_buf_is_valid(lastUsedBuffer) then
    return lastUsedBuffer, terminalCreates[lastUsedBuffer]
  end
  lastUsedBuffer = nil
  for i = #terminalBufIDs, 1, -1 do
    if validBufferIndex(i) then
      lastUsedBuffer = terminalBufIDs[i]
      return terminalBufIDs[i], terminalCreates[terminalBufIDs[i]]
    end
  end
  local bufferID, _ = createBuffer()
  lastUsedBuffer = bufferID
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
    return nil
  end
  local function setBufCallbacks(bufnr)
    autocmd.buf.define(bufnr, event.TermOpen, function()
      vim.notify('TermOpen', vim.log.levels.INFO)
      initialized = true
      visibility = true
      --nuiComponent:show()
    end, {once=true})
    autocmd.buf.define(bufnr, event.TermClose, function()
      vim.notify('TermClose', vim.log.levels.INFO)
      --nuiComponent:hide()
    end, {once=true})
    autocmd.buf.define(bufnr, event.TermChanged, function()
      vim.notify('TermChanged', vim.log.levels.INFO)
      --nuiComponent:hide()
    end, {once=true})
    autocmd.buf.define(bufnr, event.TermEnter, function()
      vim.notify('TermEnter', vim.log.levels.INFO)
    end, {once=true})
    autocmd.buf.define(bufnr, event.BufHidden, function()
      vim.notify('BufHidden', vim.log.levels.INFO)
      nuiComponent:hide()
    end, {once=true})
    autocmd.buf.define(bufnr, event.BufLeave, function()
      vim.notify('BufLeave', vim.log.levels.INFO)
      --nuiComponent:hide()
    end, {once=true})
    autocmd.buf.define(bufnr, event.BufEnter, function()
      vim.notify('BufEnter', vim.log.levels.INFO)
      nuiComponent:show()
    end, {once=true})
    autocmd.buf.define(bufnr, event.BufWinEnter, function()
      vim.notify('BufWinEnter', vim.log.levels.INFO)
      nuiComponent:show()
    end, {once=true})
    autocmd.buf.define(bufnr, event.BufWinLeave, function()
      vim.notify('BufWinLeave', vim.log.levels.INFO)
      nuiComponent:hide()
    end, {once=true})
  end
  return hide, function(bufferID, winID)
    if nuiComponent.winid ~= nil and not vim.api.nvim_win_is_valid(nuiComponent.winid) then
      initialized = false
    end
    if initialized == true and visibility == true then
      if bufferID ~= nuiComponent.bufnr then
        --vim.notify('Buffer ID ' .. bufferID .. ' does not match ' .. nuiComponent.bufnr, vim.log.levels.ERROR)
      end
      if nuiComponent.winid ~= nil and winID ~= nuiComponent.winid then
        --vim.notify('initialized and visibility, winId and nuiWinId ' .. tostring(winID) .. ' does not match ' .. tostring(nuiComponent.winid), vim.log.levels.ERROR)
        vim.fn.win_gotoid(nuiComponent.winid)
        nuiComponent.bufnr = bufferID
        --setBufCallbacks(bufferID)
        return nuiComponent
      end
    end
    nuiComponent.bufnr = bufferID
    if initialized == true and visibility == true then
      --vim.notify('hiding', vim.log.levels.INFO)
      hide()
      return nil
    end
    if initialized == true then
      --vim.notify('showing already initialized', vim.log.levels.INFO)
      nuiComponent:show()
    end
    if initialized == false then
      --vim.notify('mounting', vim.log.levels.INFO)
      initialized = true
      nuiComponent:mount()
    end
    visibility = true
    nuiComponent.bufnr = bufferID
    setBufCallbacks(nuiComponent.bufnr)
    --setBufCallbacks(bufferID)
    return nuiComponent
  end
end

local splitHide, splitHandler  = createNuiHandler(split)
local popupHide, popupHandler = createNuiHandler(popup)
local lastHandler = nil

function ToggleSplitWin()
  popupHide()
  local curWin = vim.api.nvim_get_current_win()
  local bufId, termCallback = bufferChooser()
  local nuiComponent = splitHandler(bufId, curWin)
  --setBufCallbacks(nuiComponent)
  termCallback(bufId)
  lastHandler = splitHandler
end

function ToggleFloatWin()
  splitHide()
  local curWin = vim.api.nvim_get_current_win()
  local bufId, termCallback = bufferChooser()
  local nuiComponent = popupHandler(bufId, curWin)
  --setBufCallbacks(nuiComponent)
  termCallback(bufId)
  lastHandler = popupHandler
end

function NewTerminal()
  local bufId, termCallback = createBuffer()
  if bufId == nil or termCallback == nil then return end
  lastHandler(bufId)
  termCallback(bufId)
end

local function bufferMenus()
  local menuItems = {}
  for i = #terminalBufIDs, 1, -1 do
    if validBufferIndex(i) then
      table.insert(menuItems, Menu.item('Terminal ' .. i .. ' (b#'.. terminalBufIDs[i] .. ')', { id = terminalBufIDs[i], callback=function()
        local bufId = terminalBufIDs[i]
        local termCallback = terminalCreates[bufId]
        lastHandler(bufId)
        vim.cmd('buffer ' .. bufId)
        termCallback(bufId)
        return bufId
      end }))
    end
  end
  return menuItems
end

function TerminalMenu()
  local lines = bufferMenus()
  local menu = Menu({
    position = '50%',
    size = {
      width = 30,
      height = 5,
    },
    border = {
      style = 'single',
      text = {
        top = "[Choose Terminal]",
        top_align = "center",
      },
    },
    win_options = {
      winhighlight = "Normal:Normal,FloatBorder:Normal",
    },
  }, {
    lines = lines,
    max_width = 25,
    keymap = {
      focus_next = {"j", "<C-n>"},
      focus_prev = {"k", "<C-p>"},
      close = {"q", "<Esc>"},
      submit = {"<CR>", "<C-y>"},
    },
    on_close = function()
      popup:hide()
    end,
    on_submit = function(item)
      --vim.notify('Selected ' .. item.id, vim.log.levels.INFO)
      lastUsedBuffer = item.callback()
    end,
  })
  menu:mount()
end

-- Map the key combination <C-j> in normal mode
KM('n', '<C-j>', '<Cmd>lua ToggleSplitWin()<CR>', NOREMAP_SILENT)
KM('n', '<C-\\><C-s>', '<Cmd>lua ToggleFullScreenTerminal()<CR>', NOREMAP_SILENT)
KM('n', '<C-\\><C-f>', '<Cmd>lua ToggleFloatWin()<CR>', NOREMAP_SILENT)

-- Map the key combination <C-j> in terminal mode
KM('t', '<C-j>', '<Cmd>lua ToggleSplitWin()<CR>', NOREMAP_SILENT)
KM('t', '<C-\\><C-s>', '<Cmd>lua ToggleFullScreenTerminal()<CR>', NOREMAP_SILENT)
KM('t', '<C-\\><C-f>', '<Cmd>lua ToggleFloatWin()<CR>', NOREMAP_SILENT)
KM('t', '<C-\\><C-t>', '<Cmd>lua NewTerminal()<CR>', NOREMAP_SILENT)

KM('t', '<C-\\><C-e>', '<Cmd>lua TerminalMenu()<CR>', NOREMAP_SILENT)

-- use make movement from terminal to window same as between windows
KM('t', '<M-w>', '<C-\\><C-n><C-w>', NOREMAP_SILENT)

