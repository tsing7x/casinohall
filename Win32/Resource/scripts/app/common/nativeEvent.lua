-- NativeEvent.lua
-- 本地事件方法
NativeEvent = class();
local printInfo, printError = overridePrint("NativeEvent")

NativeEvent.s_platform = System.getPlatform();

NativeEvent.getInstance = function()
	if not NativeEvent.s_instance then
		NativeEvent.s_instance = new(NativeEvent);
	end
	return NativeEvent.s_instance;
end

NativeEvent.onEventCall = function()
	local callParam, json_data, resultStr = NativeEvent.getInstance():getNativeCallResult();
	-- -- 全局有效的本地方法 在此处拦截
	printInfo("java 调用 lua 方法 callParam = %s, status = %s", callParam or "null", status or -1)
	NativeEvent.getInstance():onNativeCallDone(callParam, json_data, resultStr);
end

NativeEvent.onEventPause = function()
	audio_music_pause()
	EventDispatcher.getInstance():dispatch(Event.onEventPause);--jaywillou-20160126-add-抛出pause事件
end

-- application come to foreground
-- 注意容错
NativeEvent.onEventResume = function()
	if GameSetting then
		GameSetting:setIsSecondScene(false)
	end
	audio_music_resume()
	EventDispatcher.getInstance():dispatch(Event.onEventResume);--jaywillou-20160126-add-抛出resume事件
	-- 发送心跳包测试
	if GameSocketMgr then
		GameSocketMgr:onHeartBeat()
	end
end

NativeEvent.onNativeCallDone = function(self, param, ...)
	if NativeEvent.callEventFuncMap[param] then
		NativeEvent.callEventFuncMap[param](self, ...);
	else
		EventDispatcher.getInstance():dispatch(Event.Call, param,...);
	end
end

-- 解析 call_native 返回值
NativeEvent.getNativeCallResult = function(self)
	local callParam		= dict_get_string(kLuaCallEvent, kLuaCallEvent);
	local callResult	= dict_get_int(callParam, kCallResult, -1);
	if callResult ~= 0 then -- 获取数值失败
		return callParam , nil, false;
	end
	local result = dict_get_string(callParam, callParam .. kResultPostfix);
	dict_delete(callParam);
	local json_data = json.decode_node(result);
	dump(json_data,callParam)
	return callParam, json_data, result;
end

NativeEvent.onWinKeyDown = function(key)
	-- printInfo("onWinKeyDown" .. key)
	if key == 60 or key == 81 then --Q 键返回
		EventDispatcher.getInstance():dispatch(Event.Back);
	elseif key == 55 or key == 76 then -- L键 debug
		dofile("../Resource/scripts/debug.lua")
	else
		EventDispatcher.getInstance():dispatch(Event.KeyDown,key);
	end
end

if NativeEvent.s_platform == kPlatformAndroid then
	require("app.common.nativeEvent_android")
	NativeEvent.sid = 1
end

if NativeEvent.s_platform == kPlatformIOS then
	require("app.common.nativeEvent_ios")
	NativeEvent.sid = 2
end

if NativeEvent.s_platform ~= kPlatformAndroid and NativeEvent.s_platform ~= kPlatformIOS  then
	require("app.common.nativeEvent_win32")
end

function NativeEvent:onLoadSoundResCallback(jsonData, resultStr)
	-- AlarmTip.play("resultStr =" .. resultStr)
end
function NativeEvent:onActiviyCloseCallback(jsonData, resultStr)
	WindowManager:onKeyBack();
end


