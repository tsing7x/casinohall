local Reader = require('app.games.exGameBase.command_reader')

local PokdengReader = class(Reader)

--[[
	功能描述：服务器广播可以开始获取第三张牌
数据结构：
	seatid 	: int(玩家座位)
]]
function PokdengReader:onBroadcastThirdCardAvailable(packetId)
	local data = {}
	data.seatid = self.m_socket:readInt(packetId, -1)+1
	return data
end

--[[
	card 	: byte(第三张牌数值)
]]
function PokdengReader:onGetThirdCard(packetId)
	local data = {}
	data.card = self.m_socket:readByte(packetId, -1)
	return data
end

--[[
	功能描述：服务器广播用户操作获取第三张牌结果
数据结构：
	seatid 	: int(玩家座位)
	type    : int 1要牌 0不要
]]
function PokdengReader:onBroadcastGetThirdCard(packetId)
	local data = {}
	data.seatid = self.m_socket:readInt(packetId, -1)+1
	data.type = self.m_socket:readInt(packetId, -1)
	return data
end

--[[
	功能描述：服务器返回用户下注
数据结构：
	ret 	: int(0--成功，1--失败)
]]
function PokdengReader:onBet(packetId)
	local data = {}
	data.retCode = self.m_socket:readInt(packetId, -1)
	return data
end

--[[
	功能描述：服务器广播玩家下注
数据结构：
	seatid 	: int(玩家座位)
	ante    ：int64(下注金额)
]]
function PokdengReader:onBroadcastBet(packetId)
	local data = {}
	data.seatid = self.m_socket:readInt(packetId, -1)+1
	data.ante = self.m_socket:readInt64(packetId, -1)
	return data
end


--[[
	cmd:0x6012 			S   --->  C
功能描述：服务器广播前两张牌
数据结构：
	totalAnte       : int64 桌子上的总筹码数量
	count 		: int(手牌数量)
	for(i=0;i<count;i++)
	{
		card 	: byte(牌值)
	}
	OutCardPlayerCount: int(亮牌玩家数量)
	for(j=0;j<OutCardPlayerCount;j++)
	{
		OutCardCount 		: int(亮牌玩家手牌数量)
		for(k=0;k<OutCardCount;k++)
		{
			card 	: byte(牌值)
		}
		seatid 		: int(亮牌玩家座位)
	}
]]
function PokdengReader:onDeal2Cards(packetId)
	local data = {}
	data.totalAnte = self.m_socket:readInt64(packetId, -1)
	local myCount = self.m_socket:readInt(packetId,-1)
	data.myCards = {}
	for i=1,myCount do
		data.myCards[i] = self.m_socket:readByte(packetId,-1)
	end

	local pokdengNum = self.m_socket:readInt(packetId,-1)
	data.pokdengCards = {}
	for i=1,pokdengNum do
		local user = {cards = {},seatId=nil}
		data.pokdengCards[i] = user
		local userCardCount = self.m_socket:readInt(packetId,-1)
		for j=1,userCardCount do
			user.cards[j] = self.m_socket:readByte(packetId,-1)
		end
		user.seatId = self.m_socket:readInt(packetId,-1)+1
	end

	data.myCount=myCount
	data.pokdengNum=pokdengNum
	return data
end

