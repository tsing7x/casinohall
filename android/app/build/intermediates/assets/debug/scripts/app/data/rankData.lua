local RankData = class(require('app.data.dataList'))

addProperty(RankData, "hours", "")
addProperty(RankData, "next", 0)
addProperty(RankData, "info", setProxy(new(require('app.data.rank'))))

function RankData:clear()
	self.super.clear(self);
	self:setHours("");
	self:setNext(0);
end

return RankData  