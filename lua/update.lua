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

local remote_url = 'https://github.com/akshit-sharma/nvim'
local config_parent = vim.fn.stdpath('config')
local config_root = 'nvim/'
local config_path = config_parent..config_root

local update_required = function(git_path, remote_url, update_cmd)
  update_cmd()
end

local clone_or_update_repo = function()
  local fn = vim.fn
  if fn.empty(fn.glob(config_path)) > 0 or fn.empty(fn.glob(config_path..'init.lua')) > 0 then
    on_exit = function(j, return_val)
      vim.notify('cloned repo ('..return_val..')')
    end
    COMMAND('git', {'clone', remote_url, config_path}, config_parent, on_exit, false)
    return
  end
  on_update_exit = function(j, return_val)
    vim.notify('pulled repo ('..return_val..')')
  end
  local update_cmd = function()
    COMMAND('git', {'pull', '-C', config_path}, config_path, on_update_exit, false)
  end
  update_required(config_path..'nvim', remote_url, update_cmd) 
end

clone_or_update_repo()

