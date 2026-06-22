local state = require("features.jumplist.state")
local helpers = require("features.jumplist.helpers")
local render = require("features.jumplist.render")

local M = {}

-- Forward declarations to resolve internal calls
function M.redraw_tree()
  if not state.buf_id or not vim.api.nvim_buf_is_valid(state.buf_id) then
    return
  end

  local flat_results, active_idx, max_column = render._build_chronological_data(state.target_win_id)
  if not flat_results then
    vim.bo[state.buf_id].modifiable = true
    vim.api.nvim_buf_set_lines(state.buf_id, 0, -1, false, { " Jumplist is empty" })
    vim.bo[state.buf_id].modifiable = false
    state.flat_results = nil
    return
  end

  state.flat_results = flat_results

  local lines = {}
  local highlight_list = {}

  -- Build help legend
  local header = {}
  if state.show_help then
    table.insert(header, "=== Jumplist Tree Help ===")
    table.insert(header, " <CR>   : Jump & focus editor")
    table.insert(header, " C-n    : Preview next jump")
    table.insert(header, " C-p    : Preview prev jump")
    table.insert(header, " C-x    : Clear jumplist")
    table.insert(header, " q      : Close side-pane")
    table.insert(header, " ?      : Toggle this help")
    table.insert(header, "==========================")
    table.insert(header, "")
  else
    table.insert(header, " Jumplist Tree (Press ? for help)")
    table.insert(header, "")
  end
  local header_count = #header

  for _, h_line in ipairs(header) do
    table.insert(lines, h_line)
    table.insert(highlight_list, {})
  end

  for row_idx, item in ipairs(flat_results) do
    local line_text, row_highlights = render._generate_row_text_and_highlights(item, max_column, true)
    table.insert(lines, line_text)
    table.insert(highlight_list, row_highlights)
  end

  vim.bo[state.buf_id].modifiable = true
  vim.api.nvim_buf_set_lines(state.buf_id, 0, -1, false, lines)

  local ns = vim.api.nvim_create_namespace("JumplistTreeNs")
  vim.api.nvim_buf_clear_namespace(state.buf_id, ns, 0, -1)

  -- Highlight header lines
  for i = 1, header_count do
    local line_idx = i - 1
    vim.api.nvim_buf_add_highlight(state.buf_id, ns, "Comment", line_idx, 0, -1)
  end

  for row_idx, row_highlights in ipairs(highlight_list) do
    if row_idx > header_count then
      local line_idx = row_idx - 1
      for _, hl in ipairs(row_highlights) do
        local start_col = hl[1][1]
        local end_col = hl[1][2]
        local hl_group = hl[2]
        vim.api.nvim_buf_add_highlight(state.buf_id, ns, hl_group, line_idx, start_col, end_col)
      end
    end
  end

  vim.bo[state.buf_id].modifiable = false

  if active_idx and state.win_id and vim.api.nvim_win_is_valid(state.win_id) then
    pcall(vim.api.nvim_win_set_cursor, state.win_id, { active_idx + header_count, 1 })
  end
end

-- Move side-pane cursor up or down by delta, landing on a node row
function M.select_node_delta(delta)
  if not state.win_id or not vim.api.nvim_win_is_valid(state.win_id) then
    return
  end
  if not state.flat_results then
    return
  end

  local cursor = vim.api.nvim_win_get_cursor(state.win_id)
  local current_row = cursor[1]
  local header_count = state.show_help and 9 or 2
  local current_idx = current_row - header_count
  local target_idx = current_idx

  while true do
    target_idx = target_idx + delta
    if target_idx < 1 or target_idx > #state.flat_results then
      break
    end
    local item = state.flat_results[target_idx]
    if item and item.type == "node" then
      vim.api.nvim_win_set_cursor(state.win_id, { target_idx + header_count, 1 })
      M.update_preview()
      break
    end
  end
end

