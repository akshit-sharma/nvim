return function()
  require'themer'.setup({
    colorscheme = "tokyonight",
    -- colorscheme = "monokai_pro",
    -- colorscheme = "dracula",
    styles = {
      functionBuiltIn = { style = 'italic' },
      variableBuiltIn = { style = 'italic' },
    }
  })
end
