-- NativeEvent.lua
-- 本地事件方法

local NativeEvent = {}
NativeEvent.s_luaCallNavite = "OnLuaCall";
NativeEvent.s_luaCallEvent = "LuaCallEvent";
NativeEvent.s_platform = System.getPlatform();

local kcallEvent = "LuaEventCall"; -- 获得 指令值的key
local kCallResult="CallResult"; --结果标示  0 -- 成功， 1--失败,2 -- ...
local kResultPostfix="_result"; --返回结果后缀  与call_native(key) 中key 连接(key.._result)组成返回结果key
local kparmPostfix="_parm"; --参数后缀 



-- 解析 call_native 返回值
NativeEvent.getNativeCallResult = function()
	local callParam = dict_get_string(kcallEvent,kcallEvent);
	local callResult = dict_get_int(callParam, kCallResult,-1);

    if callResult == 1 then -- 获取数值失败
        return callParam , false;
    end
    local result = dict_get_string(callParam , callParam .. kResultPostfix);
    
    local json_data = {};
    if result and type(result) == "string" and result == "onWindowFocusChanged" then
    	json_data.onWindowFocusChanged = "onWindowFocusChanged";
    else
	    json_data = cjson.decode(result);
	end

    --返回错误json格式.
    if json_data then
        return callParam ,true, json_data;
    else
        return callParam , true;
    end

    dict_delete(callParam);
end

--/////////////////////////////// android //////////////////////////////////

if NativeEvent.s_platform == kPlatformAndroid or NativeEvent.s_platform == kPlatformIOS then
	-- 公共call_native 方法
	local callNativeEvent = function(keyParm , data)
		if data then
			dict_set_string(keyParm,keyParm..kparmPostfix,data);
		end
		dict_set_string(NativeEvent.s_luaCallEvent,NativeEvent.s_luaCallEvent,keyParm);
		call_native(NativeEvent.s_luaCallNavite);
	end

	
	--请求图库
	NativeEvent.RequestGallery = function(data)
		callNativeEvent("RequestGallery",data);
	end

	--拍照
	NativeEvent.RequestCapture = function(data)
		callNativeEvent("RequestCapture",data);
	end

    --录音权限
	NativeEvent.canRecord = function()
        if NativeEvent.s_platform == kPlatformIOS then
            callNativeEvent("canRecord");
        end
	end

end

--///////////////////////////////// Win32 ////////////////////////////////

if NativeEvent.s_platform == kPlatformWin32 then
	--请求图库
	NativeEvent.RequestGallery = function(self,data)

	end

	--拍照
	NativeEvent.RequestCapture = function(self)

	end

    --录音权限
	NativeEvent.canRecord = function(self)

	end

end

return NativeEvent

