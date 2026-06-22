local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local entry_display = require("telescope.pickers.entry_display")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local state = require("features.jumplist.state")
local helpers = require("features.jumplist.helpers")
local render = require("features.jumplist.render")

local M = {}

-- Full Telescope visualizer
function M.visualize(opts)
  opts = opts or {}
  local telescope_opts = vim.tbl_extend("force", {}, opts)

  local flat_results, default_selection_idx, max_column = render._build_chronological_data(vim.api.nvim_get_current_win())
  if not flat_results then
    vim.notify("Jumplist is empty", vim.log.levels.INFO)
    return
  end

  local picker_opts = {
    prompt_title = " Jumplist Visualizer (Chronological: Newest Top) ",
    finder = finders.new_table({
      results = flat_results,
      entry_maker = function(entry)
        local value_node = entry.node
        if entry.type == "branch" then
          value_node = entry.target_node
        end
        return {
          value = entry,
          display = function(tbl_entry)
            local display_str, highlights = render._generate_row_text_and_highlights(tbl_entry.value, max_column, false)
            return display_str, highlights
          end,
          ordinal = string.format("%s %s", value_node.target or "", value_node.line_content or ""),
          filename = value_node.filename,
          lnum = value_node.lnum,
          col = value_node.col,
        }
      end,
    }),
    sorter = conf.generic_sorter(telescope_opts),
    default_selection_index = default_selection_idx,
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)

        if not selection or not selection.value then
          return
        end

        local val = selection.value
        local value_node = val.node
        if val.type == "branch" then
          value_node = val.target_node
        end

        vim.schedule(function()
          local target_win = vim.api.nvim_get_current_win()
          state.is_switching_branch = true

          if value_node.rel_idx then
            if value_node.rel_idx < 0 then
              local count = -value_node.rel_idx
              vim.cmd([[execute "normal! ]] .. count .. [[\<C-o>"]])
            elseif value_node.rel_idx > 0 then
              local count = value_node.rel_idx
              vim.cmd([[execute "normal! ]] .. count .. [[\<C-i>"]])
            end
          else
            -- Alternative branch node: play back path from common ancestor to switch branches!
            local path = state.active_node_path[target_win]
            if path then
              -- Build path to selected node
              local path_to_node = {}
              local curr = value_node
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
                  vim.api.nvim_win_set_buf(target_win, bufnr)
                  vim.api.nvim_win_set_cursor(target_win, { lnum, col })
                end
              end
            end
          end

          -- Explicitly set the active path and node matching the selected node
          local path_to_node = {}
          local curr = value_node
          while curr do
            table.insert(path_to_node, 1, curr)
            curr = curr.parent
          end
          state.active_node_path[target_win] = path_to_node

          local normalized, current_idx = helpers.get_normalized_jumps(target_win)
          state.last_raw_jumplist[target_win] = {
            jumps = normalized,
            current_idx = current_idx,
            active_node = value_node
          }

          state.is_switching_branch = false

          vim.cmd("silent! normal! zvzz")
        end)
      end)

      local clear_jumps = function()
        actions.close(prompt_bufnr)
        vim.cmd("clearjumps")
        pcall(vim.cmd, "wshada!")
        vim.notify("Jumplist cleared persistently", vim.log.levels.INFO)
      end
      map("i", "<C-x>", clear_jumps)
      map("n", "<C-x>", clear_jumps)

      return true
    end,
  }

  picker_opts.previewer = conf.qflist_previewer(telescope_opts)

  pickers.new(telescope_opts, picker_opts):find()
end

return M
