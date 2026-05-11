return {
  defaults = {
    prompt_prefix = "🤔 ",
    selection_caret = "👉 ",
    path_display = { "smart" },
    entry_prefix = " ",
    sorting_strategy = "ascending",
    layout_state = "vertical",
    preview = {
      filesize_limit = 0.5, -- MB: Do not preview files larger than 500KB
      timeout = 250,    -- ms: If the previewer hangs, kill it quickly
      msg_bg_fillchar = "╱",
    },
    layout_config = {
      flex = {
        flip_columns = 125,
        vertical = {
          mirror = false,
          prompt_position = "top",
        },
        horizontal = {
          prompt_position = "top",
          preview_width = 0.70,
        },
      },
      horizontal = {
        prompt_position = "top",
        preview_width = 0.70,
      },
      width = 0.90,
      height = 0.80,
    },
    mappings = {
      i = { ["<C-q>"] = function(prompt_bufnr) require("trouble.sources.telescope").open(prompt_bufnr) end, },
      n = {
        ["q"] = function(...) require("telescope.actions").close(...) end,
        ["<C-q>"] = function(prompt_bufnr) require("trouble.sources.telescope").open(prompt_bufnr) end,
      },
    },
  },
}

