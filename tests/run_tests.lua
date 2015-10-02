package.path = './?.lua'
require('tests.strict')
local util = require('tests.util')

local moonscheme = require('moonscheme.base')
local InputStringPort = moonscheme.InputStringPort
local OutputStringPort = moonscheme.OutputStringPort

local port = InputStringPort.new('')
assert(port:read_char() == moonscheme.EOF)
assert(port:peek_char() == moonscheme.EOF)
assert(port:read_char() == moonscheme.EOF)
local port = InputStringPort.new('a')
assert(port:read_char() == 'a')
local port = InputStringPort.new('a')
assert(port:peek_char() == 'a')
assert(port:read_char() == 'a')
assert(port:peek_char() == moonscheme.EOF)
assert(port:read_char() == moonscheme.EOF)

local function read(text)
  local port = InputStringPort.new(text)
  local data = moonscheme.read(port)
  -- print(data)
  return data
end

assert(read('1') == 1)
assert(read('1.1') == 1.1)
assert(read('0xffff') == 65535)
assert(read('+42') == 42)
assert(read('-42') == -42)

-- print(util.show(read('foo')))

-- read('[]')
-- read('{}')

assert(read([["\\"]]) == [[\]])
assert(read([["\""]]) == [["]])
assert(read([["Here's text \
            containing just one line"]]) ==
            [[Here's text containing just one line]])

assert(read([[#t]]) == true)
assert(read([[#true]]) == true)
assert(read([[#f]]) == false)
assert(read([[#false]]) == false)

assert(read('||').name == '||')
assert(read('|Hello|').name == 'Hello')

local function serialize_check(text)
  local inport = InputStringPort.new(text)
  local data = moonscheme.read(inport)
  -- print(util.show(data))
  local outport = OutputStringPort.new()
  moonscheme.write(data, outport)
  local serialized_text = outport:get_output_string() 
  print(serialized_text)
  assert(serialized_text == text)
end

serialize_check([[#t]])
serialize_check([[#f]])

serialize_check([["asdf"]])
serialize_check([["\t"]])

serialize_check([[foo]])
-- samples from official whitepaper
serialize_check([[...]])
serialize_check([[+]])
serialize_check([[-]])
serialize_check([[+soup+]])
serialize_check([[<=?]])
serialize_check([[->string]])
serialize_check([[a34kTMNs]])
serialize_check([[lambda]])
serialize_check([[list->vector]])
serialize_check([[q]])
serialize_check([[V17a]])

serialize_check([[()]])
serialize_check([[(list)]])
serialize_check([[(foo bar)]])
serialize_check([[(foo . bar)]])
serialize_check([[(foo bar (fizz buzz))]])
-- read('(. 2)')
serialize_check([[(1 . 2)]])
assert(moonscheme.car(read([[(1 . 2)]])) == 1)
assert(moonscheme.cdr(read([[(1 . 2)]])) == 2)