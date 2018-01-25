-- 公共call_native 方法
NativeEvent.callNativeEvent = function(self, keyParm, data)
	-- JLog.d("NativeEvent.callNativeEvent(keyParm :" .. keyParm .. ").data :================", data)

	if data then
		dict_set_string(keyParm, keyParm .. kparmPostfix, data)
	end
	dict_set_string(kLuaCallEvent, kLuaCallEvent, keyParm)
	call_native("OnLuaCall")
end

-- 立即返回结果的的操作
NativeEvent.encodeStr = function(self, str)
	-- local key = "encodeStr"
	-- self:callNativeEvent(key, str)
	--		return dict_get_string(key, key .. kResultPostfix);
	return str
end

NativeEvent.isFileExist = function(self, filePath, fileFolder)
	local key = "isFileExist"
	local tab = {}
	tab.path = filePath
	tab.folder = fileFolder
	self:callNativeEvent(key, json.encode(tab))
	return dict_get_int(key, key .. kResultPostfix, 0)
end

-- 涉及ui的操作 放在消息队列中执行
--延时释放 defualt png , 解决 Android 游戏启动时屏幕黑一下的问题
NativeEvent.CloseStartScreen = function(self)
	local key = "CloseStartScreen"
	self:callNativeEvent(key)
end

NativeEvent.GetInitValue =function(self)
	local key = "GetInitValue"
	self:callNativeEvent(key,json.encode())
	return dict_get_string(key, key.."_result");
end

NativeEvent.GetNetAvaliable = function(self)
	local key = "GetNetAvaliable"
	self:callNativeEvent(key)
	return dict_get_int(key, key..kResultPostfix, 0);
end

NativeEvent.PreloadAllSound = function(self, musicsMap, effectsMap)
	local key = "LoadSoundRes"
	local tab={};
	tab.bgMusic = musicsMap;
	tab.soundRes = effectsMap;
	self:callNativeEvent(key, json.encode(tab))
end

NativeEvent.ReportLuaError = function(self, faultInfo)
	local key = "ReportLuaError"
	local tab = {};
	tab.faultInfo = faultInfo;
	local json_data = json.encode(tab);
	self:callNativeEvent(key, json_data);
end

NativeEvent.Exit = function(self)
	local key = "Exit"
	self:callNativeEvent(key)
end

-- 拍照
NativeEvent.takePhoto = function(self, userId)
	self:callNativeEvent(kTakePhoto, json.encode({name = tostring(userId)}))
end

--选择图片
NativeEvent.pickPhoto = function(self, userId)
	self:callNativeEvent(kPickPhoto, json.encode({name = tostring(userId)}))
end

NativeEvent.chooseFeedBackImg = function(self)
	-- body
	self:callNativeEvent(KChooseFeedBackImg, json.encode({name = "feedback"}))
end

--上传图片
NativeEvent.uploadImage = function(self, url, uploadImageName, doType)
	printInfo("NativeEvent.uploadImage.url :" .. url)
	local api = PhpManager:getAPI()
	api['do'] = doType
	api['sid'] = PhpManager:getGame()
	api['time'] = os.time()
	api['sig'] = md5_string(MyUserData:getId() .. '|' .. api['sid'] .. '|' .. api['time'] .. '~#kevin&^$xie$&boyaa')
	api['upload'] = uploadImageName
	local sid = api['sid']
	local time = api['time']
	local sig = api['sig']
	local upload = api['upload']
	self:callNativeEvent(kUploadImage, json.encode({url = url, sid = sid, mid = MyUserData:getId(), time = time, sig = sig, upload = upload, uploadImageName = uploadImageName, api = api, ['type'] = 0}))
end

--上传图片
NativeEvent.uploadFeedbackImage = function(self, url, uploadImageName, api)
	self:callNativeEvent(kUploadFeedbackImage, json.encode({url = url, uploadImageName = uploadImageName, api = api, ['type'] = 1}));
end
--打开粉丝页
NativeEvent.openLink = function(self, url)
	self:callNativeEvent(kOpenLink, json.encode({url = url}));
end


