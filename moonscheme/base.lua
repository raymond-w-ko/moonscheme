local util = require('moonscheme.util')
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
function Symbol:__tostring()
  return self.name
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
    line_number = 1
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
  if next_char == "\n" then
    self.line_number = self.line_number + 1
  end
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
M['set-car!'] = set_car
M['set-cdr!'] = set_cdr

local function to_lua_array(list)
  local arr = {}; local nextslot = 1
  while list ~= EMPTY_LIST do
    arr[nextslot] = car(list); nextslot = nextslot + 1
    list = cdr(list)
  end
  return arr
end

function M.to_scheme_list(packed_array)
  local n = packed_array.n
  local list = EMPTY_LIST
  local p
  for i = 1, n do
    if list == EMPTY_LIST then
      list = cons(packed_array[i], EMPTY_LIST)
      p = list
    else
      local nextobj = cons(packed_array[i], EMPTY_LIST)
      set_cdr(p, nextobj)
      p = nextobj
    end
  end
  return list
end

--------------------------------------------------------------------------------
-- reader
--------------------------------------------------------------------------------

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

local function read(port, is_recursive)
  -- lazy hack since I don't feel like over complicating generated source code
  if type(port) == 'string' then
    port = InputStringPort.new(port)
  end
  while true do
    local ch = port:read_char()
    while whitespaces[ch] do
      ch = port:read_char()
    end

    if ch == EOF then
      if is_recursive then
        error('EOF while reading')
      else
        return EOF
      end
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
M['read'] = read

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
      local obj = read(port, true)
      if obj == kDotSymbol then
        assert(list ~= EMPTY_LIST, "read: illegal use of '.'")
        local cdr_obj = read(port, true)
        set_cdr(p, cdr_obj)
      elseif list == EMPTY_LIST then
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

local kQuoteSymbol = Symbol.new('quote')
macros["'"] = function(port, initial_ch)
  local list = cons(kQuoteSymbol, EMPTY_LIST)
  set_cdr(list, cons(read(port, true), EMPTY_LIST))
  return list
end

macros[";"] = function(port, initial_ch)
  while port:peek_char() ~= "\n" do
    port:read_char()
  end
  return port
end

local dispatch_macros = {}
macros['#'] = function(port, initial_ch)
  local data = read(port, true)
  if data == 'EOF' then
    error('EOF while reading character for dispatch macro #')
  end
  local mt = getmetatable(data)
  local macro_name
  if mt == Symbol then
    macro_name = tostring(data)
  else
    error("unknown dispatch macro type")
  end
  local fn = dispatch_macros[macro_name]
  if fn == nil then
    error('no dispatch macro for: ' .. macro_name)
  end
  return fn(port)
end

dispatch_macros['t'] = function() return true end
dispatch_macros['true'] = dispatch_macros['t']
dispatch_macros['f'] = function() return false end
dispatch_macros['false'] = dispatch_macros['f']

dispatch_macros['lang'] = function(port)
  local lang = read(port)
  assert(getmetatable(lang) == Symbol)
  lang = tostring(lang)
  assert(lang == "r7rs", "unknown language specified, only r7rs is understood")
end

-- TODO: handle lists that reference itself via #1=() syntax to prevent an
-- infinite loop
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
  elseif obj == nil then
    port:write_string('nil')
    return
  end

  local objtype = type(obj)
  if objtype == 'string' then
    write_quoted_string(obj, port)
    return
  elseif objtype == 'number' then
    port:write_string(tostring(obj))
    return
  elseif objtype == 'function' then
    port:write_string(tostring(obj))
    return
  end

  local mt = getmetatable(obj)
  if mt == Symbol then
    port:write_string(tostring(obj))
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
M['write'] = write

--------------------------------------------------------------------------------
-- compiler
--------------------------------------------------------------------------------

-- Scheme identifier to Lua identifier
local scheme_identifier_map = {}
for i = string.byte('0'), string.byte('9') do
  local ch = string.char(i)
  assert(ch:len() == 1)
  scheme_identifier_map[ch] = ch
end
for i = string.byte('A'), string.byte('Z') do
  local ch = string.char(i)
  assert(ch:len() == 1)
  scheme_identifier_map[ch] = ch
end
for i = string.byte('a'), string.byte('z') do
  local ch = string.char(i)
  assert(ch:len() == 1)
  scheme_identifier_map[ch] = ch
end
scheme_identifier_map['_'] = '_'
scheme_identifier_map['-'] = '_HYPHEN_'
scheme_identifier_map['.'] = '_DOT_'
local function to_lua_identifier(scheme_identifier)
  local buf = {nil, nil, nil, nil, nil, nil, nil, nil}; local nextslot = 1
  local n = scheme_identifier:len()
  for i = 1, n do
    local origch = scheme_identifier:sub(i, i)
    local ch = scheme_identifier_map[origch]
    assert(ch, 'missing mapping in scheme_identifier_map: ' .. origch)
    buf[nextslot] = ch; nextslot = nextslot + 1
  end
  return table.concat(buf)