function NativeEvent:onLoginFbCallback(data)
	local loginType = tonumber(data.type:get_value());
	local status = tonumber(data.status:get_value());

	if loginType ~= MyUserData:getUserType() then
		printInfo("登录方式返回不一致，忽略")
		return
	end

	-- "accessToken":"CAANthoRYTyEBANLbuZBoNQ8yf1uyX3JPjn2YTyPAU0nqKtHXdOx3cyywoDQww5ZB5sPNoCP9F2L00xiMVZBXCCOReZCsGAKxjiAFVxdj5wfUbW4NVRMQn8ucNCnVNTYbfgLggtHqvtX6PmJTZBZAgxNbPzCzabZBGnIDEcdORU5yjpd9X6q6n7MKFAiOc7h9vyLNMkQVU1GjAznBQoLAztt",
	-- "type":"1",
	-- "status":"0",
	-- "tokenExpData":"1444361262016",
	-- "siteMid":"107612419589266",
	-- "name":"Riqiang Liang"

	-- printInfo("accessToken:"..data.accessToken:get_value());

	if loginType == UserType.Facebook then
		if status == 0 then
			printInfo("login suc");
			require('app.utils.base64')
			local loginData = {
				fbUser = {
					name = data.name:get_value(),
					mnick= data.name:get_value(),
					sitemid = data.siteMid:get_value(),
					email = "",
					pic = ""
				},
				access_token = data.accessToken:get_value(),
				sig_sitemid = base64.encode(string.format(data.siteMid:get_value()..'_gamehallboyaa')),
			}
			--强制FACEBOOK
			MyUserData:setUserType(UserType.Facebook);
			EventDispatcher.getInstance():dispatch(Event.Message, "loginFbSuccess", loginData);
		else
			AlarmTip.play(data.error:get_value() or "login error");
		end

	end
	printInfo("login status = " .. status);
end

--邀请FACEBOOK好友回调
function NativeEvent:onSendInvitesCallback(jsonData)
	if jsonData and jsonData.toIds and jsonData.toIds:get_value() and MyUserData then
		NativeEvent.getInstance():boyaaAd({type = kADInvite or 10, value = MyUserData:getId()})
		local hasInviteIds = jsonData.toIds:get_value();
		local ids = {}
		for id in string.gmatch(hasInviteIds, '%d+') do
			table.insert(ids, id);
		end
		local leftNum = MyUserData:getLeftInviteNum() - #ids
		if leftNum < 0 then
			leftNum = 0
		end
		MyUserData:setLeftInviteNum(leftNum)

		JLog.d("NativeEvent:onSendInvitesCallback", jsonData)
		HttpModule.getInstance():execute(HttpModule.s_cmds.GET_FB_INVITE_AWARD, {arrFriends=ids}, false, true);

		local toStr = jsonData.to:get_value();

		local to = {}
		for id in string.gmatch(toStr, '[^,]+') do
			table.insert(to, id);
		end
		local inviteFriend = MyUserData:getInviteFriend();
		local invitableFriend = {}
		invitableFriend.status = 0
		local strInvites = ""
		local hasInvite = {}
		if inviteFriend then
			for i = 1, #inviteFriend do
				local flag = false
				for j = 1, #to do
					if tostring(inviteFriend[i].id) == tostring(to[j]) then
						table.insert(hasInvite, inviteFriend[i].urlMd5)

						strInvites = strInvites..(inviteFriend[i].urlMd5)..","
						flag = true
						break;
					end
				end
				if not flag then
					table.insert(invitableFriend, inviteFriend[i])
				end
			end
		end
		GameSetting:setInviteIdGuest(GameSetting:getInviteIdGuest()..strInvites)
		GameSetting:save()
		MyUserData:setInviteFriend(invitableFriend)
		EventDispatcher.getInstance():dispatch(Event.Message, kGetFbFriend)
	end

end

function NativeEvent:onSendRecallsCallback(jsonData)
	--召回消息发送成功，抛出Event.Message
	EventDispatcher.getInstance():dispatch(Event.Message, "sendFBRecallSuccess")
end
--分享回调
function NativeEvent:onShareCallback(jsonData)
	if jsonData and jsonData.shareData then
		local result = jsonData.shareData:get_value()
		if result == "-1" then
			AlarmTip.play(STR_SHARE_FAILED)
		elseif result == "0" then
			AlarmTip.play(STR_SHARE_CANCEL)
		elseif result == "1" then
			NativeEvent.getInstance():boyaaAd({type = kADShare or 9, value = MyUserData:getId()})
			HttpModule.getInstance():execute(HttpModule.s_cmds.FRONTSTATISTICS, {reportData =  {{id= 'shareSucc'}}}, false, true)
			AlarmTip.play(STR_SHARE_SUCCESS)
			local from = jsonData.from and jsonData.from:get_value() or ""
			--分享是来自活动中心
			if from == "activity" then
				HttpModule.getInstance():execute(HttpModule.s_cmds.SEND_ACTIVITY_SHARE_STATISTIC, {}, false, false)
			elseif from == "honourEmblem" then
			elseif from == "newPlayer" then
				local expand = jsonData.expand and tonumber(jsonData.expand:get_value())
				-- print_string("zyh expand is "..tostring(expand))
				if expand then
					HttpModule.getInstance():execute(HttpModule.s_cmds.ACT_NEW_PLATER_TASK_DONE, {tid = expand}, false, false)
				end
			end
		end
	end