-- Update bottom preview pane
function M.update_preview()
  if not state.win_id or not vim.api.nvim_win_is_valid(state.win_id) then
    return
  end
  if not state.flat_results or state.is_previewing then
    return
  end

  local cursor = vim.api.nvim_win_get_cursor(state.win_id)
  local row = cursor[1]
  local header_count = state.show_help and 9 or 2
  local item = state.flat_results[row - header_count]
  if not item then
    return
  end

  local node
  if item.type == "node" then
    node = item.node
  elseif item.type == "branch" then
    local next_item = state.flat_results[row - header_count + 1]
    if next_item and next_item.type == "node" then
      node = next_item.node
    end
  end

  if not node then
    return
  end

  state.is_previewing = true

  -- Update bottom preview pane
  if state.preview_win_id and vim.api.nvim_win_is_valid(state.preview_win_id) and state.preview_buf_id and vim.api.nvim_buf_is_valid(state.preview_buf_id) then
    local bufnr = node.entry.bufnr
    local lnum = node.entry.lnum
    if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
      local total_lines = vim.api.nvim_buf_line_count(bufnr)
      local start_line = math.max(1, lnum - 7)
      local end_line = math.min(total_lines, lnum + 7)
      local lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)

      local display_lines = {}
      local target_line_in_preview = 1
      for idx, line in ipairs(lines) do
        local current_lnum = start_line + idx - 1
        local prefix = string.format("%4d │ ", current_lnum)
        if current_lnum == lnum then
          target_line_in_preview = idx
          table.insert(display_lines, "> " .. prefix .. line)
        else
          table.insert(display_lines, "  " .. prefix .. line)
        end
      end

      vim.bo[state.preview_buf_id].modifiable = true
      vim.api.nvim_buf_set_lines(state.preview_buf_id, 0, -1, false, display_lines)
      
      local ft = vim.bo[bufnr].filetype
      if ft and ft ~= "" then
        vim.bo[state.preview_buf_id].filetype = ft
      end
      vim.bo[state.preview_buf_id].modifiable = false

      vim.api.nvim_win_set_cursor(state.preview_win_id, { target_line_in_preview, 1 })
      
      local ns = vim.api.nvim_create_namespace("JumplistPreviewNs")
      vim.api.nvim_buf_clear_namespace(state.preview_buf_id, ns, 0, -1)
      vim.api.nvim_buf_add_highlight(state.preview_buf_id, ns, "Search", target_line_in_preview - 1, 0, -1)
    end
  end

  state.is_previewing = false
end

