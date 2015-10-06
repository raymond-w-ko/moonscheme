-- moonscheme.base/x
local __MODULE = require("moonscheme.base")
local __MOONSCHEME_BASE_MODULE = require("moonscheme.base")
__MODULE["x"] = 1
return __MODULE["x"]
----------------------------------------
-- moonscheme.base/z
local __MODULE = require("moonscheme.base")
local __MOONSCHEME_BASE_MODULE = require("moonscheme.base")
__MODULE["z"] = "foobar"
return __MODULE["z"]
----------------------------------------
-- moonscheme.base/a
local __MODULE = require("moonscheme.base")
local __MOONSCHEME_BASE_MODULE = require("moonscheme.base")
__MODULE["a"] = __MODULE["car"]
return __MODULE["a"]
----------------------------------------
local __MODULE = require("moonscheme.base")
local __MOONSCHEME_BASE_MODULE = require("moonscheme.base")
local __data_1 = __MOONSCHEME_BASE_MODULE.read("(42 84 168)")
local __call_arg_0 = __data_1
return __MODULE["car"](__call_arg_0)
----------------------------------------
local __MODULE = require("moonscheme.base")
local __MOONSCHEME_BASE_MODULE = require("moonscheme.base")
return function()
    return 42
end
----------------------------------------
local __MODULE = require("moonscheme.base")
local __MOONSCHEME_BASE_MODULE = require("moonscheme.base")
return function(x)
    return __MODULE["car"](x)
end
----------------------------------------
local __MODULE = require("moonscheme.base")
local __MOONSCHEME_BASE_MODULE = require("moonscheme.base")
return function(x, y, z)
    return __MODULE["car"](y)
end
----------------------------------------
local __MODULE = require("moonscheme.base")
local __MOONSCHEME_BASE_MODULE = require("moonscheme.base")
return function(x, y, z, ...)
    local w = __MOONSCHEME_BASE_MODULE.to_scheme_list(table.pack(...))
    __MODULE["write"](x)
    return __MODULE["write"](w)
end
----------------------------------------
-- moonscheme.base/foo
local __MODULE = require("moonscheme.base")
local __MOONSCHEME_BASE_MODULE = require("moonscheme.base")
__MODULE["foo"] = function(x, y)
    return 42
end
return __MODULE["foo"]
----------------------------------------
-- moonscheme.base/bar
local __MODULE = require("moonscheme.base")
local __MOONSCHEME_BASE_MODULE = require("moonscheme.base")
__MODULE["bar"] = function(x)
    return _G["assert"](false)
end
return __MODULE["bar"]
----------------------------------------
-- moonscheme.base/quux
local __MODULE = require("moonscheme.base")
local __MOONSCHEME_BASE_MODULE = require("moonscheme.base")
__MODULE["quux"] = function()
    return _G["assert"](false)
end
return __MODULE["quux"]
----------------------------------------
-- moonscheme.base/colbert
local __MODULE = require("moonscheme.base")
local __MOONSCHEME_BASE_MODULE = require("moonscheme.base")
__MODULE["colbert"] = function(...)
    local stewart = __MOONSCHEME_BASE_MODULE.to_scheme_list(table.pack(...))
    return __MODULE["write"](stewart)
end
return __MODULE["colbert"]
----------------------------------------
-- moonscheme.base/test1
local __MODULE = require("moonscheme.base")
local __MOONSCHEME_BASE_MODULE = require("moonscheme.base")
__MODULE["test1"] = function(arg0, arg1, ...)
    local stewart = __MOONSCHEME_BASE_MODULE.to_scheme_list(table.pack(...))
    __MODULE["write"](stewart)
    local __call_arg_2 = __MODULE["car"](stewart)
    return __MODULE["test1"](__call_arg_2)
end
return __MODULE["test1"]
----------------------------------------
local __MODULE = require("moonscheme.base")
local __MOONSCHEME_BASE_MODULE = require("moonscheme.base")
return __MODULE["colbert"](1, 2, 3)
----------------------------------------
local __MODULE = require("moonscheme.base")
local __MOONSCHEME_BASE_MODULE = require("moonscheme.base")
local __if_test_3 = true
local __if_ret_4 = nil
if __if_test_3 ~= false then
    __if_ret_4 = 1
end
return __if_ret_4
----------------------------------------
local __MODULE = require("moonscheme.base")
local __MOONSCHEME_BASE_MODULE = require("moonscheme.base")
local __if_test_5 = false
local __if_ret_6 = nil
if __if_test_5 ~= false then
    __if_ret_6 = 1
