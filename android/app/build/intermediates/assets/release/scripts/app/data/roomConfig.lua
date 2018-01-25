local RoomConfig = class()

function RoomConfig:ctor()
	-- body
	self.mRoom = {}
end

function RoomConfig:dtor()
	-- body
end
--加入房间配置
function RoomConfig:set(gameId, roomList)
	-- body
	self.mRoom[tonumber(gameId)] = roomList
end

--加入房间配置
function RoomConfig:get(gameId)
	-- body
	return self.mRoom[tonumber(gameId)]
end

function RoomConfig:clear()
    self.mRoom = {}
end

return RoomConfig