-- Perform jump to the entry selected in the side-pane
function M.jump_to_selected()
  if not state.flat_results or not state.win_id or not vim.api.nvim_win_is_valid(state.win_id) then
    return
  end

  local cursor = vim.api.nvim_win_get_cursor(state.win_id)
  local row = cursor[1]
  local header_count = state.show_help and 9 or 2
  local item = state.flat_results[row - header_count]
  if not item then
    return
  end

  local node
  if item.type == "node" then
    node = item.node
  elseif item.type == "branch" then
    local next_item = state.flat_results[row - header_count + 1]
    if next_item and next_item.type == "node" then
      node = next_item.node
    end
  end

  if not node then
    return
  end

  -- Focus main editor window
  if state.target_win_id and vim.api.nvim_win_is_valid(state.target_win_id) and state.target_win_id ~= state.preview_win_id then
    vim.api.nvim_set_current_win(state.target_win_id)
  else
    local wins = vim.api.nvim_list_wins()
    local found = false
    for _, win in ipairs(wins) do
      if win ~= state.win_id and win ~= state.preview_win_id then
        vim.api.nvim_set_current_win(win)
        state.target_win_id = win
        found = true
        break
      end
    end
    if not found then
      vim.cmd("wincmd p")
      state.target_win_id = vim.api.nvim_get_current_win()
    end
  end

  -- Perform jump
  vim.schedule(function()
    state.is_switching_branch = true

    if node.rel_idx then
      -- Use native C-o/C-i relative navigation keys for synchronized stack nodes
      if node.rel_idx < 0 then
        local count = -node.rel_idx
        vim.cmd([[execute "normal! ]] .. count .. [[\<C-o>"]])
      elseif node.rel_idx > 0 then
        local count = node.rel_idx
        vim.cmd([[execute "normal! ]] .. count .. [[\<C-i>"]])
      end
    else
      -- Alternative branch node: play back path from common ancestor to switch branches!
      local path = state.active_node_path[state.target_win_id]
      if path then
        -- Build path to selected node
        local path_to_node = {}
        local curr = node
        while curr do
          table.insert(path_to_node, 1, curr)
          curr = curr.parent
        end

        -- Find common ancestor
        local common_idx = 1
        for idx = 1, math.min(#path_to_node, #path) do
          if path_to_node[idx] == path[idx] then
            common_idx = idx
          else
            break
          end
        end

        -- 1. Backtrack to common ancestor
        local backtrack_count = #path - common_idx
        if backtrack_count > 0 then
          vim.cmd([[execute "normal! ]] .. backtrack_count .. [[\<C-o>"]])
        end

        -- 2. Play forward to target node
        for idx = common_idx + 1, #path_to_node do
          local next_node = path_to_node[idx]
          local bufnr = next_node.entry.bufnr
          local lnum = next_node.entry.lnum
          local col = next_node.entry.col or 0
          
          vim.cmd("normal! m'")
          if vim.api.nvim_buf_is_valid(bufnr) then
            vim.api.nvim_win_set_buf(state.target_win_id, bufnr)
            vim.api.nvim_win_set_cursor(state.target_win_id, { lnum, col })
          end
        end
      end
    end

    -- Explicitly set the active path and node matching the selected node
    local path_to_node = {}
    local curr = node
    while curr do
      table.insert(path_to_node, 1, curr)
      curr = curr.parent
    end
    state.active_node_path[state.target_win_id] = path_to_node

    local normalized, current_idx = helpers.get_normalized_jumps(state.target_win_id)
    state.last_raw_jumplist[state.target_win_id] = {
      jumps = normalized,
      current_idx = current_idx,
      active_node = node
    }

    state.is_switching_branch = false

    vim.cmd("silent! normal! zvzz")
    M.redraw_tree()
  end)
end

-- Clear history persistently from the side-pane
function M.clear_jumps_sidepane()
  local old_win = vim.api.nvim_get_current_win()
  if state.target_win_id and vim.api.nvim_win_is_valid(state.target_win_id) then
    vim.api.nvim_set_current_win(state.target_win_id)
  end
  vim.cmd("clearjumps")
  pcall(vim.cmd, "wshada!")
  vim.api.nvim_set_current_win(old_win)

  -- Reset custom persistent tracking
  if state.target_win_id then
    state.last_raw_jumplist[state.target_win_id] = nil
    state.active_node_path[state.target_win_id] = nil
    state.all_nodes[state.target_win_id] = nil
  end

  vim.notify("Jumplist cleared persistently", vim.log.levels.INFO)
  M.redraw_tree()
end

-- Toggle side-pane tree visualization
function M.toggle_tree()
  if state.preview_win_id and vim.api.nvim_win_is_valid(state.preview_win_id) then
    pcall(vim.api.nvim_win_close, state.preview_win_id, true)
  end
  state.preview_win_id = nil
  state.preview_buf_id = nil

  if state.win_id and vim.api.nvim_win_is_valid(state.win_id) then
    pcall(vim.api.nvim_win_close, state.win_id, true)
    state.win_id = nil
    state.buf_id = nil
    return
  end

  state.target_win_id = vim.api.nvim_get_current_win()

  -- Create vertical split on the far left
  vim.cmd("vertical topleft 35split")
  state.win_id = vim.api.nvim_get_current_win()

  -- Create scratch buffer
  state.buf_id = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(state.buf_id, "Jumplist Tree")
  vim.api.nvim_win_set_buf(state.win_id, state.buf_id)

  -- Create preview horizontal split at the bottom of the tree split
  vim.cmd("belowright 15split")
  state.preview_win_id = vim.api.nvim_get_current_win()
  
  state.preview_buf_id = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(state.preview_buf_id, "Jumplist Preview")
  vim.api.nvim_win_set_buf(state.preview_win_id, state.preview_buf_id)

  -- Preview window options
  local p_win = state.preview_win_id
  vim.wo[p_win].number = false
  vim.wo[p_win].relativenumber = false
  vim.wo[p_win].signcolumn = "no"
  vim.wo[p_win].foldcolumn = "0"
  vim.wo[p_win].wrap = false
  vim.wo[p_win].winfixheight = true

  -- Preview buffer options
  local p_buf = state.preview_buf_id
  vim.bo[p_buf].buftype = "nofile"
  vim.bo[p_buf].bufhidden = "wipe"
  vim.bo[p_buf].swapfile = false

  -- Move focus back to the tree window
  vim.api.nvim_set_current_win(state.win_id)

  -- Window options
  local win = state.win_id
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"
  vim.wo[win].foldcolumn = "0"
  vim.wo[win].winfixwidth = true
  vim.wo[win].wrap = false

  -- Buffer options
  local buf = state.buf_id
  vim.bo[buf].filetype = "jumplist"
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false

  -- Map local keys in the side-pane
  local map_opts = { silent = true, buffer = buf }
  vim.keymap.set("n", "<CR>", function()
    M.jump_to_selected()
  end, map_opts)
  vim.keymap.set("n", "<LeftRelease>", function()
    M.jump_to_selected()
  end, map_opts)
  vim.keymap.set("n", "q", function()
    M.toggle_tree()
  end, map_opts)
  vim.keymap.set("n", "<C-x>", function()
    M.clear_jumps_sidepane()
  end, map_opts)
  vim.keymap.set("n", "<C-n>", function()
    M.select_node_delta(1)
  end, map_opts)
  vim.keymap.set("n", "<C-p>", function()
    M.select_node_delta(-1)
  end, map_opts)
  vim.keymap.set("n", "<C-o>", "<Nop>", map_opts)
  vim.keymap.set("n", "<C-i>", "<Nop>", map_opts)
  vim.keymap.set("n", "?", function()
    state.show_help = not state.show_help
    M.redraw_tree()
  end, map_opts)

  -- Also set Nops in preview buffer
  local p_map_opts = { silent = true, buffer = p_buf }
  vim.keymap.set("n", "<C-o>", "<Nop>", p_map_opts)
  vim.keymap.set("n", "<C-i>", "<Nop>", p_map_opts)

  -- Auto-update preview when moving cursor in the tree pane
  vim.api.nvim_create_autocmd("CursorMoved", {
    buffer = buf,
    callback = function()
      M.update_preview()
    end
  })

  -- Cleanup preview split when the main tree buffer is wiped out
  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = buf,
    callback = function()
      if state.preview_win_id and vim.api.nvim_win_is_valid(state.preview_win_id) then
        pcall(vim.api.nvim_win_close, state.preview_win_id, true)
      end
      state.win_id = nil
      state.buf_id = nil
      state.preview_win_id = nil
      state.preview_buf_id = nil
    end
  })

  -- Setup auto-refresh on navigation in main windows
  local group = vim.api.nvim_create_augroup("JumplistTreeGroup", { clear = true })
  vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold" }, {
    group = group,
    callback = function()
      if not state.win_id or not vim.api.nvim_win_is_valid(state.win_id) then
        return true -- delete autocmd
      end
      if state.is_previewing then
        return
      end
      local current_win = vim.api.nvim_get_current_win()
      if current_win ~= state.win_id and current_win ~= state.preview_win_id then
        state.target_win_id = current_win
        pcall(M.redraw_tree)
      end
    end
  })

  M.redraw_tree()
  vim.schedule(function()
    M.update_preview()
  end)
end

return M
