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

function _M.string_split(str, pattern)
  local _t = {}
  for k, _ in string.gmatch(str, pattern) do
    _t[k] = true
  end
  return _t
end

return _M