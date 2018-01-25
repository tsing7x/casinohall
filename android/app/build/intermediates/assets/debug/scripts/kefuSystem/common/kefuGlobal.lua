--------------------client 配置信息--------------------------- 
mqtt_client_config = {
["host"]			= "cs-test.oa.com",
["port"]			= "3333",
["gameId"]		    = "1",
["siteId"]		    = "117",
["role"]			= "2",
["stationId"]		= "201121",
["avatarUri"]		= "default",
["qos"]				= 1,
["cleanSession"]	= true,
["keepalive"]		= 60,
["timeout"]			= 1,
["retain"]		    = false,
["ssl"]				= false,
["sslKey"]		    = "",
["userName"]		= "username",
["userPwd"]			= "123456",
}

mqtt_client_info = {
["nickName"]		= "Bryan",
["avatarUri"]		= "default",
["vipLevel"]		= "3",
["gameName"]		= "德州扑克",
["accountType"]		= "IOS豌豆荚联运",
["client"]		    = "IOS新浪简体",
["userID"]		    = mqtt_client_config.stationId,
["deviceType"]	    = "IOS",
["connectivity"]	= "wifi",
["gameVersion"]		= "3.1",
["deviceDetail"]	= "iphone 6s",
["mac"]				= "B0:83:FE:94:58:F3",
["ip"]			    = "135.454.55.22",
["browser"]			= "其他",
["screen"]		    = "1280*720",
["OSVersion"]		= "6.0.1",
["jailbreak"]		= false,
["operator"]		= "1",
["sdkVersion"] 		= "1.0",
["hotline"] 		= "0755-86166169",
}




ConversationStatus_Map = 
{
    ["DISCONNECTED"]    = 0, --未链接
    ["CONNECTING"]      = 1, --正在连接
    ["CONNECTED"]       = 2, --已连接
    ["LOGINED"]         = 3, --已登录
    ["SHIFTED"]         = 4, --转接
    ["SESSION"]         = 5, --会话状态
    ["FINSHED"]         = 6, --会话结束
    ["LOGOUT"]          = 7, --已连接，但已登出，需要重新login
};


--------------------- require --------------------
--require('kefuSystem/libs/json_wrap)
-- GKefuOnlyOneConstant = require('kefuSystem/common/kefuConstant')
-- GKefuNetWorkControl = require('kefuSystem/conversation/netWorkControl')
-- GKefuSessionControl = require('kefuSystem/conversation/sessionControl')
-- GKefuViewManager = require('kefuSystem/viewManager')