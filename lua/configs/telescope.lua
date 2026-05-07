return {
  defaults = {
    prompt_prefix = "🤔 ",
    selection_caret = "👉 ",
    path_display = { "smart" },
    entry_prefix = " ",
    sorting_strategy = "ascending",
    layout_state = "vertical",
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
      n = { ["q"] = function(...) require("telescope.actions").close(...) end },
    },
  },
}

