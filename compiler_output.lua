do -- chunk start
local __MODULE = package.loaded["tests.test0"]
return nil
end -- chunk END
----------------------------------------
-- tests.test0/x
do -- chunk start
local __MODULE = package.loaded["tests.test0"]
__MODULE["x"] = 1
__MODULE["*ENVIRONMENT*"].symbols["x"] = true
return __MODULE["x"]
end -- chunk END
----------------------------------------
-- tests.test0/z
do -- chunk start
local __MODULE = package.loaded["tests.test0"]
__MODULE["z"] = "foobar"
__MODULE["*ENVIRONMENT*"].symbols["z"] = true
return __MODULE["z"]
end -- chunk END
----------------------------------------
-- tests.test0/a
do -- chunk start
local __MODULE = package.loaded["tests.test0"]
local __MODULE_moonscheme_DOT_base = package.loaded["moonscheme.base"]
__MODULE["a"] = __MODULE_moonscheme_DOT_base["car"]
__MODULE["*ENVIRONMENT*"].symbols["a"] = true
return __MODULE["a"]
end -- chunk END
----------------------------------------
do -- chunk start
local __MODULE = package.loaded["tests.test0"]
local __MODULE_moonscheme_DOT_base = package.loaded["moonscheme.base"]
local __data_1 = __MODULE_moonscheme_DOT_base.read("(42 84 168)")
local __call_arg_0 = __data_1
return __MODULE_moonscheme_DOT_base["car"](__call_arg_0)
end -- chunk END
----------------------------------------
do -- chunk start
local __MODULE = package.loaded["tests.test0"]
return function()
    return 42
end
end -- chunk END
----------------------------------------
do -- chunk start
local __MODULE = package.loaded["tests.test0"]
local __MODULE_moonscheme_DOT_base = package.loaded["moonscheme.base"]
return function(x)
    return __MODULE_moonscheme_DOT_base["car"](x)
end
end -- chunk END
----------------------------------------
do -- chunk start
local __MODULE = package.loaded["tests.test0"]
local __MODULE_moonscheme_DOT_base = package.loaded["moonscheme.base"]
return function(x, y, z)
    return __MODULE_moonscheme_DOT_base["car"](y)
end
end -- chunk END
----------------------------------------
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
do -- chunk start
local __MODULE = package.loaded["tests.test0"]
return __MODULE["colbert"](1, 2, 3)
end -- chunk END
----------------------------------------
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
do -- chunk start
local __MODULE = package.loaded["tests.test0"]
local __let_ret_27 = nil
do
    local __let_var_28 = 1
    local __let_var_29 = 1
    local x = __let_var_28
    local y = __let_var_29
    __let_ret_27 = __MODULE["foo"]()
end
return __let_ret_27
end -- chunk END
----------------------------------------
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
do -- chunk start
local __MODULE = package.loaded["tests.test0"]
local __let_star_ret_31 = nil
do
    local x = 1
    local y = 1
    __let_star_ret_31 = __MODULE["foo"]()
end
return __let_star_ret_31
end -- chunk END
----------------------------------------
do -- chunk start
local __MODULE = package.loaded["tests.test0"]
local __letrec_ret_32 = nil
do
    local x = nil
    local y = nil
    x = 1
    y = 1
    __letrec_ret_32 = x
end
return __letrec_ret_32
end -- chunk END
----------------------------------------
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
