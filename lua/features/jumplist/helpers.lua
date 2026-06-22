local M = {}

-- Helper to safely load a buffer and get its line content
function M.get_line_content(bufnr, lnum)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return ""
  end
  local loaded = vim.api.nvim_buf_is_loaded(bufnr)
  if not loaded then
    vim.fn.bufload(bufnr)
  end
  local lines = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)
  return lines[1] or ""
end

-- Helper to get the filename basename + line number
function M.get_basename_with_line(bufnr, lnum)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return "[None]"
  end
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then
    return string.format("[No Name]:%d", lnum)
  end
  local basename = vim.fn.fnamemodify(name, ":t")
  return string.format("%s:%d", basename, lnum)
end

-- Helper to fetch and normalize native jumplist entries
function M.get_normalized_jumps(win)
  local jl = vim.fn.getjumplist(win)
  if not jl or #jl[1] == 0 then
    local current_buf = vim.api.nvim_win_get_buf(win)
    local cursor = vim.api.nvim_win_get_cursor(win)
    jl = {
      {
        {
          bufnr = current_buf,
          lnum = cursor[1],
          col = cursor[2],
          filename = vim.api.nvim_buf_get_name(current_buf),
        }
      },
      0
    }
  end

  local raw_jumps = jl[1] or {}
  local current_idx = jl[2] or 0

  local normalized = {}
  for _, j in ipairs(raw_jumps) do
    if j.bufnr and vim.api.nvim_buf_is_valid(j.bufnr) then
      table.insert(normalized, {
        bufnr = j.bufnr,
        lnum = j.lnum,
        col = j.col or 0,
        filename = j.filename or vim.api.nvim_buf_get_name(j.bufnr),
      })
    end
  end

  if #normalized == 0 then
    local current_buf = vim.api.nvim_win_get_buf(win)
    local cursor = vim.api.nvim_win_get_cursor(win)
    table.insert(normalized, {
      bufnr = current_buf,
      lnum = cursor[1],
      col = cursor[2],
      filename = vim.api.nvim_buf_get_name(current_buf),
    })
    current_idx = 0
  end

  if current_idx >= #normalized then
    current_idx = #normalized - 1
  end

  return normalized, current_idx
end

return M
