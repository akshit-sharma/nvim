return {
  "jiaoshijie/undotree",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = true,
  lazy = true,
  cmd = { "UndotreeToggle" },
  keys = {
    { "<leader>u", "<cmd>UndotreeToggle<cr>", desc = "Toggle Undotree" },
  },
}