end

--个推回调
function NativeEvent:onPostClientId(jsonData)
	if jsonData and jsonData.clientId and MyUserData and MyUserData:getId() then
		local result = jsonData.clientId:get_value()
		if result ~= nil then
			HttpModule.getInstance():execute(HttpModule.s_cmds.POST_CLIENTID, {mid = MyUserData:getId(), token = result}, false, true)
		end
	end
end

--评分
function NativeEvent:onScoreCallback(jsonData)

end

function NativeEvent:onGetFbAppCallback(jsonData)
	printInfo("onGetFbAppCallback")
	if jsonData and jsonData.length and jsonData.length:get_value() and MyUserData then
		local len  = jsonData.length:get_value() or 0;
		local jdata= jsonData.dataArrStr:get_value();
		local data = json.decode(jdata);
		--zyh 只给第一个用户发奖励
		if data[1] and data[1].data then
			-- print_string("zyh onGetFbAppCallback data[1].data "..tostring(data[1].data))
			HttpModule.getInstance():execute(HttpModule.s_cmds.GET_FB_INVITE_SUC_AWARD, {fid=data[1].data or 0}, false, true);
		end
	end

end

function NativeEvent:onDownloadFileCallback(jsonData)
	printInfo('kDownloadFile finish');
	EventDispatcher.getInstance():dispatch(Event.Call, kDownloadUpdate, jsonData);
end

function NativeEvent:onUnzipCallback(jsonData)
	EventDispatcher.getInstance():dispatch(Event.Call, kUnzip, jsonData);

end
function NativeEvent:onUnzipGameCallback(jsonData)
	-- printInfo('kUnzipGame finish');
	-- printInfo("status = " .. jsonData.status:get_value() or "")
	-- printInfo("file = " .. jsonData.file:get_value() or "")

	local status = tonumber(jsonData.status:get_value()) or 0
	if status == 1 then
		AlarmTip.play(string.format("解压成功"))
	else
		AlarmTip.play(string.format("解压失败"))
	end
end


function NativeEvent:onUploadImageCallBack(result)
	-- JLog.d("NativeEvent:onUploadImageCallBack.result :================", result)
	if result then
		if result.iconname then
			-- printInfo("result.iconname.value :" .. result.iconname:get_value())

			HttpModule.getInstance():execute(HttpModule.s_cmds.UPDATE_USER_ICON,{iconname = result.iconname:get_value()}, false, false)
		end
		if result.code:get_value() == 1 then
			AlarmTip.play(STR_UPLOAD_SUCC)
		else
			AlarmTip.play(STR_UPLOAD_HEADER_ERROR)
		end
	else
		AlarmTip.play(STR_SVAE_HEARD_ERROR)
	end
end

function NativeEvent:onUploadHeadImageCallBack(result)

	local sid = tonumber(PhpManager:getGame())

	if result then
		local isSucc = result.isSucc and result.isSucc:get_value() or "false"
		local dResult = result.result and result.result:get_value() or ""
		local dResultJsonObj = json.decode(dResult)

		if dResultJsonObj and dResultJsonObj.iconname then
			if result.iconname then
				HttpModule.getInstance():execute(HttpModule.s_cmds.UPDATE_USER_ICON,{iconname = (result.iconname:get_value() or dResultJsonObj.iconname), sid = sid}, false, false)
			end

		end

		if (isSucc == "true") and dResultJsonObj and dResultJsonObj.code == 1 then
			AlarmTip.play(STR_UPLOAD_SUCC);
		else
			AlarmTip.play(STR_UPLOAD_HEADER_ERROR)
		end
	else
		AlarmTip.play(STR_SVAE_HEARD_ERROR);
	end
