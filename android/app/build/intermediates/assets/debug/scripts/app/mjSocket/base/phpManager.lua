
PlatformConfig = {
	basePlatform = 1,
	
}


local PhpManager = class()


local s_commandMap = {
}
local smsType = {
	[0] = "未知", 
	[1] = "移动", 
	[2] = "联通", 
	[3] = "电信",
}

GAME_LOBBY_ID = {
	Casinohall 		= "117",
	PokdengCash     = "118",
}

GAME_ID = {
	Casinohall   	= "1017",
	PokdengCash		= "1018",
	PokdengBanker	= "1019",
}

addProperty(PhpManager, "currPlatform", PlatformConfig.basePlatform)
addProperty(PhpManager, "usertype", 1)


addProperty(PhpManager, "versionCode", 201)
addProperty(PhpManager, "versionName", "2.0.1")


addProperty(PhpManager, "packages", "")
addProperty(PhpManager, "apk_path", "")
addProperty(PhpManager, "lib_path", "")
addProperty(PhpManager, "files_path", "")
addProperty(PhpManager, "sd_path", "")
addProperty(PhpManager, "root_path", "")
addProperty(PhpManager,"res_path","")
addProperty(PhpManager, "lang", "")
addProperty(PhpManager, "country", "")
addProperty(PhpManager, "device_id", "")
addProperty(PhpManager, "appname", "")

addProperty(PhpManager, "packageName", "com.boyaa.hallgame3h_vtn")--

addProperty(PhpManager, "modelName", "4.1.1")
addProperty(PhpManager, "phone", "")
addProperty(PhpManager, "net", "2G")
addProperty(PhpManager, "mac", "")
addProperty(PhpManager, "appid", "1110")
addProperty(PhpManager, "appkey", "not known")
addProperty(PhpManager, "api", 0x10B04000)
addProperty(PhpManager, "isSdCard", "")
addProperty(PhpManager, "simType", 0)
addProperty(PhpManager, "imsi", "")
addProperty(PhpManager, "rat", "")

addProperty(PhpManager, "game", GAME_LOBBY_ID.Casinohall) --默认是骰子大厅

addProperty(PhpManager, "gameName", "") --
addProperty(PhpManager, "isTest", 1)

function PhpManager:ctor()
	self:_initPlatform()
end

function PhpManager:getBasic(command)
	local methodInfo = s_commandMap[command]
	local _m, _p = unpack(string.split(methodInfo, "#"))
	return {
		m = _m,
		p = _p,
		api = self:getAPI(),
	}
end

function PhpManager:getAPI()
	return {
			sitemid 	= self:getDevice_id() .. GameConfig:getLastSuffix(),
			device_id 	= self:getDevice_id() .. GameConfig:getLastSuffix(),
			api 		= self:getApi(),
			version 	= self:getVersionName(),
			usertype	= MyUserData:getUserType(),
			sess_id 	= MyUserData:getSessionId(),
			mid 		= MyUserData:getId(),
		}

end

function PhpManager:getLoginParam()
	-- return {
	-- 	device_type 		= "android", 				-- 移动终端设备机型
 --       	device_os 			= self:getModelName(), 			-- 移动终端设备操作系统
 --       	resolution 			= display.resolution,
 --       	network_mode        = self:getNet(),
 --       	network_operator 	= smsType[self.simType] or "未知",    -- 移动终端设备所使用的网络运营商(1:移动, 2:联通, 3:电信)
 --       	mac_address			= self:getMac(),
 --       	channel_id          = self:getAppid(),			-- 渠道id
 --       	channel_key 		= self:getAppkey(), 		-- 渠道key
 --       	imsi                = self:getImsi(),
	-- }
	-- return {
	-- 	sesskey 			= nil, 					-- 会话ID
 --       	sid 				= 1, 					-- 平台ID
 --       	lid 				= 2,					-- 登录帐号类型ID(1:FB, 2:游客)
 --       	method        		= 'Login.guest',		-- 请求接口方法名
 --       	version 			= '1.0',    			-- 版本号
 --       	demo				= 1,
	-- }
