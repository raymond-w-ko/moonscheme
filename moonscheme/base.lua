local util = require('tests.util')
local M = {}

-- empty tables for metatable tagging so we can know what Scheme type a table
-- is without having to box it in another table
local Pair = {}

--------------------------------------------------------------------------------
-- symbol type
--------------------------------------------------------------------------------
local Symbol = {}
Symbol.__index = Symbol

local _symbol_cache = {}
setmetatable(_symbol_cache, {__mode = 'kv'})

function Symbol.new(name)
  local symbol = _symbol_cache[name]
  if symbol then
    return symbol
  end
  symbol = setmetatable({name = name}, Symbol)
  _symbol_cache[name] = symbol
  return symbol
end
M.Symbol = Symbol

local kDotSymbol = Symbol.new('.')

--------------------------------------------------------------------------------
-- ports
--------------------------------------------------------------------------------
local EOF = {}
M.EOF = EOF

-- input string port
local InputStringPort = {}
InputStringPort.__index = InputStringPort
function InputStringPort.new(string)
  assert(type(string) == 'string')
  local port = {
    string = string,
    len = string:len(),
    index = 1,
  }
  return setmetatable(port, InputStringPort)
end
function InputStringPort:peek_char()
  local n = self.index
  if n > self.len then
    return EOF
  end
  return self.string:sub(n, n)
end
function InputStringPort:read_char()
  local n = self.index
  if n > self.len then
    return EOF
  end
  local next_char = self.string:sub(n, n)
  self.index = n + 1
  return next_char
end
M['InputStringPort'] = InputStringPort

-- output string port
local OutputStringPort = {}
OutputStringPort.__index = OutputStringPort
function OutputStringPort.new()
  local t = {
    buf = {},
    nextslot = 1,
  }
  return setmetatable(t, OutputStringPort)
end
function OutputStringPort:write_string(string)
  local n = self.nextslot
  self.buf[n] = string
  self.nextslot = n + 1
  return string:len()
end
-- verified in Racket that this does not empty the buffer!
function OutputStringPort:get_output_string()
  return table.concat(self.buf)
end
M['OutputStringPort'] = OutputStringPort

-- stdout port
local stdout_port = {}
function stdout_port:write_string(string)
  io.write(string)
  return string:len()
end

--------------------------------------------------------------------------------
-- pairs
--------------------------------------------------------------------------------

local EMPTY_LIST = {}
setmetatable(EMPTY_LIST,
             {
               ['__index'] = function()
                 assert('attempted to index into the empty list')
               end
               ,
               ['__newindex'] = function()
                 assert('attempted to modify the empty list')
               end
             })
local cons
local car
local cdr
local set_car
local set_cdr

-- LuaJIT has a penalty free 0 index, unlike plain Lua, so we would potentially
-- waste a lot of memory if we didn't use this index (i.e. pairs would take up
-- 3 memory slots in LuaJIT)
-- 
-- http://lua-users.org/lists/lua-l/2011-03/msg00608.html
-- 
if rawget(_G, 'jit') and type(jit) == 'table' then
  cons = function(obj1, obj2)
    return setmetatable({[0] = obj1, obj2}, Pair)
  end
  car = function(pair)
    return pair[0]
  end
  cdr = function(pair)
    return pair[1]
  end
  set_car = function(pair, obj)
    pair[0] = obj
  end
  set_cdr = function(pair, obj)
    pair[1] = obj
  end
else
  cons = function(obj1, obj2)
    return setmetatable({obj1, obj2}, Pair)
  end
  car = function(pair)
    return pair[1]
  end
  cdr = function(pair)
    return pair[2]
  end
  set_car = function(pair, obj)
    pair[1] = obj
  end
  set_cdr = function(pair, obj)
    pair[2] = obj
  end
end
M['cons'] = cons
M['car'] = car
M['cdr'] = cdr

