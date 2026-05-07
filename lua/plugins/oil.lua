return {
  "stevearc/oil.nvim",
  lazy = true,
  opts = {},
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "<C-->", "<cmd>Oil<cr>", desc = "Open parent directory" },
  },
  cmd = { "Oil" },
}
