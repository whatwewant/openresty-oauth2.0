local _M = {}

function _M.keys(table)
  local keys = {}
  local i = 1
  for k, _ in ipairs(table) do
    keys[i] = k
    i = i + 1
  end
  return keys
end

function _M.values(table)
  local values = {}
  local i = 1
  for _, v in ipairs(table) do
    values[i] = v
    i = i + 1
  end
  return values
end

function _M.pick(table, keys)
  local _object = {}

  for i, key in ipairs(keys) do
    if table[key] then
      _object[key] = table[key]
    end
  end

  return _object
end

function _M.pick_alias(table, alias)
  local _object = {}

  for key, value in pairs(alias) do
    if key and value and table[value] then
      _object[key] = table[value]
    end
  end

  return _object
end

function _M.merge(t1, t2, t3)
  local _t = t1 or {}

  if t2 then
    for k, v in pairs(t2) do
      _t[k] = v
    end
  end

  if t3 then
    for k, v in pairs(t3) do
      _t[k] = v
    end
  end

  return _t
end

function _M.includes(table, key)
  return table[key] ~= nil and table[key] ~= false
end

function string_split(str, pattern)
  local _t = {}
  for k, _ in string.gmatch(str, pattern) do
    _t[k] = true
  end
  return _t
end

function split(str, seperator)
  local _t = {}
  local pattern = '([^'..seperator..']+)'
  for k, _ in string.gmatch(str, pattern) do
    table.insert(_t, k)
  end
  return _t
end

function get(object, path_str)
  local paths = split(path_str, '.')
  local parent = object
  local len = #paths

  for i, k in ipairs(paths) do
    local v = parent[k]
    if not v then
      return nil
    elseif i == len then
      return v
    elseif type(v) ~= 'table' then
      return nil
    end
    
    parent = v
  end

  return nil
end

_M.split = split
_M.string_split = string_split
_M.get = get

return _M