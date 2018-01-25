local BaseReader = require("app.mjSocket.game.baseReader")
local RoomReader = class(BaseReader)
local printInfo, printError = overridePrint("RoomReader")
function RoomReader:ctor()
end
--[[
	功能描述：请求分配桌子ID返回
数据结构：
	table_id		: int (桌子ID)
	is_in_table		: int (是否本来就在桌子上)
	game_level 		: int (游戏场次)
	gameID 			: int (游戏ID,如与请求的不一样说明此用户在另一游戏中,需请求进入另一游戏)
]]
function RoomReader:onGetTableId(packetId)
	local data = {};
	data.tableId 	= self.m_socket:readInt(packetId, -1);
	data.isInTable	= self.m_socket:readInt(packetId, -1);
	data.gameLevel	= self.m_socket:readInt(packetId, -115);
	data.gameId		= self.m_socket:readInt(packetId, -1);
	return data;
end

--[[
	enum FOLLOW_SYS_ERR
{
	FS_SUCCESS = 0,                                   //跟随成功
    FS_USER_NOT_LOGIN = 1,                            //用户未登录
    FS_USER_IN_GAME = 2,                              //用户已经在玩游戏
    FS_FOLLOWED_USER_NOT_LOGIN = 3,                   //被跟随用户未在线   
    FS_FOLLOWED_USER_NOT_IN_GAME = 4,                 //被跟随用户未在玩游戏
};

cmd: 0x214		server -> client
功能描述：跟随用户请求进入桌子失败返回
数据结构：
	error_code 	: int (登录错误码, 见上面枚举)
]]
function RoomReader:onFollow(packetId)
	local data = {};
	data.code = self.m_socket:readInt(packetId, -1);
	return data;
end

--[[
	功能描述：通知被跟随用户跟随成功
数据结构：
	error_code 	: int (登录错误码, 见上面枚举)
	uid  		: int (跟随者用户ID)
	nickname	: string (跟随者的昵称)
]]
function RoomReader:onFollowed(packetId)
	local data = {};
	data.code = self.m_socket:readInt(packetId, -1);
	data.uid = self.m_socket:readInt(packetId, -1);
	data.nick= self.m_socket:readString(packetId);
	return data;
end


function RoomReader:onLoginGame(packetId)
end

--[[
	功能描述：服务器返回登陆失败
数据结构：
	errno 	: int(错误码描述暂缺,错误码暂缺的默认为>=1,下同)
]]
function RoomReader:onLoginErrorGame(packetId)
	local data = {};
	data.retcode = self.m_socket:readInt(packetId, -1);
	return data;
end

function RoomReader:onExitRoom(packetId)
	local data = {}
	data.money = self.m_socket:readInt64(packetId, -1);
	return data;
end

function RoomReader:onBroadcastExitRoom(packetId)
	local data = {}
	data.uid = self.m_socket:readInt(packetId, -1);
	return data;
end
--[[
	ret 	: int(0--成功，非0--失败)
	seatId  : 座位号
]]
function RoomReader:onSitDownInGame(packetId)
	printInfo("RoomReader:onSitDownInGame");
	local data = {};
	data.retCode = self.m_socket:readInt(packetId, -1);
	if data.retCode==0 then
		data.seatId = self.m_socket:readInt(packetId,-1)+1
	end
	return data;
end
--[[
	uid 	: int(用户ID)
	seatid  : int(座位ID)
	ante	: int64(携带金额)
	money	: int64(身上的总钱数,包括携带的值)
	userInfo	：string（用户个人信息）
	WinTimes	：int（用户赢次数）
	LoseTimes	：int（用户输次数）
]]
function RoomReader:onBroadcastSitDown(packetId)
	printInfo("RoomReader:onBroadcastSitDown");

	local data = {}
	data.uid 		= self.m_socket:readInt(packetId, -1)
	data.seatId 	= self.m_socket:readInt(packetId, -1) + 1
	data.ante 		= self.m_socket:readInt64(packetId, -1)
	data.money 		= self.m_socket:readInt64(packetId, -1)
	data.userInfo	= self.m_socket:readString(packetId)
	data.WinTimes 	= self.m_socket:readInt(packetId, -1)
	data.LoseTimes 	= self.m_socket:readInt(packetId, -1)
	return data
end

--[[
	功能描述：服务器返回请求站起
数据结构：
	ret 	: int(0--成功，非0--失败)
	seatid 	: int(座位ID)
	reason	: int(站起原因：1-玩家主动站起或掉线；2-携带不够；3-连续未操作；4-换庄时进行的站起操作)
	nMoney  ：int64用户金币值
]]

function RoomReader:onStandUp(packetId)
	printInfo("RoomReader:onStandUp");
	local data = {};
	data.code = self.m_socket:readInt(packetId, -1);
	data.seatId = self.m_socket:readInt(packetId, -1) + 1;
	data.reason = self.m_socket:readInt(packetId, -1);
	data.nMoney = self.m_socket:readInt64(packetId, -1);
	return data;
end
--[[
	功能描述：服务器广播用户站起
数据结构：
	uid 	: int(用户ID)
	seatid  : int(座位ID)
]]
function RoomReader:onBroadcastStandup(packetId)
	printInfo("RoomReader:onBroadcastStandup");
	local data = {}
	data.uid = self.m_socket:readInt(packetId, -1)
	data.seatId = self.m_socket:readInt(packetId, -1) + 1
	return data
end

--   type 	: int (类型)
--	mid 	: int (触发用户id)
--	dest_mid: int (目标用户id)
--	msg_info: string (发给客户端的json串)
--	default : string (预留字段,默认传空字符串即可)字段,默认传空字符串即可)
    -- 发送互动道具
function RoomReader:onSendProp(packetId)

	printInfo("RoomReader:onSendProp"..packetId);

	local data 		= {};
    data.type 		= self.m_socket:readInt(packetId, -1);
	data.mid 		= self.m_socket:readInt(packetId, -1);
    data.dest_mid 	= self.m_socket:readInt(packetId, -1);
    data.msg_info 	= self.m_socket:readString(packetId);
    data.default 	= self.m_socket:readString(packetId);
    
	return data;
end
--[[
cmd：0x1014		server ->  client
功能描述：用户私聊桌子广播
数据结构：
	mid 		: int (触发用户id)
	type 		: int (表情类型)
	IsVipFace 	: int (是否VIP表情)
]]
function RoomReader:onSendFace(packetId)
	printInfo("RoomReader:onSendFace"..packetId);
	local data = {};
	data.mid = self.m_socket:readInt(packetId, -1);
	data.type = self.m_socket:readInt(packetId, -1);
	data.isVipFace	= self.m_socket:readInt(packetId, -1);
	return data;
end
--[[
功能描述：服务器广播房间内聊天
数据结构：
	uid     ： int
	strChat : string(聊天内容)
]]
function RoomReader:onSendChat(packetId)
	printInfo("RoomReader:onSendChat"..packetId);
	local data = {};
	data.mid = self.m_socket:readInt(packetId, -1);
	data.msg = self.m_socket:readString(packetId);
	return data;
end

function RoomReader:onBankerOffline(packetId)
	printInfo("RoomReader:onBankerOffline"..packetId);
	local data = {};
	return data;
end

function RoomReader:initCommandFuncMap()
	RoomReader.super.initCommandFuncMap(self)
	local Command = require('app.games.exGameBase.commonProtocol')
	local s_severCmdFunMap = {
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

	table.merge(self.s_severCmdFunMap, s_severCmdFunMap)
end

return RoomReader