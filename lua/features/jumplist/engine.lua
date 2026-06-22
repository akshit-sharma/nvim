local state = require("features.jumplist.state")
local helpers = require("features.jumplist.helpers")

local M = {}

-- Sync native Neovim jumplist changes with our persistent custom tree
function M.sync_history(target_win)
  target_win = target_win or vim.api.nvim_get_current_win()
  if not vim.api.nvim_win_is_valid(target_win) then
    return
  end

  -- Skip sync during programmatic branch playback
  if state.is_switching_branch then
    return
  end

  local normalized, current_idx = helpers.get_normalized_jumps(target_win)
  if #normalized == 0 then return end

  -- Initialize active path and all_nodes if empty
  if not state.active_node_path[target_win] or #state.active_node_path[target_win] == 0 then
    state.active_node_path[target_win] = {}
    state.all_nodes[target_win] = {}
    state.node_counter = 0

    local last_node = nil
    for _, entry in ipairs(normalized) do
      state.node_counter = state.node_counter + 1
      local node = {
        id = state.node_counter,
        entry = entry,
        parent = last_node,
        children = {},
        created_at = state.node_counter,
        timestamp = nil,
      }
      if last_node then
        table.insert(last_node.children, node)
      end
      table.insert(state.active_node_path[target_win], node)
      table.insert(state.all_nodes[target_win], node)
      last_node = node
    end

    state.last_raw_jumplist[target_win] = {
      jumps = normalized,
      current_idx = current_idx,
      active_node = state.active_node_path[target_win][current_idx + 1]
    }
    return
  end

  local path = state.active_node_path[target_win]
  local last_data = state.last_raw_jumplist[target_win]
  local prev_active_node = last_data and last_data.active_node or path[#path]

  local target_entry = normalized[current_idx + 1]
  if not target_entry then return end

  -- Check if this is a simple traversal (native list entry at target index has not changed)
  local is_traversal = false
  if last_data and last_data.jumps then
    local old_entry = last_data.jumps[current_idx + 1]
    if old_entry and old_entry.bufnr == target_entry.bufnr and old_entry.lnum == target_entry.lnum then
      is_traversal = true
    end
  end

  local active_node
  if is_traversal then
    local node = path[current_idx + 1]
    if node and node.entry.bufnr == target_entry.bufnr and node.entry.lnum == target_entry.lnum then
      active_node = node
    else
      for _, n in ipairs(path) do
        if n.entry.bufnr == target_entry.bufnr and n.entry.lnum == target_entry.lnum then
          active_node = n
          break
        end
      end
    end
    active_node = active_node or path[#path]
  else
    -- New Jump! Transition from prev_active_node to target_entry
    local reused_node = nil
    if prev_active_node then
      for _, child in ipairs(prev_active_node.children) do
        if child.entry.bufnr == target_entry.bufnr and child.entry.lnum == target_entry.lnum then
          reused_node = child
          break
        end
      end
    end

    -- Truncate active path to prev_active_node
    local prev_idx = nil
    for idx, node in ipairs(path) do
      if node == prev_active_node then
        prev_idx = idx
        break
      end
    end

    if prev_idx then
      while #path > prev_idx do
        table.remove(path)
      end
    else
      prev_active_node = path[#path]
    end

    if reused_node then
      table.insert(path, reused_node)
      active_node = reused_node
    else
      state.node_counter = state.node_counter + 1
      local node = {
        id = state.node_counter,
        entry = target_entry,
        parent = prev_active_node,
        children = {},
        created_at = state.node_counter,
        timestamp = os.time(),
      }
      if prev_active_node then
        table.insert(prev_active_node.children, node)
      end
      table.insert(path, node)
      table.insert(state.all_nodes[target_win], node)
      active_node = node
    end
  end

  state.last_raw_jumplist[target_win] = {
    jumps = normalized,
    current_idx = current_idx,
    active_node = active_node
  }
end

return M
