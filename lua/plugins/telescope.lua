return {
  'nvim-telescope/telescope.nvim',
  branch = '0.1.x',
  lazy = true,
  dependencies = {
    { 'nvim-lua/plenary.nvim' },
    { 'nvim-tree/nvim-web-devicons' },
  },
  cmd = "Telescope",
  keys = {
    { "<leader><space>", function() require("telescope.builtin").buffers() end, desc = "Buffers" },
    { "<leader>sh", function() require("telescope.builtin").help_tags() end, desc = "[S]earch [H]elp Tags" },
    { "<leader>sf", function() require("telescope.builtin").find_files() end, desc = "[S]earch [F]iles" },
    { "<leader>sg", function() require("telescope.builtin").find_grep() end, desc = "[S]earch by [G]rep" },
    { "<leader>sw", function() require("telescope.builtin").grep_string() end, desc = "[S]earch current [W]ord" },
    { "<leader>sd", function() require("telescope.builtin").diagnostics() end, desc = "[S]earch [D]iagnostics" },
    { "<leader>tt", function() require("telescope.builtin").builtin() end, desc = "[T]elescope buil[T]in" },
    { "<leader>td", function() require("telescope.builtin").diagnosics() end, desc = "[T]elescope [D]iagnostics" },
  },
  opts = require'configs.telescope',
}
