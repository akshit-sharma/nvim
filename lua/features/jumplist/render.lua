local state = require("features.jumplist.state")
local helpers = require("features.jumplist.helpers")
local engine = require("features.jumplist.engine")

local M = {}

-- Internal helper to build tree data and return flat chronological results
function M._build_chronological_data(target_win)
  target_win = target_win or vim.api.nvim_get_current_win()
  if not vim.api.nvim_win_is_valid(target_win) then
    return nil, nil, 0
  end

  engine.sync_history(target_win)

  local all_nodes = state.all_nodes[target_win]
  local path = state.active_node_path[target_win]
  local last = state.last_raw_jumplist[target_win]
  if not all_nodes or not path or not last then
    return nil, nil, 0
  end

  local current_idx = last.current_idx or 0
  local active_node = path[current_idx + 1]

  -- Sort nodes chronologically
  local unique_nodes = {}
  for _, node in ipairs(all_nodes) do
    table.insert(unique_nodes, node)
  end
  table.sort(unique_nodes, function(a, b)
    return a.created_at < b.created_at
  end)

  -- Assign sequence numbers and reset columns
  for i, node in ipairs(unique_nodes) do
    node.seq = i - 1
    node.column = nil
  end

  -- Assign columns from newest to oldest
  local next_col = 1
  for i = #unique_nodes, 1, -1 do
    local node = unique_nodes[i]
    if not node.column then
      local col = next_col
      next_col = next_col + 1
      
      local curr = node
      while curr and not curr.column do
        curr.column = col
        curr = curr.parent
      end
    end
  end
  local max_column = math.max(1, next_col - 1)

  -- Map nodes in active path to calculate rel_idx
  local path_indices = {}
  for idx, node in ipairs(path) do
    path_indices[node.id] = idx
  end

  -- Populate properties for nodes
  for _, node in ipairs(unique_nodes) do
    local p_idx = path_indices[node.id]
    if p_idx then
      node.rel_idx = p_idx - (current_idx + 1)
    else
      node.rel_idx = nil
    end
    node.target = helpers.get_basename_with_line(node.entry.bufnr, node.entry.lnum)
    node.line_content = vim.trim(helpers.get_line_content(node.entry.bufnr, node.entry.lnum))
    node.filename = node.entry.filename or vim.api.nvim_buf_get_name(node.entry.bufnr)
    node.lnum = node.entry.lnum
    node.col = node.entry.col
  end

  -- Interleave nodes with branch/merge rows
  local display_rows = {}
  for i = #unique_nodes, 1, -1 do
    local node = unique_nodes[i]
    
    local merging_children = {}
    for _, other in ipairs(unique_nodes) do
      if other.parent and other.parent.id == node.id and other.column > node.column then
        table.insert(merging_children, other)
      end
    end
    
    if #merging_children > 0 then
      table.insert(display_rows, {
        type = "branch",
        target_node = node,
        merging_children = merging_children
      })
    end
    
    table.insert(display_rows, {
      type = "node",
      node = node
    })
  end

  -- Helper to check if a column is active at a given row index
  local function is_column_active(c, r_idx)
    for _, other_node in ipairs(unique_nodes) do
      if other_node.column == c then
        local child_idx, parent_idx
        for idx, item in ipairs(display_rows) do
          if item.type == "node" and item.node.id == other_node.id then
            child_idx = idx
          end
          if other_node.parent and item.type == "node" and item.node.id == other_node.parent.id then
            parent_idx = idx
          end
        end
        
        if child_idx then
          parent_idx = parent_idx or (#display_rows + 1)
          local end_idx = parent_idx
          if other_node.parent and other_node.column ~= other_node.parent.column then
            end_idx = parent_idx - 1
          end
          if r_idx >= child_idx and r_idx <= end_idx then
            return true
          end
        end
      end
    end
    return false
  end

  -- Generate graph characters
  for row_idx, row_item in ipairs(display_rows) do
    local chars = {}
    for c = 1, max_column do
      chars[c] = " "
    end

    if row_item.type == "node" then
      local node = row_item.node
      local node_col = node.column
      chars[node_col] = "*"

      for c = 1, max_column do
        if c ~= node_col then
          if is_column_active(c, row_idx) then
            chars[c] = "|"
          end
        end
      end
    elseif row_item.type == "branch" then
      for c = 1, max_column do
        local is_merge = false
        for _, child in ipairs(row_item.merging_children) do
          if child.column == c then
            is_merge = true
            break
          end
        end

        if is_merge then
          chars[c] = "/"
        elseif is_column_active(c, row_idx) then
          chars[c] = "|"
        end
      end
    end
    row_item.chars = chars
  end

  -- Find active_idx
  local active_idx = 1
  if active_node then
    for idx, item in ipairs(display_rows) do
      if item.type == "node" and item.node.id == active_node.id then
        active_idx = idx
        break
      end
    end
  end

  return display_rows, active_idx, max_column
end

-- Shared helper to build text and highlights for a row
function M._generate_row_text_and_highlights(row_item, max_column, simple_tree)
  local chars = row_item.chars or {}
  local highlights = {}

  -- 1. Graph prefix
  local prefix = ""
  for c = 1, max_column do
    local char = chars[c] or " "
    local char_len = #char
    local start_pos = #prefix
    local end_pos = start_pos + char_len
    
    if char == "*" then
      local is_active = (row_item.type == "node" and row_item.node.rel_idx == 0)
      table.insert(highlights, { { start_pos, end_pos }, is_active and "String" or "Special" })
    elseif char == "|" or char == "/" or char == "\\" then
      table.insert(highlights, { { start_pos, end_pos }, "Comment" })
    end
    
    prefix = prefix .. char
    if c < max_column then
      prefix = prefix .. " "
    end
  end

  -- 2. Index and metadata
  if row_item.type == "node" then
    local node = row_item.node
    local graph_width = max_column * 2
    local current_len = #prefix
    if current_len < graph_width then
      prefix = prefix .. string.rep(" ", graph_width - current_len)
    end
    prefix = prefix .. "  "

    local seq_str = ""
    local is_active = (node.rel_idx == 0)
    if is_active then
      seq_str = string.format(">%d<", node.seq)
    else
      seq_str = string.format(" %d ", node.seq)
    end
    
    local idx_start = #prefix
    prefix = prefix .. seq_str
    local idx_end = #prefix
    table.insert(highlights, { { idx_start, idx_end }, is_active and "String" or "Comment" })

    local target_str = string.format(" (%s)", node.target)
    if node.timestamp then
      local diff = os.time() - node.timestamp
      local time_str
      if diff < 5 then time_str = "just now"
      elseif diff < 60 then time_str = string.format("%ds ago", diff)
      elseif diff < 3600 then time_str = string.format("%dm ago", math.floor(diff / 60))
      else time_str = string.format("%dh ago", math.floor(diff / 3600))
      end
      target_str = target_str .. string.format(" (%s)", time_str)
    else
      target_str = target_str .. " (Orig)"
    end
    local target_start = #prefix
    prefix = prefix .. target_str
    local target_end = #prefix
    table.insert(highlights, { { target_start, target_end }, is_active and "Normal" or "Comment" })

    -- Line content
    if not simple_tree then
      local target_width = 40
      local current_len2 = #prefix
      if current_len2 < target_width then
        prefix = prefix .. string.rep(" ", target_width - current_len2)
      end
      
      local div_start = #prefix
      prefix = prefix .. " │ "
      local div_end = #prefix
      table.insert(highlights, { { div_start, div_end }, "Comment" })
      
      local content_start = #prefix
      prefix = prefix .. node.line_content
      local content_end = #prefix
      table.insert(highlights, { { content_start, content_end }, "Normal" })
    end
  end

  return prefix, highlights
end

return M
