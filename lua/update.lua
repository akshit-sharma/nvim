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

