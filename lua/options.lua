local vimopt = vim.opt

vimopt.termguicolors = true
vimopt.updatetime = 300

vimopt.foldenable = false

vimopt.tabstop = 2
vimopt.shiftwidth = 2
vimopt.softtabstop = 2
vimopt.expandtab = true
vimopt.autoindent = true
vimopt.copyindent = true

vimopt.number = true
vimopt.relativenumber = true

vimopt.signcolumn = "yes"

vimopt.cmdheight = 2

vimopt.listchars = {
  tab = "»·",
  trail = "·",
  extends = "↪",
  precedes = "↩",
}

vimopt.background = "dark"
