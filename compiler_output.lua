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
