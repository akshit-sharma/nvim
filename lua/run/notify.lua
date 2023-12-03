return function()
  local notify = require('notify')
  local once_message =  { "warning: multiple different client offset_encodings detected for buffer, this is not supported yet" }
  -- list of banned_message with false
  local bm_displayed = {}
  for _, banned in ipairs(once_message) do
    bm_displayed[banned] = false
  end

  local levelSymbol = {}
  levelSymbol[vim.log.levels.DEBUG] = " "
  levelSymbol[vim.log.levels.ERROR] = " "
  levelSymbol[vim.log.levels.INFO] = " "
  levelSymbol[vim.log.levels.TRACE] = "🔍"
  levelSymbol[vim.log.levels.WARN] = " "
  levelSymbol[vim.log.levels.OFF] = "⛔"

  local notifications = {}

  local isShownOnce = function(msg)
    for _, banned in ipairs(once_message) do
      if msg == banned then
        return true
      end
    end
    return false
  end

  local customNotify = function(msg, level, opts)
    opts = type(opts) == 'table' and opts or {}
    opts.title = opts.title or "misc"
    opts.render = opts.render or "wrapped-compact"
    local displayer = notify

    if isShownOnce(msg) then
      opts.title = opts.title or "notify once"
      displayer = vim.notify_once
    end

    level = level or vim.log.levels.INFO
    msg = levelSymbol[level] .. " " .. msg
    local prevWin = nil

    if notifications[opts.title] then
      prevWin = notifications[opts.title].win
      notifications[opts.title].msg = msg .. "\n" .. notifications[opts.title].msg
    else
      notifications[opts.title] = { msg = msg, level = level, opts = opts, win = nil }
    end

    local notification = notifications[opts.title]
    local dmsg = notification.msg
    local dlevel = notification.level
    local dopts = notification.opts

    local on_open = function(win)
      notifications[opts.title].win = win
      if opts.on_open then
        opts.on_open(win)
      end
    end

    dopts.on_open = on_open

    if prevWin and vim.api.nvim_win_is_valid(prevWin) then
      vim.api.nvim_win_close(prevWin, true)
    end

    displayer(dmsg, dlevel, dopts)
  end

  local customNotifySimple = function(msg, level, opts)
    opts = type(opts) == 'table' and opts or {}
    opts.title = opts.title or "misc"
    opts.render = opts.render or "wrapped-compact"
    local displayer = notify
    if isShownOnce(msg) then
      displayer = vim.notify_once
    end
    displayer(msg, level, opts)
  end
  vim.notify = customNotifySimple
end
