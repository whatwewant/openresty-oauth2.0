
local cjson = require('cjson')
local requests = require('oauth/utils/requests')
local object = require('oauth/utils/object')

local Oauth = {}
local mt = { __index = Oauth }

function Oauth.new(self, options)
  local debug = options.debug

  return setmetatable({
    options = options,
    debug = debug,
  }, mt)
end

-- @2 URL INFO
-- @2.1 GET AUTHORIZE_URL
--   args: ?client_id=CLIENT_ID&redirect_uri=REDIRECT_URI&scope=SCOPE&state=xxx
function Oauth.authorize(self)
  local query = {
    client_id = self.options.client_id,
    redirect_uri = self.options.redirect_uri,
    response_type = self.options.response_type,
    scope = self.options.scope,
    state = self.options.state, -- @TODO
  }

  local url = self.options.authorize_url..'?'..ngx.encode_args(query)

  return ngx.redirect(url)
end

-- @2.2 POST TOKEN_URL
--  body: { client_id, client_secret, redirect_uri, code, state }
function Oauth.token(self, code, state)
  local url = self.options.token_url;
  local body = {
    client_id = self.options.client_id,
    client_secret = self.options.client_secret,
    redirect_uri = self.options.redirect_uri,
    grant_type = self.options.grant_type,
    code = code,
    state = state -- @TODO
  }

  local res, err = requests.post(url, body)
  if err then
    ngx.say(err)
    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
  end

  -- { scope, token_type, access_token }
  if res.access_token == nil then
    -- @DEBUG
    if self.debug then
      ngx.say(cjson.encode({
        debug = self.debug,
        context = self.options,
        response = res,
      }))
      return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end

    -- @ERROR LOG
    ngx.log(ngx.ERR, cjson.encode({
      debug = self.debug,
      context = self.options,
      response = res,
    }))

    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
  end

  return res.access_token
end

function Oauth.user(self, token)
  local url = self.options.user_info_url
  local headers = {
    -- ['Content-Type'] = 'application/json',
    Accept = 'application/json',
    Authorization = 'Bearer '..token,
  }
  
  local user, err = requests.get(url, headers)

  if err then
    ngx.say(err)
    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
  end

  -- return object.pick_alias(user, self.options.user_fields)
  return self:map_user(user)
end

function Oauth.map_user(self, user)
  -- User Info
  local user_fields_map = self.options.user_fields
  local mapped_user = {}

  -- @example { username = 'login' }
  -- @example key: username, v_map: login
  for key, v_map in pairs(user_fields_map) do
    if v_map then
      local value = user[v_map]

      -- has v_map, but value is nil, need debug
      if not value then
        -- @DEBUG
        if self.debug then
          ngx.say(cjson.encode({
            debug = self.debug,
            context = self.options,
            response = user,
          }))
          return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
        end

        -- @ERROR LOG
        ngx.log(ngx.ERR, cjson.encode({
          debug = self.debug,
          context = self.options,
          response = user,
        }))
        return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
      end

      mapped_user[key] = value
    end
  end

  return mapped_user
end

return Oauth;