end
local function to_lua_module_identifier(module_name)
  return "__MODULE_" .. to_lua_identifier(module_name)
end

local _genvar_count = 0
local function genvar(info)
  local buf = {nil, nil, nil, nil}; local nextslot = 1
  buf[nextslot] = '__'; nextslot = nextslot + 1
  if info then
    buf[nextslot] = info; nextslot = nextslot + 1
  else
    buf[nextslot] = 'var'; nextslot = nextslot + 1
  end
  buf[nextslot] = '_'; nextslot = nextslot + 1
  buf[nextslot] = tostring(_genvar_count); nextslot = nextslot + 1
  _genvar_count = _genvar_count + 1
  return Symbol.new(table.concat(buf))
end

local kModuleLocal = '__MODULE'

-- lexical environment

-- TODO: add name to module map so we can import variables from other modules
-- and have the table index work
local Environment = {}
Environment.__index = Environment
-- The lowest level is 0, which indicates a top level environment.
-- Unfortunately, these will slightly be inefficient as the "top level" is a
-- lua table in "package.loaded".
--
-- So variables in the top level are always accessed with a table index. This
-- is needed to solve the problem of not having C++ style references which
-- means two variables names point to the same object / memory region.
--
-- All symbol access at level >= 1 are efficient because they are just locals
-- or function arguments.
function Environment.new(level)
  assert(type(level) == 'number' and level >= 0)

  local env = {}
  env.symbols = {}
  env.module_name_of_symbol = {}
  env.level = level
  return setmetatable(env, Environment)
end
function Environment:extend_with(symbols)
  local newenv = Environment.new(self.level + 1)
  newenv.parent = self
  for i = 1, #symbols do
    local symbol = symbols[i]
    assert(getmetatable(symbol) == Symbol)
    newenv.symbols[tostring(symbol)] = true
  end
  return newenv
end
-- This is mainly used in (define) and does a deep copy. Not sure if totally
-- correct, or if modules are suppose to be in a (letrec) fashion. How can it
-- be split in multiple files if it is in a (letrec) fasion? need to find out
-- one day if this is true or false.
function Environment:add_symbols_to_same_level(symbols)
  local newenv = Environment.new(self.level)
  newenv.parent = self.parent
  -- deppcopy symbols from older environment
  for symbol_name, v in pairs(self.symbols) do
    newenv.symbols[symbol_name] = true
  end
  for symbol_name, module_name in pairs(self.module_name_of_symbol) do
    newenv.module_name_of_symbol[symbol_name] = module_name
  end

  for i = 1, #symbols do
    local symbol = symbols[i]
    assert(getmetatable(symbol) == Symbol)
    local name = tostring(symbol)
    assert(newenv.symbols[name] == nil,
           "Environment: duplicate symbol being defined: " .. name)
    newenv.symbols[name] = true
  end
  return newenv
end
-- there is no environment above this one, except _G, the Lua globals table.
-- Not esure how to handle this. Should symbols be brought in explicitly or
-- implicitly.
function Environment:is_top_level()
  return self.parent == nil
end
-- returns
-- (level of symbol or nil if not found, module name symbol belongs to)
-- module name only makes sense if the level of environment is 0
function Environment:get_symbol_level_and_module(symbol)
  assert(getmetatable(symbol) == Symbol)
  local name = tostring(symbol)
  if self.symbols[name] then
    local module_name = self.module_name_of_symbol[name]
    return self.level, module_name
  end

  if self.parent then
    local level, module_name = self.parent:get_symbol_level_and_module(symbol)
    return level, module_name
  else
    return nil
  end
end
function Environment:add_external_symbol(symbol, module_name)
  assert(self.level == 0, "external symbols may only be added to the top level")
  assert(getmetatable(symbol) == Symbol)
  local name = tostring(symbol)
  assert(self.symbols[name] == nil, "symbol already defined: " .. name)
  self.symbols[name] = true
  self.module_name_of_symbol[name] = module_name
