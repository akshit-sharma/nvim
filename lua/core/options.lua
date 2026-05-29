-- lua/core/options.lua

-- Disable legacy remote provider detection (Saves ~52ms on Python files)
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider    = 0
vim.g.loaded_node_provider    = 0
vim.g.loaded_perl_provider    = 0

-- 1. Performance & Latency Essentials
vim.opt.updatetime = 250       -- Faster completion/diagnostic response (default is 4000ms)
vim.opt.timeoutlen = 300       -- Faster key-mapping response
vim.opt.lazyredraw = true      -- Don't redraw screen while executing macros (Zero-Glitch)
vim.opt.shadafile  = ""        -- Handled by sessions.lua, keep baseline clean

-- 2. Visuals & UI (The "Standard" Look)
vim.opt.termguicolors = true   -- 24-bit RGB color
vim.opt.number         = true   -- Show line numbers
vim.opt.relativenumber = true   -- Show relative numbers (Disabled by Guard on big files)
vim.opt.signcolumn     = "yes:2" -- Always show 1-column wide sign column to prevent "jumping"
vim.opt.numberwidth    = 3
vim.opt.cursorline     = true   -- Highlight current line
vim.opt.cursorlineopt  = "number" -- Only highlight the number, not the whole line (Faster)

-- 3. Search & Interaction
vim.opt.ignorecase = true      -- Ignore case in search patterns
vim.opt.smartcase  = true      -- ...unless search contains a capital letter
vim.opt.mouse      = "a"       -- Enable mouse for those "just in case" moments
vim.opt.scrolloff  = 8         -- Keep 8 lines of context when scrolling

-- 4. Indentation & Tabs (Standard Project Rules)
vim.opt.expandtab    = true      -- Convert tabs to spaces
vim.opt.shiftwidth   = 2         -- 1 tab = 2 spaces
vim.opt.tabstop      = 2
vim.opt.conceallevel = 2
vim.opt.autoindent   = true
vim.opt.smartindent  = false

-- 5. Split Management
vim.opt.splitright = true      -- Horizontal splits open to the right
vim.opt.splitbelow = true      -- Vertical splits open below

-- 6. Baseline Folding (CHEAP FALLBACK)
-- We set this to 'indent' as a baseline.
-- The 'folding.lua' module will upgrade this to 'expr' for TS files.
vim.opt.fillchars:append({ fold = " " })
vim.opt.viewoptions = { "folds", "cursor" }
vim.opt.foldmethod = "indent"
vim.opt.foldminlines = 1
vim.opt.foldlevel  = 99

vim.opt.viewoptions = { "folds", "cursor" }

vim.opt.foldopen = "hor,mark,percent,quickfix,search,tag,undo"
