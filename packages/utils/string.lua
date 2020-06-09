local ngx_re_match = ngx.re.match

local _M = { _VERSION = '0.1' }

local function includes(text, key_word)
  local matched, err = ngx_re_match(text, key_word, "jo")

  if not matched or err then
    return false
  end

  return true
end

_M.includes = includes

return _M