local LoginScene = class(BaseScene)

local cIndex = 0
local function getIndex()
	cIndex = cIndex + 1
	return cIndex
end

LoginScene.s_controls =
	{
		--topView
		btn_login_fb = getIndex(),
		btn_login_vistor = getIndex(),

	}

LoginScene.s_controlConfig =
	{
		[LoginScene.s_controls.btn_login_fb] = {"img_bg","view_login","btn_login_fb"},
		[LoginScene.s_controls.btn_login_vistor] = {"img_bg","view_login","btn_login_vistor"},

	}


function LoginScene:ctor(viewConfig,controller)
	print_string("zyh loginScene ctor")
	EventDispatcher.getInstance():register(HttpModule.s_event, self, self.onHttpRequestsCallBack);
	EventDispatcher.getInstance():register(Event.Call, self, self.onNativeCallBack)
	if MyUserData:getId() == 0 then --显示登录界面
		local delayAnim = self:addPropTransparency(1, kAnimNormal, 0, 500, 1.0, 1.0)
		delayAnim:setEvent(
			self,
			function (self)
				checkAndRemoveOneProp(self, 1)
				--自动登陆
				-- EventDispatcher.getInstance():dispatch(Event.Message, "autoLogin", GameSetting:getLoginType())
			end
		)
	else   ---已经登录了

	end
    self:findChildByName("text_tip"):setText(Hall_string.STR_FB_LOGIN_HINT)
	self:initView()
	self:testInit()
end

function LoginScene:resume(bundleData)
	self.super.resume(self,bundleData)
end


function LoginScene:initView()
end


function LoginScene:onAutoLogin(loginType)
	-- body
	MyUserData:clear();
	HallConfig:clear()
	MySwitchData:clear();
	MyUserData:setUserType(loginType);

	if System.getPlatform() == kPlatformWin32 then
		MyUserData:setUserType(UserType.Visitor)
		self:loginAnim();
	elseif UserType.Visitor == loginType then
		GameSocketMgr:closeSocketSync(true)
		self:loginAnim();
	elseif UserType.Facebook == loginType then
		GameSocketMgr:closeSocketSync(true)
		NativeEvent.getInstance():login();
	end
end


--登录动画
function LoginScene:loginAnim()
	--加载loading文字和转圈圈效果
	app:showLoadingTip(Hall_string.STR_LOAING,true)	self:loginLoadingAnim();
end



function LoginScene:loginLoadingAnim()
	--自动登录
	if MyUserData:getUserType() == UserType.Visitor then
		-- PlatformManager:executeAdapter(PlatformManager.s_cmds.LoginBtnClickAdapter, MyUserData:getUserType());
		self:requestLoginPhp()
	end
end

function LoginScene:logoutAnim(anim)

end


function LoginScene:onLoginFbClick()
	-- AlarmTip.play("สร้างห้องต่ำสุs ชิปเงินสดของคุณมีไม่พอค่ะสร้างห้องต่ำสุดs ชิปเงินสดของคุณมีไม่พอค่ะสร้างห้องต่ำสุดs ชิปเงินสดของคุณมีไม่พอค่ะ")
	GameSocketMgr:closeSocketSync(false)
	MyUserData:clear();
	MySwitchData:clear();
	MyUserData:setUserType(UserType.Facebook);
	NativeEvent.getInstance():login();
	GameSetting:setLoginType(UserType.Facebook);
	GameSetting:save();
end

function LoginScene:onLoginVistorClick()
	GameSetting:load()
	print("GameSetting:getIsNewUser()",GameSetting:getIsNewUser())
	print(GameSetting.m_set:getBoolean("isNewUser"),GameSetting.m_set:getInt("isxxxxxxxxxx"))
	MyUserData:setUserType(UserType.Visitor)
	if GameSetting:getIsNewUser()=="1" then
		-- WindowManager:showWindow(
		-- 	WindowTag.CreateRolePopu,
		-- 	{
		-- 		callback = function(data)
		-- 			-- PlatformManager:executeAdapter(PlatformManager.s_cmds.LoginBtnClickAdapter, MyUserData:getUserType(),{sex=data.sex,name=data.name});
		-- 			self:requestLoginPhp({sex=data.sex,name=data.name})
		-- 			WindowManager:closeWindowByTag(WindowTag.CreateRolePopu)
		-- 		end

		-- 	},
		-- 	WindowStyle.POPUP
		-- )
		self:requestLoginPhp({sex="male",name=PhpManager:getModelName()})
	else
		GameSocketMgr:closeSocketSync(false)
		MyUserData:clear();
		MySwitchData:clear();
		MyUserData:setUserType(UserType.Visitor);
		self:loginAnim();
		--不为游客自动登录
		GameSetting:setLoginType(UserType.Visitor);
		GameSetting:save();
	end
