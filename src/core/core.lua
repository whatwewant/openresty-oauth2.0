
local cjson = require('cjson')
local requests = require('oauth/utils/requests')
local object = require('oauth/utils/object')

local Oauth = {}
local mt = { __index = Oauth }

function Oauth.new(self, options)
  return setmetatable({ options = options }, mt)
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
    return ngx.exit(500)
  end

  -- { scope, token_type, access_token }
  if res.access_token == nil then
    ngx.say(cjson.encode(res))
    return ngx.exit(500)
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
    return ngx.exit(500)
  end

  return object.pick_alias(user, self.options.user_fields)

end

return Oauth;