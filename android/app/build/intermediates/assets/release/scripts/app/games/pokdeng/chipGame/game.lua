local Game = class(require('base.basegame'))

--协议类
local Command = require("app.games.exGameBase.commonProtocol")

--游戏属性
addProperty(Game, "name", '')
addProperty(Game, "iconFile", "")
addProperty(Game, "update", false)
addProperty(Game, "roomList", nil)

function Game:ctor(roomList)
	self:setName("博定筹码场")
    self:setIconFile("kaengWild/kaeng_icon.png")
	self:setRoomList(new(require('app.data.dataList')))
	self:initRoom(roomList)
end

function Game:initRoom(roomList)
	if roomList then
		local mRoomList = self:getRoomList()
		for i = 1, roomList:count() do
			local room = roomList:get(i)
			local adapterRoom = mRoomList:get(i) or setProxy(new(require('app.games.pokdeng.data.chiproom')))
			adapterRoom:init(room:getData())
			if not mRoomList:get(i) then
				mRoomList:add(adapterRoom)
			end
		end
		mRoomList:setInit(true)
	end
end

function Game:getRoomFromLevel(level)
	-- body
	repeat
		local roomList = self:getRoomList()
		if not roomList then break end
		for i = 1, roomList:count() do
			local room = roomList:get(i);
			if level == room:getLevel() then
				return room;
			end
		end
	until true
end

--[[
	根据玩家筹码数返回对应的筹码场房间
--]]
function Game:getRoomFromMoney(money)
	--获取房间列表
	local roomList = self:getRoomList()
	if not roomList then
		return
	end
	
	--根据房间列表的筹码限制返回房间
	for i = 1, roomList:count() do
		local room = roomList:get(i);
		if money <= room:getMaxChip() and money >= room:getMinChip() then
			return room 
		end
	end

	--筹码数超过最大筹码限制，返回最后一个房间
	if money >= roomList:get(roomList:count()):getMaxChip() then
		return roomList:get(roomList:count())
	end
end

--[[
	进入游戏房间
]]
function Game:enterRoom(roomConfig)
	-- 默认根据钱进房间
	JLog.d("pokdeng! enterRoom");
	local money = MyUserData:getMoney();
	local config = roomConfig or self:getRoomFromMoney(money);
	if config then
		JLog.d("存在该房间");
		self:requestRoomByLevel(config:getLevel())
		return true;
	else
		JLog.d("不存在该房间",money);
	end
	return false;
end


function Game:requestRoomByLevel(level)
	if not level then return end;
	local userInfo = {appid = 0, nick = MyUserData:getNick(), sex = MyUserData:getSex(), micon = MyUserData:getHeadUrl(), giftId = MyUserData:getGiftId()}
	JLog.d("发送进房请求");
	GameSocketMgr:sendMsg(Command.ENTER_ROOM_REQ,{gameid=tonumber(GAME_ID.Casinohall),level = level,userInfo=json.encode(userInfo), is_reconnect = 0})
	JLog.d("发送进房请求2");
end



function Game:enterRoomWithData(bundleData)
	-- JLog.d("ChipGame:enterRoomWithData.bundleData :=========", bundleData)

	States.GameRoom  = "pokdeng.chipGame.roomState"
	StateFileMap[States.GameRoom] = 'app/games/pokdeng/room/roomState'
	StateChange.changeState(States.GameRoom,bundleData,StateStyle.TRANSLATE_TO,{jay ="hhhahaha"})
end

--[[
	进入游戏大厅
]]
function Game:enterLobby()
	-- 默认根据钱进房间
	States.GameLobby = "pokdeng.lobbyState"
	States.GameRoom  = "pokdeng.chipGame.roomState"
	StateFileMap[States.GameLobby] = 'app/games/pokdeng/pokdengLobbyState'
	StateFileMap[States.GameRoom] = 'app/games/pokdeng/room/roomState'
	StatesMap[States.GameLobby] = nil
	StatesMap[States.GameRoom] = nil
	StateChange.changeState(States.GameLobby, {gameId = GAME_ID.Casinohall})
	return true
end


function Game:dtor()
	-- body
end

return Game