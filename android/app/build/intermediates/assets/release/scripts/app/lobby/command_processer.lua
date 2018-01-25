local BaseProcesser = require("app.mjSocket.game.baseProcesser")
local RoomProcesser = class(BaseProcesser)

function RoomProcesser:onLoginError(data)
	self.m_controller:onLoginError(data)
end
function RoomProcesser:onEnterRoom(data)
	self.m_controller:onEnterRoom(data)
end


function RoomProcesser:initCommandFuncMap()
	RoomProcesser.super.initCommandFuncMap(self)
	local Command = require('app.lobby.command')
	local s_severCmdEventFuncMap = {
		[Command.ENTER_PRIVATEROOM_RSP] 					= self.onEnterRoom,	--
		[Command.COMMAND_LOGIN_ERR_RSP] 					= self.onLoginError,	--
	}

	table.merge(self.s_severCmdEventFuncMap, s_severCmdEventFuncMap)
end

return RoomProcesser