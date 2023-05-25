return function()
  -- https://github.com/nvim-telescope/telescope.nvim
  OK_TELESCOPE, TELESCOPE = pcall(require, "telescope")
  if not OK_TELESCOPE then
    vim.notify('"nvim-telescope/telescope.nvim" not available', 'error')
    return
  end

  local open_with_trouble = nil
  local ok_trouble, trouble = pcall(require, "trouble")
  if ok_trouble then
    open_with_trouble = trouble.open_with_trouble
  else
    vim.notify('"folke/trouble.nvim" not available, for use in "nvim-telescope/nvim-telescope"', 'error')
  end

  TELESCOPE_BUILTIN = require("telescope.builtin")
  local telescope_extensions = TELESCOPE.extensions

  TELESCOPE.setup({
    defaults = {

      prompt_prefix = ">> ",
      selection_caret = "📌 ",
      path_display = { "smart" },

      mappings = {
        i = { ["<C-t>"] = open_with_trouble },
        n = { ["<C-t>"] = open_with_trouble },
      },
    },
    extensions = {
      fzf = {
        fuzzy = true, -- false will only do exact matching
        override_generic_sorter = true, -- override the generic sorter
        override_file_sorter = true, -- override the file sorter
        case_mode = "smart_case", -- or "ignore_case" or "respect_case"
        -- the default case_mode is "smart_case"
      },
      aerial = {
        show_nesting = {
          ['_'] = false,
          json = true,
          yaml = true,
        }
      }
    },
  })

end