--打开第三方登录
NativeEvent.login = function(self, param)
	-- 包装登录方式
	param = param or {}
	table.merge(param, { loginType = MyUserData:getUserType() })
	self:callNativeEvent(kLogin, json.encode(param));
	--
	-- NativeEvent.getInstance():login();
end

--分享
NativeEvent.share = function(self, param)
	self:callNativeEvent(kShare, json.encode(param))
end

--获取clientId
NativeEvent.getClientId = function(self, param)
	self:callNativeEvent(kClientId, json.encode(param))
end


--评分
NativeEvent.score = function(self, param)
	self:callNativeEvent(kScore, json.encode(param))
end

NativeEvent.boyaaAd = function(self, param)
	self:callNativeEvent('boyaaAd', json.encode(param))
end

--注销
NativeEvent.logout = function(self, param)
	-- 包装登录方式
	param = param or {}
	table.merge(param, { loginType = MyUserData:getUserType() })
	self:callNativeEvent(kLogout, json.encode(param));
end

--获取Facebook好友
NativeEvent.getFbFriend = function(self, param)
	self:callNativeEvent(kGetFbFriend, "");
end
--获取Facebook 信息
NativeEvent.getFbAppInfo = function(self, param)
	self:callNativeEvent('getFbAppInfo', "");
end

--邀请好友
NativeEvent.inviteFbFriend = function(self, param)
	self:callNativeEvent(kInviteFbFriend, json.encode(param));
end
--邀请短信好友
NativeEvent.inviteSmsFriend = function(self, param)
	self:callNativeEvent(kInviteSmsFriend, json.encode(param));
end

NativeEvent.downloadImage = function(self, param)
	self:callNativeEvent(kDownloadImage , json.encode(param));
end

--重命名图片
NativeEvent.renameImage = function(self, oldName, newName, url)

	local param = {
		oldName = oldName,
		newName = newName,
		url		= url;
	};

	self:callNativeEvent(kRenameImage , json.encode(param));
end

--下载文件
--type: 'image' or 'audio'
NativeEvent.downloadFile = function(self, type, url, file, tag)
	-- printInfo("开始下载文件")
	local param = {
		file	= file,
		type	= type,
		url		= url,
		tag		= tag,
	};

	self:callNativeEvent(kDownloadFile , json.encode(param));
end

--解压文件
--type: 'image' or 'audio'
NativeEvent.unzip = function(self, type, path, file, tag)

	local param = {
		file	= file,
		type	= type,
		path	= path,
		tag		= tag,
	};

	self:callNativeEvent(kUnzip , json.encode(param));
end

--解压游戏
NativeEvent.unzipGame = function(self, file)

	local param = {
		file	= file
	};

	self:callNativeEvent(kUnzipGame , json.encode(param));
end

--支付
NativeEvent.pay = function(self, param)
	self:callNativeEvent(kPay, json.encode(param));
end
--友盟统计
NativeEvent.collectByUmeng = function(self, param)
	self:callNativeEvent(kCollectByUmeng, json.encode(param));
end
--推广
NativeEvent.loadAdData = function(self, userId, isShowAd)
	self:callNativeEvent(kLoadAdData, json.encode({userId = userId, isShowAd = isShowAd}))
end
NativeEvent.showAd = function(self, isFloat)
	self:callNativeEvent(kShowAd, json.encode({isFloat = isFloat}))
end

--获取Facebook好友
--打开活动中心
NativeEvent.openActivity = function(self, param)
	local activityParam =
		{mid	= MyUserData:getId(),
		 version = PhpManager:getVersionName(),
		 sid	= PhpManager:getGame(),
		 appId	= ACTIVITY_APPID,
		 sitemid = string.format(PhpManager:getDevice_id()..'_gamehallboyaa'),
		 userType= MyUserData:getUserType(),
		 secret_key = ACTIVITY_SECRET_KEY,
		 url = LOCAL_NET and "http://actcenter.ifere.com/operating/web/index.php" or "http://mvlptldc.boyaagame.com",
		 debug = LOCAL_NET and 1 or 0,
		 language = 1,   --0中文 1泰语 2印尼
		 isReleated = param and param.isReleated or -1, -- -1是默认的，打开活动中心，0、1、2是打开强推界面，对应小中大窗口, -2是1280*720比例的满屏强推
		 channelID = "" --目前我们不需要这个参数来区分，但是sdk里必须要传
		}
	self:callNativeEvent(kActivity, json.encode(activityParam))
