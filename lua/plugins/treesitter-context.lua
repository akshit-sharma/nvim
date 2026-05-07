return {
  'nvim-treesitter/nvim-treesitter-context',
  enable = false,
  lazy = true,
  opts = {
    enable = true,
    max_lines = 5,
    seperator = "-",
  },
  keys = {
    { "[c", function() require("treesitter-context").go_to_context(vim.v.count1) end },
  },
}