local whitespaces = {}
whitespaces[' '] = true
whitespaces['\t'] = true
whitespaces['\r'] = true
whitespaces['\n'] = true
local digits = {}
digits['0'] = true
digits['1'] = true
digits['2'] = true
digits['3'] = true
digits['4'] = true
digits['5'] = true
digits['6'] = true
digits['7'] = true
digits['8'] = true
digits['9'] = true

local macros = {}
local function IsTerminatingMacroChar(ch)
  return ch ~= "'" and ch ~= '#' and macros[ch]
end

local function read_number(port, initial_ch)
  local buf = {initial_ch, nil, nil, nil}; local nextslot = 2
  while true do
      local ch = port:peek_char()
      if ch == EOF or whitespaces[ch] or macros[ch] then
      break
    end
    buf[nextslot] = port:read_char(); nextslot = nextslot + 1
  end
  
  local s = table.concat(buf)
  local num = tonumber(s)
  if num == nil then
    error('failed to parse number: ' .. s)
  end
  return num
end

-- TODO implement "\x<hex scalar value>;"
local function read_stringish(port, initial_ch, terminating_ch)
  local buf = {nil, nil, nil, nil}; local nextslot = 1

  local ch = port:read_char()
  while ch ~= terminating_ch do
    if ch == EOF then
      error('EOF while reading string')
    end

    if ch == '\\' then
      ch = port:read_char()
      if ch == EOF then
        error('EOF while reading string escape character: ' .. terminating_ch)
      end

      if ch == 'a' then ch = '\a' -- bell
      elseif ch == 'b' then ch = '\b'
      elseif ch == 't' then ch = '\t'
      elseif ch == 'n' then ch = '\n'
      elseif ch == 'r' then ch = '\r'
      elseif ch == [["]] then --already double quote
      elseif ch == [[\]] then -- already backslash
      elseif ch == '|' then ch = '|'
      elseif ch == 'f' then ch = '\f'
        -- FOLLOWING NOT IN SCHEME!
        -- adding them because they are present in Lua
        -- (who actually uses these?)
      elseif ch == 'v' then ch = '\v' -- vertical tab
      elseif whitespaces[ch] then
        while whitespaces[port:peek_char()] do
          port:read_char()
        end
        ch = port:read_char()
        if ch == EOF then
          error('EOF while reading string escape character')
        end
      else
        error('unknown escape character while reading string: ' .. ch)
      end
    end

    buf[nextslot] = ch; nextslot = nextslot + 1

    ch = port:read_char()
  end

  return table.concat(buf)
end

local function read_identifier(port, initial_ch)
  if initial_ch == '|' then
    local escaped_name = read_stringish(port, initial_ch, '|')
    if escaped_name == '' then
      return '||'
    else
      return escaped_name
    end
  end
  
  local buf = {initial_ch, nil, nil, nil}; local nextslot = 2
  while true do
    local ch = port:peek_char()
    if ch == EOF or whitespaces[ch] or IsTerminatingMacroChar(ch) then
      return table.concat(buf)
    end
    buf[nextslot] = port:read_char(); nextslot = nextslot + 1
  end
end

local function interpret_identifier(identifier)
  return Symbol.new(identifier)
end

local function read(port)
  while true do
    local ch = port:read_char()
    while whitespaces[ch] do
      ch = port:read_char()
    end

    if ch == EOF then
      error('EOF while reading')
    end

    if digits[ch] then
      return read_number(port, ch)
    end

    local fn = macros[ch]
    if fn then
      local ret = fn(port, ch)
      if ret ~= port then
        return ret
      else
        -- fallthrough and continue reading
        -- such a case occurs when comments are encountered
      end
    else
      if ch == '+' or ch == '-' then
        local ch2 = port:peek_char()
        if ch2 ~= EOF and digits[ch2] then
          return read_number(port, ch)
        end
      end
      return interpret_identifier(read_identifier(port, ch))
    end
  end
end
M.read = read

macros['['] = function(port, ch)
  error('reserved notation [ used')
end
macros[']'] = function(port, ch)
  error('reserved notation ] used')
end
macros['{'] = function(port, ch)
  error('reserved notation [ used')
end
macros['{'] = function(port, ch)
  error('reserved notation } used')
end

macros['"'] = function(port, initch)
  return read_stringish(port, initch, '"')
end

-- TODO: properly write with strings unicode character escapes?
local function write_quoted_string(string, port)
  port:write_string('"')
  
  local n = string:len()
  for i = 1, n do
    local ch = string:sub(i, i)
    
    local text = ch
    if ch == '\a' then text = [[\a]] -- bell
    elseif ch == '\b' then text = [[\b]]
    elseif ch == '\t' then text = [[\t]]
    elseif ch == '\n' then text = [[\n]]
    elseif ch == '\r' then text = [[\r]]
    elseif ch == '"' then text = [[\"]]
    elseif ch == [[\]] then text = [[\\]]
    elseif ch == '|' then text = [[\|]]
    elseif ch == '\f' then text = [[\f]]
      -- FOLLOWING NOT IN SCHEME!
      -- adding them because they are present in Lua
      -- (who actually uses these?)
    elseif ch == '\v' then text = [[\v]] -- vertical tab
    end
    
    port:write_string(text)
  end
  
  port:write_string('"')
end

macros[')'] = function(port, initial_ch)
  error('unmatched delimiter: ' .. ch)
end

macros['('] = function(port, initial_ch)
  local list = EMPTY_LIST
  local p
  while true do
    while whitespaces[port:peek_char()] do
      port:read_char()
    end
    
    local ch = port:peek_char()
    if ch == EOF then
      error('EOF encountered while reading list')
    elseif ch == ')' then
      port:read_char()
      break
    else
      local obj = read(port)
      if obj == kDotSymbol then
        assert(list ~= EMPTY_LIST, "read: illegal use of '.'")
        local cdr_obj = read(port)
        set_cdr(p, cdr_obj)
        return list
      end
      
      if list == EMPTY_LIST then
        list = cons(obj, EMPTY_LIST)
        p = list
      else
        local nextobj = cons(obj, EMPTY_LIST)
        set_cdr(p, nextobj)
        p = nextobj
      end
    end
  end
  return list
end

local dispatch_macros = {}
macros['#'] = function(port, initial_ch)
  local ch = port:read_char()
  if ch == 'EOF' then
    error('EOF while reading character for dispatch macro #')
  end
  local fn = dispatch_macros[ch]
  if fn == nil then
    error('no dispatch macro for: ' .. ch)
  end
  return fn(port, ch)
end

dispatch_macros['t'] = function()
  return true
end
dispatch_macros['f'] = function()
  return false
end

local function write(obj, port)
  if port == nil then
    port = stdout_port
  end
  if obj == true then
    port:write_string('#t')
    return
  elseif obj == false then
    port:write_string('#f')
    return
  elseif obj == EMPTY_LIST then
    port:write_string('()')
    return
  end
  
  local objtype = type(obj)
  if objtype == 'string' then
    write_quoted_string(obj, port)
    return
  elseif objtype == 'number' then
    port:write_string(tostring(obj))
    return
  end
  
  local mt = getmetatable(obj)
  if mt == Symbol then
    port:write_string(obj.name)
  elseif mt == Pair then
    port:write_string('(')
    while true do
      write(car(obj), port)
      local nextobj = cdr(obj)
      
      if nextobj == EMPTY_LIST then
        break
      elseif getmetatable(nextobj) ~= Pair then
        port:write_string(' . ')
        write(nextobj, port)
        break
      end
        
      if cdr(obj) ~= EMPTY_LIST then
        port:write_string(' ')
      end
      
      obj = nextobj
    end
    port:write_string(')')
  else
    print(util.show(obj))
    error('(write) encountered unknown object type')
  end
end
M.write = write

return M
