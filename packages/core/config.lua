local getenv = os.getenv
local object = require('oauth/utils/object')

local split = object.split
local merge = object.merge

local version = '1.0.5'

local PRODUCTION = 'production'
local ALLOW_ALL = 'all'

local mode = getenv('MODE') or PRODUCTION
local root_url = getenv('ROOT_URL') or 'http://127.0.0.1:8080'
local provider = getenv('PROVIDER')
local allow_usernames_str = getenv('ALLOW_USERNAMES') or 'all'

local redirect_uri = root_url..'/_oauth/'..provider
local response_type = getenv('RESPONSE_TYPE') or 'code'
local scope = getenv('SCOPE') or ''

local authorize_url = getenv('AUTHORIZE_URL')
local token_url = getenv('TOKEN_URL')
local user_info_url = getenv('USER_INFO_URL')

local client_id = getenv('CLIENT_ID')
local client_secret = getenv('CLIENT_SECRET')

local config = {
  version = version,
  
  -- Mode: development or production
  mode = mode,
  -- Debug
  debug = mode ~= PRODUCTION,

  -- Root url is for outside url, using to visit,
  --   and callback root url, works with redirect_uri
  root_url = root_url,

  -- Provider Name
  --   using for dynamic provider target
  --   using for callback url, works with redirect_uri  
  provider = provider,

  -- @1 AUTHORIZE INFO
  client_id = client_id,
  -- @example http://127.0.0.1:8080/_oauth/github
  redirect_uri = redirect_uri, -- getenv('REDIRECT_URI'),

  -- @2 URL INFO
  -- @2.1 GET AUTHORIZE_URL
  --   args: ?client_id=CLIENT_ID&redirect_uri=REDIRECT_URI&scope=SCOPE&state=xxx
  authorize_url = authorize_url,
  -- using to authorize, default: code
  response_type = response_type,
  scope = scope,

  -- @2.2 POST TOKEN_URL
  --  body: { client_id, client_secret, redirect_uri, code, state }
  token_url = token_url,
  client_secret = client_secret,
  -- using to get access token, default: authorization_code
  grant_type = getenv('GRANT_TYPE') or 'authorization_code',

  -- @2.2.1 Extendable Data in Body, Query
  token_data_in_body = getenv('TOKEN_DATA_IN_BODY') or false,
  token_data_in_body_content_type = getenv('TOKEN_DATA_IN_BODY_CONTENT_TYPE') or 'application/json',
  token_data_in_query = getenv('TOKEN_DATA_IN_QUERY') or false,

  -- @2.3 GET USER_INFO_URL
  --  header: { Authorization: Bearer Token; }
  user_info_url = user_info_url,

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

  -- @4 Permission
  --   Allow all
  allow_all = allow_usernames_str == ALLOW_ALL,
  --   Multiple User
  allow_usernames = split(allow_usernames_str, ','),

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
    username = '_zo_uid',
    nickname = '_zo_un',
    avatar = '_zo_ua',
    signature = '_zo_sig', -- signature is for safe
  },

  -- Cookie Token
  cookie_token = '_zo_ut',
}

local provider_config = require('oauth/providers/'..provider..'/config')

return merge(config, provider_config);