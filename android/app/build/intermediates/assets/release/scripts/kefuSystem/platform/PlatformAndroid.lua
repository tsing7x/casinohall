local class, mixin, super = unpack(require("byui/class"))
local Log = require('kefuSystem/common/log')
local PlatformBase = require("kefuSystem/platform.PlatformBase")

local PlatformAndroid = nil
local PlatformAndroidMeta = {}


local classPath = 'com/boyaa/customerservice/LuaCallManager';

function PlatformAndroidMeta:__init__()
	super(PlatformAndroid, self).__init__(self)
end

function PlatformAndroidMeta:RequestGallery(savePath,cb)
    local args = {function(ret)
        Clock.instance():schedule_once(function (  )
            Log.d('RequestGallery RequestGallery ' ,ret)
            if cb then
                cb(ret)
            end
        end)
        return 1
    end,
    savePath,}
    Log.v("PlatformAndroidMeta:RequestGallery()")
    local success, result = LuaBridge.instance():call_java(classPath, "RequestGallery",'(ILjava/lang/String;)V', args);
    Log.d("PlatformAndroidMeta:RequestGallery()", success, result)
end

function PlatformAndroidMeta:RequestCapture(savePath,cb)
    local args = {function(ret)
        Clock.instance():schedule_once(function (  )
            Log.d('RequestCapture RequestCapture ' ,ret)
            if cb then
                cb(ret)
            end
        end)
        
        return 1
    end,
    savePath,}
    Log.v("PlatformAndroidMeta:RequestCapture()")
    local success, result = LuaBridge.instance():call_java(classPath, "RequestCapture",'(ILjava/lang/String;)V', args);
    Log.d("PlatformAndroidMeta:RequestCapture()", success, result)
end

function PlatformAndroidMeta:canRecord()
    local success, result = LuaBridge.instance():call_java(classPath, "canRecord",'()Z', {});
    Log.d("PlatformAndroidMeta:canRecord()", success, result)
end

function PlatformAndroidMeta:getIP()
    local success, result = LuaBridge.instance():call_java(classPath, "getIP",'()Ljava/lang/String;', {});
    if not success then
        result = "android ip unkown"
    end
    Log.d("PlatformAndroidMeta:getIP()", success, result)
    return result
end

function PlatformAndroidMeta:getConnectivity()
    local connectivity = {"wifi","2G","3G","4G"}
    local success, result = LuaBridge.instance():call_java(classPath, "getConnectivity",'()I', {});
    if not success then
        result = "android Connectivity unkown"
    else
        if connectivity[result] then
            result = connectivity[result]
        else
            result = "android Connectivity unkown"
        end
    end
    Log.d("PlatformAndroidMeta:getConnectivity()", success, result)
    return result
end

function PlatformAndroidMeta:getMacAddress()
    local success, result = LuaBridge.instance():call_java(classPath, "getMacAddress",'()Ljava/lang/String;', {});
    if not success then
        result = "android mac unkown"
    end
    Log.d("PlatformAndroidMeta:getMacAddress()", success, result)
    return result
end

function PlatformAndroidMeta:getDeviceDetail()
    local success, result = LuaBridge.instance():call_java(classPath, "getDeviceDetail",'()Ljava/lang/String;', {});
    if not success then
        result = "android DeviceDetail unkown"
    end
    Log.d("PlatformAndroidMeta:getDeviceDetail()", success, result)
    return result
end


function PlatformAndroidMeta:getOSVersion()
    local success, result = LuaBridge.instance():call_java(classPath, "getOSVersion",'()Ljava/lang/String;', {});
    if not success then
        result = "android OSVersion unkown"
    end
    Log.d("PlatformAndroidMeta:getOSVersion()", success, result)
    return result
end


PlatformAndroid = class("PlatformAndroid", PlatformBase, PlatformAndroidMeta)
return PlatformAndroid