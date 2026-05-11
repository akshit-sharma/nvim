return {
  'nvim-treesitter/nvim-treesitter',
  dependencies = {
    { 'nvim-treesitter/nvim-treesitter-textobjects' },
  },
  branch = 'main',
  build = ':TSUpdate',
  config = function()
    local filetypes = { "cpp", "lua", "python" }
    ---@diagnostic disable-next-line:missing-fields
    require('nvim-treesitter.configs').setup {
      ensure_installed = filetypes,
      sync_install = false,
      auto_install = true,
      highlight = { enable = true, },
      indent = { enable = true, },
      incremental_selection = { enable = true, },

      modules = {},
      ignore_install = {},

      textobjects = {
        select = {
          enable = true, lookahead = true,
          keymaps = {
            -- You can use the capture groups defined in textobjects.scm
            ["a="] = { query = "@assignment.outer", desc = "Select outer part of an assignment" },
            ["i="] = { query = "@assignment.inner", desc = "Select inner part of an assignment" },
            ["l="] = { query = "@assignment.lhs", desc = "Select left hand side of an assignment" },
            ["r="] = { query = "@assignment.rhs", desc = "Select right hand side of an assignment" },
            ["aa"] = { query = "@parameter.outer", desc = "Select outer part of a parameter/argument" },
            ["ia"] = { query = "@parameter.inner", desc = "Select inner part of a parameter/argument" },
            ["ai"] = { query = "@conditional.outer", desc = "Select outer part of a conditional" },
            ["ii"] = { query = "@conditional.inner", desc = "Select inner part of a conditional" },
            ["al"] = { query = "@loop.outer", desc = "Select outer part of a loop" },
            ["il"] = { query = "@loop.inner", desc = "Select inner part of a loop" },
            ["af"] = { query = "@call.outer", desc = "Select outer part of a function call" },
            ["if"] = { query = "@call.inner", desc = "Select inner part of a function call" },
            ["am"] = { query = "@function.outer", desc = "Select outer part of a method/function definition" },
            ["im"] = { query = "@function.inner", desc = "Select inner part of a method/function definition" },
            ["ac"] = { query = "@class.outer", desc = "Select outer part of a class" },
            ["ic"] = { query = "@class.inner", desc = "Select inner part of a class" },
          },
          selection_modes = {
            ['@parameter.outer'] = 'v', -- charwise
            ['@function.outer'] = 'V',  -- linewise
            ['@class.outer'] = '<c-v>', -- blockwise
          },
          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              [']m'] = '@function.outer',
              [']]'] = { query = '@class.outer', desc = 'Next class start' },
              [']o'] = '@loop.*',
              [']s'] = { query = '@local.scope', query_groups = 'locals', desc = 'Next scope' },
              [']z'] = { query = '@fold', query_groups = 'folds', desc = 'Next fold' },
            },
            goto_next_end = {
              [']M'] = '@function.outer',
              [']['] = '@class.outer',
            },
            goto_previous_start = {
              ['[m'] = '@function.outer',
              ['[['] = '@class.inner',
            },
            goto_previous_end = {
              ['[M'] = '@function.outer',
              ['[]'] = '@class.outer',
            },
            goto_next = {
              [']i'] = '@conditional.outer',
            },
            goto_previous = {
              ['[i'] = '@conditional.outer',
            },
          },
        },
      },
      folding = {
        enable = true,
        node_type_filters = {
          python = { 'class_definition' },
          cpp = { 'class_definition' },
          c = { 'struct_specifier', 'union_specifier' },
          -- lua = { 'table_constructor' },
        }
      }
    }
  end,
}
