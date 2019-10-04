
local cjson = require('cjson')
local logger = require('logger/index')
local requests = require('oauth/utils/requests')
local object = require('oauth/utils/object')

local stringify = cjson.encode
local get = object.get

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
  local data = {
    client_id = self.options.client_id,
    client_secret = self.options.client_secret,
    redirect_uri = self.options.redirect_uri,
    grant_type = self.options.grant_type,
    code = code,
    state = state -- @TODO
  }

  local res, err = nil, nil
  -- in body
  if self.options.token_data_in_body then
    res, err = requests.post(url, data)
  -- in query
  elseif self.options.token_data_in_query then
    res, err = requests.post(url..'?'..ngx.encode_args(data))
  else
    logger.debug({
      message = '[token] please set token_data_in_body or token_data_in_query',
      response = res,
    })

    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
  end

  -- if true then
  --   ngx.say(stringify({
  --     message = 'core.token',
  --     url = url,
  --     body = body,
  --     res = res,
  --     err = err,
  --   }))
  --   return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
  -- end

  if err then
    ngx.say(err)
    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
  end

  -- { scope, token_type, access_token }
  if res.access_token == nil then
    logger.debug({
      message = '[token] access_token is nil, please see response',
      response = res,
    })

    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
  end

  return res.access_token
end

function Oauth.user(self, token)
  local base_url = self.options.user_info_url
  local header = self:get_user_header(token)
  local query = self:get_user_query(token)
  -- local body = self:get_user_body(token)

  local url = base_url..query

  local headers = object.merge({
    -- ['Content-Type'] = 'application/json',
    Accept = 'application/json',
    -- Authorization = 'Bearer '..token,
  }, header)
  
  local user, err = requests.get(url, headers)

  if err then
    ngx.say(stringify({
      context = {
        url = base_url,
        header = header,
        headers = headers,
        query = query,
      },
      err = err,
    }))

    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
  end

  -- @TODO
  -- if true then
  --   ngx.say(stringify({
  --     context = {
  --       url = base_url,
  --       header = header,
  --       headers = headers,
  --       query = query,
  --     },
  --     err = err,
  --   }))
  --   return ngx.exit(500)
  -- end

  -- return object.pick_alias(user, self.options.user_fields)
  return self:map_user(user)
end

function Oauth.get_user_header(self, token)
  if self.options.user_info_header then
    return {
      [self.options.user_info_header] = 'Bearer '..token, -- @TODO TOKEN
    }
  end

  return nil
end

function Oauth.get_user_query(self, token)
  if self.options.user_info_query then
    return '?'..ngx.encode_args({
      [self.options.user_info_query] = token,
    })
  end

  return ''
end

-- function Oauth.get_user_body(self, token)
--   if self.options.user_info_body then
--     return {
--       [self.options.user_info_body] = token,
--     }
--   end

--   return ''
-- end

function Oauth.map_user(self, user)
  -- User Info
  local user_fields_map = self.options.user_fields
  local mapped_user = {}

  -- @example { username = 'login' }
  -- @example key: username, v_map: login
  for key, v_map in pairs(user_fields_map) do
    if v_map then
      local value = get(user, v_map) -- user[v_map]

      -- has v_map, but value is nil, need debug
      if not value then
        logger.debug({
          message = '[map_user] user fields('..key..') failed, please look at the response',
          response = user,
        })

        return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
      end

      mapped_user[key] = value
    end
  end

  return mapped_user
end

return Oauth;