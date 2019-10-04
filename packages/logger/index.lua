local cjson = require('cjson')
local core_config = require('oauth/core/config')

local stringify = cjson.encode

local debug_mode = core_config.debug

local _M = {}

local function info(json)
  local body = stringify(json)
  ngx.info(ngx.ERR, body)
end

local function debug(json)
  local body = stringify(json)

  if debug_mode then
    ngx.say(body)
    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
  end

  ngx.log(ngx.ERR, body)
end

_M.debug = debug
_M.info = info

return _M