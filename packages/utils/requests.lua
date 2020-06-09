local requests = require('resty.requests')
local cjson = require('cjson')

local logger = require('oauth/logger/index')
local object = require('oauth/utils/object')
local string = require('oauth/utils/string')

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

local function post(url, body, headers)
  local headers = object.merge({
    ['Content-Type'] = 'application/json',
    ['User-Agent'] = USER_AGENT,
    Accept = 'application/json',
  }, headers)

  local _body = nil

  -- support application/x-www-form-urlencoded
  --  default application/json
  if string.includes(headers['Content-Type'], 'application/x-www-form-urlencoded') then
    _body = ngx.encode_args(body)
  else
    _body = cjson.encode(body)
  end

  local res, err = requests.post(url, { body = _body, headers = headers })

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