end

function PhpManager:mergeApiParams(apiData, param)
	table.merge(apiData, param)
end

--[[
	获取机器信息
]]
function PhpManager:getMachineInfo()
	local fmt = "附加信息 [ 平台：%s, 版本号：%s, 机型：%s, phone: %s, 手机卡类型：%s, 机器码: %s, 联网方式：%s, 是否有sd卡：%s ]"
	return string.format(fmt, self.currPlatform or "未知", self.version or "未知", self.modelName or "未知", 
		self.phone or "未知", smsType[self.simType] or "未知", self.device_id or "未知", self.net or "未知", self.isSdCard or "未知")
end

function PhpManager:_initPlatform()
	local platform = System.getPlatform();
	if platform == kPlatformAndroid then --android登录
		GAME_LOBBY_ID = {
			Casinohall 		= "117",
			PokdengCash		= "118",
		}

		GAME_ID = {
			Casinohall   	= "1017",
			PokdengCash		= "1018",
			PokdengBanker	= "1019",
		}
		self:_initAndroid()
	elseif platform == kPlatformIOS then
		GAME_LOBBY_ID = {
			Casinohall 		= "117",
			PokdengCash		= "118",
		}

		GAME_ID = {
			Casinohall   	= "1017",
			PokdengCash		= "1018",
			PokdengBanker	= "1019",
		}
		self:_initWinIos()

	else
		self:_initWin32() --win32登录
	end
	self:initExtraInfo()
end


function PhpManager:_initWinIos( )

	dump("_initWinIos")
	local result = NativeEvent.getInstance():GetInitValue()
	local json_data=json.decode_node(result);
	self.currPlatform   = GetNumFromJsonTable(json_data, "currPlatform", 1)
	self.versionCode 	= GetNumFromJsonTable(json_data, "version_code", 1)
	self.versionName 	= GetStrFromJsonTable(json_data, "version_name", "1.0.0")
	self.packages 		= GetStrFromJsonTable(json_data, "packages", "")
	self.apk_path 		= GetStrFromJsonTable(json_data, "apk_path", "")
	self.lib_path 		= GetStrFromJsonTable(json_data, "lib_path", "")
	self.files_path 	= GetStrFromJsonTable(json_data, "files_path", "")
	self.sd_path 		= GetStrFromJsonTable(json_data, "sd_path", "")
	self.root_path 		= GetStrFromJsonTable(json_data, "root_path", "")
	self.res_path		= GetStrFromJsonTable(json_data, "res_path", "")
	self.lang 			= GetStrFromJsonTable(json_data, "lang", "")
	self.country 		= GetStrFromJsonTable(json_data, "country", "")
	-- ios uuid 和 device_id 是同一个值
	self.device_id 		= GetStrFromJsonTable(json_data, "device_id", "")
	self.uuid 		= GetStrFromJsonTable(json_data, "uuid", "")
	self.appname 		= GetStrFromJsonTable(json_data, "appname", "")
	self.packageName 	= GetStrFromJsonTable(json_data, "packageName", "")
	self.modelName 		= GetStrFromJsonTable(json_data, "modelName", "")
	self.phone 			= GetStrFromJsonTable(json_data, "phone", "")
	self.net 			= GetStrFromJsonTable(json_data, "net", "")
	self.mac 			= GetStrFromJsonTable(json_data, "mac", "")
	self.appid 			= GetStrFromJsonTable(json_data, "appid", "")
	self.appkey 		= GetStrFromJsonTable(json_data, "appkey", "")
	self.api 			= GetNumFromJsonTable(json_data, "api", 0x10B04000)
	self.isSdCard 		= GetNumFromJsonTable(json_data, "isSdCard", 0)
	self.simType 		= GetNumFromJsonTable(json_data, "simType", 0)
	self.imsi 		    = GetStrFromJsonTable(json_data, "imsi", "")
	self.rat 		    = GetStrFromJsonTable(json_data, "rat", "")
	self.isTest         = GetNumFromJsonTable(json_data, "isTest", 0)  -- 0 正式服

	if self.packageName == 'com.boyaa.casinohall' or self.packageName == 'com.boyaa.casinohallinhouse' then
		self:setPackageName('com.boyaa.casinohall')
		self.game 			= GAME_LOBBY_ID.Casinohall --103
		self.gameName 		= STR_APP_H3
	end


