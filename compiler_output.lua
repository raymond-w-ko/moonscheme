-- RET PRIMITIVE nil () 
do -- chunk start
local __MODULE = package.loaded["tests.test0"]
return nil
end -- chunk END
----------------------------------------
-- x = PRIMITIVE 1 (x) 
-- DEFSYM x (x) 
-- RET SYMBOL x (x) 
-- tests.test0/x
do -- chunk start
local __MODULE = package.loaded["tests.test0"]
__MODULE["x"] = 1
__MODULE["*ENVIRONMENT*"].symbols["x"] = true
return __MODULE["x"]
end -- chunk END
----------------------------------------
-- z = PRIMITIVE "foobar" (x z) 
-- DEFSYM z (x z) 
-- RET SYMBOL z (x z) 
-- tests.test0/z
do -- chunk start
local __MODULE = package.loaded["tests.test0"]
__MODULE["z"] = "foobar"
__MODULE["*ENVIRONMENT*"].symbols["z"] = true
return __MODULE["z"]
end -- chunk END
----------------------------------------
-- a = SYMBOL car (x z a) 
-- DEFSYM a (x z a) 
-- RET SYMBOL a (x z a) 
-- tests.test0/a
do -- chunk start
local __MODULE = package.loaded["tests.test0"]
local __MODULE_moonscheme_DOT_base = package.loaded["moonscheme.base"]
__MODULE["a"] = __MODULE_moonscheme_DOT_base["car"]
__MODULE["*ENVIRONMENT*"].symbols["a"] = true
return __MODULE["a"]
end -- chunk END
----------------------------------------
-- LOCAL __call_arg_0 = DATA "(42 84 168)" (__call_arg_0) (x a z) 
-- RET CALL car __call_arg_0 (__call_arg_0) (x a z) 
do -- chunk start
local __MODULE = package.loaded["tests.test0"]
local __MODULE_moonscheme_DOT_base = package.loaded["moonscheme.base"]
local __data_1 = __MODULE_moonscheme_DOT_base.read("(42 84 168)")
local __call_arg_0 = __data_1
return __MODULE_moonscheme_DOT_base["car"](__call_arg_0)
end -- chunk END
----------------------------------------
-- RET FUNC nil () (x a z) 
-- RET PRIMITIVE 42 () () (x a z) 
-- ENDFUNC nil () (x a z) 
do -- chunk start
local __MODULE = package.loaded["tests.test0"]
return function()
    return 42
end
end -- chunk END
----------------------------------------
-- RET FUNC x (x) (x a z) 
-- RET CALL car x () (x) (x a z) 
-- ENDFUNC nil (x) (x a z) 
do -- chunk start
local __MODULE = package.loaded["tests.test0"]
local __MODULE_moonscheme_DOT_base = package.loaded["moonscheme.base"]
return function(x)
    return __MODULE_moonscheme_DOT_base["car"](x)
end
end -- chunk END
----------------------------------------
-- RET FUNC x y z (y x z) (x a z) 
-- RET CALL car y () (y x z) (x a z) 
-- ENDFUNC nil (y x z) (x a z) 
do -- chunk start
local __MODULE = package.loaded["tests.test0"]
local __MODULE_moonscheme_DOT_base = package.loaded["moonscheme.base"]
return function(x, y, z)
    return __MODULE_moonscheme_DOT_base["car"](y)
end
end -- chunk END
----------------------------------------
-- RET FUNC x y z ... (y x ... z) (x a z) 
-- LOCAL w = PACKARGS nil (w) (y x ... z) (x a z) 
-- CALL write x () (w) (y x ... z) (x a z) 
-- RET CALL write w () (w) (y x ... z) (x a z) 
-- ENDFUNC nil (w) (y x ... z) (x a z) 
do -- chunk start
local __MODULE = package.loaded["tests.test0"]
local __MODULE_moonscheme_DOT_base = package.loaded["moonscheme.base"]
return function(x, y, z, ...)
    local w = __MODULE_moonscheme_DOT_base.to_scheme_list(table.pack(...))
    __MODULE_moonscheme_DOT_base["write"](x)
    return __MODULE_moonscheme_DOT_base["write"](w)
end
end -- chunk END
----------------------------------------
-- foo = FUNC x y (y x) (x a foo z) 
-- RET PRIMITIVE 42 () (y x) (x a foo z) 
-- ENDFUNC nil (y x) (x a foo z) 
-- DEFSYM foo (y x) (x a foo z) 
-- RET SYMBOL foo (y x) (x a foo z) 
-- tests.test0/foo
do -- chunk start
local __MODULE = package.loaded["tests.test0"]
__MODULE["foo"] = function(x, y)
    return 42
end
__MODULE["*ENVIRONMENT*"].symbols["foo"] = true
return __MODULE["foo"]
end -- chunk END
----------------------------------------
-- bar = FUNC x (x) (foo x bar a z) 
-- RET CALL assert #f () (x) (foo x bar a z) 
-- ENDFUNC nil (x) (foo x bar a z) 
-- DEFSYM bar (x) (foo x bar a z) 
-- RET SYMBOL bar (x) (foo x bar a z) 
-- tests.test0/bar
do -- chunk start
local __MODULE = package.loaded["tests.test0"]
local __MODULE_moonscheme_DOT_base = package.loaded["moonscheme.base"]
__MODULE["bar"] = function(x)
    return __MODULE_moonscheme_DOT_base["assert"](false)
