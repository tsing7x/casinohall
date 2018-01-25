require('core/object');
require('core/dict');
require('app.common/toolKit');
require('libs/json_wrap');

local Update = class()

function Update:ctor()
	-- body
	EventDispatcher.getInstance():register(Event.Call, self, self.onNativeCallBack);
	self.mCallback = {}
	self.mTag 	   = 0
	self.mImgQueue = {}  --图片下载队列，保持串行下载
	self.mImgQueueId = 0 --图片下载任务ID，每加一个任务就递增
	self.mIsImgDownloading  = false
end

function Update:dtor()
	-- body
	EventDispatcher.getInstance():unregister(Event.Call, self, self.onNativeCallBack);
end

function Update:update(verUrl, zipUrl, verPath)
	-- body
	--先下载配置文件
	local curVer = require(not verPath and 'version' or string.format('%s.%s', verPath, 'version'))
	local url = string.format('%s%s.lua', verUrl, curVer)
	app:staticstics('download:'..url)

	local file
	local basePath
	local folder

	local s_platform = System.getPlatform()
	if s_platform == kPlatformIOS  then
		basePath = "/update/"
		folder = "scripts/"
		file = "verconf.lua"

	else
		file = "scripts/verconf.lua"
	end


	self:download("update", url, file, self, function (self, jsonData)
									-- body
									local status = tonumber(jsonData.status:get_value()) or 0
									--下载完成
									if status == 1 then
										app:staticstics('done:'..url)
										local path 	= jsonData.path:get_value()

										local basePath = jsonData.basePath:get_value()
										local folder = jsonData.folder:get_value()
										local file = jsonData.file

										--- 兼容IOS 和 安卓 写了这段，有空统一下

										basePath = basePath or ""
										folder = folder or ""

										if not path then
											path = basePath .. folder .. file
										end

										-- dump(jsonData," downloadfile")


										if path then
											local fileName = string.match(path, "/(.+).lua")
											if fileName then
												--return{ver=105;size=3727;patchMd5="fe52ca1b9dd04531c435de1dc682f9de";newApkMd5="08a8489dd3beba89c72ab288eceeba5a";type=0;url="";info={[1]="";};};
												local verconf 	= require(fileName);
												local updateVer = verconf.ver
												--如果需要更新
												if tonumber(curVer) < tonumber(updateVer) then
													local file 		= string.format('update_%s_%s.zip', curVer, updateVer)
													local url 		= string.format('%s%s', zipUrl, file);
													app:staticstics('download:'..url)
													MyUpdate:download("updatezip", url, file, self, function (self, jsonData)
																							local status 	= tonumber(jsonData.status:get_value()) or 0
																							if status == 1 then
																								app:staticstics('done:'..url)
																								AlarmTip.play(STR_UPDATE_TIP);
																							end
													end)
												end
											end
										end
									end
																					 end,basePath,folder)
end

function Update:download(type, url, saveFile, obj, callback,basePath,folder)
	-- body
	for k, v in pairs(self.mCallback) do
		--正在下载
		if v.url == url then 
			self.mCallback[k] = {obj = obj, callback = callback, url = url}
			return true 
		end
	end
	self.mTag = self.mTag + 1
	local tag = 't'..tostring(self.mTag)
	self.mCallback[tag] = {obj = obj, callback = callback, url = url,basePath = basePath,folder = folder}
	NativeEvent.getInstance():downloadFile(type, url, saveFile, tag,basePath,folder);
	if callback then
		callback(obj, json.decode_node(json.encode({status = 2, progress = 0})))
	end
end

function Update:downloadImage(url, folder, name, callback)
	--并行下载的时候http返回405错误，方法不存在，目前不知原因，脚本控制串行下载，不依赖于线程池的串行方法
	self.mImgQueueId = self.mImgQueueId + 1
	local imgTask = {
		id = self.mImgQueueId,
		url = url,
		folder = folder,
		name = name
	}
	self.mImgQueue[self.mImgQueueId] = {downloadParam = imgTask, callbackFunc = callback}
	if not self.mIsImgDownloading then
		self.mIsImgDownloading = true
		NativeEvent.getInstance():downloadImage(imgTask)
	end
end

--native callback
function Update:OnDownloadUpdate(jsonData)
	local status 	= tonumber(jsonData.status:get_value()) or 0
	local tag 	 	= jsonData.tag:get_value() or ""

	local callback = self.mCallback[tag]
	if callback and callback.callback then
		callback.callback(callback.obj, jsonData)
	end
	--下载完成或下载失败
	if status == 1 or status == 0 then
		self.mCallback[tag] = nil
	end
end

function Update:onDownloadImage(jsonData)
	local stat 		= jsonData.stat:get_value()
	-- print("zyh onDownloadImage stat "..tostring(stat))
	local folder 	= jsonData.folder:get_value()
	local name 		= jsonData.name:get_value()
	local id 		= tonumber(jsonData.id:get_value())
	local callback = self.mImgQueue[id] and self.mImgQueue[id].callbackFunc
	if callback then
		callback(stat, folder, name);
	end
	self.mIsImgDownloading = false
	if id then
		self.mImgQueue[id] = nil

		local nextTask = self.mImgQueue[id + 1]
		if nextTask then
			local task = nextTask.downloadParam
			self.mIsImgDownloading = true
			NativeEvent.getInstance():downloadImage(task)
		end
	end
end

function Update:onNativeCallBack(key, jsonData)
	if Update.callEventFuncMap[key] then
		Update.callEventFuncMap[key](self, jsonData)
	end
end

Update.callEventFuncMap = {
	[kDownloadUpdate]   =   Update.OnDownloadUpdate,
	[kDownloadImage]    =   Update.onDownloadImage,
}

return Update
