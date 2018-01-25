local LoginMethod = class()

function LoginMethod:ctor()

	EventDispatcher.getInstance():register(HttpModule.s_event,self,self.onHttpRequestsCallBack);
	EventDispatcher.getInstance():register(Event.Call, self,self.onNativeCallDone);
end

function LoginMethod:dtor()
	
	EventDispatcher.getInstance():unregister(HttpModule.s_event,self,self.onHttpRequestsCallBack);
	EventDispatcher.getInstance():unregister(Event.Call, self,self.onNativeCallDone);
end

-- 自动登录
function LoginMethod:autoRequestLogin()
    PlatformManager:executeAdapter(PlatformManager.s_cmds.AutoLoginAdapter);
end

--游客登录
function LoginMethod:requestGuestLogin()
	MyUserData:setUserType(UserType.Visitor)
	PlatformManager:executeAdapter(PlatformManager.s_cmds.LoginCallbackAdapter, UserType.Visitor)
end

function LoginMethod:logOut()
	MyUserData:clear()
	HallConfig:clear()
--	MySignAwardData:clear()
--	MyPayData:clear()
--	MyBaseInfoData:clear()
    MySwitchData:clear()
end

function LoginMethod:onHttpRequestsCallBack(command, ...)
	if LoginMethod.httpRequestsCallBackFuncMap[command] then
     	LoginMethod.httpRequestsCallBackFuncMap[command](self,...)
	end
end

function LoginMethod:onNativeCallDone(key, data)
	
	if key == "login" then
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
				if DEBUG_MODE then
					AlarmTip.play("login suc");
				end
				require('utils.base64')
				local loginData = {fbUser = {
												name = data.name:get_value(),
												mnick= data.name:get_value(),
												sitemid = data.siteMid:get_value(),
												email = "",
												pic = ""},
									access_token = data.accessToken:get_value(),
									sig_sitemid = base64.encode(string.format(data.siteMid:get_value()..'_gamehallboyaa')),
									};
				--强制FACEBOOK
				MyUserData:setUserType(UserType.Facebook);
				PlatformManager:executeAdapter(PlatformManager.s_cmds.LoginCallbackAdapter, loginType, loginData)
			else
				AlarmTip.play(data.error:get_value() or "login error");
			end

		end
		printInfo("login status = " .. status);
	end
end

LoginMethod.httpRequestsCallBackFuncMap = {
}
return LoginMethod