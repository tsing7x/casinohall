local RoomConfig = class()
local printInfo, printError = overridePrint("RoomConfig")

addProperty(RoomConfig, "gameId", 0)  --子游戏id
addProperty(RoomConfig, "roomCode", 0) --房号
addProperty(RoomConfig, "baseAnte", 0) --底注
addProperty(RoomConfig, "roundIndex", 1) --第几局
addProperty(RoomConfig, "totalRound", 10) --本轮最多几局
addProperty(RoomConfig, "playStatus", 0) --0未开始（如人没凑齐）,1游戏中,2结算中，等待下一局开启
addProperty(RoomConfig, "createConfig", nil) --建房参数

addProperty(RoomConfig, "seatCount", 9) --有几个座位,不包括庄家（用于转换local座位）
addProperty(RoomConfig, "maxPlayerNum", 10) --最大玩家数量
addProperty(RoomConfig, "myLocalSeat", 1) --我的本地座位
addProperty(RoomConfig, "bankerLocalSeat", 10) --庄家本地座位
addProperty(RoomConfig, "bankerServerSeat", 10) --庄家server座位
addProperty(RoomConfig, "bankerId", 10) --庄家id

addProperty(RoomConfig, "chatHistory", {}) --聊天历史
addProperty(RoomConfig, "enterType", 3) --进入房间的方式，1创建房间进来的，2输入房号进来的，3随机进房进来的

addProperty(RoomConfig, "latestBet", 0) --上次的下注（用于重复上局）


function RoomConfig:ctor()
end

function RoomConfig:init(data)
	JLog.d("测试RoomConfig init",data.enterType);
	self.gameId = data.gameId
	self.roomCode = data.roomCode
	self.enterType = data.enterType
	self.createConfig = data.createConfig
	if self.createConfig then
		self.baseAnte = self.createConfig:getAnte()
	end
end

function RoomConfig:clear()
	self.gameId = 0
	self.roomCode = 0
	self.baseChip = 0
	self.createConfig = nil
	self.playStatus = 0
	
end


function RoomConfig:addChatRecord(nick, chatInfo)
	local chatHistory = self:getChatHistory()
	table.insert(chatHistory, {
		nick = nick, 
		chatInfo = chatInfo
	})
end

function RoomConfig:clearForExitRoom()
	
end

function RoomConfig:onGameOver(isLiuju)
	
end

return RoomConfig