end

NativeEvent.hideEditTextView = function(self)
	self:callNativeEvent("hideEditTextView");
end

NativeEvent.shareToMessenger = function(self, param)
	self:callNativeEvent(kShareToMessenger, json.encode(param));
end

NativeEvent.isMessengerExist = function(self)
	local key = "isMessengerExist"
	self:callNativeEvent(key);
	return dict_get_int(key, key .. kResultPostfix, 0)
end
--获取启动方式，默认0是点击图标启动，1是从fb messenger启动，用于统计启动方式
NativeEvent.getStartWay = function(self)
	local key = "getStartWay"
	self:callNativeEvent(key)
	return dict_get_string(key, key..kResultPostfix)
end

NativeEvent.getAllUpdateFile = function(self, param)
	local key = "getAllUpdateFile"
	self:callNativeEvent(key)
	return dict_get_string(key, key..kResultPostfix)
end

NativeEvent.getNetworkType = function(self)
	local key = "getNetworkType"
	self:callNativeEvent(key)
	return dict_get_int(key, key..kResultPostfix, 0)
end

NativeEvent.backupScripts = function(self)
	local key = "backupScripts"
	self:callNativeEvent(key)
	return dict_get_int(key, key..kResultPostfix, 0)
end
NativeEvent.updateGameFinish = function(self, param)
	local key = "updateGameFinish"
	self:callNativeEvent(key, json.encode(param))
	return dict_get_int(key, key..kResultPostfix, 0)
end
NativeEvent.deleteFile = function(self, param)
	local key = "deleteFile"
	self:callNativeEvent(key, json.encode(param))
end
NativeEvent.getLocation = function(self)
	local key = "getLocation"
	self:callNativeEvent(key)
	return dict_get_string(key, key..kResultPostfix)
end
NativeEvent.checkUnfinishIAP = function(self)
	self:callNativeEvent("checkUnfinishIAP")
end
NativeEvent.consumeProduct = function(self, productId)
	local key = "consumeProduct"
	self:callNativeEvent(key, json.encode({productId = productId}))
end
NativeEvent.getFileMD5 = function(self, param)
	local key = "getFileMD5"
	self:callNativeEvent(key, json.encode(param))
	return dict_get_string(key, key..kResultPostfix)
end
NativeEvent.getPermission = function(self, param)
	local key = "getPermission"
	self:callNativeEvent(key, json.encode(param))
	return dict_get_string(key, key..kResultPostfix)
end
NativeEvent.downloadUpdateApk = function(self, param)
	print_string("NativeEvent.downloadUpdateApk ")
	self:callNativeEvent("downloadUpdateApk", json.encode(param))
end
NativeEvent.pauseDownloadUpdateApk = function(self, param)
	self:callNativeEvent("pauseDownloadUpdateApk",json.encode(param));
end
NativeEvent.installUpdateApk = function(self, param)
	self:callNativeEvent("installUpdateApk",json.encode(param));
end
NativeEvent.queryDownloadProgress = function(self, param)
	local key = "queryDownloadProgress"
	self:callNativeEvent(key,json.encode(param))
	return dict_get_int(key, key..kResultPostfix, 0)
end
NativeEvent.queryDownloadStatus = function(self, param)
	local key = "queryDownloadStatus"
	self:callNativeEvent(key,json.encode(param))
	return dict_get_int(key, key..kResultPostfix, 0)
end
NativeEvent.deleteDownloadTask = function(self, param)
	local key = "deleteDownloadTask"
	self:callNativeEvent(key,json.encode(param))
	return dict_get_int(key, key..kResultPostfix, 1)
end
NativeEvent.getSystemVersion = function(self, param)
	local key = "getSystemVersion"
	self:callNativeEvent(key)
	return dict_get_string(key, key..kResultPostfix)
end