end
__MODULE["*ENVIRONMENT*"].symbols["bar"] = true
return __MODULE["bar"]
end -- chunk END
----------------------------------------
-- quux = FUNC nil () (foo x bar a quux z) 
-- RET CALL assert #f () () (foo x bar a quux z) 
-- ENDFUNC nil () (foo x bar a quux z) 
-- DEFSYM quux () (foo x bar a quux z) 
-- RET SYMBOL quux () (foo x bar a quux z) 
-- tests.test0/quux
do -- chunk start
local __MODULE = package.loaded["tests.test0"]
local __MODULE_moonscheme_DOT_base = package.loaded["moonscheme.base"]
__MODULE["quux"] = function()
    return __MODULE_moonscheme_DOT_base["assert"](false)
end
__MODULE["*ENVIRONMENT*"].symbols["quux"] = true
return __MODULE["quux"]
end -- chunk END
----------------------------------------
-- colbert = FUNC ... (...) (foo x bar colbert a quux z) 
-- LOCAL stewart = PACKARGS nil (stewart) (...) (foo x bar colbert a quux z) 
-- RET CALL write stewart () (stewart) (...) (foo x bar colbert a quux z) 
-- ENDFUNC nil (stewart) (...) (foo x bar colbert a quux z) 
-- DEFSYM colbert (...) (foo x bar colbert a quux z) 
-- RET SYMBOL colbert (...) (foo x bar colbert a quux z) 
-- tests.test0/colbert
do -- chunk start
local __MODULE = package.loaded["tests.test0"]
local __MODULE_moonscheme_DOT_base = package.loaded["moonscheme.base"]
__MODULE["colbert"] = function(...)
    local stewart = __MODULE_moonscheme_DOT_base.to_scheme_list(table.pack(...))
    return __MODULE_moonscheme_DOT_base["write"](stewart)
end
__MODULE["*ENVIRONMENT*"].symbols["colbert"] = true
return __MODULE["colbert"]
end -- chunk END
----------------------------------------
-- test1 = FUNC arg0 arg1 ... (arg1 arg0 ...) (colbert foo test1 x bar a z quux) 
-- LOCAL stewart = PACKARGS nil (stewart) (arg1 arg0 ...) (colbert foo test1 x bar a z quux) 
-- CALL write stewart () (stewart) (arg1 arg0 ...) (colbert foo test1 x bar a z quux) 
-- LOCAL __call_arg_2 = CALL car stewart (__call_arg_2) () (stewart) (arg1 arg0 ...) (colbert foo test1 x bar a z quux) 
-- RET CALL test1 __call_arg_2 (__call_arg_2) () (stewart) (arg1 arg0 ...) (colbert foo test1 x bar a z quux) 
-- ENDFUNC nil (stewart) (arg1 arg0 ...) (colbert foo test1 x bar a z quux) 
-- DEFSYM test1 (arg1 arg0 ...) (colbert foo test1 x bar a z quux) 
-- RET SYMBOL test1 (arg1 arg0 ...) (colbert foo test1 x bar a z quux) 
-- tests.test0/test1
do -- chunk start
local __MODULE = package.loaded["tests.test0"]
local __MODULE_moonscheme_DOT_base = package.loaded["moonscheme.base"]
__MODULE["test1"] = function(arg0, arg1, ...)
    local stewart = __MODULE_moonscheme_DOT_base.to_scheme_list(table.pack(...))
    __MODULE_moonscheme_DOT_base["write"](stewart)
    local __call_arg_2 = __MODULE_moonscheme_DOT_base["car"](stewart)
    return __MODULE["test1"](__call_arg_2)
end
__MODULE["*ENVIRONMENT*"].symbols["test1"] = true
return __MODULE["test1"]
end -- chunk END
----------------------------------------
-- RET CALL colbert 1 2 3 (test1 x bar colbert a quux foo z) 
do -- chunk start
local __MODULE = package.loaded["tests.test0"]
return __MODULE["colbert"](1, 2, 3)
end -- chunk END
----------------------------------------
-- LOCAL __if_test_3 = PRIMITIVE #t (__if_test_3) (test1 x bar colbert a quux foo z) 
-- LOCAL __if_ret_4 = PRIMITIVE nil (__if_ret_4) (__if_test_3) (test1 x bar colbert a quux foo z) 
-- IF __if_test_3 (__if_ret_4) (__if_test_3) (test1 x bar colbert a quux foo z) 
-- __if_ret_4 = PRIMITIVE 1 (__if_ret_4) (__if_test_3) (test1 x bar colbert a quux foo z) 
-- ENDIF nil (__if_ret_4) (__if_test_3) (test1 x bar colbert a quux foo z) 
-- RET SYMBOL __if_ret_4 (__if_ret_4) (__if_test_3) (test1 x bar colbert a quux foo z) 
do -- chunk start
local __MODULE = package.loaded["tests.test0"]
local __if_test_3 = true
local __if_ret_4 = nil
if __if_test_3 ~= false then
    __if_ret_4 = 1
end
return __if_ret_4
end -- chunk END
----------------------------------------
-- LOCAL __if_test_5 = PRIMITIVE #f (__if_test_5) (test1 x bar colbert a quux foo z) 
-- LOCAL __if_ret_6 = PRIMITIVE nil (__if_ret_6) (__if_test_5) (test1 x bar colbert a quux foo z) 
-- IF __if_test_5 (__if_ret_6) (__if_test_5) (test1 x bar colbert a quux foo z) 
-- __if_ret_6 = PRIMITIVE 1 (__if_ret_6) (__if_test_5) (test1 x bar colbert a quux foo z) 
-- ENDIF nil (__if_ret_6) (__if_test_5) (test1 x bar colbert a quux foo z) 
-- RET SYMBOL __if_ret_6 (__if_ret_6) (__if_test_5) (test1 x bar colbert a quux foo z) 
do -- chunk start
local __MODULE = package.loaded["tests.test0"]
local __if_test_5 = false
local __if_ret_6 = nil
if __if_test_5 ~= false then
    __if_ret_6 = 1
