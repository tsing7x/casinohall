local RoomController 	= require("app.games.pokdeng.room.roomController")
local RoomScene 	= require("app.games.pokdeng.room.roomScene")
local RoomLayout  		= require(ViewPath .. "games.pokdeng.pokdengLayout")

local RoomState = class(BaseState);

function RoomState:ctor(...)
	JLog.d("pokdeng RoomState");
	self.mParam = {...};
end

function RoomState:load()
	RoomState.super.load(self);
	self.m_controller = new(RoomController, self, RoomScene, RoomLayout, self.mParam)
	return true;
end

function RoomState:getController()
	return self.m_controller
end

function RoomState:gobackLastState()
	-- body
end

function RoomState:unload()
	RoomState.super.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end

return RoomState