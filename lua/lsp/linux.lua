return {
  cmd = { "clangd", "--compile-commands-dir=build/linux/debug" },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    if fname == "" then return end
    
    local cwd = vim.fn.getcwd()

    -- Check if it belongs to embedded-only context (app or Zephyr SDK /ncs/)
    if fname:find(cwd .. "/app/", 1, true)
       or fname:find("/ncs/", 1, true) then
      return
    end

    -- Check if it belongs to linux or core context
    local is_linux = fname:find(cwd .. "/linux/", 1, true)
                  or fname:find(cwd .. "/core/", 1, true)

    -- If it's a system/external file, check the alternate buffer context
    if not is_linux then
      local alt_buf = vim.fn.bufnr('#')
      local alt_name = alt_buf > 0 and vim.api.nvim_buf_get_name(alt_buf) or ""
      if alt_name ~= "" then
        if alt_name:find(cwd .. "/app/", 1, true)
           or alt_name:find("/ncs/", 1, true) then
          return -- Alternate buffer was embedded-only, so this system file should be embedded context
        elseif alt_name:find(cwd .. "/linux/", 1, true)
            or alt_name:find(cwd .. "/core/", 1, true) then
          is_linux = true
        end
      else
        -- Default to linux if there is no alternate buffer (e.g. opened directly)
        is_linux = true
      end
    end

    if is_linux and vim.fn.filereadable(cwd .. "/build/linux/debug/compile_commands.json") == 1 then
      on_dir(cwd)
    end
  end,
}
