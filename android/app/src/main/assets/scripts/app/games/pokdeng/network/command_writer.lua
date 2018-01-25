local Writer = require('app.games.exGameBase.command_writer')

local PokdengWriter = class(Writer)

--[[
	type 		: int(是否需要第三张牌，0--不需要，1--需要)
]]
function PokdengWriter:onGetThirdCard(packetId,param)
	self.m_socket:writeInt(packetId, param.type);
end

--[[
	功能描述：用户下注
数据结构：
	ante 	: int64(下注金额)
]]
function PokdengWriter:onBet(packetId,param)
	self.m_socket:writeInt64(packetId, param.ante);
end

--[[
	功能描述:请求上庄
数据结构：
	无
]]
function PokdengWriter:onUpBanker(packetId,param)

end

--[[
	cmd:0x1038 			C --> S
功能描述：庄家请求开始游戏
数据结构：
	无	
]]
function PokdengWriter:onBankerToStart(packetId,param)

end

function PokdengWriter:initCommandFuncMap()
	Writer.initCommandFuncMap(self)
	local Command = require('app.games.pokdeng.network.command')
	local s_clientCmdFunMap = {
		[Command.GET_THIRD_CARD_REQ]		= self.onGetThirdCard,
		[Command.BET_REQ]					= self.onBet,
		[Command.UP_BANKER_REQ]				= self.onUpBanker,
		[Command.BANKER_START_REQ]			= self.onBankerToStart,
	}

	table.merge(self.s_clientCmdFunMap, s_clientCmdFunMap)
end


return PokdengWriter