-- http://metalua.luaforge.net/src/lib/strict.lua.html
--  
--  NOTE: this has been modified to be SUPER strict. Probably not recommended
--  for normal usage.
local mt = getmetatable(_G)
if mt == nil then
  mt = {}
  setmetatable(_G, mt)
end

__STRICT = true
mt.__declared = {}

function global(...)
   for _, v in ipairs{...} do mt.__declared[v] = true end
end

mt.__newindex = function (t, n, v)
  if __STRICT and not mt.__declared[n] then
    error("assign to undeclared variable '"..n.."'", 2)
  end
  rawset(t, n, v)
end
  
mt.__index = function (t, n)
  if not mt.__declared[n] then
    error("variable '"..n.."' is not declared", 2)
  end
  return rawget(t, n)
end
