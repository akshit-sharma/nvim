local function realpath(p)
  if not p or p == "" then
    return p
  end
  -- Fallback: expand + simplify
  return vim.fs.normalize(vim.fn.expand(p))
end

local function starts_with(s, prefix)
  return s:sub(1, #prefix) == prefix
end

local HOME = realpath(vim.env.HOME)
local CONFIG_BASE = realpath(HOME .. "/.config")

-- Root rules (ordered by priority)
-- Each rule returns either a root string or nil.
local ROOT_RULES = {
  -- 1) Fixed dirs (add as many as you want)
  {
    name = "hammerspoon",
    match = function(fname)
      local root = realpath(HOME .. "/.hammerspoon")
      if starts_with(fname, root .. "/") or fname == root then
        return root
      end
    end,
  },

  -- 2) Any ~/.config/<dir> becomes its own root
  {
    name = "xdg-config-subdir",
    match = function(fname)
      if starts_with(fname, CONFIG_BASE .. "/") then
        local rel = fname:sub(#CONFIG_BASE + 2) -- strip "~/.config/"
        local top = rel:match("([^/]+)")
        if top then
          return CONFIG_BASE .. "/" .. top
        end
      end
    end,
  },
}

local function pick_root(fname)
  fname = realpath(fname)
  if not fname or fname == "" then
    return nil
  end

  for _, rule in ipairs(ROOT_RULES) do
    local root = rule.match(fname)
    if root then
      return root
    end
  end

  return nil
end

return {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local root = pick_root(fname)
    if root then
      on_dir(root)
      return
    end

    -- fallback: git root if present, else current working directory
    local git = vim.fs.find(".git", { path = fname, upward = true })[1]
    on_dir(git and vim.fs.dirname(git) or vim.fn.getcwd())
  end,
}
