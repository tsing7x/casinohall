local BasePlatform = require("app.platform.branch.basePlatform")
-- 主版本

local MainPlatform = class(BasePlatform);
local printInfo, printError = overridePrint("MainPlatform")

function MainPlatform:ctor()
	self._name = "MainPlatform"
	self._loginType = UserType.Visitor  -- 默认登录方式
end

function MainPlatform:autoLoginAdapter(data)
	-- FACEBOOK登录
	local userType = MyUserData:getUserType();
	if userType == UserType.Facebook then
		NativeEvent.getInstance():login()
	else --默认游客登录
		self:requestLoginPhp(data)
	end
end
--第三方登录返回
function MainPlatform:loginCallbackAdapter(loginType, data)
	if loginType == UserType.Facebook then
		--
		self:requestLoginPhp(data);
		--获取好友
		-- NativeEvent.getInstance():getFbFriend();
		
		EventDispatcher.getInstance():dispatch(Event.Message, "FaceBooklogin", 0)
	end
end

-- 登录适配
function MainPlatform:loginPopuAdapter(loginBtns)
end

-- 登录
function MainPlatform:loginBtnClickAdapter(userType,data)
	--清除上一登录数据
	GameSocketMgr:closeSocketSync(false)
	--设置登录类型
	MyUserData:setUserType(userType)
	--自动登陆
	self:autoLoginAdapter(data);

end

return MainPlatform