end

function PhpManager:_initAndroid()
	local result = NativeEvent.getInstance():GetInitValue()
	local json_data=json.decode_node(result);
	self.currPlatform   = GetNumFromJsonTable(json_data, "currPlatform", 1)
	self.versionCode 	= GetNumFromJsonTable(json_data, "version_code", 1)
	self.versionName 	= GetStrFromJsonTable(json_data, "version_name", "1.0.0")
	self.packages 		= GetStrFromJsonTable(json_data, "packages", "")
	self.apk_path 		= GetStrFromJsonTable(json_data, "apk_path", "")
	self.lib_path 		= GetStrFromJsonTable(json_data, "lib_path", "")
	self.files_path 	= GetStrFromJsonTable(json_data, "files_path", "")
	self.sd_path 		= GetStrFromJsonTable(json_data, "sd_path", "")
	self.root_path 		= GetStrFromJsonTable(json_data, "root_path", "")
	self.res_path		= GetStrFromJsonTable(json_data, "res_path", "")
	self.lang 			= GetStrFromJsonTable(json_data, "lang", "")
	self.country 		= GetStrFromJsonTable(json_data, "country", "")
	self.device_id 		= GetStrFromJsonTable(json_data, "device_id", "")
	self.appname 		= GetStrFromJsonTable(json_data, "appname", "")
	self.packageName 	= GetStrFromJsonTable(json_data, "packageName", "")
	self.modelName 		= GetStrFromJsonTable(json_data, "modelName", "")
	self.phone 			= GetStrFromJsonTable(json_data, "phone", "")
	self.net 			= GetStrFromJsonTable(json_data, "net", "")
	self.mac 			= GetStrFromJsonTable(json_data, "mac", "")
	self.appid 			= GetStrFromJsonTable(json_data, "appid", "")
	self.appkey 		= GetStrFromJsonTable(json_data, "appkey", "")
	self.api 			= GetNumFromJsonTable(json_data, "api", 0x10B04000)
	self.isSdCard 		= GetNumFromJsonTable(json_data, "isSdCard", 0)
	self.simType 		= GetNumFromJsonTable(json_data, "simType", 0)
	self.imsi 		    = GetStrFromJsonTable(json_data, "imsi", "")
	self.rat 		    = GetStrFromJsonTable(json_data, "rat", "")
	self.isTest         = 1--GetNumFromJsonTable(json_data, "isTest", 0)  -- 0 正式服

	if self.packageName == 'com.boyaa.casinohall' or self.packageName == 'com.boyaa.pokdeng' then
		self.game 			= GAME_LOBBY_ID.Casinohall
		self.gameName 		= STR_APP_H3
	end

end

function PhpManager:_initWin32()
	local guid_str = System.getWindowsGuid()
	local str = "0"
	if guid_str then
		if string.len(guid_str) > 4 then
			str = string.sub(guid_str, 2, 9)
		else
			str = guid_str
		end
	else
		guid_str = "0"
	end


	-- self.device_id = guid_str .. os.clock() .. os.time();
 	self.device_id = guid_str .. "tsing"
 	self.isTest = 1
end

-- 根据是否正式包
function PhpManager:initExtraInfo()
	if self.device_id and self.device_id == "02:00:00:00:00:00" then
		self.device_id = ""
	end
	-- wifi下dump文件上传 
	-- if self.net == "wifi" then
	-- 	require("UploadDumpFile")
	-- 	local upload = new(UploadDumpFile, "11"); --appid为11
	-- 	upload:execute(true); --请在wifi网络的情况下调用上传
	-- end
end

return PhpManager