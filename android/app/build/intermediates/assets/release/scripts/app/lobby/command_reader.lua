local BaseReader = require("app.mjSocket.game.baseReader")
local LobbyReader = class(BaseReader)

--[[
	功能描述：登录失败
数据结构：
	
]]
function LobbyReader:onLoginError(packetId)
	printInfo("错误,%s","LobbyReader:onLoginError")
	local data = {};
	data.errCode 	= self.m_socket:readByte(packetId, -1);
	
	return data;
end

--[[
	功能描述：进房返回、建房返回
数据结构：
	required int32 reason = 1;				//reason的值有三种可能;0:进房间出错，可用房间为空；1：使用房卡创建而进入成功；2：使用验证码进入成功,3是随机分配的
	required int32 roomCode = 2;				//! 展示桌子ID(验证码) 
	required int32 gameId = 3;          		//! gameId
	required int32 serverId = 4;          		//! serverId
	required int32 tableId = 5;					//! 桌子ID 
	required int32 level = 6;				//！房间等级
]]
function LobbyReader:onEnterRoom(packetId)
	printInfo("进房,%s","LobbyReader:onEnterRoom")
	local data = {};
	data.reason 	= self.m_socket:readInt(packetId, -1);
	data.roomCode 	= self.m_socket:readInt(packetId, -1);
	data.gameId	= self.m_socket:readInt(packetId, -1);
	data.serverId	= self.m_socket:readInt(packetId, -1);
	data.tableId		= self.m_socket:readInt(packetId, -1);
	data.level		= self.m_socket:readInt(packetId, -1);
	return data;
end


function LobbyReader:initCommandFuncMap()
	LobbyReader.super.initCommandFuncMap(self)
	local Command = require('app.lobby.command')
	local s_severCmdFunMap = {
		[Command.ENTER_PRIVATEROOM_RSP] 					= self.onEnterRoom,	--
		[Command.COMMAND_LOGIN_ERR_RSP] 						= self.onLoginError,	--

	}

	table.merge(self.s_severCmdFunMap, s_severCmdFunMap)
end

return LobbyReader