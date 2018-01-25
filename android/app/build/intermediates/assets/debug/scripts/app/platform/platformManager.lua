local PlatformFactory = require("app/platform/platformFactory")
local PlatformManager = class();
local printInfo, printError = overridePrint("PlatformManager")

PlatformManager.s_cmds = {
	StartSceneInit 		= 1,
	RequestChargeList 	= 2,
	SelectPayWay 		= 3,
    AutoLoginAdapter    = 4,
    LoginCallbackAdapter = 5,  -- sdk返回 获取merge参数
    LoginPopuAdapter    = 6,
    LoginBtnClickAdapter = 7,
    GetShopListAppIdAndPmode = 8,
    AddPayTypeAdapter = 9,  --为联运平台添加额外的支付支持
}

function PlatformManager:ctor()
	self.m_platformRef = PlatformFactory.initPlatform(PhpManager:getCurrPlatform());
end

function PlatformManager:executeAdapter(configId, ...)
	if not configId then return end
	printInfo("executeAdapter command = %d", configId)
	local configFunc = PlatformManager.s_cmdConfig[configId];
	if configFunc and self.m_platformRef then
		printInfo("[[ %s ]] 来处理该适配功能 %d", self.m_platformRef:getName(), configId)
		return configFunc(self, ...);
	end
	return false;
end

-- 初始界面适配
PlatformManager.startSceneInit = function(self)
	self.m_platformRef:startSceneInit();
end

PlatformManager.requestChargeList = function(self, isLogin)
	self.m_platformRef:requestChargeList(isLogin);
end

PlatformManager.selectPayWay = function(self, goodsInfo, isLuoMaFirst, sceneChargeData)
	--相应平台下的支付方式
	self.m_platformRef:selectPayWay(goodsInfo, isLuoMaFirst, sceneChargeData)
end

PlatformManager.autoLoginAdapter = function(self)
	--相应平台下的自动登陆适配
	self.m_platformRef:autoLoginAdapter()
end

-- 根据返回结果获取参数 并进行下一步操作
PlatformManager.loginCallbackAdapter = function(self, loginType, data)
	data = data or {}
	self.m_platformRef:loginCallbackAdapter(loginType, data)
end

-- 适配所有登录按钮的显示
PlatformManager.loginPopuAdapter = function(self, loginViews)
	self.m_platformRef:loginPopuAdapter(loginViews)
end

PlatformManager.loginBtnClickAdapter = function(self, index,data)
	self.m_platformRef:loginBtnClickAdapter(index,data)
end

PlatformManager.getShopListAppIdAndPmode = function(self, index)
	return self.m_platformRef:getShopListAppIdAndPmode();
end

PlatformManager.addPayTypeAdapter = function(self)
	return self.m_platformRef:addPayTypeAdapter()
end

PlatformManager.s_cmdConfig = {
	[PlatformManager.s_cmds.StartSceneInit] 		= PlatformManager.startSceneInit,
	[PlatformManager.s_cmds.RequestChargeList] 		= PlatformManager.requestChargeList,
	[PlatformManager.s_cmds.SelectPayWay] 			= PlatformManager.selectPayWay,
  	[PlatformManager.s_cmds.AutoLoginAdapter] 		= PlatformManager.autoLoginAdapter,
  	[PlatformManager.s_cmds.LoginCallbackAdapter] 	= PlatformManager.loginCallbackAdapter,
  	[PlatformManager.s_cmds.LoginPopuAdapter] 		= PlatformManager.loginPopuAdapter,
  	[PlatformManager.s_cmds.LoginBtnClickAdapter] 	= PlatformManager.loginBtnClickAdapter,
  	[PlatformManager.s_cmds.GetShopListAppIdAndPmode] = PlatformManager.getShopListAppIdAndPmode,
  	[PlatformManager.s_cmds.AddPayTypeAdapter] 	    = PlatformManager.addPayTypeAdapter,

}

return PlatformManager