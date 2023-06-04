local Terminal = require('toggleterm.terminal').Terminal

function TerminalNew()
  local newTerminal = Terminal:new({ })
  newTerminal:toggle()
  return newTerminal
end

vim.notify('Loaded toggleterm config', 'info', { title = 'toggleterm' })
