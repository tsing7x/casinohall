-- 各种子平台的基类，子平台需继承该类，覆盖有区别的方法即可
local BasePlatform = class();
local printInfo, printError = overridePrint("BasePlatform")

function BasePlatform:ctor()
	self._name = "BasePlatform"
	self._loginType = UserType.Visitor  -- 默认登录方式
end

function BasePlatform:getName()
	return self._name
end
-- 登录
function BasePlatform:requestLoginPhp(mergeParams)
	--登录PHP
	require('app.utils.base64')
    local sesskey = UserType.Facebook == MyUserData:getUserType() and GameSetting:getSesskey() or ""
	local param_post = {
		mac				= PhpManager:getMac(),
		sig_sitemid		= base64.encode(string.format(PhpManager:getDevice_id()..'_gamehallboyaa')),
		machineType		= PhpManager:getModelName(),
		net				= PhpManager:getNet(),
							simOperatorName = PhpManager:getNet(),
		apkVer			= PhpManager:getVersionName(),
		pixel				= PhpManager:getRat(),
		imei			= PhpManager:getDevice_id(),
                            sesskey         = sesskey,
						};

	table.merge(param_post, mergeParams or {});
    -- writeTabToLog({mergeParams=mergeParams or "nil"},"登录login","debug_common.lua",2)
    writeTabToLog({},"登录login","debug_socket.lua",2)
    writeTabToLog({},"登录login","debug_http.lua",2)
	HttpModule.getInstance():execute(HttpModule.s_cmds.LOGIN_PHP, param_post, false, true);
end

-- 手机登录逻辑较多 独立出来
function BasePlatform:requestPhoneLogin()
	local loginData = GameConfig:getLastLoginData()
	if loginData then
		local param = {
	    	['phoneno'] 	= loginData.username,
	    	['pwd'] 		= loginData.password,
	    	['verifycode'] 	= loginData.verifycode,
	    	['act'] 		= loginData.act,
	    };
	    self:requestLoginPhp(param)
	else
		local loginData = ToolKit.getDict("TelLoginPopu", {'remebered', 'username','password'});
		if loginData.username ~= "" and loginData.password ~= "" then
			local param = {
		    	['phoneno'] 	= loginData.username,
		    	['pwd'] 		= loginData.password,
		    };
		    self:requestLoginPhp(param)
		else
			self:requestLoginPhp()
		end
	end
end

function BasePlatform:startSceneInit()
	GameConfig      = GameConfig 		or new(require("app.data.gameConfig"))
	GameConfig:load()

	MyUserData 		= MyUserData 		or setProxy(new(require("app.data.userData")))
	MyUpdateData 	= MyUpdateData 		or 	new(require("app.data.updateData"));

	MyNoticeData 	    = MyNoticeData 		or 	new(require("app.data.noticeData"));
	MyPayData 		    = MyPayData 		or 	new(require("app.data.shopData"));

	MyBaseInfoData      = MyBaseInfoData  or  setProxy(new(require("app.data.baseInfoData")))

	--初始化全局socket
	GameSocketMgr = GameSocketMgr or new(require("app.mjSocket.base.socketMgr"), kGameSocket, PROTOCOL_TYPE_QE, 1)

	LoginMethod   = LoginMethod   or new(require("app.common.loginMethod"))

	WindowManager 	= WindowManager 	or new(require("app.manager.windowManager"))

	HallConfig 	  	= HallConfig		or new(require("app.data.hallConfig"))
	HallConfig:load()

	G_RoomCfg 		= G_RoomCfg or setProxy(new(require("app.room.utils.roomConfig")))

	GameSetting		= GameSetting 		or setProxy(new(require("app.data.gameSetting")))
	GameSetting:load()

   	-- kMusicPlayer:setVolume(GameSetting:getMusicVolume())
   	-- kEffectPlayer:setVolume(GameSetting:getSoundVolume())

	--本地更新
	MyUpdate 	= MyUpdate 	or 	new(require("app.update.update"));

	--支付方式
	MyPayMode 	= MyPayMode or nil;
	MyPay 		= MyPay or new(require('app.pay.pay'))

	--房间配置
	MyRoomConfig = MyRoomConfig or new(require('app.data.roomConfig'))

    --全局开关控制列表
    MySwitchData        = MySwitchData or setProxy(new(require("app.data.allSwitchData")))

	--全局的跑马灯消息队列
	MySpeakerQueue      = MySpeakerQueue or new(require("app.manager.speakerQueue"))
	StateChange.changeState(States.Login)
end

function BasePlatform:requestChargeList(isLogin)
	-- 注意先后 先初始化配置 再拉取商品列表
	UnitePay.getInstance():requestChargeConfig(isLogin)
	UnitePay.getInstance():requestChargeList(isLogin)
end

-- isLuoMaFirst 为是否优先选裸码
-- 由于联运版本的存在 所以默认 [[不开启]]
-- 由主版本覆盖该方法 让isLuoMaFirst生效
function BasePlatform:selectPayWay(goodsInfo, isLuoMaFirst, sceneChargeData)
	local bundleData = {
		goodsInfo 		= goodsInfo,
		sceneChargeData = sceneChargeData
	}
	UnitePay.getInstance():autoSelectPay(bundleData, isLuoMaFirst)
end

function BasePlatform:autoLoginAdapter(data)
	MyUserData:setUserType(self._loginType)
	NativeEvent.getInstance():login(data)
end

-- 走第三方的登录方式都会回调到这里来 在进行数据加工 登录php
-- 默认直接登录 如需要修改 则在子类中覆盖
function BasePlatform:loginCallbackAdapter(loginType, data)
	self:requestLoginPhp(data)
end

-- 登录适配
function BasePlatform:loginPopuAdapter(loginViews)
end

-- 登录按钮适配
function BasePlatform:loginBtnClickAdapter(userType)

end

function BasePlatform:addPayTypeAdapter()
end

return BasePlatform
