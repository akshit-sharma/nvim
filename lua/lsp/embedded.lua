return {
  cmd = {
    "clangd",
    "--compile-commands-dir=build/app/debug",
    "--query-driver=/home/akshit/ncs/toolchains/*/opt/zephyr-sdk/arm-zephyr-eabi/bin/arm-zephyr-eabi-*"
  },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    if fname == "" then return end
    
    local cwd = vim.fn.getcwd()

    -- Check if it belongs to linux context
    if fname:find(cwd .. "/linux/", 1, true) then return end

    -- Check if it belongs to embedded context (app, core, or Zephyr SDK /ncs/)
    local is_embedded = fname:find(cwd .. "/app/", 1, true)
                     or fname:find(cwd .. "/core/", 1, true)
                     or fname:find("/ncs/", 1, true)

    -- If it's a system/external file, check the alternate buffer context
    if not is_embedded then
      local alt_buf = vim.fn.bufnr('#')
      local alt_name = alt_buf > 0 and vim.api.nvim_buf_get_name(alt_buf) or ""
      if alt_name ~= "" then
        if alt_name:find(cwd .. "/linux/", 1, true) then
          return -- Alternate buffer was linux, so this system file should be linux context
        elseif alt_name:find(cwd .. "/app/", 1, true)
            or alt_name:find(cwd .. "/core/", 1, true)
            or alt_name:find("/ncs/", 1, true) then
          is_embedded = true
        end
      end
    end

    if is_embedded and vim.fn.filereadable(cwd .. "/build/app/debug/compile_commands.json") == 1 then
      on_dir(cwd)
    end
  end,
}
