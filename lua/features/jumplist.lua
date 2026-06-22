local state = require("features.jumplist.state")
local engine = require("features.jumplist.engine")
local render = require("features.jumplist.render")
local ui = require("features.jumplist.ui")
local telescope = require("features.jumplist.telescope")

local M = {}

-- Expose State properties dynamically
setmetatable(M, {
  __index = function(_, key)
    if state[key] ~= nil then
      return state[key]
    end
    if engine[key] ~= nil then
      return engine[key]
    end
    if render[key] ~= nil then
      return render[key]
    end
    if ui[key] ~= nil then
      return ui[key]
    end
    if telescope[key] ~= nil then
      return telescope[key]
    end
  end,
  __newindex = function(_, key, value)
    if state[key] ~= nil or key == "win_id" or key == "buf_id" or key == "target_win_id" or key == "flat_results" or key == "last_raw_jumplist" or key == "active_node_path" or key == "all_nodes" or key == "node_counter" or key == "preview_win_id" or key == "preview_buf_id" or key == "is_previewing" or key == "is_switching_branch" or key == "show_help" then
      state[key] = value
    else
      rawset(M, key, value)
    end
  end
})

-- Expose Public/Internal functions directly for backwards compatibility with tests and keymaps
M.sync_history = engine.sync_history
M._build_chronological_data = render._build_chronological_data
M._generate_row_text_and_highlights = render._generate_row_text_and_highlights
M.toggle_tree = ui.toggle_tree
M.redraw_tree = ui.redraw_tree
M.select_node_delta = ui.select_node_delta
M.update_preview = ui.update_preview
M.jump_to_selected = ui.jump_to_selected
M.clear_jumps_sidepane = ui.clear_jumps_sidepane
M.visualize = telescope.visualize

return M