end

function NativeEvent:onRenameImageCallBack(result)
	if result and tonumber(result.status:get_value() or 0) == 1 and MyUserData and MyUserData:getId() > 0 then
		url = result.url:get_value();
		MyUserData:setHeadUrl(url);
	end
end

function NativeEvent:onGetFbFriendCallback(result, origin)
	-- print_string("onGetFbFriendCallback result "..tostring(result))
	-- JLog.d("NativeEvent:onGetFbFriendCallback", result, origin)
	if MyUserData then
		local invitableFriend = MyUserData:getInviteFriend() or {}
		invitableFriend.status = 1
		local status = tonumber(result.status and result.status:get_value() or 0)
		if status == 0 and MyUserData then
			invitableFriend.status = 0
			local str = GameSetting:getInviteIdGuest()
			local hasInviteIds = {}
			local hasInviteNum = 0
			for id in string.gmatch(str, "(.-),") do
				hasInviteIds[id] = true
				hasInviteNum = hasInviteNum + 1
			end
			local data = result
			for i = 1, #data do
				local url = data[i].picture.data.url:get_value() or ""
				local strUrlMd5 = md5_string(url)
				if not hasInviteIds[strUrlMd5] then
					local facebookFriend = setProxy(new(require("app.data.facebookFriend")));
					facebookFriend:setId(data[i].id:get_value())
					facebookFriend:setNickname(data[i].first_name:get_value() or data[i].name:get_value())
					facebookFriend:setMoney(HallConfig:getInvitemoney() or 1000)
					facebookFriend:setHeadUrl(data[i].picture.data.url:get_value())
					facebookFriend:setUrlMd5(strUrlMd5)
					-- facebookFriend:setSex(1)
					table.insert(invitableFriend, facebookFriend)
				end
			end
			MyUserData:setInviteFriend(invitableFriend)
		end
		EventDispatcher.getInstance():dispatch(Event.Message, kGetFbFriend);
	end
end

function NativeEvent:onPayCallback(result)
	-- JLog.d("NativeEvent:onPayCallback", result)
	MyPay:paycb(result);
end

function NativeEvent:onActivityCallback(result)
	-- printInfo('onActivityCallback')
end
function NativeEvent:onAndroidE2PayBack(result)

	local code = tonumber(result.code:get_value())
	local content = ""
	if code == 404 then
		content = STR_PAY_JMTSMS_NOCARD
		--content = "没SIM卡"
	elseif code == 100 then
		content = STR_PAY_SUC
	else
		content = STR_PAY_FAILED
		--上报支付失败记录
		local errorLog = "E2PpayFail "..tostring(code)
		--        HttpModule.getInstance():execute(HttpModule.s_cmds.REPORT_DEBUG_INFO, {log = errorLog})
	end

	WindowManager:showWindow(
		WindowTag.LobbyConfirmPopu,
		{
			title = (content == STR_PAY_FAILED) and "ERROR: "..tostring(code) or nil,
			content = content,
			confirm = STR_EXIT_GAME_CONFIRM,
		},
		WindowStyle.POPUP
	)


end
function NativeEvent:onGetOneTwoCallPinNoCallBack(result)

	local pmode = tonumber(result.pmode:get_value())
	if pmode == 621 then
		local params = {
			pmode = tostring(result.pmode:get_value()),
			mid = tostring(result.mid:get_value()),
			channel = result.channel:get_value(),
			id =  tostring(result.id:get_value()),--商品ID
			sitemid =  result.sitemid:get_value(),
			pin_no = result.pinNo:get_value(),
			sid =  PhpManager:getGame(),
			lid = '',
		}
		HttpModule.getInstance():execute(HttpModule.s_cmds.GET_PAY_ORDER,params,true, true);
	elseif pmode == 623 then
		local params = {
			pmode = tostring(result.pmode:get_value()),
			username = tostring(result.username:get_value()),
			channel = result.channel:get_value(),
			id =  tostring(result.id:get_value()),--商品ID
			sitemid =  result.sitemid:get_value(),
			pin_no = result.pinNo:get_value(),
			sid =  PhpManager:getGame(),
			lid = '',
		}
		HttpModule.getInstance():execute(HttpModule.s_cmds.GET_PAY_ORDER,params,true, true);
	end

	print('onGetOneTwoCallPinNoCallBack')
