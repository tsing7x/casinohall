local Pay = class(require('app.data.dataList'))

addProperty(Pay, "time", "")
addProperty(Pay, "info", nil)
addProperty(Pay, "mode", 0)

function Pay:clear()
	self.super.clear(self);
	self:setTime("");
	self:setInfo(time);

end

return Pay  