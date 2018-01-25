--
--  平台（win32、ios、adnroid ）相关信息的封装 
--
local Log = require('kefuSystem/common/log')

local curPlatform = System.getPlatform();
local PlatformCls = nil

if curPlatform == kPlatformWin32 then
	PlatformCls = require("kefuSystem/platform.PlatformWin")
elseif curPlatform == kPlatformAndroid then
	PlatformCls = require("kefuSystem/platform.PlatformAndroid")
elseif curPlatform == kPlatformIOS then
	PlatformCls = require("kefuSystem/platform.PlatformIOS")
else
	log.e("unknown platform", curPlatform)
end

local platform = {}
local s_instance = nil

function platform.getInstance()
	if s_instance == nil then
		s_instance = PlatformCls()
	end

	return s_instance
end

return platform