end
return __if_ret_6
end -- chunk END
----------------------------------------
-- LOCAL __if_test_7 = PRIMITIVE #t (__if_test_7) (test1 x bar colbert a quux foo z) 
-- LOCAL __if_ret_8 = PRIMITIVE nil (__if_ret_8) (__if_test_7) (test1 x bar colbert a quux foo z) 
-- IF __if_test_7 (__if_ret_8) (__if_test_7) (test1 x bar colbert a quux foo z) 
-- __if_ret_8 = PRIMITIVE 1 (__if_ret_8) (__if_test_7) (test1 x bar colbert a quux foo z) 
-- ELSE nil (__if_ret_8) (__if_test_7) (test1 x bar colbert a quux foo z) 
-- __if_ret_8 = PRIMITIVE 2 (__if_ret_8) (__if_test_7) (test1 x bar colbert a quux foo z) 
-- ENDIF nil (__if_ret_8) (__if_test_7) (test1 x bar colbert a quux foo z) 
-- RET SYMBOL __if_ret_8 (__if_ret_8) (__if_test_7) (test1 x bar colbert a quux foo z) 
do -- chunk start
local __MODULE = package.loaded["tests.test0"]
local __if_test_7 = true
local __if_ret_8 = nil
if __if_test_7 ~= false then
    __if_ret_8 = 1
else
    __if_ret_8 = 2
end
return __if_ret_8
end -- chunk END
----------------------------------------
-- LOCAL __if_test_9 = PRIMITIVE #f (__if_test_9) (test1 x bar colbert a quux foo z) 
-- LOCAL __if_ret_10 = PRIMITIVE nil (__if_ret_10) (__if_test_9) (test1 x bar colbert a quux foo z) 
-- IF __if_test_9 (__if_ret_10) (__if_test_9) (test1 x bar colbert a quux foo z) 
-- __if_ret_10 = PRIMITIVE 1 (__if_ret_10) (__if_test_9) (test1 x bar colbert a quux foo z) 
-- ELSE nil (__if_ret_10) (__if_test_9) (test1 x bar colbert a quux foo z) 
-- __if_ret_10 = PRIMITIVE 2 (__if_ret_10) (__if_test_9) (test1 x bar colbert a quux foo z) 
-- ENDIF nil (__if_ret_10) (__if_test_9) (test1 x bar colbert a quux foo z) 
-- RET SYMBOL __if_ret_10 (__if_ret_10) (__if_test_9) (test1 x bar colbert a quux foo z) 
do -- chunk start
local __MODULE = package.loaded["tests.test0"]
local __if_test_9 = false
local __if_ret_10 = nil
if __if_test_9 ~= false then
    __if_ret_10 = 1
else
    __if_ret_10 = 2
end
return __if_ret_10
end -- chunk END
----------------------------------------
-- LOCAL __if_test_11 = SYMBOL nil (__if_test_11) (test1 x bar colbert a quux foo z) 
-- LOCAL __if_ret_12 = PRIMITIVE nil (__if_ret_12) (__if_test_11) (test1 x bar colbert a quux foo z) 
-- IF __if_test_11 (__if_ret_12) (__if_test_11) (test1 x bar colbert a quux foo z) 
-- __if_ret_12 = PRIMITIVE "yes, nil is true!" (__if_ret_12) (__if_test_11) (test1 x bar colbert a quux foo z) 
-- ELSE nil (__if_ret_12) (__if_test_11) (test1 x bar colbert a quux foo z) 
-- __if_ret_12 = PRIMITIVE 2 (__if_ret_12) (__if_test_11) (test1 x bar colbert a quux foo z) 
-- ENDIF nil (__if_ret_12) (__if_test_11) (test1 x bar colbert a quux foo z) 
-- RET SYMBOL __if_ret_12 (__if_ret_12) (__if_test_11) (test1 x bar colbert a quux foo z) 
do -- chunk start
local __MODULE = package.loaded["tests.test0"]
local __if_test_11 = nil
local __if_ret_12 = nil
if __if_test_11 ~= false then
    __if_ret_12 = "yes, nil is true!"
else
    __if_ret_12 = 2
