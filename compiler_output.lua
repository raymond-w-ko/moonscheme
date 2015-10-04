local __MODULE = require("moonscheme.base")
local __MOONSCHEME_BASE_MODULE = require("moonscheme.base")
__MODULE.x = 1
return __MODULE["x"]
----------------------------------------
local __MODULE = require("moonscheme.base")
local __MOONSCHEME_BASE_MODULE = require("moonscheme.base")
__MODULE.y = _G["math"]
return __MODULE["y"]
----------------------------------------
local __MODULE = require("moonscheme.base")
local __MOONSCHEME_BASE_MODULE = require("moonscheme.base")
__MODULE.z = "foobar"
return __MODULE["z"]
----------------------------------------
local __MODULE = require("moonscheme.base")
local __MOONSCHEME_BASE_MODULE = require("moonscheme.base")
__MODULE.a = __MODULE["car"]
return __MODULE["a"]
----------------------------------------
local __MODULE = require("moonscheme.base")
local __MOONSCHEME_BASE_MODULE = require("moonscheme.base")
local __data_1 = __MOONSCHEME_BASE_MODULE.read("(42 84 168)")
local __call_arg_0 = __data_1
return __MODULE["car"](__call_arg_0)
----------------------------------------
