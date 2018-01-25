require('core/object');
require('core/dict');
require('app.common/toolKit');
require('libs/json_wrap');

local Zip = class()

function Zip:ctor()
	-- body
	EventDispatcher.getInstance():register(Event.Call, self, self.onNativeCallBack);
	self.mCallback = {}
	self.mTag 	   = 0
end

function Zip:dtor()
	-- body
	EventDispatcher.getInstance():unregister(Event.Call, self, self.onNativeCallBack);
end

function Zip:unzip(type, file, unzipPath, obj, callback)
	-- body
	self.mTag = self.mTag + 1
	local tag = 't'..tostring(self.mTag)
	self.mCallback[tag] = {obj = obj, callback = callback}
	NativeEvent.getInstance():unzip(type, unzipPath, file, tag);
end

--native callback
function Zip:onNativeCallBack(key, jsonData)
	if key == kUnzip then

		local status 	= tonumber(jsonData.status:get_value()) or 0
		local tag 	 	= jsonData.tag:get_value() or ""

		local callback = self.mCallback[tag]
		if callback and callback.callback then
			callback.callback(callback.obj, jsonData)
		end
		--解压完成或解压失败
		if status == 1 or status == 0 then
			self.mCallback[tag] = nil
		end
	end
end

return Zip