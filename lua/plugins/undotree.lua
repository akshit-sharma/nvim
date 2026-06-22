return {
  "jiaoshijie/undotree",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = true,
  cmd = { "UndotreeToggle" },
  keys = {
    { "<leader>u", "<cmd>UndotreeToggle<cr>", desc = "Toggle Undotree" },
    { "<space>u", "<cmd>UndotreeToggle<cr>", desc = "Toggle Undotree (Space)" },
    { "<BS>u", "<cmd>UndotreeToggle<cr>", desc = "Toggle Undotree (Backspace)" },
  },
  config = function(_, opts)
    require("undotree").setup(opts)
    vim.api.nvim_create_user_command("UndotreeToggle", function()
      require("undotree").toggle()
    end, {})
  end,
}
