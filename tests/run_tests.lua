package.path = './?.lua;./?/init.lua'
require('tests.strict')
local util = require('tests.util')

local moonscheme = require('moonscheme')
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
  -- print(serialized_text)
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

local function eval(text)
  print(text)
  local port = InputStringPort.new(text)
  local data = moonscheme.read(port)
  while data ~= moonscheme.EOF do
    local ret = moonscheme.eval(data)
    local out_port = moonscheme.stdout_port
    moonscheme.write(ret, out_port)
    print("\n----------------------------------------")
    data = moonscheme.read(port)
  end
end

-- eval of empty list is an error
-- eval([[()]])

-- (define) wrong arity (!= 2)
-- eval([[(define)]])
-- eval([[(define x)]])
-- eval([[(define x 1 2)]])

-- (define) on existing top-level symbol, duplicated
-- eval([[(define car 1234)]])

eval([[(define x 1)]])
-- eval([[(define y math)]])
eval([[(define z "foobar")]])
eval([[(define a car)]])
-- eval([[(quote)]])
-- eval([[(quote 1 2)]])
eval([[(car '(42 84 168))]])

-- eval([[(lambda)]])
-- eval([[(lambda 42 42)]])
-- eval([[(lambda (x y z))]])
-- eval([[(lambda (x y z . w))]])

eval([[(lambda () 42)]])
eval([[(lambda (x) (car x))]])
eval([[(lambda (x y z) (car y))]])
eval([[
(lambda (x y z . w)
  (write x)
  (write w))]])
-- eval([[(lambda packed)]])


eval([[

(define (foo x y)
  42)
(define (bar x)
  (assert #f))
(define (quux)
  (assert #f))
(define (colbert . stewart)
  (write stewart))
(define (test1 arg0 arg1 . stewart)
  (write stewart)
  (test1 (car stewart)))
;(bar 1)
(colbert 1 2 3)
]])
