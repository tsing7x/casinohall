local Command = require('app.games.exGameBase.commonProtocol')

local Command = clone(Command)

local pokdengCmd = {
	BROADCAST_THIRD_CARD_AVAILABLE   	= 0x6009,   -- 广播此时可以请求第三张牌
	GET_THIRD_CARD_REQ 					= 0x1010,   -- 请求第三张牌
	GET_THIRD_CARD_RSP 					= 0x2005,   -- 请求第三张牌返回
	BROADCAST_GET_THIRD_CARD_RSP   		= 0x6010,   -- 广播请求第三张牌结果

	BET_REQ 							= 0x1006,   -- 请求下注
	BET_RSP 							= 0x2006,   -- 下注返回
	BROADCAST_BET 						= 0x6008,   -- 广播下注

	BROADCAST_START_GAME				= 0x6006,	-- 广播游戏真正开始
	BROADCAST_GAME_OVER					= 0x6007,	-- 广播游戏结束
	
	BROADCAST_SHOWCARD					= 0x6011,	-- 广播用户亮牌
	BROADCAST_DEAL2CARDS				= 0x6012,	-- 广播所有用户发前两张
	BROADCAST_HANDCARD				    = 0x2008,	-- 通知玩家手牌

	UP_BANKER_REQ 						= 0x1034,   	-- 请求上庄
	UP_BANKER_RSP 						= 0x1054,   	-- 上庄返回

	DOWN_BANKER_REQ						= 0x1037,		--请求下庄
	DOWN_BANKER_RSP						= 0x1057,		--下庄返回

	BROADCAST_BANKER_CAN_START 			= 0x1059, 	--提示庄家可以开始游戏
	BANKER_START_REQ 					= 0x1038, 	--庄家请求开始游戏
	BANKER_START_RSP 					= 0x1058, 	--庄家请求开始游戏,的返回

	BIT_SETTLE							= 0x6014,	--一轮结束之后的大结算

}

table.merge(Command,pokdengCmd)

return Command