end
-- The magic function to compile down the symbol to Lua code
function Environment:mangle_symbol(symbol, used_module_names)
  assert(getmetatable(symbol) == Symbol)
  assert(used_module_names)

  local name = tostring(symbol)
  if name == "..." or name == "nil" then
    return name
  end

  local buf = {nil, nil, nil, nil}; local nextslot = 1

  local symbol_level, module_name = self:get_symbol_level_and_module(symbol)
  -- local info = string.format("symbol: %s, level: %d, module: %s",
  --                            name, symbol_level, module_name)
  -- print(info)

  if symbol_level == nil then
    error("unbound symbol in module: " .. name)
    -- to dangerous for dev right now, maybe later in production
    -- buf[nextslot] = '_G["'; nextslot = nextslot + 1
  elseif symbol_level == 0 then
    local table_name
    if module_name then
      table_name = to_lua_module_identifier(module_name)
      used_module_names[module_name] = true
    else
      table_name = kModuleLocal
    end
    buf[nextslot] = table_name; nextslot = nextslot + 1
    buf[nextslot] = '["'; nextslot = nextslot + 1
  end

  if symbol_level and symbol_level > 0 then
    buf[nextslot] = to_lua_identifier(symbol.name); nextslot = nextslot + 1
  else
    buf[nextslot] = name; nextslot = nextslot + 1
  end

  if symbol_level == nil then
    buf[nextslot] = '"]'
  elseif symbol_level == 0 then
    buf[nextslot] = '"]'
  end

  return table.concat(buf)
end

local function IsLuaPrimitive(obj)
  local type = type(obj)
  return (
    type == 'string' or
    type == 'number' or
    type == 'boolean' or
    type == 'nil'
  )
end

-- new IR node
local function new_node(op, args, env)
  assert(type(args) == 'table')
  assert(env)
  assert(getmetatable(env) == Environment)
  local node = {
    ['op'] = op,
    ['args'] = args,
    ['env'] = env,
    -- tells the compiler to return from the current function with this IR
    -- node's value
    ['ret'] = false,
    -- a non-nil value tells the compiler to bound the value of this IR node to
    -- a new local variable with this name
    ['new_local'] = nil,
    -- a non-nil value tells the compiler to set the named variable to the
    -- value of this IR node
    ['set_var'] = nil,
  }
  return node
end
local function insert_before(node, newnode)
  local oldprev = node.prev
  if oldprev then
    oldprev.next = newnode
    newnode.prev = oldprev
  end
  newnode.next = node
  node.prev = newnode
end
local function insert_after(node, newnode)
  local oldnext = node.next
  if oldnext then
    oldnext.prev = newnode
    newnode.next = oldnext
  end
  newnode.prev = node
  node.next = newnode
end

local ir_compilers = {}

-- list to IR code
local function transform_to_ir_list(expr, module)
  local base_env = module["*ENVIRONMENT*"]
  local ir_list = new_node('LISP', {expr}, base_env)
  ir_list.ret = true
  local dirty_nodes = {ir_list}

  while #dirty_nodes > 0 do
    local new_dirty_nodes = {}
    for i = 1, #dirty_nodes do
      local node = dirty_nodes[i]
      local compiler = ir_compilers[node.op]
      assert(compiler, 'missing compiler for IR op: ' .. node.op)
      compiler(node, new_dirty_nodes)
    end
    dirty_nodes = new_dirty_nodes
  end

  -- definitely possible that IR compilation create new nodes before the
  -- original single node
  while ir_list.prev do
    ir_list = ir_list.prev
  end
  return ir_list
end

local special_form_compilers = {}

