return {
  'nvim-treesitter/nvim-treesitter',
  dependencies = {
    { 'nvim-treesitter/nvim-treesitter-textobjects' },
  },
  branch = 'main',
  build = ':TSUpdate',
  config = function()
    -- Initialize the main treesitter plugin (main branch)
    require('nvim-treesitter').setup({})

    -- Initialize textobjects
    require('nvim-treesitter-textobjects').setup({
      select = {
        lookahead = true,
        selection_modes = {
          ['@parameter.outer'] = 'v', -- charwise
          ['@function.outer'] = 'V',  -- linewise
          ['@class.outer'] = '<c-v>', -- blockwise
        },
      },
      move = {
        set_jumps = true,
      },
    })

    -- Keymaps for selection
    local select = require('nvim-treesitter-textobjects.select')
    vim.keymap.set({ "x", "o" }, "a=", function() select.select_textobject("@assignment.outer", "textobjects") end, { desc = "Select outer part of an assignment" })
    vim.keymap.set({ "x", "o" }, "i=", function() select.select_textobject("@assignment.inner", "textobjects") end, { desc = "Select inner part of an assignment" })
    vim.keymap.set({ "x", "o" }, "l=", function() select.select_textobject("@assignment.lhs", "textobjects") end, { desc = "Select left hand side of an assignment" })
    vim.keymap.set({ "x", "o" }, "r=", function() select.select_textobject("@assignment.rhs", "textobjects") end, { desc = "Select right hand side of an assignment" })
    vim.keymap.set({ "x", "o" }, "aa", function() select.select_textobject("@parameter.outer", "textobjects") end, { desc = "Select outer part of a parameter/argument" })
    vim.keymap.set({ "x", "o" }, "ia", function() select.select_textobject("@parameter.inner", "textobjects") end, { desc = "Select inner part of a parameter/argument" })
    vim.keymap.set({ "x", "o" }, "ai", function() select.select_textobject("@conditional.outer", "textobjects") end, { desc = "Select outer part of a conditional" })
    vim.keymap.set({ "x", "o" }, "ii", function() select.select_textobject("@conditional.inner", "textobjects") end, { desc = "Select inner part of a conditional" })
    vim.keymap.set({ "x", "o" }, "al", function() select.select_textobject("@loop.outer", "textobjects") end, { desc = "Select outer part of a loop" })
    vim.keymap.set({ "x", "o" }, "il", function() select.select_textobject("@loop.inner", "textobjects") end, { desc = "Select inner part of a loop" })
    vim.keymap.set({ "x", "o" }, "af", function() select.select_textobject("@call.outer", "textobjects") end, { desc = "Select outer part of a function call" })
    vim.keymap.set({ "x", "o" }, "if", function() select.select_textobject("@call.inner", "textobjects") end, { desc = "Select inner part of a function call" })
    vim.keymap.set({ "x", "o" }, "am", function() select.select_textobject("@function.outer", "textobjects") end, { desc = "Select outer part of a method/function definition" })
    vim.keymap.set({ "x", "o" }, "im", function() select.select_textobject("@function.inner", "textobjects") end, { desc = "Select inner part of a method/function definition" })
    vim.keymap.set({ "x", "o" }, "ac", function() select.select_textobject("@class.outer", "textobjects") end, { desc = "Select outer part of a class" })
    vim.keymap.set({ "x", "o" }, "ic", function() select.select_textobject("@class.inner", "textobjects") end, { desc = "Select inner part of a class" })

    -- Keymaps for movement
    local move = require('nvim-treesitter-textobjects.move')
    vim.keymap.set({ "n", "x", "o" }, "]m", function() move.goto_next_start("@function.outer", "textobjects") end, { desc = "Next function start" })
    vim.keymap.set({ "n", "x", "o" }, "]]", function() move.goto_next_start("@class.outer", "textobjects") end, { desc = "Next class start" })
    vim.keymap.set({ "n", "x", "o" }, "]o", function() move.goto_next_start("@loop.*", "textobjects") end, { desc = "Next loop start" })
    vim.keymap.set({ "n", "x", "o" }, "]s", function() move.goto_next_start("@local.scope", "locals") end, { desc = "Next scope" })
    vim.keymap.set({ "n", "x", "o" }, "]z", function() move.goto_next_start("@fold", "folds") end, { desc = "Next fold" })

    vim.keymap.set({ "n", "x", "o" }, "]M", function() move.goto_next_end("@function.outer", "textobjects") end, { desc = "Next function end" })
    vim.keymap.set({ "n", "x", "o" }, "][", function() move.goto_next_end("@class.outer", "textobjects") end, { desc = "Next class end" })

    vim.keymap.set({ "n", "x", "o" }, "[m", function() move.goto_previous_start("@function.outer", "textobjects") end, { desc = "Previous function start" })
    vim.keymap.set({ "n", "x", "o" }, "[[", function() move.goto_previous_start("@class.inner", "textobjects") end, { desc = "Previous class start" })

    vim.keymap.set({ "n", "x", "o" }, "[M", function() move.goto_previous_end("@function.outer", "textobjects") end, { desc = "Previous function end" })
    vim.keymap.set({ "n", "x", "o" }, "[]", function() move.goto_previous_end("@class.outer", "textobjects") end, { desc = "Previous class end" })

    vim.keymap.set({ "n", "x", "o" }, "]i", function() move.goto_next("@conditional.outer", "textobjects") end, { desc = "Next conditional start/end" })
    vim.keymap.set({ "n", "x", "o" }, "[i", function() move.goto_previous("@conditional.outer", "textobjects") end, { desc = "Previous conditional start/end" })
  end,
}
