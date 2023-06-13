return function ()
  return require('goto-preview').setup{
    default_mappings = true,
    post_open_hook = function(_, win)
      vim.keymap.set('n', '<Esc>', function()
        vim.api.nvim_win_close(win, true)
      end,
      { buffer = true }
      )
    end
  }
end
