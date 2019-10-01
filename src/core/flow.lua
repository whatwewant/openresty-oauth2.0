local getenv = os.getenv
local cjson = require('cjson')
local Cookie = require('resty.cookie')
local Oauth = require('oauth/core/core')
local config = require('oauth/core/config')
local object = require('oauth/utils/object')

local _M = {}
local mt = { __index = _M }

local COOKIES_USER = {
  username = 'uid',
  nickname = 'un',
  avatar = 'ua',
}

local COOKIES_TOKEN = 'ut'

function _M.new(self)
  local cookie, err = Cookie:new()
  local oauth = Oauth:new(config)
  if not cookie then
    ngx.log(ngx.ERR, err)
    return
  end

  return setmetatable({ cookie = cookie, oauth = oauth }, mt)
end

function _M.get_token(self)
  local token, err = self.cookie:get(COOKIES_TOKEN)

  if err then
    ngx.log(ngx.ERR, err)
    return nil
  end

  return token
end

function _M.get_user(self)
  -- User Info
  local user = {}

  for k, v in pairs(COOKIES_USER) do
    local value, err = self.cookie:get(v)

    if err then
      ngx.log(ngx.ERR, err)
      return
    end

    user[k] = value
  end

  return user
end

function _M.set_token(self, user, token)
  -- User Info
  for k, v in pairs(COOKIES_USER) do
    local ok, err = self.cookie:set(object.merge({
      key = v,
      value = user[k],
    }, config.cookie_options))

    if err then
      ngx.log(ngx.ERR, err)
      return
    end
  end

  -- Token Info
  local ok, err = self.cookie:set(object.merge({
    key = COOKIES_TOKEN,
    value = token,
  }, config.cookie_options))

  if err then
    ngx.log(ngx.ERR, err)
    return
  end
end

function _M.validate_token(self, token)
  if token == nil then
    ngx.log(ngx.INFO, '@Check.Validate(1) Token: Go to authorize')
    return self.oauth:authorize()
  end
end

function _M.validate_permission(self, user)
  local ok = object.includes(config.allow_usernames, user.username)
  if ok ~= true then
    ngx.log(ngx.INFO, '@Check.Validate(2) Permission: 403 Forbidden')
    return ngx.exit(ngx.HTTP_FORBIDDEN)
  end
end

function _M.check_done_or_go_authorize(self)
  -- @1 Get Token
  local token = self:get_token()
  ngx.log(ngx.INFO, '@Check.Prepare(1) Get Token: '..(token or 'null'))
  
  -- @2 Verify Token
  self:validate_token(token)
  ngx.log(ngx.INFO, '@Check.Validate(1) Token OK')

  -- @3 Get User
  local user = self:get_user()
  ngx.log(ngx.INFO, '@Check.Prepare(2) Get User: '..(user and user.username or 'null'))

  -- @4 Check Permission
  self:validate_permission(user)
  ngx.log(ngx.INFO, '@Check.Validate(1) Permission OK')
end

function _M.authorize(self)
  local args = ngx.req.get_uri_args()
  -- @1 Get Code
  local code = args.code
  ngx.log(ngx.INFO, '@Authorize(1) Get Code: '..(code or 'null'))

  if code == nil then
    -- @TODO
    return ngx.exit(ngx.HTTP_NOT_FOUND)
  end

  local uri = ngx.var.uri
  local matched = ngx.re.match(uri, [[^\/_oauth\/([^\/]+)]], 'jo')

  if matched == nil or matched[1] == nil then
    -- @TODO
    return ngx.exit(ngx.HTTP_NOT_FOUND)
  end

  -- @1.1 Get App Name
  local app_name = matched[1]
  ngx.log(ngx.INFO, '@Authorize(1.1) Get App Name: '..(app_name or 'null'))

  -- @2 Get Token
  local token = self.oauth:token(code)
  ngx.log(ngx.INFO, '@Authorize(2) Get Token: '..(token or 'null'))

  -- @3 Get User
  local user = self.oauth:user(token)
  ngx.log(ngx.INFO, '@Authorize(3) Get User: '..(user and user.username or 'null'))

  -- @4 Set Token
  self:set_token(user, token)
  ngx.log(ngx.INFO, '@Authorize(4) Set Token Done')

  -- @5 Check Permission
  self:validate_permission(user)
  ngx.log(ngx.INFO, '@Authorize(5) Check Permission Done')

  -- @6 Redirect
  -- @TODO default /
  local next = '/'
  ngx.redirect(next)
  ngx.log(ngx.INFO, '@Authorize(6) Redirect To: '..next)
end

return _M