ir_compilers['LISP'] = function(node, new_dirty_nodes)
  local lisp = node.args[1]
  if lisp == EMPTY_LIST then
    error("attempted to evaluate empty list")
  end

  local mt = getmetatable(lisp)
  if IsLuaPrimitive(lisp) then
    node.op = 'PRIMITIVE'
    node.args = {lisp}
  elseif mt == Symbol then
    -- symbol which is a variable that is looked up at run time
    node.op = 'SYMBOL'
    node.args = {lisp}
  elseif mt == Pair then
    -- function call

    local proc = car(lisp)
    local args = cdr(lisp)

    local call_args = {}

    local mt = getmetatable(proc)
    if mt == Symbol then
      local special_form_compiler = special_form_compilers[tostring(proc)]
      if special_form_compiler then
        node.args = args
        special_form_compiler(node, new_dirty_nodes)
        return
      end
      table.insert(call_args, proc)

      -- at this point, we have exhausted all special forms, so we the list as
      -- a normal function call
    elseif mt == Pair then
      -- the operator of the function call needs to be evaluated, like
      -- ((lambda (x) (+ x 1) 2)
      local fn_get_sym = genvar("operator")
      table.insert(call_args, fn_get_sym)

      local fn_get_node = new_node('LISP', {proc}, node.env)
      fn_get_node.new_local = fn_get_sym
      insert_before(node, fn_get_node)
      table.insert(new_dirty_nodes, fn_get_node)

      node.env = node.env:extend_with({fn_get_sym})
      fn_get_node.env = node.env
    else
      print(util.show(lisp))
      error("unrecognized (operator ...) type")
    end

    while args ~= EMPTY_LIST do
      local arg = car(args)
      if getmetatable(arg) == Pair then
        local var_get_sym = genvar("call_arg")
        table.insert(call_args, var_get_sym)

        local var_get_node = new_node('LISP', {arg}, node.env)
        var_get_node.new_local = var_get_sym
        insert_before(node, var_get_node)
        table.insert(new_dirty_nodes, var_get_node)

        node.env = node.env:extend_with({var_get_sym})
        var_get_node.env = node.env
      else
        table.insert(call_args, arg)
      end
      args = cdr(args)
    end

    node.op = 'CALL'
    node.args = call_args
  else
    error("unknown LISP data encountered")
  end

end

special_form_compilers['define'] = function(node, new_dirty_nodes)
  local orignode = node
  local args = to_lua_array(orignode.args)
  if #args < 1 then
    error("define: bad syntax (called with no arguments)")
  end

  local node = new_node('DUMMY', {}, orignode.env)
  insert_before(orignode, node)

  local variable = args[1]
  local variable_symbol
  -- deduce variable type, of which there can be 3 possibilities
  local mt = getmetatable(variable)
  if mt == Symbol then
    -- 1. define a new variable equal to the second argument
    if #args <= 0 then
      error("define: bad syntax (missing expression after identifier)")
    elseif #args >= 3 then
      error("define: bad syntax, (multiple expressions after identifier)")
    end
    variable_symbol = variable
    local expr = args[2]
    if IsLuaPrimitive(expr) then
      node.op = 'PRIMITIVE'
      node.args = {expr}
    else
      node.op = 'LISP'
      node.args = {expr}
      table.insert(new_dirty_nodes, node)
    end

    if node.env:is_top_level() then
      node.set_var = variable_symbol
      node.env = node.env:add_symbols_to_same_level({variable_symbol})
    else
      node.new_local = variable_symbol
      node.env = node.env:extend_with({variable_symbol})
    end
  elseif mt == Pair then
    -- we just transform this to lambda with the variable introduced by this
    -- defined into the scope
    local proc_name = car(variable)
    local proc_args = cdr(variable)
    variable_symbol = proc_name
    local env = node.env
    if env:is_top_level() then
      node.set_var = variable_symbol
      node.env = env:add_symbols_to_same_level({variable_symbol})
    else
      node.new_local = variable_symbol
      node.env = env:extend_with({variable_symbol})
    end
    local lambda_args = cons(proc_args, cdr(orignode.args))
    local lambda_compiler = special_form_compilers["lambda"]
    node.args = lambda_args
    lambda_compiler(node, new_dirty_nodes)
  else
    error("define: bad syntax (unknown first argument type)")
  end

  local env = node.env
  local defsym_node = new_node("DEFSYM", {variable_symbol}, env)
  insert_before(orignode, defsym_node)

  orignode.env = env
  orignode.op = 'SYMBOL'
  orignode.args = {variable_symbol}
end

local kTripDotSymbol = Symbol.new("...")

special_form_compilers["lambda"] = function(node, new_dirty_nodes)
  local args = node.args
  if args == EMPTY_LIST then
    error("lambda: bad syntax (missing identifiers and expressions)")
  end

  local proc_args = car(args)

  local func_args
  local pack_args = false
  local packed_args_sym

  local mt = getmetatable(proc_args)
  if mt == Symbol then
    pack_args = true
    packed_args_sym = proc_args
    func_args = {kTripDotSymbol}
  elseif mt == Pair then
    -- this can also include packed args at the end!!
    func_args = {}
    while true do
      local arg = car(proc_args)
      table.insert(func_args, arg)
      local nextobj = cdr(proc_args)
      if getmetatable(nextobj) == Symbol then
        -- dotted argument detected, pack the rest
        table.insert(func_args, kTripDotSymbol)
        pack_args = true
        packed_args_sym = nextobj
        break
      else
        proc_args = nextobj
        if proc_args == EMPTY_LIST then
          break
        end
      end
    end
  elseif proc_args == EMPTY_LIST then
    func_args = {}
  else
    error("lambda: bad argument sequence")
  end
  assert(func_args)

  node.op = "FUNC"
  node.args = func_args

  local func_env = node.env:extend_with(func_args)
  node.env = func_env
  if pack_args then
    local env = node.env:extend_with({packed_args_sym})
    local pack_args_node = new_node('PACKARGS', {}, env)
    pack_args_node.new_local = packed_args_sym
    insert_after(node, pack_args_node)
    node = pack_args_node
  end
  local func_env = node.env:extend_with(func_args)

  -- TODO: the body of a lambda has to be a (letrec*) in case of (define)s
  -- inside, right now this is just a (let*)
  local proc_bodies = cdr(args)
  if proc_bodies == EMPTY_LIST then
    error("lambda: bad syntax (missing body expressions)")
  end
  proc_bodies = to_lua_array(proc_bodies)
  local n = #proc_bodies
  for i = 1, n do
    local body_node = new_node('LISP', {proc_bodies[i]}, func_env)
    table.insert(new_dirty_nodes, body_node)
    if i == n then
      body_node.ret = true
    end
    insert_after(node, body_node)
    node = body_node
  end

  local endfunc_node = new_node("ENDFUNC", {}, func_env)
  insert_after(node, endfunc_node)
  node = endfunc_node
end

special_form_compilers["quote"] = function(node, new_dirty_nodes)
  local args = to_lua_array(node.args)
  if #args == 0 or #args >= 2 then
    error("quote: wrong number of parts")
  end
  local port = OutputStringPort.new()
  M.write(node.args[1], port)
  node.op = "DATA"
  local serialized_data = port:get_output_string()
  node.args = {serialized_data}
end

special_form_compilers["if"] = function(node, new_dirty_nodes)
  local args = node.args
  if args == EMPTY_LIST then
    error("if: bad syntax (has 0 parts after keyword)")
  end
  local test = car(args)
  args = cdr(args)
  local consequent
  local alternate
  if args ~= EMPTY_LIST then
    consequent = car(args)
    args = cdr(args)
    if args ~= EMPTY_LIST then
      alternate = car(args)
    end
  else
    error("if: bad syntax (has only 1 part after keyword)")
  end

  local env = node.env

  -- handle the if test
  local test_ret_sym = genvar("if_test")
  env = env:extend_with({test_ret_sym})
  local test_node = new_node('LISP', {test}, env)
  test_node.new_local = test_ret_sym
  insert_before(node, test_node)
  table.insert(new_dirty_nodes, test_node)

  -- create a variable to store the value of the if expression, which is
  -- complicated since we don't want to create a lambda as that hampers JIT
  local if_ret_sym = genvar("if_ret")
  env = env:extend_with({if_ret_sym})
  local if_ret_node = new_node('PRIMITIVE', {nil}, env)
  if_ret_node.new_local = if_ret_sym
  insert_before(node, if_ret_node)

  local if_node = new_node('IF', {test_ret_sym}, env)
  insert_before(node, if_node)

  local consequent_node = new_node("LISP", {consequent}, env)
  consequent_node.set_var = if_ret_sym
  table.insert(new_dirty_nodes, consequent_node)
  insert_before(node, consequent_node)

  if alternate then
    local else_node = new_node('ELSE', {}, env)
    insert_before(node, else_node)

    local alternate_node = new_node("LISP", {alternate}, env)
    alternate_node.set_var = if_ret_sym
    table.insert(new_dirty_nodes, alternate_node)
    insert_before(node, alternate_node)
  end

  local endif_node = new_node('ENDIF', {}, env)
  insert_before(node, endif_node)

  node.op = 'SYMBOL'
  node.args = {if_ret_sym}
  node.env = env
end

special_form_compilers["let"] = function(node, new_dirty_nodes)
  local args = node.args
  if args == EMPTY_LIST then
    error("let: bad syntax (missing name or binding pairs)")
  end

  local bindings = car(args)
  args = cdr(args)
  local bodies = args

  if getmetatable(bindings) == Symbol then
    error("TODO: supported named let")
  end

  assert(getmetatable(bindings) == Pair,
         "let: bad syntax (bindings not a list)")

  local env = node.env

  local let_ret_sym = genvar("let_ret")
  env = env:extend_with({let_ret_sym})
  local let_ret_node = new_node("PRIMITIVE", {nil}, env)
  insert_before(node, let_ret_node)
  let_ret_node.new_local = let_ret_sym

  local memfence_node = new_node("VARFENCE", {}, env)
  insert_before(node, memfence_node)

  local local_map = {}
  local new_vars = {}
  local seen_variables = {}

  while bindings ~= EMPTY_LIST do
    local binding = car(bindings)
    assert(getmetatable(binding) == Pair)
    local variable = car(binding)
    assert(getmetatable(variable) == Symbol,
           "let: bad syntax (variable not an identifier)")
    binding = cdr(binding)
    local init = car(binding)
    bindings = cdr(bindings)

    local name = tostring(variable)
    assert(seen_variables[name] == nil, "let: duplicate identifier: " .. name)
    seen_variables[name] = true

    local tmp_var_sym = genvar("let_var")
    local tmp_var_node = new_node("LISP", {init}, env)
    tmp_var_node.new_local = tmp_var_sym
    insert_before(node, tmp_var_node)
    table.insert(new_dirty_nodes, tmp_var_node)
    env = env:extend_with({tmp_var_sym})
    tmp_var_node.env = env

    table.insert(local_map, {variable, tmp_var_sym})
    table.insert(new_vars, variable)
  end

  env = env:extend_with(new_vars)
  for i, m in ipairs(local_map) do
    local local_assign_node = new_node('SYMBOL', {m[2]}, env)
    local_assign_node.new_local = m[1]
    insert_before(node, local_assign_node)
  end

  while bodies ~= EMPTY_LIST do
    local body = car(bodies)
    local body_node = new_node("LISP", {body}, env)
    insert_before(node, body_node)
    table.insert(new_dirty_nodes, body_node)
    bodies = cdr(bodies)
    if bodies == EMPTY_LIST then
      body_node.set_var = let_ret_sym
    end
  end

  local endmemfence_node = new_node("ENDVARFENCE", {}, env)
  insert_before(node, endmemfence_node)

  node.op = 'SYMBOL'
  node.args = {let_ret_sym}
  node.env = env
end

special_form_compilers["let*"] = function(node, new_dirty_nodes)
  local args = node.args
  if args == EMPTY_LIST then
    error("let: bad syntax (missing name or binding pairs)")
  end

  local bindings = car(args)
  args = cdr(args)
  local bodies = args

  assert(getmetatable(bindings) == Pair,
         "let*: bad syntax (not a sequence of identifier--expression bindings)")

  local env = node.env

  local let_ret_sym = genvar("let_ret")
  env = env:extend_with({let_ret_sym})
  local let_ret_node = new_node("PRIMITIVE", {nil}, env)
  insert_before(node, let_ret_node)
  let_ret_node.new_local = let_ret_sym

  local memfence_node = new_node("VARFENCE", {}, env)
  insert_before(node, memfence_node)

  while bindings ~= EMPTY_LIST do
    local binding = car(bindings)
    assert(getmetatable(binding) == Pair)
    local variable = car(binding)
    assert(getmetatable(variable) == Symbol,
           "let: bad syntax (variable not an identifier)")
    binding = cdr(binding)
    local init = car(binding)
    bindings = cdr(bindings)

    local binding_node = new_node("LISP", {init}, env)
    binding_node.new_local = variable
    insert_before(node, binding_node)
    table.insert(new_dirty_nodes, binding_node)
    env = env:extend_with({variable})
    binding_node.env = env
  end

  while bodies ~= EMPTY_LIST do
    local body = car(bodies)
    local body_node = new_node("LISP", {body}, env)
    insert_before(node, body_node)
    table.insert(new_dirty_nodes, body_node)
    bodies = cdr(bodies)
    if bodies == EMPTY_LIST then
      body_node.set_var = let_ret_sym
    end
  end

  local endmemfence_node = new_node("ENDVARFENCE", {}, env)
  insert_before(node, endmemfence_node)

  node.op = 'SYMBOL'
  node.args = {let_ret_sym}
  node.env = env
end

special_form_compilers["letrec"] = function(node, new_dirty_nodes)
  local args = node.args
  if args == EMPTY_LIST then
    error("let: bad syntax (missing name or binding pairs)")
  end

  local bindings = car(args)
  args = cdr(args)
  local bodies = args

  if getmetatable(bindings) == Symbol then
    error("TODO: supported named let")
  end

  assert(getmetatable(bindings) == Pair,
         "let: bad syntax (bindings not a list)")

  local env = node.env

  local let_ret_sym = genvar("let_ret")
  env = env:extend_with({let_ret_sym})
  local let_ret_node = new_node("PRIMITIVE", {nil}, env)
  insert_before(node, let_ret_node)
  let_ret_node.new_local = let_ret_sym

  local memfence_node = new_node("VARFENCE", {}, env)
  insert_before(node, memfence_node)

  local seen_variables = {}
  local local_init_list = {}

  while bindings ~= EMPTY_LIST do
    local binding = car(bindings)
    assert(getmetatable(binding) == Pair)
    local variable = car(binding)
    assert(getmetatable(variable) == Symbol,
           "let: bad syntax (variable not an identifier)")
    binding = cdr(binding)
    local init = car(binding)
    bindings = cdr(bindings)

    local name = tostring(variable)
    assert(seen_variables[name] == nil, "let: duplicate identifier: " .. name)
    seen_variables[name] = true

    table.insert(local_init_list, {variable, init})
  end

  for i, m in ipairs(local_init_list) do
    local variable = m[1]
    local local_node = new_node("PRIMITIVE", {nil}, env)
    local_node.new_local = variable
    insert_before(node, local_node)
    env = env:extend_with({variable})
    local_node.env = env
  end

  for i, m in ipairs(local_init_list) do
    local variable = m[1]
    local init = m[2]
    local bind_node = new_node("LISP", {init}, env)
    insert_before(node, bind_node)
    bind_node.set_var = variable
    table.insert(new_dirty_nodes, bind_node)
  end

  while bodies ~= EMPTY_LIST do
    local body = car(bodies)
    local body_node = new_node("LISP", {body}, env)
    insert_before(node, body_node)
    table.insert(new_dirty_nodes, body_node)
    bodies = cdr(bodies)
    if bodies == EMPTY_LIST then
      body_node.set_var = let_ret_sym
    end
  end

  local endmemfence_node = new_node("ENDVARFENCE", {}, env)
  insert_before(node, endmemfence_node)

  node.op = 'SYMBOL'
  node.args = {let_ret_sym}
  node.env = env
end

-- our letrec already processess sequentially from left to right, not sure if
-- it is possible to re-arrange stuff to be faster on a Lua level. Maybe in
-- assembly or LLVM this makes sense?
--
-- In Racket, letrec is letrec*, which suggests there is minimal benefit
special_form_compilers["letrec*"] = special_form_compilers["letrec"]

local function compile_lua_primitive(obj)
  if type(obj) == 'string' then
    return string.format("%q", obj)
  elseif type(obj) == 'number' then
    return tostring(obj)
  elseif obj == true then
    return "true"
  elseif obj == false then
    return "false"
  elseif obj == nil then
    return "nil"
  else
    assert(false)
  end
end

-- Lua does not allow standalone values that aren't being bound to anything
local function is_rvalue(node)
  if node.set_var or node.new_local or node.ret then
    return true
  end
  return false
end

local function transform_to_lua(ir_list, module)
  local current_module_name = module["*MODULE-NAME*"]
  local used_module_names = {}

  local indent = 0
  local lua_code = {}
  local lua_header_code = {}
  local function insert(text)
    table.insert(lua_code, text)
  end
  local function insert_header(text)
    table.insert(lua_header_code, text)
  end

  insert_header('do -- chunk start\n')
  insert_header('local ')
  insert_header(kModuleLocal)
  insert_header(' = package.loaded[')
  insert_header(string.format("%q", current_module_name))
  insert_header(']\n')

  -- anchor data to the beginning of the source code
  local node = ir_list
  while node do
    if node.op == 'DATA' then
      used_module_names["moonscheme.base"] = true

      local data_name = tostring(genvar("data"))
      insert('local ')
      insert(data_name)
      insert(' = ')
      insert(to_lua_module_identifier("moonscheme.base"))
      insert('.read(')
      insert(string.format("%q", node.args[1]))
      insert(')')
      insert('\n')

      node.args[1] = data_name
    end
    node = node.next
  end

  local node = ir_list
  while node do
    local op = node.op
    local env = node.env
    local args = node.args

    if op == "ENDFUNC" or
      op == "ENDIF" or
      op == "ELSE" or
      op == "ENDVARFENCE"
      then
      indent = indent - 1
    end

    for i = 1, indent do
      table.insert(lua_code, "    ")
    end

    if node.new_local then
      assert(getmetatable(node.new_local) == Symbol)
      insert("local ")
      insert(env:mangle_symbol(node.new_local, used_module_names))
      insert(" = ")
    elseif node.set_var then
      assert(getmetatable(node.set_var) == Symbol)
      insert(env:mangle_symbol(node.set_var, used_module_names))
      insert(" = ")
    elseif node.ret then
      insert("return ")
    end

    if op == 'PRIMITIVE' then
      if is_rvalue(node) then
        local obj = node.args[1]
        insert(compile_lua_primitive(obj))
      end
    elseif op == 'SYMBOL' then
      if is_rvalue(node) then
        local symbol = node.args[1]
        insert(env:mangle_symbol(symbol, used_module_names))
      end
    elseif op == 'DATA'then
      if is_rvalue(node) then
        insert(args[1])
      end
    elseif op == 'CALL' then
      for i = 1, #args do
        local arg = args[i]
        if getmetatable(arg) == Symbol then
          insert(env:mangle_symbol(arg, used_module_names))
        else
          insert(compile_lua_primitive(arg))
        end

        if i == 1 then
          insert("(")
        elseif i == #args then
          -- consider case of 0 arguments, then it would match above but not
          -- also here. move outside to fix this.
        else
          insert(", ")
        end
      end
      insert(")")
    elseif op == 'FUNC' then
      insert("function(")
      local n = #args
      for i = 1, n do
        local symbol = args[i]
        insert(env:mangle_symbol(symbol, used_module_names))
        if i ~= n then
          insert(", ")
        end
      end
      insert(")")
      indent = indent + 1
    elseif op == 'PACKARGS' then
      used_module_names["moonscheme.base"] = true
      insert(to_lua_module_identifier("moonscheme.base"))
      insert('.to_scheme_list(table.pack(...))')
    elseif op == 'ENDFUNC' then
      insert("end")
    elseif op == 'IF' then
      insert("if ")
      insert(env:mangle_symbol(args[1], used_module_names))
      insert(" ~= false then")
      indent = indent + 1
    elseif op == 'ELSE' then
      insert("else")
      indent = indent + 1
    elseif op == 'ENDIF' then
      insert("end")
    elseif op == "VARFENCE" then
      insert("do")
      indent = indent + 1
    elseif op == "ENDVARFENCE" then
      insert("end")
    elseif op == "DEFSYM" then
      insert(kModuleLocal)
      insert('["*ENVIRONMENT*"].symbols')
      insert('[')
      insert(string.format("%q", tostring(args[1])))
      insert('] = true')
    else
      error("unknown opcode type in Lua generation: " .. op)
    end
    insert("\n")
    node = node.next
  end

  for module_name, _ in pairs(used_module_names) do
    insert_header('local ')
    insert_header(to_lua_module_identifier(module_name))
    insert_header(' = package.loaded["')
    insert_header(module_name)
    insert_header('"]\n')
  end

  insert("end -- chunk END\n")
  insert("----------------------------------------\n")

  return table.concat(lua_header_code) ..table.concat(lua_code)
end

local function compile(expr, module)
  local ir_list = transform_to_ir_list(expr, module)
  local lua_code = transform_to_lua(ir_list, module)
  return lua_code
end

local out = io.open('compiler_output.lua', 'wb')
local kDefineSymbol = Symbol.new("define")
local function eval(expr, module)
  local lua_code = compile(expr, module)

  -- extract defines to give functions names
  local current_module_name = module["*MODULE-NAME*"]
  local description
  if getmetatable(expr) == Pair then
    local arg0 = car(expr)
    if arg0 == kDefineSymbol then
      local arg1 = car(cdr(expr))
      if getmetatable(arg1) == Pair then
        description = current_module_name .. '/' .. tostring(car(arg1))
      elseif getmetatable(arg1) == Symbol then
        description = current_module_name .. '/' .. tostring(arg1)
      end
    end
  end

  -- debug
  if description then
    out:write("-- ")
    out:write(description)
    out:write("\n")
  end
  out:write(lua_code)

  local fn, err = load(lua_code, description)
  if fn == nil then
    assert(false, err)
  end
  return fn()
end
M.eval = eval

local function require(module_name)
  if package.loaded[module_name] then
    return package.loaded[module_name]
  end

  local paths = util.split(package.path, ";")
  local file
  local attempted_paths = {}
  for i, path in ipairs(paths) do
    path = path:gsub(".lua$", ".scm")
    path = path:gsub("%?", module_name:gsub("%.", "/"))
    table.insert(attempted_paths, "\t" .. path)
    local f, err = io.open(path, 'rb')
    if f then
      file = f
      break
    end
  end
  if file == nil then
    local msg = "module '" .. module_name .. "' not found at any of following locations:\n"
    msg = msg .. table.concat(attempted_paths, "\n")
    error(msg)
  end

  local source_code = file:read("*all")

  local env = Environment.new(0)
  for k, v in pairs(M) do
    -- TODO proper environment table for moonscheme.base
    env:add_external_symbol(Symbol.new(k), "moonscheme.base")
  end
  local module = {
    ["*MODULE-NAME*"] = module_name,
    ["*ENVIRONMENT*"] = env
  }
  package.loaded[module_name] = module

  local port = InputStringPort.new(source_code)
  local expr_or_def = M.read(port)
  while expr_or_def ~= M.EOF do
    local function safe_eval()
      return M.eval(expr_or_def, module)
    end
    local function on_err(err)
      return err .. "\n" .. debug.traceback()
    end
    local status, ret_or_error = xpcall(safe_eval, on_err)
    if status then
      -- TODO: remove this debugging
      M.write(ret_or_error, M.stdout_port)
      print()

      expr_or_def = M.read(port)
    else
      print(ret_or_error)
      local string_port = OutputStringPort.new()
      M.write(expr_or_def, string_port)
      print("moonscheme info:")
      print("\twhile reading: " .. string_port:get_output_string())
      print("\tnear line number: " .. tostring(port.line_number))
      return
    end
  end
  print("\n----------------------------------------")
end
M["require"] = require

M["assert"] = _G["assert"]

--------------------------------------------------------------------------------
-- inefficient, needs to be a special form eventually
--------------------------------------------------------------------------------
M["+"] = function(...)
  local sum = 0
  local t = table.pack(...)
  for i = 1, t.n do
    sum = sum + t[i]
  end
  return sum
end

M["-"] = function(...)
  local sum = 0
  local t = table.pack(...)
  if t.n < 1 then
    error("arity mismatch")
  elseif t.n == 1 then
    return -t[1]
  else
    sum = t[1]
  end

  for i = 2, t.n do
    sum = sum - t[i]
  end
  return sum
end

M["zero?"] = function(n)
  return n == 0
end

return M
