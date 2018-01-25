local LobbyController 	= require("app.lobby.lobbyController")
local LobbyScene 	= require("app.lobby.lobbyScene")
local LobbyLayout  		= require(ViewPath .. "lobbyLayout")

local LobbyState = class(BaseState);

function LobbyState:ctor( ... )
	self.mParam = {...};
end

function LobbyState:load(...)
	LobbyState.super.load(self);
	self.m_controller = new(LobbyController, self,LobbyScene, LobbyLayout,self.mParam);
	return true;
end

function LobbyState:getController()
	return self.m_controller
end

function LobbyState:gobackLastState()
	-- body
end

function LobbyState:unload()
	LobbyState.super.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end

return LobbyState