end


function LoginScene:pause()
	LoginScene.super.pause(self)
end

function LoginScene:dtor()
	EventDispatcher.getInstance():unregister(HttpModule.s_event, self, self.onHttpRequestsCallBack);
	EventDispatcher.getInstance():unregister(Event.Call, self, self.onNativeCallBack);
end

function LoginScene:onBack()
	print("onBack()")
	WindowManager:showWindow(WindowTag.MessageBox, {text = Hall_string.STR_EXITGAME,rightFunc=function()
    	NativeEvent.getInstance():Exit()
    	GameSocketMgr:closeSocketSync()
    end}, WindowStyle.POPUP)
end

function LoginScene:requestLoginPhp(mergeParams)
	require('app.utils.base64')
	local sesskey = UserType.Facebook == MyUserData:getUserType() and GameSetting:getSesskey() or ""
	local param_post = {
		mac 	 		= PhpManager:getMac(),
		sig_sitemid 	= base64.encode(string.format(PhpManager:getDevice_id()..'_gamehallboyaa')),
		machineType 	= PhpManager:getModelName(),
		net 			= PhpManager:getNet(),
		simOperatorName = PhpManager:getNet(),
		apkVer 	 		= PhpManager:getVersionName(),
		pixel  			= PhpManager:getRat(),
		imei	 		= PhpManager:getDevice_id(),
		sesskey         = sesskey,
	};

	table.merge(param_post, mergeParams or {})
	HttpModule.getInstance():execute(HttpModule.s_cmds.LOGIN_PHP, param_post, false, true)
end

function LoginScene:testInit()
	if DEBUG_MODE then
		local debugView = self:findChildByName("debug")
		debugView:setVisible(true)
		debugView:findChildByName("test"):setOnClick(nil, function()
			HOST_URL = 'http://192.168.203.228/casinohall/game/hall/index.php'
			LOCAL_NET = true
			HttpModule.getInstance():initUrlConfig()
            MyRoomConfig:clear()
            MyGameVerManager:setUpdateUrl("http://pkgserver.oa.com/Api/Client/testUpdateInfo")
            AlarmTip.play("已切换测试服")
		end)
		debugView:findChildByName("release"):setOnClick(nil, function()
			LOCAL_NET = false
			HOST_URL = 'http://thaicasino.boyaagame.com/game/hall/index.php'
			HttpModule.getInstance():initUrlConfig()
            MyRoomConfig:clear()
            MyGameVerManager:setUpdateUrl("https://pkgserver.boyaagame.com/Api/Client/onlineUpdateInfo")
            AlarmTip.play("已切换正式服")
        end)

        local CHINA 	= 'chn'
		local THAILAND  = 'tpe'
        debugView:findChildByName("CHN"):setOnClick(nil, function()
			LANGUAGE = CHINA
			Hall_string = require('app.res.string.string_chn')
			AlarmTip.play("已切换到中文")
		end)
		debugView:findChildByName("TPE"):setOnClick(nil, function()
			LANGUAGE = THAILAND
			Hall_string = require('app.res.string.string_tpe')
			AlarmTip.play("已切换到泰语")
		end)
	end
end

--HTTP回调
function LoginScene:onHttpRequestsCallBack(command, ...)
	if self.s_severCmdEventFuncMap[command] then
		self.s_severCmdEventFuncMap[command](self, ...)
	end
end

--native callback
function LoginScene:onNativeCallBack(key, data, result)

end


function LoginScene:onLoginPHPResponse(isSuccess, data)
	--登录成功
	if isSuccess and data and 1 == data.code then
		GameSetting:setIsNewUser("0"):save()
		StateChange.changeState(States.Lobby,data.data,StateStyle.TRANSLATE_TO)
	else
		--登录失败
		app:showLoadingTip(Hall_string.STR_LOAING,false)
	end
end



LoginScene.messageFunMap = {
	["autoLogin"]					= LoginScene.onAutoLogin,
	["loginFbSuccess"]    = LoginScene.requestLoginPhp,
}

LoginScene.s_severCmdEventFuncMap = {
	[HttpModule.s_cmds.LOGIN_PHP]			= LoginScene.onLoginPHPResponse,

}

LoginScene.s_controlFuncMap =
	{
		[LoginScene.s_controls.btn_login_fb] = LoginScene.onLoginFbClick,
		[LoginScene.s_controls.btn_login_vistor] = LoginScene.onLoginVistorClick,

	}

return LoginScene
