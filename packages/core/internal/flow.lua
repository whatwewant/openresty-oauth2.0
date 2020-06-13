local getenv = os.getenv
local cjson = require('cjson')
local Cookie = require('resty.cookie')
local Aes = require('resty.aes')
local Lru = require('resty.lrucache')
-- local String = require('resty.string')

local Oauth = require('oauth/core/internal/oauth')
local config = require('oauth/core/config')
local logger = require('logger/index')
local object = require('oauth/utils/object')

local format = string.format
local stringify = cjson.encode

local MAX_SIGNATURE_CACHE_SIZE = 200
local signature_cache = Lru.new(MAX_SIGNATURE_CACHE_SIZE)

local _M = {}
local mt = { __index = _M }

local COOKIES_USER = config.cookie_fields

local COOKIES_TOKEN = config.cookie_token

function _M.new(self)
  local cookie, err = Cookie:new()
  local oauth = Oauth:new(config)
  local aes = Aes:new(config.cookie_secret)

  if not cookie then
    logger.debug({
      message = 'resty.cookie new error, please check the lib',
      error = err,
    })

    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
  end

  return setmetatable({
    cookie = cookie,
    oauth = oauth,
    aes = aes,
  }, mt)
end

function _M.get_token(self)
  local token, err = self.cookie:get(COOKIES_TOKEN)

  if token ~= nil and err then
    logger.debug({
      message = '[get_token] get token from cookie error',
      error = err,
    })

    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
  end

  return token
end

function _M.get_user(self)
  -- User Info
  local user = {}

  for k, v in pairs(COOKIES_USER) do
    local value, err = self.cookie:get(v)

    if err then
      logger.debug({
        message = string.format('[get_user] get user(%s: %s) from cookie error', v, value),
        error = err,
      })
  
      return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end

    user[k] = value
  end

  if not user.username then
    logger.debug({
      message = format('Invalid User.username field (username is nil by cookie key (%s))', COOKIES_USER.username),
      user = user,
    })

    return ngx.exit(ngx.INTERNAL_SERVER_ERROR)
  end

  self:validate_signature(user.signature)

  return user
end

function _M.validate_signature(self, signature)
  if not signature then
    -- @TODO should remember current path for redirect
    logger.log('Invalid Signature, Go Authorize')
    return self.oauth:authorize()
  end

  local is_valid = signature_cache:get(signature)
  if not is_valid then
    logger.log(format('[validate_signature] signature not hit cache, using ase:descript'))
    
    is_valid = self.aes:decrypt(ndk.set_var.set_decode_hex(signature))
    signature_cache:set(signature, true, 60 * 5) -- @TODO 5 minutes
  else
    logger.log('[validate_signature] signature hit cache')
  end

  -- ngx.say(signature..': '..tostring(is_valid))

  if not is_valid then
    -- return ngx.exit(ngx.HTTP_FORBIDDEN)
    logger.log(format('Invalid Signature (%s), Go Authorize', signature))
    ngx.sleep(1)
    return self.oauth:authorize()
  end
end

function _M.generate_signature(self, username)
  return ndk.set_var.set_encode_hex(self.aes:encrypt(username))
end

function _M.set_token(self, user, token)
  -- Generate Signature Info
  user.signature = self:generate_signature(user.username)

  -- User Info
  for k, v in pairs(COOKIES_USER) do
    local key = v
    local value = user[k]

    -- @ISSUE: attempt to concatenate field 'value' (a userdata value)
    --  1.json null is userdata, custom structure
    --  2.nickname, avatar maybe is null
    --  3.json null != nil, null == ngx.null
    --
    if value == ngx.null then
      value = 'null'
    end

    local ok, err = self.cookie:set(object.merge({
      key = key,
      value = value,
    }, config.cookie_options))

    if err then
      logger.debug({
        message = format('[set_token] failed to set user to cookie (%s: %s)', k, user[k]),
        error = err,
      })
      
      return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end
  end

  -- Token Info
  local ok, err = self.cookie:set(object.merge({
    key = COOKIES_TOKEN,
    value = token,
  }, config.cookie_options))

  if err then
    logger.debug({
      message = format('[set_token] failed to set token to cookie (%s: %s)', COOKIES_TOKEN, token),
      error = err,
    })

    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
  end
