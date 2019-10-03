local OauthFlow = require('oauth/core/internal/flow')

local flow = OauthFlow:new()

flow:check_done_or_go_authorize()