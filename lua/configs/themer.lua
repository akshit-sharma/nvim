return function()
  require'themer'.setup({
    colorscheme = "monokai_pro",
    -- colorscheme = "dracula",
    styles = {
      functionBuiltIn = { style = 'italic' },
      variableBuiltIn = { style = 'italic' },
    }
  })
end
