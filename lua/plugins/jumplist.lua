return {
  dir = vim.fn.stdpath("config"),
  name = "jumplist",
  cmd = { "JumplistToggle" },
  keys = {
    { "<leader>j", "<cmd>JumplistToggle<CR>", desc = "Toggle Jumplist Tree Side Pane" },
    { "<space>j", "<cmd>JumplistToggle<CR>", desc = "Toggle Jumplist Tree Side Pane (Space)" },
    { "<BS>j", "<cmd>JumplistToggle<CR>", desc = "Toggle Jumplist Tree Side Pane (Backspace)" },
  },
  config = function()
    vim.api.nvim_create_user_command("JumplistToggle", function()
      require("features.jumplist").toggle_tree()
    end, {})
  end,
}
