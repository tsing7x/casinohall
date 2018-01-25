local BaseProcesser = require("app.mjSocket.game.baseProcesser")
local RoomProcesser = class(BaseProcesser)

function RoomProcesser:onGetTableId(data)
	self.m_controller:onGetTableId(data)
end
function RoomProcesser:onFollow(data)
	self.m_controller:onFollow(data)
end
function RoomProcesser:onFollowed(data)
	self.m_controller:onFollowed(data)
end
function RoomProcesser:onLoginGame(data)
	self.m_controller:onLoginGame(data)
end
function RoomProcesser:onLoginErrorGame(data)
	self.m_controller:onLoginErrorGame(data)
end
function RoomProcesser:onExitRoom(data)
	self.m_controller:onExitRoom(data)
end
function RoomProcesser:onBroadcastExitRoom(data)
	self.m_controller:onBroadcastExitRoom(data)
end
function RoomProcesser:onSitDownInGame(data)
	self.m_controller:onSitDownInGame(data)
end
function RoomProcesser:onBroadcastSitDown(data)
	self.m_controller:onBroadcastSitDown(data)
end
function RoomProcesser:onBroadcastStandup(data)
	self.m_controller:onBroadcastStandup(data)
end
function RoomProcesser:onGameStart(data)
	self.m_controller:onGameStart(data)
end
function RoomProcesser:onGameEnd(data)
	self.m_controller:onGameEnd(data)
end
function RoomProcesser:onStandUp(data)
	self.m_controller:onStandUp(data)
end
function RoomProcesser:onSendProp(data)
	self.m_controller:onSendProp(data)
end
function RoomProcesser:onSendFace(data)
	self.m_controller:onSendFace(data)
end
function RoomProcesser:onSendChat(data)
	self.m_controller:onSendChat(data)
end

function RoomProcesser:onBankerOffline(data)
	self.m_controller:onBankerOffline(data)
end

function RoomProcesser:initCommandFuncMap()
	RoomProcesser.super.initCommandFuncMap(self)
	local Command = require('app.games.exGameBase.commonProtocol')
	local s_severCmdEventFuncMap = {
		[Command.GET_TABLEID_RSP] 					= self.onGetTableId,	--
		[Command.FOLLOW_RSP] 						= self.onFollow,	--
		[Command.FOLLOWED_RSP] 						= self.onFollowed,	--
		[Command.LOGIN_GAME_RSP] 					= self.onLoginGame,
		[Command.LOGIN_GAME_ERROR_RSP] 				= self.onLoginErrorGame,
		[Command.EXIT_ROOM_RSP] 					= self.onExitRoom,
		[Command.BROADCAST_EXIT]					= self.onBroadcastExitRoom,
		[Command.SITDOWN_IN_GAME_RSP] 				= self.onSitDownInGame,
		[Command.BROADCAST_SITDOWN] 				= self.onBroadcastSitDown,
		[Command.STANDUP_RSP] 						= self.onStandUp,
		[Command.BROADCAST_STANDUP] 				= self.onBroadcastStandup,
        [Command.SEND_PROP_RSP] 					= self.onSendProp,
        [Command.SEND_FACE]							= self.onSendFace,
        [Command.SEND_CHAT]							= self.onSendChat,
        [Command.BROADCAST_BANKER_OFFLINE]          = self.onBankerOffline
	}

	table.merge(self.s_severCmdEventFuncMap, s_severCmdEventFuncMap)
end

return RoomProcesser