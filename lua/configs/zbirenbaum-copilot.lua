return function()
  require'copilot'.setup({
    filetype = {
      cpp = function()
        if string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), '^%.leetcode.*') then
          return false
        end
        return true
      end,
      c = true,
      lua = true,
      tex = true,
      python = true,
      markdown = true,
      sh = true,
      zsh = true,
      typescript = true,
      javascript = true,
      html = true,
      css = true,
      rust = true,
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
