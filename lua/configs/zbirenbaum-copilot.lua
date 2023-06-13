return function()
  require'copilot'.setup({
    filetype = {
      ["*"] = true
    },
    suggestion = {
      keymap = {
        accept = "<C-x><C-e>",
        accept_word = "<C-x><C-w>",
        accept_line = "<C-x><C-l>",
      },
    },
  })
end
