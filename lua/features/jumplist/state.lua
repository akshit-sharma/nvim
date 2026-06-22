local M = {}

M.win_id = nil
M.buf_id = nil
M.target_win_id = nil
M.flat_results = nil

M.last_raw_jumplist = {}
M.active_node_path = {}
M.all_nodes = {}
M.node_counter = 0

M.preview_win_id = nil
M.preview_buf_id = nil
M.is_previewing = false
M.is_switching_branch = false
M.show_help = false

return M
