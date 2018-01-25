local LoginController 	= require("app.login.loginController")
local LoginScene 	= require("app.login.loginScene")
local LoginLayout  		= require(ViewPath .. "loginLayout")

local LoginState = class(BaseState);

function LoginState:load()
	LoginState.super.load(self);
	self.m_controller = new(LoginController, self,LoginScene, LoginLayout);
	return true;
end

function LoginState:getController()
	return self.m_controller
end

function LoginState:gobackLastState()
	-- body
end

function LoginState:resume(bundle)
	self.super.resume(self,bundle)
end

function LoginState:unload()
	LoginState.super.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end

return LoginState