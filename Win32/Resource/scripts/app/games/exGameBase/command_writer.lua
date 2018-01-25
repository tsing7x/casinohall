
local BaseWriter = require("app.mjSocket.game.baseWriter")
local RoomWriter = class(BaseWriter)
local printInfo, printError = overridePrint("RoomWriter")

--[[
	功能描述：请求分配桌子ID
数据结构：
	u16_gameLevel		: short (游戏场次)
	u32_gameId 			: int (游戏ID)
]]
function RoomWriter:onGetTableId(packetId, param)
	printInfo("RoomWriter:onGetTableId");
	dump(param)
	self.m_socket:writeShort(packetId, param.u16_gameLevel);	-- gamelevel
	self.m_socket:writeInt(packetId, param.u32_gameId); 		-- gameid
	if param.tableId then
		self.m_socket:writeInt(packetId, param.tableId);
	end
	
end

--[[
	功能描述：跟随用户请求进入桌子
数据结构：
	u32_follow 		: int (被跟随用户ID)
	str_key			: string (用户验证key)
	str_info			: string (用户信息json串)
	str_followNick     	: string (跟随者的昵称)
]]
function RoomWriter:onFollow(packetId, param)
	printInfo("RoomWriter:onFollow");
	self.m_socket:writeInt(packetId, param.u32_follow);			-- u32_follow
	self.m_socket:writeString(packetId, param.str_key); 		--
	self.m_socket:writeString(packetId, param.str_info); 		--
	self.m_socket:writeString(packetId, param.str_followNick); 		--
	
end

--[[
	功能描述：请求登陆房间
数据结构：
	u32_follow 		: int (被跟随用户ID)
	str_key			: string (用户验证key)
	str_info			: string (用户信息json串)
	str_followNick     	: string (跟随者的昵称)
]]
function RoomWriter:onLoginRoom(packetId, param)
	self.m_socket:writeInt(packetId, param.tableId);
	self.m_socket:writeInt(packetId, param.reason);
end

--[[
	功能描述：请求登录游戏
数据结构：
	u32_tableId		: int (桌子ID)
	u32_uid				: int (用户id)
	str_key			: string (验证key)
	str_info			: string (用户信息json串)
	u32_flag 			: int
]]
function RoomWriter:onLoginGame(packetId, param)
	printInfo("RoomWriter:onLoginGame");
	dump(param)
	self.m_socket:writeInt(packetId, param.u32_tableId);	-- 
	self.m_socket:writeInt(packetId, param.u32_uid); 		--
	self.m_socket:writeString(packetId, param.str_key); 	-- 
	self.m_socket:writeString(packetId, param.str_info); 	--
	self.m_socket:writeInt(packetId, param.u32_flag); 	--
end
--[[
	seatid 		: int(座位ID)
	ante 		: int64(携带金额)
	autoBuyin   : int (是否自动买入 1是0否)
]]
function RoomWriter:onSitDownInGame(packetId, param)
	printInfo("RoomWriter:onSitDownInGame");
	dump(param)
	self.m_socket:writeInt(packetId, param.u32_seatId -1);	-- 
	self.m_socket:writeInt64(packetId, param.u64_ante); --
	self.m_socket:writeInt(packetId, param.autoBuyin or 0);	--
end

-- param:nil
function RoomWriter:onStandUp(packetId, param)
	printInfo("RoomWriter:onStandup");
end
-- param:nil
function RoomWriter:onExitRoom(packetId, param)
	printInfo("RoomWriter:onExitRoom");
end

function RoomWriter:onSendChat(packetId, param)
	self.m_socket:writeString(packetId, param.iChatInfo); 
end

function RoomWriter:onSendFace(packetId, param)
	self.m_socket:writeInt(packetId, param.iFaceType);
	self.m_socket:writeInt(packetId, param.isVipFace);
end

function RoomWriter:initCommandFuncMap()
	RoomWriter.super.initCommandFuncMap(self)
	local Command = require('app.games.exGameBase.commonProtocol')
	local s_clientCmdFunMap = {
		[Command.GET_TABLEID_REQ]  	  		= self.onGetTableId,	--
		[Command.FOLLOW_REQ]  			  	= self.onFollow,	--
		[Command.CLIENT_CMD_LOGINROMM]      = self.onLoginRoom,
		[Command.LOGIN_GAME_REQ] 		  	= self.onLoginGame,
		[Command.SITDOWN_IN_GAME_REQ] 	  	= self.onSitDownInGame,
		[Command.STANDUP_REQ] 			  	= self.onStandUp,
		[Command.EXIT_ROOM_REQ] 		  	= self.onExitRoom,
		[Command.SEND_CHAT]			  		= self.onSendChat,
		[Command.SEND_FACE]			  		= self.onSendFace,

	}
	table.merge(self.s_clientCmdFunMap, s_clientCmdFunMap)
end

return RoomWriter