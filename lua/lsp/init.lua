-- lua/lsp/init.lua
local M = {}

-- 1. Static Configuration
-- Map server names to their config modules (e.g., lua/lsp/clangd.lua)
vim.lsp.config['clangd'] = require('lsp.clangd')
vim.lsp.config['lua_ls'] = require('lsp.lua_ls')
vim.lsp.config['linux'] = require('lsp.linux')
vim.lsp.config['embedded'] = require('lsp.embedded')

vim.lsp.enable({
  'clangd',
  'lua_ls',
  'linux',
  'embedded',
})

function M.setup()
  -- Apply diagnostic UI globally (Zero-glitch icons)
  vim.diagnostic.config({
    virtual_text = { prefix = '●', spacing = 2 },
    signs = true,
    underline = true,
    update_in_insert = false, -- Only update when you stop typing
    severity_sort = true,
  })

  local function deduplicate_locations(locations)
    if not locations then return nil end
    if not vim.tbl_islist(locations) then
      return locations
    end

    local seen = {}
    local unique = {}
    for _, loc in ipairs(locations) do
      local uri = loc.uri or loc.targetUri
      local range = loc.range or loc.targetSelectionRange or loc.targetRange
      if uri and range then
        local key = string.format("%s:%d:%d", uri, range.start.line, range.start.character)
        if not seen[key] then
          seen[key] = true
          table.insert(unique, loc)
        end
      else
        table.insert(unique, loc)
      end
    end
    return unique
  end

  -- Wrap definition and declaration handlers to automatically run zv (unfold cursor line)
  -- and deduplicate results when multiple active clients return identical locations
  local methods = {
    "textDocument/definition",
    "textDocument/declaration",
    "textDocument/implementation",
    "textDocument/typeDefinition",
    "textDocument/references",
  }
  for _, method in ipairs(methods) do
    local default_handler = vim.lsp.handlers[method]
    vim.lsp.handlers[method] = function(err, result, ctx, config)
      if result then
        result = deduplicate_locations(result)
      end
      if default_handler then
        default_handler(err, result, ctx, config)
      end
      -- Post-jump: ensure the fold containing the cursor is open
      vim.schedule(function()
        vim.cmd("silent! normal! zv")
      end)
    end
  end

  -- 2. Performance-Aware Attach Logic
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('LspArchitect', { clear = true }),
    callback = function(ev)
      local bufnr = ev.buf
      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      local opts = { buffer = bufnr, silent = true }

      -------------------------------------------------------------------------
      -- PART 1: THE ARCHITECT'S SHORTCUTS (With Deprecation Warnings)
      -------------------------------------------------------------------------
      local function wrap_nav_func(func, is_references)
        return function()
          local opts_tbl = {
            on_list = function(options)
              if not options or not options.items or vim.tbl_isempty(options.items) then
                vim.notify("No locations found", vim.log.levels.INFO)
                return
              end
              local seen = {}
              local unique_items = {}
              for _, item in ipairs(options.items) do
                local key = string.format("%s:%d:%d", item.filename, item.lnum, item.col)
                if not seen[key] then
                  seen[key] = true
                  table.insert(unique_items, item)
                end
              end

              if #unique_items == 1 then
                local item = unique_items[1]
                vim.cmd(string.format("keepjumps edit %s", vim.fn.fnameescape(item.filename)))
                vim.api.nvim_win_set_cursor(0, { item.lnum, item.col - 1 })
                vim.cmd("silent! normal! zv")
              else
                vim.fn.setqflist({}, ' ', { title = options.title, items = unique_items })
                vim.cmd('copen')
              end
            end
          }

          if is_references then
            func(nil, opts_tbl)
          else
            func(opts_tbl)
          end
        end
      end

      local function map_lsp(gr_key, old_key, func, desc)
        -- Map the new standard key (gr*)
        vim.keymap.set('n', gr_key, func, { buffer = bufnr, desc = desc })
        -- Map the leader key variant (<leader>gr*)
        vim.keymap.set('n', '<leader>' .. gr_key, func, { buffer = bufnr, desc = desc })
        
        -- Map the deprecated old key (if provided)
        if old_key then
          vim.keymap.set('n', old_key, function()
            func()
            vim.notify(
              string.format("DEPRECATED: '%s' -> USE: '%s' or '<leader>%s'", old_key, gr_key, gr_key),
              vim.log.levels.WARN,
              { title = "LSP Architect", render = "minimal" }
            )
          end, { buffer = bufnr, desc = desc .. " (Deprecated)" })
        end
      end

      -- 1. Navigation Chords
      map_lsp('grd', 'gd', wrap_nav_func(vim.lsp.buf.definition, false),      "Go to Definition")
      map_lsp('grr', 'gr', wrap_nav_func(vim.lsp.buf.references, true),       "References")
      map_lsp('gri', 'gi', wrap_nav_func(vim.lsp.buf.implementation, false),  "Implementation")
      map_lsp('grt', 'gt', wrap_nav_func(vim.lsp.buf.type_definition, false), "Type Definition")

      -- 2. Action Chords
      map_lsp('grn', '<leader>rn', vim.lsp.buf.rename,      "Rename")
      map_lsp('gra', '<leader>ca', vim.lsp.buf.code_action, "Code Action")

      -- 3. One-Shot Essentials (Non-deprecated)
      vim.keymap.set('n', 'gD',    wrap_nav_func(vim.lsp.buf.declaration, false),     opts)
      vim.keymap.set('n', 'K',     vim.lsp.buf.hover,           opts)
      vim.keymap.set('n', 'gO',    vim.lsp.buf.document_symbol, opts)
      vim.keymap.set('n', '<C-]>', wrap_nav_func(vim.lsp.buf.definition, false),      opts)
      vim.keymap.set('n', '<leader>grs', function()
        local ok, telescope = pcall(require, 'telescope.builtin')
        if ok then
          telescope.lsp_document_symbols()
        else
          vim.lsp.buf.document_symbol()
        end
      end, { buffer = bufnr, desc = "Document Symbols (Telescope)" })

      vim.keymap.set('n', '[d', function()
        vim.diagnostic.jump({ count = -1, float = true })
        vim.cmd("silent! normal! zv")
      end, opts)
      vim.keymap.set('n', ']d', function()
        vim.diagnostic.jump({ count =  1, float = true })
        vim.cmd("silent! normal! zv")
      end, opts)

      -- BLOCK: If Performance Guard is active, limit LSP intensity
      if vim.b[bufnr].perf_mode then
        -- We allow the server to run (for navigation), but disable heavy UI
        if client and client.server_capabilities.inlayHintProvider then
          vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
        end
        return
      end

      -- 3. Capability-Based Feature Activation
      -- Only enable features the server actually supports
      if client:supports_method('textDocument/completion') then
        vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = false })

        vim.keymap.set('i', '<C-Space>', function()
          vim.lsp.completion.trigger()
        end, { buffer = ev.buf, desc = "LSP Completion" })
      end

      if client:supports_method('textDocument/inlayHint') then
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      end
    end,
  })

  -- Retroactively trigger LSP startup for buffers loaded before lsp was initialized
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      local ft = vim.bo[bufnr].filetype
      if ft ~= "" then
        vim.api.nvim_exec_autocmds("FileType", { buffer = bufnr })
      end
    end
  end
end

return M
