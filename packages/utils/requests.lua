local requests = require('resty.requests')
local cjson = require('cjson')

local logger = require('oauth/logger/index')
local object = require('oauth/utils/object')

local USER_AGENT = 'ZoathOpenresty/0.0.9';

local _M = {}

local function get(url, headers)
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
    logger.debug({
      message = 'requests.get error',
      error = err,
    })

    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
  end

  return res:json(), err
end

local function post(url, body)
  local headers = {
    ['Content-Type'] = 'application/json',
    ['User-Agent'] = USER_AGENT,
    Accept = 'application/json',
  }

  local res, err = requests.post(url, { body = cjson.encode(body), headers = headers })

  if err then
    logger.debug({
      message = 'requests.post error',
      error = err,
    })

    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
  end

  return res:json(), err
end

_M.get = get
_M.post = post

return _M