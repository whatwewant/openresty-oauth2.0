local cjson = require('cjson')
local core_config = require('oauth/core/config')
local object = require('oauth/utils/object')

local stringify = cjson.encode
local merge = object.merge

local debug_mode = core_config.debug

local _M = {}

local function info(json)
  local body = stringify(merge(json, { debug = debug_mode }))
  ngx.info(ngx.ERR, body)
end

local function debug(json, status)
  local body = stringify(merge(json, { debug = debug_mode }))

  if debug_mode then
    ngx.say(body)
    return ngx.exit(status or ngx.HTTP_INTERNAL_SERVER_ERROR)
  end

  ngx.log(ngx.ERR, body)
end

_M.debug = debug
_M.info = info

return _M