--[[
	功能描述：服务器返回登陆成功，兼容重连
数据结构：	
	tableId         : int 桌子ID
	tableLevel      : int 桌子level
	tableStatus     : byte 桌子当前状态 0牌局已结束 1下注中 2等待用户获取第3张牌 3等待结算
	curDealSeatId   : int 如果为发第三张牌时，为当前询问发牌的座位
	baseAnte        : int64 底注
	totalAnte       : int64 桌子上的总筹码数量
	UserAnteTime    : byte 下注等待时间
	ExtraCardTime   : byte 询问发第三张牌等待时间	
	maxSeatCnt      : byte 总的座位数量
	minAnte         : int64 最小携带
	maxAnte         : int64 最大携带
	defaultAnte     : int64 默认携带
	playCount       : int 当前坐下玩家数
	for(i = 0; i < playCount; ++i)
	{
		UserId      ：int 用户ID
	    SeatId      ：int 用户座位ID
	    UserInfo    ：string 用户信息
	    nMoney      ：int64 用户携带
		nCurAnte    : int64 当次下注
	    nWinTimes   : int 玩家的赢次数
	    nLoseTimes  : int 玩家的输次数
		isOnline    : Byte 连接状态 0--用户掉线   1--用户在线
		isPlay      ：Byte 是否在玩牌
		isOutCard   : int 是否亮牌
		cardsCount  : int 用户手牌数量
		if (isOutCard == 1)
		{
			card1  	: byte(扑克牌数值, 无为0)
			card2  	: byte(扑克牌数值, 无为0)
			card3  	: byte(扑克牌数值, 无为0)
		}
	}
	banker_id           : int
	per_round_count : int32 一轮的总局数(目前定为10局)
	curInning		：int32	桌子目前是一轮中的第几局
]]
function PokdengReader:onLoginGame(packetId)
	printInfo("RoomReader:onLoginGame");
	local data = {};
	data.tableId = self.m_socket:readInt(packetId,-1)
	data.tableLevel = self.m_socket:readInt(packetId,-1)
	data.tableStatus = self.m_socket:readByte(packetId,-1)
	data.curDealSeatId = self.m_socket:readInt(packetId,-1)+1
	data.baseAnte 	= self.m_socket:readInt64(packetId, -1);
	data.totalAnte 	= self.m_socket:readInt64(packetId, -1);
	data.UserAnteTime = self.m_socket:readByte(packetId,-1)
	data.ExtraCardTime = self.m_socket:readByte(packetId,-1)
	data.maxSeatCnt = self.m_socket:readByte(packetId,-1)
	data.minAnte 	= self.m_socket:readInt64(packetId, -1);
	data.maxAnte 	= self.m_socket:readInt64(packetId, -1);
	data.defaultAnte 	= self.m_socket:readInt64(packetId, -1);
	data.playCount = self.m_socket:readInt(packetId,-1)
	data.players = {}
	for i=1,data.playCount do
		local player = {}
		data.players[i] = player
		player.UserId = self.m_socket:readInt(packetId,-1)
		player.SeatId = self.m_socket:readInt(packetId,-1)+1
		player.UserInfo	= self.m_socket:readString(packetId)
		player.nMoney 	= self.m_socket:readInt64(packetId, -1);
		player.nCurAnte 	= self.m_socket:readInt64(packetId, -1);
		player.nWinTimes = self.m_socket:readInt(packetId,-1)
		player.nLoseTimes = self.m_socket:readInt(packetId,-1)
		player.isOnline = self.m_socket:readByte(packetId,-1)
		player.isPlay = self.m_socket:readByte(packetId,-1)
		player.isOutCard = self.m_socket:readInt(packetId,-1)
		player.cardsCount = self.m_socket:readInt(packetId,-1)
		if player.isOutCard==1 then
			player.cards = {}
			for j=1,3 do
				player.cards[j] = self.m_socket:readByte(packetId,-1)
			end
		end
	end
	data.banker_id = self.m_socket:readInt(packetId,-1)
	data.totalRound = self.m_socket:readInt(packetId,-1)
	data.curRound = self.m_socket:readInt(packetId,-1)
	return data;
end

--[[
	功能描述：服务器广播游戏开始
数据结构：
	playCount	: int 玩牌人数
	for(i=0; i<playCount; ++i)
	{
		seatid  : int(座位ID)
		ante	: int64(携带金额)
	}
	is_new_banker       : int 是否为新庄家 1是，0不是
	banker_id           : int
	banker_seatid 	    : int
	banker_money        : int64 
	banker_info         : string 庄家信息

	curInning		：int32	桌子目前是一轮中的第几局
]]
function PokdengReader:onGameStart(packetId)
	printInfo("RoomReader:onGameStart");
	local data = {};
	data.playCount = self.m_socket:readInt(packetId, -1)
	data.playerList = {}
	for i=1,data.playCount do
		data.playerList[i] = {}
		data.playerList[i].seatid = self.m_socket:readInt(packetId, -1)+1
		data.playerList[i].ante = self.m_socket:readInt64(packetId, -1)
	end
	data.is_new_banker 		= self.m_socket:readInt(packetId, -1)
	data.banker_id 			= self.m_socket:readInt(packetId, -1)
	data.banker_seatid 		= self.m_socket:readInt(packetId, -1)+1
	data.banker_money 		= self.m_socket:readInt64(packetId, -1)
	data.banker_info	= self.m_socket:readString(packetId)
	data.is_cash 			= self.m_socket:readByte(packetId, -1)
	if data.is_cash == 1 then
		data.curRound = self.m_socket:readInt(packetId,-1)
		data.serverFee = self.m_socket:readInt64(packetId,-1)
	end
	return data;
end

