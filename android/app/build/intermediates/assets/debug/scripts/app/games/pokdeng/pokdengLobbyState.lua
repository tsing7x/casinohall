local PokdengLobbyController 	= require("app.games.pokdeng.pokdengLobbyController")
local PokdengLobbyScene 	= require("app.games.pokdeng.pokdengLobbyScene")
local PokdengLobbyLayout  		= require(ViewPath .. "games.pokdeng.pokdengLobbyLayout")

local PokdengLobbyState = class(BaseState);

function PokdengLobbyState:ctor(...)
	JLog.d("pokdeng PokdengLobbyState");
	self.mParam = {...};
end

function PokdengLobbyState:load()
	PokdengLobbyState.super.load(self);
	self.m_controller = new(PokdengLobbyController, self,PokdengLobbyScene, PokdengLobbyLayout, self.mParam);
	return true;
end

function PokdengLobbyState:getController()
	return self.m_controller
end

function PokdengLobbyState:gobackLastState()
	-- body
end

function PokdengLobbyState:resume(bundle)
	self.super.resume(self,bundle)
end

function PokdengLobbyState:unload()
	PokdengLobbyState.super.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end

return PokdengLobbyState