end
return __if_ret_12
end -- chunk END
----------------------------------------
-- LOCAL __operator_13 = FUNC x (x) (__operator_13) (test1 x bar colbert a quux foo z) 
-- LOCAL __if_test_14 = SYMBOL nil (__if_test_14) () (x) (__operator_13) (test1 x bar colbert a quux foo z) 
-- LOCAL __if_ret_15 = PRIMITIVE nil (__if_ret_15) (__if_test_14) () (x) (__operator_13) (test1 x bar colbert a quux foo z) 
-- IF __if_test_14 (__if_ret_15) (__if_test_14) () (x) (__operator_13) (test1 x bar colbert a quux foo z) 
-- __if_ret_15 = PRIMITIVE "yes, nil is true!" (__if_ret_15) (__if_test_14) () (x) (__operator_13) (test1 x bar colbert a quux foo z) 
-- ELSE nil (__if_ret_15) (__if_test_14) () (x) (__operator_13) (test1 x bar colbert a quux foo z) 
-- __if_ret_15 = PRIMITIVE 2 (__if_ret_15) (__if_test_14) () (x) (__operator_13) (test1 x bar colbert a quux foo z) 
-- ENDIF nil (__if_ret_15) (__if_test_14) () (x) (__operator_13) (test1 x bar colbert a quux foo z) 
-- SYMBOL __if_ret_15 (__if_ret_15) (__if_test_14) () (x) (__operator_13) (test1 x bar colbert a quux foo z) 
-- LOCAL __if_test_16 = PRIMITIVE #f (__if_test_16) () (x) (__operator_13) (test1 x bar colbert a quux foo z) 
-- LOCAL __if_ret_17 = PRIMITIVE nil (__if_ret_17) (__if_test_16) () (x) (__operator_13) (test1 x bar colbert a quux foo z) 
-- IF __if_test_16 (__if_ret_17) (__if_test_16) () (x) (__operator_13) (test1 x bar colbert a quux foo z) 
-- __if_ret_17 = PRIMITIVE "yes, nil is true!" (__if_ret_17) (__if_test_16) () (x) (__operator_13) (test1 x bar colbert a quux foo z) 
-- ELSE nil (__if_ret_17) (__if_test_16) () (x) (__operator_13) (test1 x bar colbert a quux foo z) 
-- __if_ret_17 = PRIMITIVE 2 (__if_ret_17) (__if_test_16) () (x) (__operator_13) (test1 x bar colbert a quux foo z) 
-- ENDIF nil (__if_ret_17) (__if_test_16) () (x) (__operator_13) (test1 x bar colbert a quux foo z) 
-- RET SYMBOL __if_ret_17 (__if_ret_17) (__if_test_16) () (x) (__operator_13) (test1 x bar colbert a quux foo z) 
-- ENDFUNC nil (x) (__operator_13) (test1 x bar colbert a quux foo z) 
-- RET CALL __operator_13 5 (__operator_13) (test1 x bar colbert a quux foo z) 
do -- chunk start
local __MODULE = package.loaded["tests.test0"]
local __operator_13 = function(x)
    local __if_test_14 = nil
    local __if_ret_15 = nil
    if __if_test_14 ~= false then
        __if_ret_15 = "yes, nil is true!"
    else
        __if_ret_15 = 2
    end
    
    local __if_test_16 = false
    local __if_ret_17 = nil
    if __if_test_16 ~= false then
        __if_ret_17 = "yes, nil is true!"
    else
        __if_ret_17 = 2
    end
    return __if_ret_17
end
return __operator_13(5)
end -- chunk END
----------------------------------------
-- LOCAL __if_test_18 = PRIMITIVE #t (__if_test_18) (test1 x bar colbert a quux foo z) 
-- LOCAL __if_ret_19 = PRIMITIVE nil (__if_ret_19) (__if_test_18) (test1 x bar colbert a quux foo z) 
-- IF __if_test_18 (__if_ret_19) (__if_test_18) (test1 x bar colbert a quux foo z) 
-- LOCAL __if_test_20 = PRIMITIVE #t (__if_test_20) (__if_ret_19) (__if_test_18) (test1 x bar colbert a quux foo z) 
-- LOCAL __if_ret_21 = PRIMITIVE nil (__if_ret_21) (__if_test_20) (__if_ret_19) (__if_test_18) (test1 x bar colbert a quux foo z) 
-- IF __if_test_20 (__if_ret_21) (__if_test_20) (__if_ret_19) (__if_test_18) (test1 x bar colbert a quux foo z) 
-- __if_ret_21 = PRIMITIVE 1 (__if_ret_21) (__if_test_20) (__if_ret_19) (__if_test_18) (test1 x bar colbert a quux foo z) 
-- ELSE nil (__if_ret_21) (__if_test_20) (__if_ret_19) (__if_test_18) (test1 x bar colbert a quux foo z) 
-- __if_ret_21 = PRIMITIVE 2 (__if_ret_21) (__if_test_20) (__if_ret_19) (__if_test_18) (test1 x bar colbert a quux foo z) 
-- ENDIF nil (__if_ret_21) (__if_test_20) (__if_ret_19) (__if_test_18) (test1 x bar colbert a quux foo z) 
-- __if_ret_19 = SYMBOL __if_ret_21 (__if_ret_21) (__if_test_20) (__if_ret_19) (__if_test_18) (test1 x bar colbert a quux foo z) 
-- ELSE nil (__if_ret_19) (__if_test_18) (test1 x bar colbert a quux foo z) 
-- LOCAL __if_test_22 = PRIMITIVE #f (__if_test_22) (__if_ret_19) (__if_test_18) (test1 x bar colbert a quux foo z) 
-- LOCAL __if_ret_23 = PRIMITIVE nil (__if_ret_23) (__if_test_22) (__if_ret_19) (__if_test_18) (test1 x bar colbert a quux foo z) 
-- IF __if_test_22 (__if_ret_23) (__if_test_22) (__if_ret_19) (__if_test_18) (test1 x bar colbert a quux foo z) 
-- __if_ret_23 = PRIMITIVE 3 (__if_ret_23) (__if_test_22) (__if_ret_19) (__if_test_18) (test1 x bar colbert a quux foo z) 
-- ELSE nil (__if_ret_23) (__if_test_22) (__if_ret_19) (__if_test_18) (test1 x bar colbert a quux foo z) 
-- __if_ret_23 = PRIMITIVE 4 (__if_ret_23) (__if_test_22) (__if_ret_19) (__if_test_18) (test1 x bar colbert a quux foo z) 
-- ENDIF nil (__if_ret_23) (__if_test_22) (__if_ret_19) (__if_test_18) (test1 x bar colbert a quux foo z) 
-- __if_ret_19 = SYMBOL __if_ret_23 (__if_ret_23) (__if_test_22) (__if_ret_19) (__if_test_18) (test1 x bar colbert a quux foo z) 
-- ENDIF nil (__if_ret_19) (__if_test_18) (test1 x bar colbert a quux foo z) 
-- RET SYMBOL __if_ret_19 (__if_ret_19) (__if_test_18) (test1 x bar colbert a quux foo z) 
do -- chunk start
local __MODULE = package.loaded["tests.test0"]
local __if_test_18 = true
local __if_ret_19 = nil
if __if_test_18 ~= false then
    local __if_test_20 = true
    local __if_ret_21 = nil
    if __if_test_20 ~= false then
        __if_ret_21 = 1
    else
        __if_ret_21 = 2
    end
    __if_ret_19 = __if_ret_21
