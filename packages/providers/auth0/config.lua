--[[
  Authentication and Authorization Flow Reference:
    https://auth0.com/docs/flows/concepts/auth-code
]]

local base_config = require('oauth/core/config')

local name = 'auth0'
local version = '0.0.1'

local config = {
  -- Provider Name
  provider_name = name,

  -- Provider Version
  provider_version = version,

  -- @2 URL INFO
  -- @2.1 GET AUTHORIZE_URL
  --   args: ?client_id=CLIENT_ID&redirect_uri=REDIRECT_URI&scope=SCOPE&state=xxx
  authorize_url = 'https://moeover.au.auth0.com/authorize',
  -- using to authorize, default: code
  response_type = 'code',
  scope = 'openid profile email', -- @TODO

  -- @2.2 POST TOKEN_URL
  --  body: { client_id, client_secret, redirect_uri, code, state }
  token_url = 'https://moeover.au.auth0.com/oauth/token',
  -- using to get access token, default: authorization_code
  grant_type = 'authorization_code',

  -- @2.2.1 Extendable Data in Body, Query
  token_data_in_body = true,

  -- @2.3 GET USER_INFO_URL
  --  header: { Authorization: Bearer Token; }
  user_info_url = 'https://moeover.au.auth0.com/userinfo',

  -- @2.3.1 Extendable Token in Header, Query, Body
  user_info_header = 'Authorization',

  -- @3 USER FIELD
  user_fields = {
    username = 'email',
    nickname = 'nickname',
    email = 'email', -- @TODO
    avatar = 'picture',
  },
}

return config;