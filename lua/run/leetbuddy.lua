local api = vim.api

local function post_leetcode()
  local filepath = api.nvim_buf_get_name(0)
  local home_directory = vim.loop.os_homedir()
  local leetcode_directory = home_directory .. '/.leetcode'
  local cpp_extension = '.cpp'

  if filepath:sub(1, #leetcode_directory) == leetcode_directory and filepath:sub(-#cpp_extension) == cpp_extension then
    vim.notify("Matched with " .. filepath, vim.log.levels.INFO)
  else
    vim.notify("Not matched with " .. filepath, vim.log.levels.INFO)
  end

  -- if filepath:find("^" .. leetcode_directory) and filepath:find(cpp_extension .. "$") then
  --   vim.notify("matched with " .. tostring(filepath))
  -- else
  --   vim.notify("not matched with " .. tostring(filepath))
  -- end
end

local leetcode_group = api.nvim_create_augroup("leetcode_autoexecute", { clear = true })
api.nvim_create_autocmd("BufEnter",
{ pattern = "cpp",
callback = post_leetcode,
group = leetcode_group
})
