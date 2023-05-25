local ok, themer = pcall(require, "themer")
if not ok then
  vim.notify('themer.configs not available', vim.log.levels.ERROR)
  return
end

themer.setup({
  colorscheme = "monokai_pro",
  -- colorscheme = "dracula",
  styles = {
    functionBuiltIn = { style = 'italic' },
    variableBuiltIn = { style = 'italic' },
  }
})
