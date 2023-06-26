return function()
  local notify = require('notify')
  local banned_message =  { "warning: multiple different client offset_encodings detected for buffer, this is not supported yet" }
  -- list of banned_message with false
  local bm_displayed = {}
  for _, banned in ipairs(banned_message) do
    bm_displayed[banned] = false
  end
  vim.notify = function(msg, ...)
    for _, banned in ipairs(banned_message) do
      if msg == banned then
        if bm_displayed[banned] == true then
          --print("message is (" .. msg .. ")")
          return
        else
          bm_displayed[banned] = true
          break
        end
      end
    end
    notify(msg, ...)
  end
end
