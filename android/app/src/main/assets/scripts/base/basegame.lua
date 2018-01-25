local BaseGame = class()

function BaseGame:ctor(roomList)
end

function BaseGame:initRoom(roomList)
end

function BaseGame:getRoomFromLevel(level)
end

function BaseGame:getRoomFromMoney(money)
end

function BaseGame:enterRoom(from, room)
	return false
end

function BaseGame:enterLobby()
	return false
end

function BaseGame:dtor()
end

return BaseGame