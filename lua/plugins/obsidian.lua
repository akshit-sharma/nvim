-- lua/plugins/obsidian.lua

local is_obsidian = os.getenv("NVIM_MODE") == "obsidian"

local function open_week_relative(day_offset)
  local target_time = os.time() + day_offset * 86400
  local week_string = os.date("%Y-W%W", target_time)
  vim.cmd("ObsidianNew Week_" .. week_string)
end

local vault_path = nil

local function telescope_picker(title, entries)
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  pickers.new({}, {
    prompt_title = title,
    finder = finders.new_table({
      results = entries,
      entry_maker = function(entry)
        return {
          value = entry.path,
          display = entry.display,
          ordinal = entry.display,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)

        if selection then
          vim.cmd("edit " .. vim.fn.fnameescape(selection.value))
        end
      end)

      return true
    end,
  }):find()
end

local function list_notes()
  local files = vim.fn.globpath(vault_path, "**/*.md", false, true)

  table.sort(files, function(a, b)
    return vim.fn.getftime(a) > vim.fn.getftime(b)
  end)

  local entries = {}

  for _, file in ipairs(files) do
    table.insert(entries, {
      path = file,
      display = vim.fn.fnamemodify(file, ":."),
    })
  end

  telescope_picker("Notes (newest first)", entries)
end

local function list_weeks()
  local files = vim.fn.globpath(vault_path, "**/Week_*.md", false, true)

  table.sort(files, function(a, b)
    return a > b
  end)

  local entries = {}

  for _, file in ipairs(files) do
    table.insert(entries, {
      path = file,
      display = vim.fn.fnamemodify(file, ":t:r"),
    })
  end

  telescope_picker("Weeks (newest first)", entries)
end

return {
  ---------------------------------------------------------------------------
  -- Obsidian
  ---------------------------------------------------------------------------
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    enabled = is_obsidian,
    lazy = false,
    priority = 900,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },

    opts = function()
      local has_config, user_opts = pcall(require, "configs.obsidian")

      local base_opts = {
        ui = {
          enable = true,
          conceallevel = 2,
        },
        mappings = {},
      }

      if has_config then
        return vim.tbl_deep_extend("force", base_opts, user_opts)
      end

      return base_opts
    end,

    config = function(_, opts)
      require("obsidian").setup(opts)
      if opts.workspaces and opts.workspaces[1] then
        vault_path = tostring(opts.workspaces[1].path)
      else
        vault_path = vim.fn.getcwd()
      end

      vim.api.nvim_create_user_command(
        "ObsidianListNotes",
        list_notes,
        {}
      )

      vim.api.nvim_create_user_command(
        "ObsidianListWeeks",
        list_weeks,
        {}
      )

      vim.api.nvim_create_user_command(
        "ObsidianWeeklyNote",
        function()
          open_week_relative(0)
        end,
        {}
      )

      vim.api.nvim_create_user_command(
        "ObsidianLastWeekNote",
        function()
          open_week_relative(-7)
        end,
        {}
      )

      vim.api.nvim_create_user_command(
        "ObsidianNextWeekNote",
        function()
          open_week_relative(7)
        end,
        {}
      )
    end,
  },

  ---------------------------------------------------------------------------
  -- Alpha Dashboard
  ---------------------------------------------------------------------------
  {
    "goolord/alpha-nvim",
    enabled = is_obsidian,
    lazy = false,
    priority = 1000,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },

    config = function()
      -- Only show dashboard when starting with no file arguments
      if vim.fn.argc() > 0 then
        return
      end

      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      dashboard.section.header.val = {
        "",
        " ██████╗ ██████╗ ███████╗██╗██████╗ ██╗ █████╗ ███╗   ██╗",
        "██╔═══██╗██╔══██╗██╔════╝██║██╔══██╗██║██╔══██╗████╗  ██║",
        "██║   ██║██████╔╝███████╗██║██║  ██║██║███████║██╔██╗ ██║",
        "██║   ██║██╔══██╗╚════██║██║██║  ██║██║██╔══██║██║╚██╗██║",
        "╚██████╔╝██████╔╝███████║██║██████╔╝██║██║  ██║██║ ╚████║",
        " ╚═════╝ ╚═════╝ ╚══════╝╚═╝╚═════╝ ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝",
        "",
        "                 Obsidian Vault Navigator",
        "",
      }

      dashboard.section.buttons.val = {
        dashboard.button("s", "🔍  Search Notes", ":ObsidianSearch<CR>"),
        dashboard.button("N", "📚  List Notes", ":ObsidianListNotes<CR>"),
        dashboard.button("W", "🗓  List Weeks", ":ObsidianListWeeks<CR>"),
        dashboard.button("n", "📝  New Note", ":ObsidianNew<CR>"),
        dashboard.button("q", "🔀  Quick Switch", ":ObsidianQuickSwitch<CR>"),
        dashboard.button("w", "📅  Weekly Note", ":ObsidianWeeklyNote<CR>"),
        dashboard.button("l", "⏮  Last Week", ":ObsidianLastWeekNote<CR>"),
        dashboard.button("x", "⏭  Next Week", ":ObsidianNextWeekNote<CR>"),
        dashboard.button("r", "🏷  Rename Note", ":ObsidianRename<CR>"),
        dashboard.button("i", "🔗  Note Links", ":ObsidianLinks<CR>"),
        dashboard.button("a", "🗃  Workspace", ":ObsidianWorkspace<CR>"),
        dashboard.button("e", "📄  Empty Buffer", ":enew<CR>"),
        dashboard.button("c", "⚙️  Config", ":e $MYVIMRC<CR>"),
        dashboard.button("Q", "🚪  Quit", ":qa<CR>"),
      }

      dashboard.section.footer.val = {
        "",
        "NVIM_MODE=obsidian",
      }

      alpha.setup(dashboard.config)

      vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])
    end,
  },
}
