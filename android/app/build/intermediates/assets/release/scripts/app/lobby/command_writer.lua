local BaseWriter = require("app.mjSocket.game.baseWriter")
local LobbyWriter = class(BaseWriter)

--[[
	功能描述：请求创建私人房
数据结构：
	required int16 gameid = 1;				//! 游戏id
	required int32 level = 201;				//! 游戏level
	required int32 money	= 3;			//用户金额，创建的时候需要判定用户金额是否足够低注
	required string userinfo = 4;			//! 请求者的用户信息
	required int8	isCash=5;				//是否是现金币场 1：是 0不是
	if(isCash==1)
	{
		required int8 allowQuickEnter=6;	//是否允许快速加入	1:是 0:否
		required int32 	roundCount=7;		//回合的局数
	}
]]
function LobbyWriter:onCreateRoom(packetId, param)
	JLog.d("LobbyWriter:onCreateRoom");
	dump(param)
	self.m_socket:writeShort(packetId, param.gameId);
	self.m_socket:writeInt(packetId, param.level);
	self.m_socket:writeInt64(packetId, param.money);
	self.m_socket:writeString(packetId, param.userInfo); 
	self.m_socket:writeByte(packetId, param.isCash)
	if param.isCash == 1 then
		self.m_socket:writeByte(packetId, param.isPublic)
		self.m_socket:writeInt(packetId, param.roundCount);
	end
end

--[[
	功能描述：密码进房
数据结构：
	required int16 gameid = 1;				//! 游戏id	
	required string password = 8;			//! 房间密码
	required string userInfo = 6;			//! 请求者的用户信息
]]
function LobbyWriter:onEnterRoomByCode(packetId, param)
	JLog.d("LobbyWriter onEnterRoomByCode",param)
	self.m_socket:writeShort(packetId, param.gameid);
	self.m_socket:writeString(packetId, param.password); 
	self.m_socket:writeString(packetId, param.userInfo); 
	
end

--[[
	功能描述：请求随机进房
数据结构：
	required int16 gameid = 1;				//! 游戏id
	required int64 money=5;					//!	玩家携带的钱
	required string userInfo = 6;			//! 请求者的用户信息
]]
function LobbyWriter:onEnterRoomRandom(packetId, param)
	dump(param)
	self.m_socket:writeShort(packetId, param.gameid);
	self.m_socket:writeInt(packetId, param.level); 
	self.m_socket:writeString(packetId, param.userInfo); 
	self.m_socket:writeByte(packetId, param.is_reconnect);
	
end

function LobbyWriter:initCommandFuncMap()
	LobbyWriter.super.initCommandFuncMap(self)
	local Command = require('app.lobby.command')
	local s_clientCmdFunMap = {
		[Command.CREATE_PRIVATEROOM_REQ]  	  		= self.onCreateRoom,	--
		[Command.ENTER_PRIVATEROOM_ERQ]  			  	= self.onEnterRoomByCode,	--
		[Command.RANDOM_ENTER_PRIVATEROOM_ERQ] 		  	= self.onEnterRoomRandom,
	}
	table.merge(self.s_clientCmdFunMap, s_clientCmdFunMap)
end

return LobbyWriter