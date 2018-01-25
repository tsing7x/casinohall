local Room = class()
local Room = class()
addProperty(Room, "data", 0)
-- addProperty(Room, "level", 0)
-- addProperty(Room, "type", 0)
-- addProperty(Room, "ante", 0)
-- addProperty(Room, "readytime", 0)
-- addProperty(Room, "bettime", 0)
-- addProperty(Room, "playercount", 0)
-- addProperty(Room, "fee", 0)
-- addProperty(Room, "minchip", 0)
-- addProperty(Room, "maxchip", 0)
-- addProperty(Room, "chip", {})
-- addProperty(Room, "dealerfee", 0)
-- addProperty(Room, "limit", 0)
-- addProperty(Room, "present", {})
-- addProperty(Room, "online", 0) --在线

--roomid, 类别,底注,准备时间,每轮下注时间,桌面人数,服务费,最小携带,最大携带,下注1,下注2,下注3,下注4,荷官小费,快速匹配最大值,房间内送钱金钱值配置1,房间内送钱金钱值配置2,房间内送钱金钱值配置3,房间内送钱金钱值配置4

function Room:init( data )
	-- body
	self:setData(data)
	-- self:setLevel(data[1] or 0);
	-- self:setType(data[2] or 0);
	-- self:setAnte(data[3] or 0);
	-- self:setReadytime(data[4] or 0);
	-- self:setBettime(data[5] or 0);
	-- self:setPlayercount(data[6] or 0);
	-- self:setFee(data[7] or 0);
	-- self:setMinchip(data[8] or 0);
	-- self:setMaxchip(data[9] or 0);
	-- self:setChip({data[10], data[11], data[12], data[13]});
	-- self:setDealerfee(data[14] or 0);
	-- self:setLimit(data[15] or 0);
	-- self:setPresent({data[16], data[17], data[18], data[19]})
end

return Room
