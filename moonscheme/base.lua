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

local function read(port)
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

local kQuoteSymbol = Symbol.new('quote')
macros["'"] = function(port, initial_ch)
  local list = cons(kQuoteSymbol, EMPTY_LIST)
  set_cdr(list, cons(read(port), EMPTY_LIST))
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
local function to_lua_identifier(scheme_identifier)
  local buf = {nil, nil, nil, nil, nil, nil, nil, nil}; local nextslot = 1
  local n = scheme_identifier:len()
  for i = 1, n do
    local ch = scheme_identifier_map[scheme_identifier:sub(i, i)]
    assert(ch, 'missing mapping in scheme_identifier_map')
    buf[nextslot] = ch; nextslot = nextslot + 1
  end
  return table.concat(buf)
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
  return table.concat(buf)
end

local kModuleLocal = '__MODULE'
local kMoonSchemeLocal = '__MOONSCHEME_BASE_MODULE'
local current_module_name = "moonscheme.base"
local current_module = M
local function GetModule(name)
  if name == 'moonscheme.base' then
    return M
  end
end


-- lexical environment
local Environment = {}
Environment.__index = Environment
function Environment.new(level)
  if level == nil then
    level = 0
  end

  local t = {}
  t.symbols = {}
  t.level = level
  return setmetatable(t, Environment)
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
function Environment:is_top_level()
  return self.parent == nil
end
function Environment:has_symbol(symbol)
  assert(getmetatable(symbol) == Symbol)
  if self.symbols[tostring(symbol)] then
    return self.level
  end

  if self.parent then
    return self.parent:has_symbol(symbol)
  else
    return nil
  end
end
function Environment:mangle_symbol(symbol)
  assert(getmetatable(symbol) == Symbol)
  local buf = {nil, nil, nil}; local nextslot = 1

  local symbol_level = self:has_symbol(symbol)

  if symbol_level == nil then
    buf[nextslot] = '_G["'; nextslot = nextslot + 1
  elseif symbol_level == 0 then
    buf[nextslot] = kModuleLocal; nextslot = nextslot + 1
    buf[nextslot] = '["'; nextslot = nextslot + 1
  end

  local name = tostring(symbol)
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
local function transform_to_ir_list(expr)
  local base_env = Environment.new()
  base_env.symbols = current_module
  local list = new_node('LISP', {expr}, base_env)
  local dirty_nodes = {list}

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
  while list.prev do
    list = list.prev
  end
  return list
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
      local fn_get_name = genvar("operator")
      local fn_get_sym = Symbol.new(fn_get_name)
      table.insert(call_args, fn_get_sym)

      local fn_get_node = new_node('LISP', {proc}, node.env)
      fn_get_name.new_local = fn_get_name
      insert_before(node, fn_get_node)
      table.insert(new_dirty_nodes, fn_get_node)

      node.env = node.env:extend_with({fn_get_sym})
    else
      print(util.show(lisp))
      assert(false, "unrecognized (operator ...) type")
    end

    while args ~= EMPTY_LIST do
      local arg = car(args)
      if getmetatable(arg) == Pair then
        local var_get_name = genvar("call_arg")
        local var_get_sym = Symbol.new(var_get_name)
        table.insert(call_args, var_get_sym)

        local var_get_node = new_node('LISP', {arg}, node.env)
        var_get_node.new_local = var_get_name
        insert_before(node, var_get_node)
        table.insert(new_dirty_nodes, var_get_node)

        node.env = node.env:extend_with({var_get_sym})
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
  local args = to_lua_array(node.args)
  if #args < 1 then
    error("define: bad syntax (called with no arguments)")
  end

  local variable = args[1]
  -- deduce variable type, of which there can be 3 possibilities
  local mt = getmetatable(variable)
  if mt == Symbol then
    -- 1. define a new variable equal to the second argument
    if #args <= 0 then
      error("define: bad syntax (missing expression after identifier)")
    elseif #args >= 3 then
      error("define: bad syntax, (multiple expressions after identifier)")
    end
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
      node.set_var = kModuleLocal .. '.' .. tostring(variable)
    else
      node.new_local = tostring(variable)
    end
  elseif mt == Pair then
    local proc_name = car(variable)
    local proc_args = cdr(variable)
    local mt = getmetatable(proc_args)
    if mt == Pair then
      -- 2. define a new named function with normal arguments
    elseif mt == Symbol then
      -- 3. define a new named function with arguments packed to a list
    end
  else
    error("define: bad syntax (unknown first argument type)")
  end
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

local function transform_to_lua(ir_list)
  local lua_code = {}
  local function insert(text)
    table.insert(lua_code, text)
  end

  insert('local ')
  insert(kModuleLocal)
  insert(' = require(')
  insert(string.format("%q", current_module_name))
  insert(')\n')

  insert('local ')
  insert(kMoonSchemeLocal)
  insert(' = require("moonscheme.base")\n')

  -- anchor data to the beginning of the source code
  local node = ir_list
  while node do
    if node.op == 'DATA' then
      local data_name = genvar("data")
      insert('local ')
      insert(data_name)
      insert(' = ')
      insert(kMoonSchemeLocal)
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

    if node.new_local then
      insert("local ")
      insert(node.new_local)
      insert(" = ")
    elseif node.set_var then
      insert(node.set_var)
      insert(" = ")
    end

    if op == 'PRIMITIVE' then
      local obj = node.args[1]
      insert(compile_lua_primitive(obj))
    elseif op == 'SYMBOL' then
      local symbol = node.args[1]
      insert(env:mangle_symbol(symbol))
    elseif op == 'DATA' then
      insert(args[1])
    elseif op == 'CALL' then
      for i = 1, #args do
        local arg = args[i]
        if getmetatable(arg) == Symbol then
          insert(env:mangle_symbol(arg))
        else
          insert(compile_lua_primitive(arg))
        end

        if i == 1 then
          insert("(")
        elseif i == #args then
          insert(")")
        else
          insert(", ")
        end
      end
    else
      error("unknown opcode type in Lua generation: " .. op)
    end
    insert("\n")
    node = node.next
  end

  insert("----------------------------------------\n")

  return table.concat(lua_code)
end

local function compile(expr)
  local ir_list = transform_to_ir_list(expr)
  local lua_code = transform_to_lua(ir_list)
  return lua_code
end

local out = io.open('compiler_output.lua', 'wb')

local function eval(expr)
  local lua_code = compile(expr)
  out:write(lua_code)
  local fn, err = load(lua_code)
  if fn == nil then
    assert(false, err)
  end
  fn()
end
M.eval = eval

return M
