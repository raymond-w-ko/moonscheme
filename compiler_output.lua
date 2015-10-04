local __MODULE = require("moonscheme.base")
local __MOONSCHEME_BASE_MODULE = require("moonscheme.base")
__MODULE.x = 1
----------------------------------------
local __MODULE = require("moonscheme.base")
local __MOONSCHEME_BASE_MODULE = require("moonscheme.base")
__MODULE.y = _G["math"]
----------------------------------------
local __MODULE = require("moonscheme.base")
local __MOONSCHEME_BASE_MODULE = require("moonscheme.base")
__MODULE.z = "foobar"
----------------------------------------
local __MODULE = require("moonscheme.base")
local __MOONSCHEME_BASE_MODULE = require("moonscheme.base")
__MODULE.a = __MODULE["car"]
----------------------------------------
local __MODULE = require("moonscheme.base")
local __MOONSCHEME_BASE_MODULE = require("moonscheme.base")
local __data_1 = __MOONSCHEME_BASE_MODULE.read("(42 84 168)")
local __call_arg_0 = __data_1
__MODULE["car"](__call_arg_0)
----------------------------------------
