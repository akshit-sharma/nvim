local function get_workspace_root()
  local taskbus = require("core.taskbus")
  local root = taskbus.get("search_root")
  -- If Taskbus is empty (e.g. fresh startup), fallback to CWD
  return (root ~= "") and root or vim.fn.getcwd()
end

return {
  'nvim-telescope/telescope.nvim',
  lazy = true,
  dependencies = {
    { 'nvim-lua/plenary.nvim' },
    { 'nvim-tree/nvim-web-devicons' },
    { 'folke/trouble.nvim' },
  },
  cmd = "Telescope",
  keys = {
    -- 1. GLOBAL SEARCH (Files)
    {
      "sf",
      function()
        require("telescope.builtin").find_files({ cwd = get_workspace_root(), hidden = true })
      end,
      desc = "Search Files (Fast)"
    },
    {
      "<leader>sf",
      function()
        require("telescope.builtin").find_files({ cwd = get_workspace_root(), hidden = true })
      end,
      desc = "Search Files (Leader)"
    },

    -- 2. PROJECT GREP
    {
      "sg",
      function()
        require("telescope.builtin").live_grep({ cwd = get_workspace_root() })
      end,
      desc = "Grep Project (Fast)"
    },
    {
      "<leader>sg",
      function()
        require("telescope.builtin").live_grep({ cwd = get_workspace_root() })
      end,
      desc = "Grep Project (Leader)"
    },

    -- 3. SYMBOLS (Treesitter)
    {
      "ss",
      function()
        if not require("core.registry").is_massive() then require("telescope.builtin").treesitter() end
      end,
      desc = "Search Symbols (Fast)"
    },
    {
      "<leader>ss",
      function()
        if not require("core.registry").is_massive() then require("telescope.builtin").treesitter() end
      end,
      desc = "Search Symbols (Leader)"
    },

    -- 4. DIAGNOSTICS
    { "sd",              function() require("telescope.builtin").diagnostics() end, desc = "Diagnostics (Fast)" },
    { "<leader>sd",      function() require("telescope.builtin").diagnostics() end, desc = "Diagnostics (Leader)" },

    -- 5. CURRENT WORD
    { "sw",              function() require("telescope.builtin").grep_string() end, desc = "Search Word (Fast)" },
    { "<leader>sw",      function() require("telescope.builtin").grep_string() end, desc = "Search Word (Leader)" },
    { "sp", function()
      require("telescope.builtin").find_files({
        prompt_title = "Select Particular Workspace",
        cwd = vim.fn.input("Custom Root: ", vim.fn.getcwd(), "dir")
      })
    end, desc = "Search Particular Path" },
    { "<leader>sp", function()
      require("telescope.builtin").find_files({
        prompt_title = "Select Particular Workspace",
        cwd = vim.fn.input("Custom Root: ", vim.fn.getcwd(), "dir")
      })
    end, desc = "Search Particular Path" },

    -- Standard Leader-only Builtins
    { "<space><space>", function() require("telescope.builtin").buffers() end,     desc = "Buffers" },
    { "<leader><space>", function() require("telescope.builtin").buffers() end,     desc = "Buffers" },
    { "<leader>sh",      function() require("telescope.builtin").help_tags() end,   desc = "Search Help" },
    { "<leader>tt",      function() require("telescope.builtin").builtin() end,     desc = "Telescope Builtins" },
  },
  opts = require('configs.telescope'),
}
