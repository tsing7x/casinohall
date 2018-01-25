local class, mixin, super = unpack(require("byui/class"))
local Log = require('kefuSystem/common/log')
local PlatformBase = require("kefuSystem/platform.PlatformBase")

local kClassName = "KeFuLuaEvent"

local PlatformIOS = nil
local PlatformIOSMeta = {}


function PlatformIOSMeta:__init__()
	super(PlatformIOS, self).__init__(self)
end

function PlatformIOSMeta:RequestGallery(savePath,cb)
    local args = {
	    callback = function(ret)
	        Clock.instance():schedule_once(function (  )
	            Log.d('PlatformIOSMeta RequestGallery ' ,ret)
	            if cb then
	                cb(ret)
	            end
	        end)
	        
	        return 1
	    end;
	    savePath = savePath;
	}
    Log.v("PlatformIOSMeta:RequestGallery()")
    local success, result = LuaBridge.instance():call_objc(kClassName, "RequestGallery", args);
    Log.d("PlatformIOSMeta:RequestGallery()", success, result)
end

function PlatformIOSMeta:RequestCapture(savePath,cb)
    local args = {
	    callback = function(ret)
	        Clock.instance():schedule_once(function (  )
	            Log.d('PlatformIOSMeta RequestCapture ' ,ret)
	            if cb then
	                cb(ret)
	            end
	        end)
	        
	        return 1
	    end;
	    savePath = savePath;
	}
    Log.v("PlatformIOSMeta:RequestCapture()")
    local success, result = LuaBridge.instance():call_objc(kClassName, "RequestCapture", args);
    Log.d("PlatformIOSMeta:RequestCapture()", success, result)
end

function PlatformIOSMeta:canRecord(cb)
	local args = {
	    callback = function(ret)
	        Clock.instance():schedule_once(function (  )
	            Log.d('PlatformIOSMeta canRecord ' ,ret)
	            if cb then
	                cb(ret)
	            end
	        end)
	        
	        return 1
	    end;
	}
    local success, result = LuaBridge.instance():call_objc(kClassName, "canRecord", args);
    Log.d("PlatformIOSMeta:canRecord()", success, result)
end

function PlatformIOSMeta:getIP()
    local success, result = LuaBridge.instance():call_objc(kClassName, "getIP", {});
    if not success then
        result = "ios ip unkown"
    end
    Log.d("PlatformIOSMeta:getIP()", success, result)
    return result
end

function PlatformIOSMeta:getConnectivity()
    local connectivity = {"wifi","2G","3G","4G"}
    local success, result = LuaBridge.instance():call_objc(kClassName, "getConnectivity", {});
    if not success then
        result = "ios Connectivity unkown"
    else
        if connectivity[result] then
            result = connectivity[result]
        else
            result = "ios Connectivity unkown"
        end
    end
    Log.d("PlatformIOSMeta:getConnectivity()", success, result)
    return result
end

function PlatformIOSMeta:getMacAddress()
    local success, result = LuaBridge.instance():call_objc(kClassName, "getMacAddress", {});
    if not success then
        result = "ios mac unkown"
    end
    Log.d("PlatformIOSMeta:getMacAddress()", success, result)
    return result
end

function PlatformIOSMeta:getDeviceDetail()
    local success, result = LuaBridge.instance():call_objc(kClassName, "getDeviceDetail", {});
    if not success then
        result = "ios DeviceDetail unkown"
    end
    Log.d("PlatformIOSMeta:getDeviceDetail()", success, result)
    return result
end


function PlatformIOSMeta:getOSVersion()
    local success, result = LuaBridge.instance():call_objc(kClassName, "getOSVersion", {});
    if not success then
        result = "ios OSVersion unkown"
    end
    Log.d("PlatformIOSMeta:getOSVersion()", success, result)
    return result
end

PlatformIOS = class("PlatformIOS", PlatformBase, PlatformIOSMeta)
return PlatformIOS