--[[
	功能描述：服务器广播牌局结束，结算结果
数据结构：
	playCount	: int 玩牌人数
	for(i=0; i<playCount; i++)
	{
		uid 	    : int(用户ID)
		seatid 	    : int(玩家座位)
		turnMoney 	: int64(用户金币变化值)
		money 		: int64(携带金额)
		getexp      : int
		exp 		: int
		count 		: int(手牌数量)
		for(i=0; i<count; i++)
		{
			card 	: byte(牌值)
		}
	}
	banker_remain : int64
	banker_turnMoney : int64
	banker_fee : int64
	banker_continue  :能否继续当庄 1能，0不能
]]
function PokdengReader:onGameEnd(packetId)
	printInfo("RoomReader:onGameEnd");
	local data = {};
	data.playCount = self.m_socket:readInt(packetId, -1)
	data.playerList = {}
	for i=1,data.playCount do
		local player = {}
		data.playerList[i] = player
		player.uid 			= self.m_socket:readInt(packetId, -1)
		player.seatid 		= self.m_socket:readInt(packetId, -1)+1
		player.turnMoney 	= self.m_socket:readInt64(packetId, -1)
		player.money 		= self.m_socket:readInt64(packetId, -1)
		player.getexp 		= self.m_socket:readInt(packetId, -1)
		player.exp 			= self.m_socket:readInt(packetId, -1)
		player.count 		= self.m_socket:readInt(packetId, -1)
		player.cards = {}
		for j=1,player.count do
			player.cards[j] = self.m_socket:readByte(packetId, -1)
		end
	end
	data.banker_remain 		= self.m_socket:readInt64(packetId, -1)
	data.banker_turnMoney 	= self.m_socket:readInt64(packetId, -1)
	data.banker_fee 		= self.m_socket:readInt64(packetId, -1)
	data.banker_continue 	= self.m_socket:readInt(packetId, -1)
	return data;
end

--[[
	功能描述：请求上庄返回
数据结构：
	error_code :int 301不满足上庄最低钱 302已经请求上庄了 303钱数低于当前庄家携带的1.5倍 304上庄请求队列已满
]]
function PokdengReader:onUpBanker(packetId)
	local data = {}
	data.error_code = self.m_socket:readInt(packetId, -1)
	return data
end


--[[
	cmd:0x1058 			S  -->   C
功能描述  请求开始返回
数据结构：
	error_code			:int (值有以下几种可能:0-请求成功；大于0表示请求出错，400-房间人数不够开局；401-请求开局时未满10局；402-非庄家不能开局；403-房卡不够)
]]
function PokdengReader:onBankerStartRsp(packetId)
	local data = {}
	data.error_code = self.m_socket:readInt(packetId, -1)
	return data
end

--[[
	cmd:0x1059 			S  -->   C
功能描述  提示庄家可以开始牌局
数据结构：
	无
]]
function PokdengReader:onBroadcastBankerCanStart(packetId)
	local data = {}
	return data
end

--[[
	cmd: 0x6014 	server -> client
功能描述：一轮后广播玩家输赢排名情况
数据结构：
	waitTime: int (等待时间)
	player_count: int (一轮中玩牌玩家数量)
	for(int i=0;i<player_count;++i)
	{
		rank		: int 	(排名)
		uid:		: int 
		userInfo	: string(玩家信息)
		turnMoney	: int64 (输赢钱数)
		isOffline	: byte  (是否已经登出->1：是，0：否)
	}

]]
function PokdengReader:onBigSettle(packetId)
	local data = {}
	data.waitTime = self.m_socket:readInt(packetId, -1)
	local playerNum = self.m_socket:readInt(packetId, -1)
	data.users = {}
	for i=1,playerNum do
		local user = {}
		data.users[i] = user
		user.rank = self.m_socket:readInt(packetId, -1)
		user.uid = self.m_socket:readInt(packetId, -1)
		user.userInfo = self.m_socket:readString(packetId, -1)
		user.turnMoney = self.m_socket:readInt64(packetId, -1)
		user.isOffline = self.m_socket:readByte(packetId, -1)
	end
	return data
end

function PokdengReader:initCommandFuncMap()
	PokdengReader.super.initCommandFuncMap(self)
	local Command = require('app.games.pokdeng.network.command')
	local s_severCmdFunMap = {
		[Command.BROADCAST_THIRD_CARD_AVAILABLE]	= self.onBroadcastThirdCardAvailable,
		[Command.GET_THIRD_CARD_RSP]				= self.onGetThirdCard,
		[Command.BROADCAST_GET_THIRD_CARD_RSP]		= self.onBroadcastGetThirdCard,
		[Command.BET_RSP]							= self.onBet,
		[Command.BROADCAST_BET] 					= self.onBroadcastBet,

		[Command.BROADCAST_START_GAME] 				= self.onGameStart,
		[Command.BROADCAST_GAME_OVER]				= self.onGameEnd,

		[Command.BROADCAST_DEAL2CARDS]				= self.onDeal2Cards,

		[Command.UP_BANKER_RSP]						= self.onUpBanker,
		[Command.BANKER_START_RSP]					= self.onBankerStartRsp,
		[Command.BROADCAST_BANKER_CAN_START]		= self.onBroadcastBankerCanStart,
		[Command.BIT_SETTLE]						= self.onBigSettle,
	}

	table.merge(self.s_severCmdFunMap, s_severCmdFunMap)
end


return PokdengReader