else
    local __if_test_22 = false
    local __if_ret_23 = nil
    if __if_test_22 ~= false then
        __if_ret_23 = 3
    else
        __if_ret_23 = 4
    end
    __if_ret_19 = __if_ret_23
end
return __if_ret_19
end -- chunk END
----------------------------------------
-- LOCAL __let_ret_24 = PRIMITIVE nil (__let_ret_24) (test1 x bar colbert a quux foo z) 
-- VARFENCE nil (__let_ret_24) (test1 x bar colbert a quux foo z) 
-- LOCAL __let_var_25 = PRIMITIVE 1 (__let_var_25) (__let_ret_24) (test1 x bar colbert a quux foo z) 
-- LOCAL __let_var_26 = PRIMITIVE 1 (__let_var_26) (__let_var_25) (__let_ret_24) (test1 x bar colbert a quux foo z) 
-- LOCAL x = SYMBOL __let_var_25 (y x) (__let_var_26) (__let_var_25) (__let_ret_24) (test1 x bar colbert a quux foo z) 
-- LOCAL y = SYMBOL __let_var_26 (y x) (__let_var_26) (__let_var_25) (__let_ret_24) (test1 x bar colbert a quux foo z) 
-- __let_ret_24 = SYMBOL x () (y x) (__let_var_26) (__let_var_25) (__let_ret_24) (test1 x bar colbert a quux foo z) 
-- ENDVARFENCE nil (y x) (__let_var_26) (__let_var_25) (__let_ret_24) (test1 x bar colbert a quux foo z) 
-- RET SYMBOL __let_ret_24 (y x) (__let_var_26) (__let_var_25) (__let_ret_24) (test1 x bar colbert a quux foo z) 
do -- chunk start
local __MODULE = package.loaded["tests.test0"]
local __let_ret_24 = nil
do
    local __let_var_25 = 1
    local __let_var_26 = 1
    local x = __let_var_25
    local y = __let_var_26
    __let_ret_24 = x
end
return __let_ret_24
end -- chunk END
----------------------------------------
-- LOCAL __let_ret_27 = PRIMITIVE nil (__let_ret_27) (test1 x bar colbert a quux foo z) 
-- VARFENCE nil (__let_ret_27) (test1 x bar colbert a quux foo z) 
-- LOCAL __let_var_28 = PRIMITIVE 1 (__let_var_28) (__let_ret_27) (test1 x bar colbert a quux foo z) 
-- LOCAL __let_var_29 = PRIMITIVE 1 (__let_var_29) (__let_var_28) (__let_ret_27) (test1 x bar colbert a quux foo z) 
-- LOCAL x = SYMBOL __let_var_28 (y x) (__let_var_29) (__let_var_28) (__let_ret_27) (test1 x bar colbert a quux foo z) 
-- LOCAL y = SYMBOL __let_var_29 (y x) (__let_var_29) (__let_var_28) (__let_ret_27) (test1 x bar colbert a quux foo z) 
-- LOCAL ayanami = PRIMITIVE nil (ayanami) (y x) (__let_var_29) (__let_var_28) (__let_ret_27) (test1 x bar colbert a quux foo z) 
-- ayanami = PRIMITIVE "rei" (ayanami) (y x) (__let_var_29) (__let_var_28) (__let_ret_27) (test1 x bar colbert a quux foo z) 
-- __let_ret_27 = CALL foo (ayanami) (y x) (__let_var_29) (__let_var_28) (__let_ret_27) (test1 x bar colbert a quux foo z) 
-- ENDVARFENCE nil (y x) (__let_var_29) (__let_var_28) (__let_ret_27) (test1 x bar colbert a quux foo z) 
-- RET SYMBOL __let_ret_27 (y x) (__let_var_29) (__let_var_28) (__let_ret_27) (test1 x bar colbert a quux foo z) 
do -- chunk start
local __MODULE = package.loaded["tests.test0"]
local __let_ret_27 = nil
do
    local __let_var_28 = 1
    local __let_var_29 = 1
    local x = __let_var_28
    local y = __let_var_29
    local ayanami = nil
    ayanami = "rei"
    __let_ret_27 = __MODULE["foo"]()
end
return __let_ret_27
end -- chunk END
----------------------------------------
-- LOCAL __let_star_ret_30 = PRIMITIVE nil (__let_star_ret_30) (test1 x bar colbert a quux foo z) 
-- VARFENCE nil (__let_star_ret_30) (test1 x bar colbert a quux foo z) 
-- LOCAL x = PRIMITIVE 1 (x) (__let_star_ret_30) (test1 x bar colbert a quux foo z) 
-- LOCAL y = PRIMITIVE 1 (y) (x) (__let_star_ret_30) (test1 x bar colbert a quux foo z) 
-- __let_star_ret_30 = SYMBOL x () (y) (x) (__let_star_ret_30) (test1 x bar colbert a quux foo z) 
-- ENDVARFENCE nil (y) (x) (__let_star_ret_30) (test1 x bar colbert a quux foo z) 
-- RET SYMBOL __let_star_ret_30 (y) (x) (__let_star_ret_30) (test1 x bar colbert a quux foo z) 
do -- chunk start
local __MODULE = package.loaded["tests.test0"]
local __let_star_ret_30 = nil
do
    local x = 1
    local y = 1
    __let_star_ret_30 = x
