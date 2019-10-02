local getenv = os.getenv
local object = require('oauth/utils/object')

local config = {
  -- @1 AUTHORIZE INFO
  client_id = getenv('CLIENT_ID'),
  client_secret = getenv('CLIENT_SECRET'),
  redirect_uri = getenv('REDIRECT_URI'),
  scope = getenv('SCOPE'),

  -- @2 URL INFO
  -- @2.1 GET AUTHORIZE_URL
  --   args: ?client_id=CLIENT_ID&redirect_uri=REDIRECT_URI&scope=SCOPE&state=xxx
  authorize_url = getenv('AUTHORIZE_URL'),

  -- @2.2 POST TOKEN_URL
  --  body: { client_id, client_secret, redirect_uri, code, state }
  token_url = getenv('TOKEN_URL'),

  -- @2.3 GET USER_INFO_URL
  --  header: { Authorization: Bearer Token; }
  user_info_url = getenv('USER_INFO_URL'),

  -- @3 USER FIELD
  user_fields = {
    username = getenv('USER_USERNAME') or 'login',
    nickname = getenv('USER_NICKNAME') or 'name',
    email = getenv('USER_EMAIL') or 'email',
    avatar = getenv('USER_AVATAR') or 'avatar',
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
  cookie_secret = getenv('COOKIE_SECRET') or tostring(ngx.now())
}

return config;