end

function _M.validate_token(self, token)
  if token == nil then
    logger.log('@Check.Validate(1) Token: Go to authorize')
    return self.oauth:authorize()
  end
end

function _M.validate_permission(self, user)
  if config.allow_all then
    return true
  end

  local ok = object.includes(config.allow_usernames, user.username)
  if not ok then
    logger.debug({
      message = '[validate_permission] @Check.Validate(2) Permission: 403 Forbidden',
      params = {
        username = user.username,
        allow_usernames = config.allow_usernames,
      },
    }, ngx.HTTP_FORBIDDEN)

    -- @TODO if uri ~= '/', redirect '/'
    if ngx.var.uri ~= '/' then
      -- @PROD production mode
      -- @TODO return ngx.exit(ngx.HTTP_FORBIDDEN)
      return ngx.redirect('/')
    end

    -- @TODO callback url is /login/{provider}/callback, so if it is impossible to get here
    logger.debug({
      message = '[validate_permission] callback url is /login/{provider}/callback, so if it is impossible to get here',
      params = {
        username = user.username,
        allow_usernames = config.allow_usernames,
      },
    }, ngx.HTTP_FORBIDDEN)

    return ngx.exit(ngx.HTTP_FORBIDDEN)
  end
end

function _M.get_code(self)
  local args = ngx.req.get_uri_args()
  -- @1 Get Code
  local code = args.code

  if code == nil then
    logger.debug({
      message = string.format('No Code Provided, or Invalid Uri Visit In: %s, this is used to authorize callback only', ngx.var.uri),
    })

    return ngx.exit(ngx.HTTP_NOT_FOUND)
  end

  return code
end

function _M.get_provider(self)
  local uri = ngx.var.uri
  local matched = ngx.re.match(uri, [[^\/login\/([^\/]+)\/callback]], 'jo')

  if matched == nil or matched[1] == nil then
    -- @TODO
    return ngx.exit(ngx.HTTP_NOT_FOUND)
  end

  -- @1.1 Get App Name (Provider)
  local provider = matched[1]
  logger.log(format('@Authorize(1.1) Get App Name: %s', (provider or 'null')))

  if provider ~= config.provider then
    logger.debug({
      message = string.format('[get_provider] invalid callback url with provider(%s), should be %s', provider, config.provider),
      params = {
        provider = provider,
      },
    })

    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
  end

  return provider
end

function _M.check_done_or_go_authorize(self)
  -- @1 Get Token
  local token = self:get_token()
  logger.log(format('@Check.Prepare(1) Get Token: %s', (token or 'null')))
  
  -- @2 Verify Token
  self:validate_token(token)
  logger.log('@Check.Validate(1) Token OK')

  -- @3 Get User
  local user = self:get_user()
  logger.log(format('@Check.Prepare(2) Get User: %s', (user and user.username or 'null')))

  -- @4 Check Permission
  self:validate_permission(user)
  logger.log('@Check.Validate(2) Permission OK')
end

function _M.authorize(self)
  -- @1 Get Code
  local code = self:get_code()
  logger.log(format('@Authorize(1) Get Code: %s', (code or 'null')))

  -- @1.1 Get App Name (Provider)
  local provider = self:get_provider()
  logger.log(format('@Authorize(1.1) Get App Name: %s', (provider or 'null')))

  -- @2 Get Token
  local token = self.oauth:token(code)
  logger.log(format('@Authorize(2) Get Token: %s', (token or 'null')))

  -- @3 Get User
  local user = self.oauth:user(token)
  logger.log(format('@Authorize(3) Get User: %s', (user and user.username or 'null')))

  -- @4 Set Token
  self:set_token(user, token)
  logger.log('@Authorize(4) Set Token Done')

  -- @5 Check Permission
  self:validate_permission(user)
  logger.log('@Authorize(5) Check Permission Done')

  -- @6 Redirect
  -- @TODO default /
  local next = '/'
  ngx.redirect(next)
  logger.log(format('@Authorize(6) Redirect To: %s', next))
end

return _M
