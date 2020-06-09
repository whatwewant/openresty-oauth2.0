local base_config = require('oauth/core/config')

-- Provider Name
local name = 'coding'
-- Provider Version
local version = '0.0.2'

local config = {
  provider_name = name,
  provider_version = version,

  -- @2 URL INFO
  -- @2.1 GET AUTHORIZE_URL
  --   args: ?client_id=CLIENT_ID&redirect_uri=REDIRECT_URI&scope=SCOPE&state=xxx
  authorize_url = 'https://whatwewant.coding.net/oauth_authorize.html',
  -- using to authorize, default: code
  response_type = 'code',
  scope = 'user', -- @TODO

  -- @2.2 POST TOKEN_URL
  --  body: { client_id, client_secret, redirect_uri, code, state }
  token_url = 'https://whatwewant.coding.net/api/oauth/access_token',
  -- using to get access token, default: authorization_code
  grant_type = 'authorization_code',

  -- @2.2.1 Extendable Data in Body, Query
  token_data_in_query = true,

  -- @2.3 GET USER_INFO_URL
  --  header: { Authorization: Bearer Token; }
  user_info_url = 'https://whatwewant.coding.net/api/account/current_user',

  -- @2.3.1 Extendable Token in Header, Query, Body
  user_info_query = 'access_token',

  -- @3 USER FIELD
  user_fields = {
    username = 'data.global_key',
    nickname = 'data.name',
    -- email = 'data.email', -- @TODO
    avatar = 'data.avatar',
  },
}

return config;