local getenv = os.getenv
local object = require('oauth/utils/object')

local PRODUCTION = 'production'

local config = {
  -- Mode: development or production
  mode = getenv('MODE') or PRODUCTION,
  -- Debug
  debug = getenv('MODE') ~= PRODUCTION,

  -- @1 AUTHORIZE INFO
  client_id = getenv('CLIENT_ID'),
  redirect_uri = getenv('REDIRECT_URI'),

  -- @2 URL INFO
  -- @2.1 GET AUTHORIZE_URL
  --   args: ?client_id=CLIENT_ID&redirect_uri=REDIRECT_URI&scope=SCOPE&state=xxx
  authorize_url = getenv('AUTHORIZE_URL'),
  -- using to authorize, default: code
  response_type = getenv('RESPONSE_TYPE') or 'code',
  scope = getenv('SCOPE'),

  -- @2.2 POST TOKEN_URL
  --  body: { client_id, client_secret, redirect_uri, code, state }
  token_url = getenv('TOKEN_URL'),
  client_secret = getenv('CLIENT_SECRET'),
  -- using to get access token, default: authorization_code
  grant_type = getenv('GRANT_TYPE') or 'authorization_code',

  -- @2.3 GET USER_INFO_URL
  --  header: { Authorization: Bearer Token; }
  user_info_url = getenv('USER_INFO_URL'),

  -- @2.3.1 Extendable Token in Header, Query, Body
  user_info_header = getenv('USER_INFO_HEADER'),
  user_info_query = getenv('USER_INFO_QUERY'),
  user_info_body = getenv('USER_INFO_BODY'),

  -- @3 USER FIELD
  user_fields = {
    username = getenv('USER_USERNAME') or 'login',
    nickname = getenv('USER_NICKNAME'),
    email = getenv('USER_EMAIL'),
    avatar = getenv('USER_AVATAR'),
  },

  -- @4 Permission: Single User
  allow_usernames = object.string_split(getenv('ALLOW_USERNAMES') or '', '(%a+),?'),

  -- @TODO
  state = '',

  -- COOKIE_OPTIONS
  cookie_options = {
    path = '/',
    httponly = true,
    -- samesite = 'Strict',
    max_age = 3600 * 24 * 7,
  },

  -- Time, Server Init Time
  created_at = ngx.now(),

  -- Cookie Secret
  cookie_secret = getenv('COOKIE_SECRET') or tostring(ngx.now()),

  -- Cookie Field
  cookie_fields = {
    username = 'uid',
    nickname = 'un',
    avatar = 'ua',
    signature = 'sig', -- signature is for safe
  },

  -- Cookie Token
  cookie_token = 'ut',
}

return config;