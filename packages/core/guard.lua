local OauthFlow = require('oauth/core/core/flow')

local flow = OauthFlow:new()

flow:check_done_or_go_authorize()