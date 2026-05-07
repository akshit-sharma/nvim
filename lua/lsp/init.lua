-- lua/lsp/init.lua
local M = {}

-- 1. Static Configuration
-- Map server names to their config modules (e.g., lua/lsp/clangd.lua)
local servers = {
  clangd   = require('lsp.clangd'),
  lua_ls   = require('lsp.lua_ls'),
  linux    = require('lsp.linux'),
  embedded = require('lsp.embedded'),
}

function M.setup()
  -- Apply diagnostic UI globally (Zero-glitch icons)
  vim.diagnostic.config({
    virtual_text = { prefix = '●', spacing = 2 },
    signs = true,
    underline = true,
    update_in_insert = false, -- Only update when you stop typing
    severity_sort = true,
  })

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
      local function map_deprecated(old, current, func, desc)
        -- The "Classic" Key (Triggers Warning)
        vim.keymap.set('n', old, function()
          func()
          vim.notify(
            string.format("DEPRECATED: '%s' -> USE: '%s'", old, current),
            vim.log.levels.WARN,
            { title = "LSP Architect", render = "minimal" }
          )
        end, { buffer = bufnr, desc = desc .. " (Deprecated)" })

        -- The "Standard" Key (Silent & Fast)
        vim.keymap.set('n', current, func, { buffer = bufnr, desc = desc })
      end

      -- 1. Navigation Chords
      map_deprecated('gd',  'grd', vim.lsp.buf.definition,      "Go to Definition")
      map_deprecated('gr',  'grr', vim.lsp.buf.references,      "References")
      map_deprecated('gi',  'gri', vim.lsp.buf.implementation,  "Implementation")
      map_deprecated('gt',  'grt', vim.lsp.buf.type_definition, "Type Definition")

      -- 2. Action Chords
      map_deprecated('<leader>rn', 'grn', vim.lsp.buf.rename,      "Rename")
      map_deprecated('<leader>ca', 'gra', vim.lsp.buf.code_action, "Code Action")

      -- 3. One-Shot Essentials (Non-deprecated)
      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration,     opts)
      vim.keymap.set('n', 'K',  vim.lsp.buf.hover,           opts)
      vim.keymap.set('n', 'gO', vim.lsp.buf.document_symbol, opts)
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev,    opts)
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next,    opts)

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
      if client.supports_method('textDocument/completion') then
        vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = false })

        vim.keymap.set('i', '<C-Space>', function()
          vim.lsp.completion.trigger()
        end, { buffer = ev.buf, desc = "LSP Completion" })
      end

      if client.supports_method('textDocument/inlayHint') then
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      end
    end,
  })

  -- 5. Enable the Servers
  for name, config in pairs(servers) do
    vim.lsp.config[name] = config
    vim.lsp.enable(name)
  end
end

return M