end
return __let_star_ret_30
end -- chunk END
----------------------------------------
-- LOCAL __let_star_ret_31 = PRIMITIVE nil (__let_star_ret_31) (test1 x bar colbert a quux foo z) 
-- VARFENCE nil (__let_star_ret_31) (test1 x bar colbert a quux foo z) 
-- LOCAL x = PRIMITIVE 1 (x) (__let_star_ret_31) (test1 x bar colbert a quux foo z) 
-- LOCAL y = PRIMITIVE 1 (y) (x) (__let_star_ret_31) (test1 x bar colbert a quux foo z) 
-- LOCAL starcraft = PRIMITIVE nil (starcraft) (y) (x) (__let_star_ret_31) (test1 x bar colbert a quux foo z) 
-- starcraft = PRIMITIVE 2 (starcraft) (y) (x) (__let_star_ret_31) (test1 x bar colbert a quux foo z) 
-- __let_star_ret_31 = CALL foo (starcraft) (y) (x) (__let_star_ret_31) (test1 x bar colbert a quux foo z) 
-- ENDVARFENCE nil (y) (x) (__let_star_ret_31) (test1 x bar colbert a quux foo z) 
-- RET SYMBOL __let_star_ret_31 (y) (x) (__let_star_ret_31) (test1 x bar colbert a quux foo z) 
do -- chunk start
local __MODULE = package.loaded["tests.test0"]
local __let_star_ret_31 = nil
do
    local x = 1
    local y = 1
    local starcraft = nil
    starcraft = 2
    __let_star_ret_31 = __MODULE["foo"]()
end
return __let_star_ret_31
end -- chunk END
----------------------------------------
-- LOCAL __letrec_ret_32 = PRIMITIVE nil (__letrec_ret_32) (test1 x bar colbert a quux foo z) 
-- VARFENCE nil (__letrec_ret_32) (test1 x bar colbert a quux foo z) 
-- LOCAL x = PRIMITIVE nil (x) (__letrec_ret_32) (test1 x bar colbert a quux foo z) 
-- LOCAL y = PRIMITIVE nil (y) (x) (__letrec_ret_32) (test1 x bar colbert a quux foo z) 
-- x = PRIMITIVE 1 (y) (x) (__letrec_ret_32) (test1 x bar colbert a quux foo z) 
-- y = PRIMITIVE 1 (y) (x) (__letrec_ret_32) (test1 x bar colbert a quux foo z) 
-- LOCAL mitsurugi = PRIMITIVE nil (mitsurugi) (y) (x) (__letrec_ret_32) (test1 x bar colbert a quux foo z) 
-- mitsurugi = PRIMITIVE "meiya" (mitsurugi) (y) (x) (__letrec_ret_32) (test1 x bar colbert a quux foo z) 
-- __letrec_ret_32 = SYMBOL x (mitsurugi) (y) (x) (__letrec_ret_32) (test1 x bar colbert a quux foo z) 
-- ENDVARFENCE nil (y) (x) (__letrec_ret_32) (test1 x bar colbert a quux foo z) 
-- RET SYMBOL __letrec_ret_32 (y) (x) (__letrec_ret_32) (test1 x bar colbert a quux foo z) 
do -- chunk start
local __MODULE = package.loaded["tests.test0"]
local __letrec_ret_32 = nil
do
    local x = nil
    local y = nil
    x = 1
    y = 1
    local mitsurugi = nil
    mitsurugi = "meiya"
    __letrec_ret_32 = x
end
return __letrec_ret_32
end -- chunk END
----------------------------------------
-- LOCAL __letrec_ret_33 = PRIMITIVE nil (__letrec_ret_33) (test1 x bar colbert a quux foo z) 
-- VARFENCE nil (__letrec_ret_33) (test1 x bar colbert a quux foo z) 
-- LOCAL x = PRIMITIVE nil (x) (__letrec_ret_33) (test1 x bar colbert a quux foo z) 
-- LOCAL y = PRIMITIVE nil (y) (x) (__letrec_ret_33) (test1 x bar colbert a quux foo z) 
-- x = PRIMITIVE 1 (y) (x) (__letrec_ret_33) (test1 x bar colbert a quux foo z) 
-- y = PRIMITIVE 1 (y) (x) (__letrec_ret_33) (test1 x bar colbert a quux foo z) 
-- __letrec_ret_33 = CALL foo x y () (y) (x) (__letrec_ret_33) (test1 x bar colbert a quux foo z) 
-- ENDVARFENCE nil (y) (x) (__letrec_ret_33) (test1 x bar colbert a quux foo z) 
-- RET SYMBOL __letrec_ret_33 (y) (x) (__letrec_ret_33) (test1 x bar colbert a quux foo z) 
do -- chunk start
local __MODULE = package.loaded["tests.test0"]
local __letrec_ret_33 = nil
do
    local x = nil
    local y = nil
    x = 1
    y = 1
    __letrec_ret_33 = __MODULE["foo"](x, y)
