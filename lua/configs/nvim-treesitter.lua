return function()
  require'nvim-treesitter.configs'.setup {
    ensure_installed = {
      "bash",
      "c",
      "comment",
      "cmake",
      "cpp",
      "cuda",
      "glsl",
      "java",
      "javascript",
      "json",
      "html",
      "lua",
      "rust",
      "python",
      "typescript",
      "vim",
      "vimdoc",
      "yaml",
    },
    auto_install=true,
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
      disable = function(lang, bufnr)
        return lang == "cpp" and vim.api.nvim_buf_line_count(bufnr) > 50000
      end,
    },
    incremental_selection = {
      enable = true,
      -- These are the default keymaps, which I can lookup via help, but still putting
      -- them here for easier access.
      keymaps = {
        init_selection = "gnn",
        node_incremental = "grn",
        scope_incremental = "grc",
        node_decremental = "grm",
      },
    },
    textobjects = {
      select = {
        enable = true,

        -- Automatically jump forward to textobj, similar to targets.vim
        lookahead = true,

        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ["<leader>a"] = "@parameter.inner",
        },
        swap_previous = {
          ["<leader>A"] = "@parameter.inner",
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          ["]m"] = "@function.outer",
          ["]]"] = "@class.outer",
          [']o'] = "@loop.*",
        },
        goto_next_end = {
          ["]M"] = "@function.outer",
          ["]["] = "@class.outer",
        },
        goto_previous_start = {
          ["[m"] = "@function.outer",
          ["[["] = "@class.outer",
          ['[o'] = "@loop.*",
        },
        goto_previous_end = {
          ["[M"] = "@function.outer",
          ["[]"] = "@class.outer",
        },
      },
      lsp_interop = {
        enable = true,
        border = "none",
        peek_definition_code = {
          ["<leader>df"] = "@function.outer",
          ["<leader>dF"] = "@class.outer",
        },
      },
    },
  }
end

-- vim.opt.foldmethod     = 'expr'
-- vim.opt.foldexpr       = 'nvim_treesitter#foldexpr()'
---WORKAROUND
--[[
vim.api.nvim_create_autocmd({'BufEnter','BufAdd','BufNew','BufNewFile','BufWinEnter'}, {
  group = vim.api.nvim_create_augroup('TS_FOLD_WORKAROUND', {}),
  callback = function()
    vim.opt.foldmethod     = 'expr'
    vim.opt.foldexpr       = 'nvim_treesitter#foldexpr()'
  end
})
]]--
---ENDWORKAROUND

--[[
local parsers = require('nvim-treesitter.parsers')
if parsers.has_parser "c" and parsers.has_parser "cpp" and parsers.has_parser "cuda" then
  local ok_query, query = pcall(require, 'vim.treesitter.query')
  local folds_query = [[
  ]]
  --[[
  if not ok_query then
    vim.notify('query null, might want to fix', vim.log.levels.ERROR)
  else
    local set_query = query.set or query.set_query
    set_query("c", "folds", folds_query)
    set_query("cpp", "folds", folds_query)
    set_query("cuda", "folds", folds_query)
  end
end
--]]