end
return __if_ret_6
----------------------------------------
local __MODULE = require("moonscheme.base")
local __MOONSCHEME_BASE_MODULE = require("moonscheme.base")
local __if_test_7 = true
local __if_ret_8 = nil
if __if_test_7 ~= false then
    __if_ret_8 = 1
else
    __if_ret_8 = 2
end
return __if_ret_8
----------------------------------------
local __MODULE = require("moonscheme.base")
local __MOONSCHEME_BASE_MODULE = require("moonscheme.base")
local __if_test_9 = false
local __if_ret_10 = nil
if __if_test_9 ~= false then
    __if_ret_10 = 1
else
    __if_ret_10 = 2
end
return __if_ret_10
----------------------------------------
local __MODULE = require("moonscheme.base")
local __MOONSCHEME_BASE_MODULE = require("moonscheme.base")
local __if_test_11 = nil
local __if_ret_12 = nil
if __if_test_11 ~= false then
    __if_ret_12 = "yes, nil is true!"
else
    __if_ret_12 = 2
end
return __if_ret_12
----------------------------------------
local __MODULE = require("moonscheme.base")
local __MOONSCHEME_BASE_MODULE = require("moonscheme.base")
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
----------------------------------------
local __MODULE = require("moonscheme.base")
local __MOONSCHEME_BASE_MODULE = require("moonscheme.base")
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
----------------------------------------
local __MODULE = require("moonscheme.base")
local __MOONSCHEME_BASE_MODULE = require("moonscheme.base")
local __let_ret_24 = nil
do
    local __let_var_25 = 1
    local __let_var_26 = 1
    local x = __let_var_25
    local y = __let_var_26
    __let_ret_24 = x
end
return __let_ret_24
----------------------------------------
local __MODULE = require("moonscheme.base")
local __MOONSCHEME_BASE_MODULE = require("moonscheme.base")
local __let_ret_27 = nil
do
    local __let_var_28 = 1
    local __let_var_29 = 1
    local x = __let_var_28
    local y = __let_var_29
    __let_ret_27 = __MODULE["foo"]()
end
return __let_ret_27
----------------------------------------
local __MODULE = require("moonscheme.base")
local __MOONSCHEME_BASE_MODULE = require("moonscheme.base")
local __let_ret_30 = nil
do
    local x = 1
    local y = 1
    __let_ret_30 = x
end
return __let_ret_30
----------------------------------------
local __MODULE = require("moonscheme.base")
local __MOONSCHEME_BASE_MODULE = require("moonscheme.base")
local __let_ret_31 = nil
do
    local x = 1
    local y = 1
    __let_ret_31 = __MODULE["foo"]()
end
return __let_ret_31
----------------------------------------
local __MODULE = require("moonscheme.base")
local __MOONSCHEME_BASE_MODULE = require("moonscheme.base")
local __let_ret_32 = nil
do
    local x = nil
    local y = nil
    x = 1
    y = 1
    __let_ret_32 = x
end
return __let_ret_32
----------------------------------------
local __MODULE = require("moonscheme.base")
local __MOONSCHEME_BASE_MODULE = require("moonscheme.base")
local __let_ret_33 = nil
do
    local x = nil
    local y = nil
    x = 1
    y = 1
    __let_ret_33 = __MODULE["foo"](x, y)
end
return __let_ret_33
----------------------------------------
local __MODULE = require("moonscheme.base")
local __MOONSCHEME_BASE_MODULE = require("moonscheme.base")
local __let_ret_34 = nil
do
    local x = nil
    local y = nil
    x = 1
    y = 1
    __let_ret_34 = __MODULE["foo"](x, y)
end
return __let_ret_34
----------------------------------------
local __MODULE = require("moonscheme.base")
local __MOONSCHEME_BASE_MODULE = require("moonscheme.base")
local __let_ret_35 = nil
do
    local p = nil
    local q = nil
    local x = nil
    local y = nil
    p = function(x)
        local __call_arg_39 = _G["-"](x, 1)
        local __call_arg_36 = q(__call_arg_39)
        return _G["+"](1, __call_arg_36)
    end
    q = function(y)
        local __if_test_37 = _G["zero?"](y)
        local __if_ret_38 = nil
        if __if_test_37 ~= false then
            __if_ret_38 = 0
        else
            local __call_arg_41 = _G["-"](y, 1)
            local __call_arg_40 = p(__call_arg_41)
            __if_ret_38 = _G["+"](1, __call_arg_40)
        end
        return __if_ret_38
    end
    x = p(5)
    y = x
    __let_ret_35 = y
end
return __let_ret_35
----------------------------------------
