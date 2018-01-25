local class, mixin, super = unpack(require("byui/class"))
local Log = require('kefuSystem/common/log')

local PlatformBase = nil
local PlatformBaseMeta = {}


local kLuacallEvent		= "event_call"; 		-- 原生语言调用lua 入口方法
local kcallEvent 		= "LuaEventCall"; 		-- 获得 指令值的key
local kCallResult		= "CallResult"; 		--结果标示  0 -- 成功， 1--失败,2 -- ...
local kResultPostfix	= "_result"; 			--返回结果后缀  与call_native(key) 中key 连接(key.._result)组成返回结果key
local kparmPostfix		= "_parm"; 				--参数后缀 



local DeviceType = {
	Android = 1;
	Iphone = 2;
	Ipad = 3;
	PC = 4;
}

PlatformBaseMeta._map = nil;

function PlatformBaseMeta:__init__()
	
end


function PlatformBaseMeta:removeFlashView()
end

PlatformBase = class("PlatformBase", nil, PlatformBaseMeta)
PlatformBase.DeviceType = DeviceType;
return PlatformBase