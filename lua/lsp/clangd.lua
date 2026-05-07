return {
  cmd = { "clangd" },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
  root_dir = function(_, on_dir)
    local marker_files = {
      "build/debug/compile_commands.json",
      "build/compile_commands.json",
      "build/release/compile_commands.json",
      "compile_commands.json",
    }
    local project_root = vim.fn.getcwd()
    for _, marker_file in ipairs(marker_files) do
      if vim.fn.filereadable(project_root .. "/" .. marker_file) == 1 then
        on_dir(project_root)
      end
    end
  end,
}
