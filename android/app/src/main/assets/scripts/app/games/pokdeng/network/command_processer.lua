local Processer = require('app.games.exGameBase.command_processer')
print("Processer",Processer)
local PokdengProcesser = class(Processer)

function PokdengProcesser:onGameStart(data)
	self.m_controller:onGameStart(data)
end
function PokdengProcesser:onGameEnd(data)
	self.m_controller:onGameEnd(data)
end

function PokdengProcesser:onBroadcastThirdCardAvailable(data)
	self.m_controller:onBroadcastThirdCardAvailable(data)
end
function PokdengProcesser:onGetThirdCard(data)
	self.m_controller:onGetThirdCard(data)
end
function PokdengProcesser:onBroadcastGetThirdCard(data)
	self.m_controller:onBroadcastGetThirdCard(data)
end
function PokdengProcesser:onBet(data)
	self.m_controller:onBet(data)
end
function PokdengProcesser:onBroadcastBet(data)
	self.m_controller:onBroadcastBet(data)
end

function PokdengProcesser:onDeal2Cards(data)
	self.m_controller:onDeal2Cards(data)
end

function PokdengProcesser:onUpBanker(data)
	self.m_controller:onUpBanker(data)
end

function PokdengProcesser:onBankerStartRsp(data)
	self.m_controller:onBankerStartRsp(data)
end

function PokdengProcesser:onBroadcastBankerCanStart(data)
	writeTabToLog(data,"可以开始游戏，processer","debug_socket.lua")
	self.m_controller:onBroadcastBankerCanStart(data)
end

function PokdengProcesser:onBigSettle(data)
	self.m_controller:onBigSettle(data)
end
function PokdengProcesser:initCommandFuncMap()
	PokdengProcesser.super.initCommandFuncMap(self)
	local Command = require('app.games.pokdeng.network.command')
	local s_severCmdEventFuncMap = {
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

	table.merge(self.s_severCmdEventFuncMap, s_severCmdEventFuncMap)
end


return PokdengProcesser