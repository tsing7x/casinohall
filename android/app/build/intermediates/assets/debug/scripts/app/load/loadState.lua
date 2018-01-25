local LoadController 	= require("app.load.loadController")
local LoadScene 	= require("app.load.loadScene")
local LoadLayout  		= require(ViewPath .. "loadLayout")

local LoadState = class(BaseState);

local printInfo, printError = overridePrint("LoadState")

function LoadState:load()
	
	self.super.load(self);
	self.m_controller = new(LoadController,self,LoadScene, LoadLayout);
	return true;
end

function LoadState:unload()
	LoadState.super.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end

function LoadState:getController()
	return self.m_controller
end

function LoadState:gobackLastState()
	-- body
end

function LoadState:ctor()
	--必须提前初始化
	PhpManager      = PhpManager    	or new(require("app.mjSocket.base.phpManager"))
	PlatformManager = PlatformManager 	or new(require("app.platform.platformManager"))
	--全局版本控制器
    MyGameVerManager    = MyGameVerManager or new(require("app.update.gameVersionManager"))
    --更新包信息，IOS没有
    MyApkUpdateInfo = MyApkUpdateInfo or setProxy(new(require("app.data.apkUpdateInfo")))
end

function LoadState:resume(bundleData)
	LoadState.super.resume(self, bundleData)
end



return LoadState