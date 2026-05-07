return {
  cmd = { "clangd", "--compile-commands-dir=build/linux/debug" },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    if fname == "" then return end
    local cwd = vim.fn.getcwd()
    if fname:find(cwd .. "/app/") then return end
    if vim.fn.filereadable(cwd .. "/build/linux/debug/compile_commands.json") == 1 then
      -- vim.notify(("linux: fname=%s cwd=%s"):format(fname, cwd))
      on_dir(cwd)
    end
  end,
}
