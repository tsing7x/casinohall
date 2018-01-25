local Game = class(require('base.basegame'))
addProperty(Game, "roomList", nil)
addProperty(Game, "update", false)
addProperty(Game, "name", '')
addProperty(Game, "iconFile", "")

function Game:ctor(roomList)
	self:setName("博定筹码场")
    self:setIconFile("kaengWild/kaeng_icon.png")
	self:setRoomList(new(require('app.data.dataList')))
	self:initRoom(roomList)
end

function Game:initRoom(roomList)
	JLog.d("pokdeng cash Game:initRoom");
	-- body
	if roomList then
		local mRoomList = self:getRoomList()
		for i = 1, roomList:count() do
			local room = roomList:get(i)
			local adapterRoom = mRoomList:get(i) or setProxy(new(require('app.games.pokdeng.data.cashroom')))
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

function Game:getRoomFromMoney(money)
	-- body
	repeat
		local roomList = self:getRoomList()
		if not roomList then break end
		for i = 1, roomList:count() do
			local room = roomList:get(i);
			if money <= room:getLimit() and money >= room:getMinchip() then return room end
 		end

		if money >= roomList:get(roomList:count()):getLimit() then
 			return roomList:get(roomList:count())
 		end

	until true

end
--[[
	进入游戏房间
]]
function Game:enterRoom(from, room, friendId, friendNick)
	-- -- 默认根据钱进房间
	-- JLog.d("pokdeng! enterRoom");
	-- room = room or self:getRoomFromMoney(MyUserData:getMoney())
	-- if room then
	-- 	-- States.GameLobby = "pokdeng.lobbyState"
	-- 	-- States.GameRoom  = "pokdeng.roomState"
	-- 	-- StateFileMap[States.GameLobby] = 'pokdeng/lobbyState'
	-- 	StateFileMap[States.GameRoom] = 'app/games/pokdeng/room/roomState'
	-- 	-- StatesMap[States.GameLobby] = nil
	-- 	-- StatesMap[States.GameRoom] = nil
	-- 	-- local fromState = from or States.Lobby 
	-- 	StateChange.changeState(States.GameRoom, fromState, nil, room, friendId, friendNick)
	-- 	return true
	-- end
	-- return false

	-- 默认根据钱进房间
	States.GameLobby = "pokdeng.lobbyState"
	States.GameRoom  = "pokdeng.cashGame.roomState"
	StateFileMap[States.GameLobby] = 'app/games/pokdeng/pokdengLobbyState'
	StateFileMap[States.GameRoom] = 'app/games/pokdeng/room/roomState'
	StatesMap[States.GameLobby] = nil
	StatesMap[States.GameRoom] = nil
	StateChange.changeState(States.GameLobby, {gameId = GAME_ID.PokdengCash})
	return true
end

function Game:enterRoomWithData(bundleData)
	JLog.d("现金币场enterRoomWithData",bundleData)
	States.GameRoom  = "pokdeng.chipGame.roomState"
	StateFileMap[States.GameRoom] = 'app/games/pokdeng/room/roomState'
	StateChange.changeState(States.GameRoom,bundleData,StateStyle.TRANSLATE_TO,{jay ="hhhahaha"})
end

--[[
	进入游戏大厅
]]
function Game:enterLobby()
	-- 默认根据钱进房间
	States.GameLobby = "kaengWild.lobbyState"
	States.GameRoom  = "kaengWild.roomState"
	StateFileMap[States.GameLobby] = 'kaengWild/lobbyState'
	StateFileMap[States.GameRoom] = 'kaengWild/room/roomState'
	StatesMap[States.GameLobby] = nil
	StatesMap[States.GameRoom] = nil
	StateChange.changeState(States.GameLobby, States.Lobby)
	return true
end


function Game:dtor()
	-- body
end

return Game