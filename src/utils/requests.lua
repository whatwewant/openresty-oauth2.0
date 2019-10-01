local requests = require('resty.requests')
local cjson = require('cjson')

local _M = {}

function _M.get(url, headers)
  local res, err = requests.get(url, { headers = headers })
  
  -- ngx.say(cjson.encode({
  --   url = url,
  --   headers = headers,
  --   res = res:json(),
  --   err = err,
  -- }))

  return res:json(), err
end

function _M.post(url, body)
  local headers = {
    ['Content-Type'] = 'application/json',
    Accept = 'application/json',
  }

  local res, err = requests.post(url, { body = cjson.encode(body), headers = headers })

  -- ngx.say(cjson.encode({
  --   url = url,
  --   body = body,
  --   headers = headers,
  --   res = res:json(),
  --   err = err,
  -- }))

  return res:json(), err
end

return _M