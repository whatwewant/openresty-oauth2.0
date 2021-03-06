local _M = {}

local function keys(table)
  local keys = {}
  local i = 1
  for k, _ in ipairs(table) do
    keys[i] = k
    i = i + 1
  end
  return keys
end

local function values(table)
  local values = {}
  local i = 1
  for _, v in ipairs(table) do
    values[i] = v
    i = i + 1
  end
  return values
end

local function pick(table, keys)
  local _object = {}

  for i, key in ipairs(keys) do
    if table[key] then
      _object[key] = table[key]
    end
  end

  return _object
end

local function pick_alias(table, alias)
  local _object = {}

  for key, value in pairs(alias) do
    if key and value and table[value] then
      _object[key] = table[value]
    end
  end

  return _object
end

local function merge(t1, t2, t3)
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

local function includes(table, key)
  -- object
  local obj_included = table[key] ~= nil and table[key] ~= false
  if obj_included then
    return true
  end

  -- array
  for i, k in ipairs(table) do
    if k == key then
      return true
    end
  end

  return false
end

-- @DEPRECIATED, bugs
local function string_split(str, pattern)
  local _t = {}
  for k, _ in string.gmatch(str, pattern) do
    _t[k] = true
  end
  return _t
end

local function split(str, seperator)
  local _t = {}
  local pattern = '([^'..seperator..']+)'
  for k, _ in string.gmatch(str, pattern) do
    table.insert(_t, k)
  end
  return _t
end

local function get(object, path_str)
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

_M.keys = keys
_M.values = values
_M.pick = pick
_M.pick_alias = pick_alias
_M.merge = merge
_M.includes = includes
_M.split = split
_M.string_split = string_split
_M.get = get

return _M