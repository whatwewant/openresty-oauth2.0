local cjson = require('cjson')
local config = require('oauth/core/config')
local object = require('oauth/utils/object')

local version = '0.0.2'

local stringify = cjson.encode
local format = string.format
-- local merge = object.merge

local debug_mode = config.debug

local _M = {}

local context = nil

-- Static Context, such as config
local function getContext()
  if not context then
    context = {
      config = config,
    }
  end
  
  return context
end

-- Dynamic Rqeuest Context, such as request info
local function get_request_context()
  return {
    uri = ngx.var.uri,
    method = ngx.req.get_method(),
    headers = ngx.req.get_headers(),
    query = ngx.req.get_uri_args(),
    ip = ngx.var.remote_addr,
    http_version = ngx.req.http_version(),
    start_time = ngx.req.start_time(),
    response_time = ngx.now() - ngx.req.start_time(),
    created_at = ngx.now(),
  }
end

local function get_body(json)
  return stringify({
    logger = json,
    context = getContext(),
    request_context = get_request_context(),
  })
end

local function info(message, code)
  if type(message) == 'string' then
    return ngx.log(ngx.INFO, format('[%s] %s', code or 200, message))
  end

  local body = message
  ngx.log(ngx.INFO, cjson.encode(body))
end

local function debug(json, status)
  local body = get_body(json)

  if debug_mode then
    -- set content type json
    ngx.header['Content-Type'] = 'application/json; charset=utf-8'

    ngx.say(body)
    return ngx.exit(status or ngx.HTTP_INTERNAL_SERVER_ERROR)
  end

  ngx.log(ngx.ERR, body)
end

_M.version = version
_M.log = info
_M.debug = debug
_M.info = info

return _M