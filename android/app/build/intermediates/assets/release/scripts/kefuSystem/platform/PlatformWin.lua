local class, mixin, super = unpack(require("byui/class"))
local Log = require('kefuSystem/common/log')
local PlatformBase = require("kefuSystem/platform.PlatformBase")

local PlatformWin = nil
local PlatformWinMeta = {}

function PlatformWinMeta:__init__()
	super(PlatformWin, self).__init__(self)
end


function PlatformWinMeta:getDeviceType()
	return PlatformBase.DeviceType.Android;
end

function PlatformWinMeta:getIP()
    return "windows ip unkown"
end
function PlatformWinMeta:getConnectivity()
    return "windows Connectivity unkown"
end
function PlatformWinMeta:getMacAddress()
    return "windows Mac unkown"
end
function PlatformWinMeta:getDeviceDetail()
    return "windows Device unkown"
end
function PlatformWinMeta:getOSVersion()
    return "windows OS unkown"
end

function PlatformWinMeta:RequestGallery(savePath,cb)
    
end

function PlatformWinMeta:RequestCapture(savePath,cb)
    
end

function PlatformWinMeta:canRecord()
    
end



PlatformWin = class("PlatformWin", PlatformBase, PlatformWinMeta)
return PlatformWin