end
return __letrec_ret_33
end -- chunk END
----------------------------------------
-- LOCAL __letrec_ret_34 = PRIMITIVE nil (__letrec_ret_34) (test1 x bar colbert a quux foo z) 
-- VARFENCE nil (__letrec_ret_34) (test1 x bar colbert a quux foo z) 
-- LOCAL x = PRIMITIVE nil (x) (__letrec_ret_34) (test1 x bar colbert a quux foo z) 
-- LOCAL y = PRIMITIVE nil (y) (x) (__letrec_ret_34) (test1 x bar colbert a quux foo z) 
-- x = PRIMITIVE 1 (y) (x) (__letrec_ret_34) (test1 x bar colbert a quux foo z) 
-- y = PRIMITIVE 1 (y) (x) (__letrec_ret_34) (test1 x bar colbert a quux foo z) 
-- __letrec_ret_34 = CALL foo x y () (y) (x) (__letrec_ret_34) (test1 x bar colbert a quux foo z) 
-- ENDVARFENCE nil (y) (x) (__letrec_ret_34) (test1 x bar colbert a quux foo z) 
-- RET SYMBOL __letrec_ret_34 (y) (x) (__letrec_ret_34) (test1 x bar colbert a quux foo z) 
do -- chunk start
local __MODULE = package.loaded["tests.test0"]
local __letrec_ret_34 = nil
do
    local x = nil
    local y = nil
    x = 1
    y = 1
    __letrec_ret_34 = __MODULE["foo"](x, y)
end
return __letrec_ret_34
end -- chunk END
----------------------------------------
-- LOCAL __letrec_ret_35 = PRIMITIVE nil (__letrec_ret_35) (test1 x bar colbert a quux foo z) 
-- VARFENCE nil (__letrec_ret_35) (test1 x bar colbert a quux foo z) 
-- LOCAL p = PRIMITIVE nil (p) (__letrec_ret_35) (test1 x bar colbert a quux foo z) 
-- LOCAL q = PRIMITIVE nil (q) (p) (__letrec_ret_35) (test1 x bar colbert a quux foo z) 
-- LOCAL x = PRIMITIVE nil (x) (q) (p) (__letrec_ret_35) (test1 x bar colbert a quux foo z) 
-- LOCAL y = PRIMITIVE nil (y) (x) (q) (p) (__letrec_ret_35) (test1 x bar colbert a quux foo z) 
-- p = FUNC x (x) (y) (x) (q) (p) (__letrec_ret_35) (test1 x bar colbert a quux foo z) 
-- LOCAL __call_arg_39 = CALL - x 1 (__call_arg_39) (__call_arg_36) () (x) (y) (x) (q) (p) (__letrec_ret_35) (test1 x bar colbert a quux foo z) 
-- LOCAL __call_arg_36 = CALL q __call_arg_39 (__call_arg_39) (__call_arg_36) () (x) (y) (x) (q) (p) (__letrec_ret_35) (test1 x bar colbert a quux foo z) 
-- RET CALL + 1 __call_arg_36 (__call_arg_36) () (x) (y) (x) (q) (p) (__letrec_ret_35) (test1 x bar colbert a quux foo z) 
-- ENDFUNC nil (x) (y) (x) (q) (p) (__letrec_ret_35) (test1 x bar colbert a quux foo z) 
-- q = FUNC y (y) (y) (x) (q) (p) (__letrec_ret_35) (test1 x bar colbert a quux foo z) 
-- LOCAL __if_test_37 = CALL zero? y (__if_test_37) () (y) (y) (x) (q) (p) (__letrec_ret_35) (test1 x bar colbert a quux foo z) 
-- LOCAL __if_ret_38 = PRIMITIVE nil (__if_ret_38) (__if_test_37) () (y) (y) (x) (q) (p) (__letrec_ret_35) (test1 x bar colbert a quux foo z) 
-- IF __if_test_37 (__if_ret_38) (__if_test_37) () (y) (y) (x) (q) (p) (__letrec_ret_35) (test1 x bar colbert a quux foo z) 
-- __if_ret_38 = PRIMITIVE 0 (__if_ret_38) (__if_test_37) () (y) (y) (x) (q) (p) (__letrec_ret_35) (test1 x bar colbert a quux foo z) 
-- ELSE nil (__if_ret_38) (__if_test_37) () (y) (y) (x) (q) (p) (__letrec_ret_35) (test1 x bar colbert a quux foo z) 
-- LOCAL __call_arg_41 = CALL - y 1 (__call_arg_41) (__call_arg_40) (__if_ret_38) (__if_test_37) () (y) (y) (x) (q) (p) (__letrec_ret_35) (test1 x bar colbert a quux foo z) 
-- LOCAL __call_arg_40 = CALL p __call_arg_41 (__call_arg_41) (__call_arg_40) (__if_ret_38) (__if_test_37) () (y) (y) (x) (q) (p) (__letrec_ret_35) (test1 x bar colbert a quux foo z) 
-- __if_ret_38 = CALL + 1 __call_arg_40 (__call_arg_40) (__if_ret_38) (__if_test_37) () (y) (y) (x) (q) (p) (__letrec_ret_35) (test1 x bar colbert a quux foo z) 
-- ENDIF nil (__if_ret_38) (__if_test_37) () (y) (y) (x) (q) (p) (__letrec_ret_35) (test1 x bar colbert a quux foo z) 
-- RET SYMBOL __if_ret_38 (__if_ret_38) (__if_test_37) () (y) (y) (x) (q) (p) (__letrec_ret_35) (test1 x bar colbert a quux foo z) 
-- ENDFUNC nil (y) (y) (x) (q) (p) (__letrec_ret_35) (test1 x bar colbert a quux foo z) 
-- x = CALL p 5 (y) (x) (q) (p) (__letrec_ret_35) (test1 x bar colbert a quux foo z) 
-- y = SYMBOL x (y) (x) (q) (p) (__letrec_ret_35) (test1 x bar colbert a quux foo z) 
-- __letrec_ret_35 = SYMBOL y () (y) (x) (q) (p) (__letrec_ret_35) (test1 x bar colbert a quux foo z) 
-- ENDVARFENCE nil (y) (x) (q) (p) (__letrec_ret_35) (test1 x bar colbert a quux foo z) 
-- RET SYMBOL __letrec_ret_35 (y) (x) (q) (p) (__letrec_ret_35) (test1 x bar colbert a quux foo z) 
do -- chunk start
local __MODULE = package.loaded["tests.test0"]
local __MODULE_moonscheme_DOT_base = package.loaded["moonscheme.base"]
local __letrec_ret_35 = nil
do
    local p = nil
    local q = nil
    local x = nil
    local y = nil
    p = function(x)
        local __call_arg_39 = __MODULE_moonscheme_DOT_base["-"](x, 1)
        local __call_arg_36 = q(__call_arg_39)
        return __MODULE_moonscheme_DOT_base["+"](1, __call_arg_36)
    end
    q = function(y)
        local __if_test_37 = __MODULE_moonscheme_DOT_base["zero?"](y)
        local __if_ret_38 = nil
        if __if_test_37 ~= false then
            __if_ret_38 = 0
        else
            local __call_arg_41 = __MODULE_moonscheme_DOT_base["-"](y, 1)
            local __call_arg_40 = p(__call_arg_41)
            __if_ret_38 = __MODULE_moonscheme_DOT_base["+"](1, __call_arg_40)
        end
        return __if_ret_38
    end
    x = p(5)
    y = x
    __letrec_ret_35 = y
