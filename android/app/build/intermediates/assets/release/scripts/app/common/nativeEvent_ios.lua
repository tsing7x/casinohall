-- 公共call_native 方法
NativeEvent.callNativeEvent = function(self, keyParm, data)
	if data then
		dict_set_string(keyParm, keyParm .. kparmPostfix, data);
	end
	dict_set_string(kLuaCallEvent, kLuaCallEvent, keyParm);
	call_native("OnLuaCall");
end

-- 立即返回结果的的操作
NativeEvent.encodeStr = function(self, str)
	-- local key = "encodeStr"
	-- self:callNativeEvent(key, str)
	--    return dict_get_string(key, key .. kResultPostfix);
	return str
end

NativeEvent.isFileExist = function(self, filePath, fileFolder)
	--ios
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
	self:callNativeEvent(key)
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
NativeEvent.takePhoto = function(self, name,folder,basePath,imgName,tag)
	self:callNativeEvent(kTakePhoto, json.encode({name = name,folder = folder,basePath = basePath,tag = tag,imgName = imgName}));
end

--选择图片
NativeEvent.pickPhoto = function(self, name,folder,basePath,imgName,tag)

	self:callNativeEvent(kPickPhoto, json.encode({name = name,folder = folder,basePath = basePath,tag = tag,imgName = imgName}));
end

NativeEvent.chooseFeedBackImg = function(self)
	-- body
	self:callNativeEvent(KChooseFeedBackImg)
end

--上传图片
NativeEvent.uploadImage = function(self, url, uploadImageName, doType)
	local api = PhpManager:getAPI();
	api['do'] = doType;
	api['sid'] = 102;
	api['time'] = os.time()
	api['sig'] = md5_string(MyUserData:getId() .. '|' .. api['sid'] .. '|' .. api['time'] .. '~#kevin&^$xie$&boyaa')
	api['upload'] = uploadImageName
	local sid = api['sid']
	local time = api['time']
	local sig = api['sig']
	local upload = api['upload']
	self:callNativeEvent(kUploadImage, json.encode({url = url, sid = sid, mid = MyUserData:getId(), time = time, sig = sig, upload = upload, uploadImageName = uploadImageName, api = api, ['type'] = 0}));
end

-- 上传头像
NativeEvent.uploadHeadImage = function(self,url,imageName,doType,basePath,folder)
	basePath = basePath or ""
	folder = folder or ""

	local api = PhpManager:getAPI();
	api['do'] = doType;
	api['sid'] = 102;
	api['time'] = os.time()
	api['sig'] = md5_string(MyUserData:getId() .. '|' .. api['sid'] .. '|' .. api['time'] .. '~#kevin&^$xie$&boyaa')
	api['upload'] = imageName

	local sid = api['sid']
	local time = api['time']
	local sig = api['sig']
	local upload = api['upload']

	self:callNativeEvent("uploadHeadImage", json.encode({url = url, sid = sid, mid = MyUserData:getId(), time = time, sig = sig, upload = upload, imgName = imageName, api = api, ['type'] = 0,basePath = basePath,folder = folder,fileKey = "upload"}));

end

--上传图片
NativeEvent.uploadFeedbackImage = function(self, url, imgName, api,basePath,folder)
	api = json.encode(api)
	self:callNativeEvent(kUploadFeedbackImage, json.encode({url = url, imgName = imgName, api = api,basePath = basePath,folder = folder,fileKey = "pfile"}));
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
	local appid = {
		["501"] = "1091505360",
		["505"] = "670832349",
		["506"] = "1116009488",
		["508"] = "1125314410",
	}
	--		local appid = "1091505360"  -- 骰子大厅appstore应用ID
	local url = string.format("itms-apps://itunes.apple.com/us/app/id%s?mt=8",appid[PhpManager:getGame()] or "1091505360")
	self:callNativeEvent(kOpenLink, json.encode({url = url}));
end

NativeEvent.boyaaAd = function(self, param)
	self:callNativeEvent('boyaaAd', json.encode(param))
end

--注销
NativeEvent.logout = function(self, param)
	-- 包装登录方式
	if MyUserData:getUserType() == UserType.Facebook then
		param = param or {}
		table.merge(param, { loginType = MyUserData:getUserType() })
		self:callNativeEvent(kLogout, json.encode(param));
	end
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
NativeEvent.downloadFile = function(self, type, url, file, tag,basePath,folder)
	printInfo("开始下载文件")
	-- print(debug.traceback("", 2))
	local param = {
		file	= file,
		type	= type,
		url		= url,
		tag		= tag,
	};
	if basePath then
		param.basePath = basePath
	end

	if folder then
		param.folder = folder
	end
	self:callNativeEvent(kDownloadFile , json.encode(param));
end

--解压文件
--type: 'image' or 'audio'
NativeEvent.unzip = function(self, type, path, file, tag)
	-- print(debug.traceback("", 2))
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

NativeEvent.IosPayResultCallback = function(self,orderId)
	self:callNativeEvent("IosPayResultCallback",orderId)
end

NativeEvent.checkUnfinishIAP = function(self)
	dump("checkUnfinishIAP=====")
	self:callNativeEvent("checkUnfinishIAP","")
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

--IOS打开活动中心
NativeEvent.openActivity = function(self, param)
	local activityParam = {
		mid		= MyUserData:getId(),
		version = PhpManager:getVersionName(),
		sid     = PhpManager:getGame(),
		appId		= ACTIVITY_APPID,
		sitemid = string.format(PhpManager:getDevice_id()..'_gamehallboyaa'),
		userType= MyUserData:getUserType(),
		secret_key = ACTIVITY_SECRET_KEY,
		url = LOCAL_NET and "http://actcenter.ifere.com/operating/web/index.php" or "http://mvlptldc.boyaagame.com",
		language = 1,   --0中文 1泰语 2印尼
		isReleated = param and param.isReleated or -1,
		channelID = "",
	}
	self:callNativeEvent(kActivity, json.encode(activityParam));
end

NativeEvent.hideEditTextView = function(self)
	self:callNativeEvent("hideEditTextView");
end

NativeEvent.shareToMessenger = function(self, param)
end

NativeEvent.isMessengerExist = function(self)
	return 0
end
--获取启动方式，默认0是点击图标启动，1是从fb messenger启动，用于统计启动方式
NativeEvent.getStartWay = function(self)
	local key = "getStartWay"
	self:callNativeEvent(key)
	return dict_get_string(key, key..kResultPostfix)
end
NativeEvent.getAllUpdateFile = function(self, param)
	return ""
end
NativeEvent.getNetworkType = function(self)
	return 0;
end

NativeEvent.backupScripts = function(self)
	return 1
end
NativeEvent.updateGameFinish = function(self)
	return 0
end
NativeEvent.deleteFile = function(self, param)
end
NativeEvent.getLocation = function(self)
	return ""
end
NativeEvent.getFileMD5 = function(self, param)
	return ""
end
NativeEvent.getPermission = function(self, param)
	return "success"
end
NativeEvent.getSystemVersion = function(self)
	local key = "getSystemVersion"
	self:callNativeEvent(key)
	return dict_get_string(key, key..kResultPostfix)
end
