local base_config = require('oauth/core/config')

local config = {
  -- @2 URL INFO
  -- @2.1 GET AUTHORIZE_URL
  --   args: ?client_id=CLIENT_ID&redirect_uri=REDIRECT_URI&scope=SCOPE&state=xxx
  authorize_url = 'https://id.zcorky.com/oauth/authorize',
  -- using to authorize, default: code
  response_type = 'code',
  scope = '_', -- @TODO
  state = '_',

  -- @2.2 POST TOKEN_URL
  --  body: { client_id, client_secret, redirect_uri, code, state }
  token_url = 'https://id.zcorky.com/oauth/token',
  -- using to get access token, default: authorization_code
  grant_type = 'authorization_code',

  -- @2.2.1 Extendable Data in Body, Query
  token_data_in_body = true,
  token_data_in_body_content_type = 'application/x-www-form-urlencoded',

  -- @2.3 GET USER_INFO_URL
  --  header: { Authorization: Bearer Token; }
  user_info_url = 'https://id.zcorky.com/oauth/user',

  -- @2.3.1 Extendable Token in Header, Query, Body
  user_info_header = 'Authorization',

  -- @3 USER FIELD
  user_fields = {
    username = 'username', -- 'result.login',
    nickname = 'nickname', -- 'result.nickname',
    email = 'email', -- 'result.email',
    avatar = 'avatar', -- 'result.avatar',
  },
}

return config;