end
return __letrec_ret_35
end -- chunk END
----------------------------------------
-- foo2 = FUNC nil () (colbert foo test1 foo2 x bar a z quux) 
-- LOCAL a = PRIMITIVE nil (y x z out sub a) () (colbert foo test1 foo2 x bar a z quux) 
-- LOCAL x = PRIMITIVE nil (y x z out sub a) () (colbert foo test1 foo2 x bar a z quux) 
-- LOCAL y = PRIMITIVE nil (y x z out sub a) () (colbert foo test1 foo2 x bar a z quux) 
-- LOCAL out = PRIMITIVE nil (y x z out sub a) () (colbert foo test1 foo2 x bar a z quux) 
-- LOCAL sub = PRIMITIVE nil (y x z out sub a) () (colbert foo test1 foo2 x bar a z quux) 
-- LOCAL z = PRIMITIVE nil (y x z out sub a) () (colbert foo test1 foo2 x bar a z quux) 
-- a = FUNC x (x) (y x z out sub a) () (colbert foo test1 foo2 x bar a z quux) 
-- RET CALL + 1 x () (x) (y x z out sub a) () (colbert foo test1 foo2 x bar a z quux) 
-- ENDFUNC nil (x) (y x z out sub a) () (colbert foo test1 foo2 x bar a z quux) 
-- x = PRIMITIVE 1 (y x z out sub a) () (colbert foo test1 foo2 x bar a z quux) 
-- y = PRIMITIVE 2 (y x z out sub a) () (colbert foo test1 foo2 x bar a z quux) 
-- out = PRIMITIVE 999 (y x z out sub a) () (colbert foo test1 foo2 x bar a z quux) 
-- sub = FUNC nil () (y x z out sub a) () (colbert foo test1 foo2 x bar a z quux) 
-- RET CALL + 200 z () () (y x z out sub a) () (colbert foo test1 foo2 x bar a z quux) 
-- ENDFUNC nil () (y x z out sub a) () (colbert foo test1 foo2 x bar a z quux) 
-- x = CALL + x 2 (y x z out sub a) () (colbert foo test1 foo2 x bar a z quux) 
-- z = PRIMITIVE 3 (y x z out sub a) () (colbert foo test1 foo2 x bar a z quux) 
-- RET CALL sub (y x z out sub a) () (colbert foo test1 foo2 x bar a z quux) 
-- ENDFUNC nil () (colbert foo test1 foo2 x bar a z quux) 
-- DEFSYM foo2 () (colbert foo test1 foo2 x bar a z quux) 
-- RET SYMBOL foo2 () (colbert foo test1 foo2 x bar a z quux) 
-- tests.test0/foo2
do -- chunk start
local __MODULE = package.loaded["tests.test0"]
local __MODULE_moonscheme_DOT_base = package.loaded["moonscheme.base"]
__MODULE["foo2"] = function()
    local a = nil
    local x = nil
    local y = nil
    local out = nil
    local sub = nil
    local z = nil
    a = function(x)
        return __MODULE_moonscheme_DOT_base["+"](1, x)
    end
    x = 1
    y = 2
    out = 999
    sub = function()
        return __MODULE_moonscheme_DOT_base["+"](200, z)
    end
    x = __MODULE_moonscheme_DOT_base["+"](x, 2)
    z = 3
    return sub()
end
__MODULE["*ENVIRONMENT*"].symbols["foo2"] = true
return __MODULE["foo2"]
end -- chunk END
----------------------------------------
-- RET CALL foo2 (test1 foo2 x bar colbert a quux foo z) 
do -- chunk start
local __MODULE = package.loaded["tests.test0"]
return __MODULE["foo2"]()
end -- chunk END
----------------------------------------
