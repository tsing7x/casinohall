--[[
	创建房间配置
]]

local CreateConfig = class()
addProperty(CreateConfig, "level", 0)  	--房间级别（id)
addProperty(CreateConfig, "baseAnte", 0)  	--底注
addProperty(CreateConfig, "zhuangLimit", 0) 	--庄家门槛
addProperty(CreateConfig, "xianLimit", 0) 	--闲家门槛
addProperty(CreateConfig, "price", 0) 	--建房消耗，单位房卡

addProperty(CreateConfig, "betLimit", 0) 	--下注上限
addProperty(CreateConfig, "warningValue", 0) 	--警告值
addProperty(CreateConfig, "kickOutValue", 0) 	--踢出值

function CreateConfig:init(info)
	self.level 			= info.level
	self.baseAnte 		= info.bet
	self.zhuangLimit 	= info.bankerThreshold
	self.xianLimit 		= info.playerThreshold
	self.price 			= info.roomCard
	self.betLimit 		= info.betLimit
	self.warningValue 	= info.warningValue
	self.kickOutValue 	= info.kickedOutValue
end




return CreateConfig