end

function NativeEvent:onDownloadApkCallBack(result)
	local status = tonumber(result.status:get_value())
	local url = result.url:get_value()
	print_string("zyh onDownloadApkCallBack "..tostring(status).." url  "..tostring(url))
	--开始下载
	if status == 0 then
		--下载中
	elseif status == 1 then
		local progress = tonumber(result.progress:get_value())
		print_string("zyh downloadApk progress is "..tostring(progress))
		if progress then
			MyApkUpdateInfo:setUpdateProgress(progress)
		end
		--暂停
	elseif status == 2 then

		--下载完成
	elseif status == 3 then
		local fileName = result.fileName:get_value()
		print_string("zyh onDownloadApkCallBack fileName is "..tostring(fileName))
		local version = MyApkUpdateInfo.updateVer or ""
		WindowManager:showWindow(
			WindowTag.LobbyConfirmPopu,
			{
				content = string.format(STR_UPDATE_FINISH_INSTALL, version),
				confirm = STR_UPDATE_INSTALL,
				confirmFunc = function()
					NativeEvent.getInstance():installUpdateApk({fileName = fileName})
				end
			},
			WindowStyle.POPUP
		)
		--下载失败
	elseif status == 4 then
		WindowManager:showWindow(
			WindowTag.LobbyConfirmPopu,
			{
				content = STR_UPDATE_FAIL,
				confirm = STR_EXIT_GAME_CONFIRM,
			},
			WindowStyle.POPUP
		)
	end
end

function NativeEvent:onPhotoCallBack(result)
	-- JLog.d("NativeEvent:onPhotoCallBack.result :================", result)
	if result and result.name then
		local imgName = result.name:get_value()

		-- printInfo("imgName :" .. imgName)
		self:uploadImage(MyUserData:getUrls().updateicon, imgName)
	end
end

function NativeEvent:onCameraPermissionDenied(result)
end

NativeEvent.callEventFuncMap = {
	["login"]                = NativeEvent.onLoginFbCallback,
	["LoadSoundRes"]				 = NativeEvent.onLoadSoundResCallback,
	["ActivityClose"]				 = NativeEvent.onActiviyCloseCallback,
	["sendInvites"]          = NativeEvent.onSendInvitesCallback,
	["sendRecalls"]          = NativeEvent.onSendRecallsCallback,
	["getFbAppInfo"]         = NativeEvent.onGetFbAppCallback,
	["shareResult"]          = NativeEvent.onShareCallback,
	["postClientId"]         = NativeEvent.onPostClientId,
	[kDownloadFile]          = NativeEvent.onDownloadFileCallback,
	[kUnzip]                 = NativeEvent.onUnzipCallback,
	[kUnzipGame]             = NativeEvent.onUnzipGameCallback,
	[kUploadImage]           = NativeEvent.onUploadImageCallBack,
	[kRenameImage]           = NativeEvent.onRenameImageCallBack,
	[kGetFbFriend]           = NativeEvent.onGetFbFriendCallback,
	[kPay]                   = NativeEvent.onPayCallback,
	[kScore]                 = NativeEvent.onScoreCallback,
	[kActivity]              = NativeEvent.onActivityCallback,
	["uploadHeadImage"]      = NativeEvent.onUploadHeadImageCallBack,
	["oneTwoCallOrder"]      = NativeEvent.onGetOneTwoCallPinNoCallBack,
	["Android_E2PayBack"]    = NativeEvent.onAndroidE2PayBack,
	["downloadApk"]          = NativeEvent.onDownloadApkCallBack,
	[kTakePhoto]			 = NativeEvent.onPhotoCallBack,
	[kPickPhoto]			 = NativeEvent.onPhotoCallBack,
	["cameraPermissionDenied"] = NativeEvent.onCameraPermissionDenied,
}
