local ok, plenary_reload = pcall(require, "plenary_reload")
if not ok then
  reloader = require
else
  reloader = plenary_reload.reload_module
end

local ok, plenary_job = pcall(require, "plenary_job")
if not ok then
  COMMAND = function(commandName, commandArgs, workingDir, onExit, sync)
--    vim.notify("might not be functional, type is "..type(commandArgs))
    cmdList = {}
    table.insert(cmdList, commandName)
    for key, arg in pairs(commandArgs) do
      table.insert(cmdList, arg)
    end
    vim.fn.system(cmdList)
  end
else
  COMMAND = function(commandName, commandArgs, workingDir, onExit, sync)
    vim.notify("making job ")
    job = Job:new({
      command = commandName,
      args = commandArgs,
      cwd = workingDir,
      on_exit = function(j, return_val)
        onExit(j, return_val)
      end,
    })
    if sync then
      job:sync()
    else
      job:start()
    end
  end
end

P = function(v)
  print(vim.inspect(v))
  return v
end

RELOAD = function(...)
  return reloader(...)
end

R = function(name)
  RELOAD(name)
  return require(name)
end


NOREMAP = { noremap = true }
NOREMAP_SILENT = { noremap = true, silent = true }
KM = function(mode, key, result, map_dict)
  map_dict = map_dict or NOREMAP_SILENT
  vim.api.nvim_set_keymap(mode, key, result, map_dict)
end

