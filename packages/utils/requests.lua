local requests = require('resty.requests')
local cjson = require('cjson')
local object = require('oauth/utils/object')

local USER_AGENT = 'ZoathOpenresty/0.0.9';

local _M = {}

function _M.get(url, headers)
  local _headers = object.merge({
    ['User-Agent'] = USER_AGENT,
  }, headers)
  local res, err = requests.get(url, { headers = headers })
  
  -- ngx.say(cjson.encode({
  --   url = url,
  --   headers = headers,
  --   res = res:json(),
  --   err = err,
  -- }))

  if err then
    ngx.log(ngx.ERR, err)
    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
  end

  return res:json(), err
end

function _M.post(url, body)
  local headers = {
    ['Content-Type'] = 'application/json',
    ['User-Agent'] = USER_AGENT,
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

  if err then
    ngx.log(ngx.ERR, err)
    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
  end

  -- if true then
  --   ngx.say(cjson.encode({
  --     err = err,
  --     res = {
  --       url = res.url,
  --       method = res.method,
  --       status = res.status_code,
  --       headers = res.headers,
  --       body = res:body(),
  --       json = res:json(),
  --       elapsed = res.elapsed,
  --     },
  --   }))
  --   return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
  -- end

  return res:json(), err
end

return _M