-- lua/core/features_init.lua
local registry = require("core.registry")
local ids = require("core.schema").TaskID

-- 1. Workspace: Current Directory Name
registry.register_feature(ids.WORKSPACE, {
  is_heavy = false,
  events = { "DirChanged", "BufEnter" },
  resolver = function()
    local cwd = vim.fn.getcwd()
    return " " .. (cwd:match("([^/]+)$") or cwd)
  end
})

-- 2. Diagnostics: Error/Warning Summary
registry.register_feature(ids.DIAGS, {
  is_heavy = false,
  events = { "DiagnosticChanged", "BufEnter" },
  resolver = function(buf)
    if not vim.api.nvim_buf_is_valid(buf) then return "" end

    -- Native 0.10+ diagnostic count is faster than get()
    local counts = vim.diagnostic.count(buf)
    local err  = counts[vim.diagnostic.severity.ERROR] or 0
    local warn = counts[vim.diagnostic.severity.WARN] or 0
    local info = counts[vim.diagnostic.severity.INFO] or 0
    local hint = counts[vim.diagnostic.severity.HINT] or 0

    local parts = {}

    -- 1. Errors: High Criticality
    if err > 0 then 
      table.insert(parts, "%#StatuslineError# " .. err .. "%*") 
    end

    -- 2. Warnings: Potential Issues
    if warn > 0 then 
      table.insert(parts, "%#StatuslineWarn# " .. warn .. "%*") 
    end

    -- 3. Info: Contextual Data
    if info > 0 then 
      table.insert(parts, "%#StatuslineInfo# " .. info .. "%*") 
    end

    -- 4. Hints: Refactoring/Improvements
    if hint > 0 then 
      table.insert(parts, "%#StatuslineHint#󰌵 " .. hint .. "%*") 
    end

    return #parts > 0 and table.concat(parts, " ") or "%#StatuslineDiagsOk#󰄬 OK%*"
  end
})

-- 3. VCS: Git Branch (Non-blocking)
registry.register_feature(ids.VCS, {
  is_heavy = true, -- Marked heavy: git calls can be slow
  events = { "BufEnter", "FocusGained" },
  resolver = function(buf)
    local dir = vim.fn.expand("%:p:h")
    -- Use vim.system to avoid blocking the UI thread
    vim.system({ "git", "-C", dir, "branch", "--show-current" }, { text = true }, function(obj)
      vim.schedule(function()
        local branch = obj.stdout:gsub("\n", "")
        if branch ~= "" then
          require("core.taskbus").set(ids.VCS, " " .. branch)
        end
      end)
    end)
    return " ..." -- Initial placeholder
  end
})

-- 4. Treesitter Status: Is parser active?
registry.register_feature(ids.TS_STATUS, {
  is_heavy = false,
  events = { "BufEnter", "FileType" },
  resolver = function(buf)
    local has_ts = vim.treesitter.highlighter.active[buf] ~= nil
    return has_ts and "%#WinbarTSOk# TS%*" or "%#WinbarTSFail# NO TS%*"
  end
})

-- 5. Diff Summary: Added/Changed/Deleted lines
registry.register_feature(ids.DIFF, {
  is_heavy = false, -- Just reading a variable, not heavy
  events = { "BufWritePost", "BufEnter", "User GitsignsAttached", "User GitsignsUpdate" },
  resolver = function(buf)
    -- O(1) retrieval from buffer-local variable
    local target_buf = (buf and buf > 0) and buf or vim.api.nvim_get_current_buf()
    local status = vim.b[target_buf].gitsigns_status_dict

    if not status then return "" end

    local a = status.added or 0
    local c = status.changed or 0
    local d = status.removed or 0

    if a == 0 and c == 0 and d == 0 then return "" end

    return string.format("%%#WinbarDiffAdd#+%d%%* %%#WinbarDiffChange#~%d%%* %%#WinbarDiffDelete#-%d%%*", a, c, d)
  end
})

-- 6. Adaptive Breadcrumbs: Logic that scales with window size
registry.register_feature(ids.BREADCRUMBS, {
  is_heavy = false,
  events = { "CursorHold", "BufWinEnter", "WinEnter", "VimResized" },
  resolver = function(buf)
    local ok, parser = pcall(vim.treesitter.get_parser, buf)
    if not ok or not parser then return "" end

    -- 1. Determine the "Space Budget"
    -- We get the current window width and reserve space for the filename and status icons
    local win_width = vim.api.nvim_win_get_width(0)
    local available_width = win_width - 30 -- Subtracting ~30 for filename, diags, and percentage

    local node = vim.treesitter.get_node()
    local nodes_found = {}

    local icons = {
      namespace_definition = "󰅩 ",
      class_definition     = "󱞎 ",
      struct_specifier     = "󱞎 ",
      function_definition  = "󰊕 ",
      method_definition    = "󰊕 ",
      if_statement         = "󰇉 ",
      else_clause          = "󰇉 ",
      for_statement        = "󰑖 ",
      while_statement      = "󰑖 ",
      function_declaration = "󰊕 ",
    }

    -- 2. First Pass: Collect all valid nodes
    while node do
      local type = node:type()
      if icons[type] then
        table.insert(nodes_found, node)
      end
      node = node:parent()
    end

    if #nodes_found == 0 then return "" end

    -- 3. Calculate dynamic length per segment
    -- If we have 4 levels in a 100-char window, each gets ~17 chars.
    local segment_count = #nodes_found
    local max_len = math.max(10, math.floor(available_width / segment_count))

    local breadcrumbs = {}

    -- 4. Second Pass: Extract and Truncate text based on calculated max_len
    for _, n in ipairs(nodes_found) do
      local type = n:type()
      local icon = icons[type]
      local name = ""

      -- Find head (declarator or identifier)
      local field_map = {
        if_statement = "condition",
        while_statement = "condition",
        for_statement = "condition",
        function_definition = "declarator",
      }

      local field = field_map[type]
      local target_node = field and n:field(field)[1] or nil

      if target_node then
        name = vim.treesitter.get_node_text(target_node, buf)
      else
        for child in n:iter_children() do
          local c_type = child:type()
          if c_type == "identifier" or c_type == "name" then
            name = vim.treesitter.get_node_text(child, buf)
            break
          end
        end
      end

      -- CLEANUP AND ADAPTIVE TRUNCATION
      if name ~= "" then
        name = name:gsub("%s+", " "):gsub("[\r\n]", "")
        if #name > max_len then
          name = name:sub(1, max_len - 1) .. "…"
        end
        table.insert(breadcrumbs, 1, icon .. name)
      elseif type == "else_clause" then
        table.insert(breadcrumbs, 1, icon .. "else")
      end
    end

    return table.concat(breadcrumbs, " %#WinBarSeparator#>%* ")
  end
})

return {}
