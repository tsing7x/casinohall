local FacebookFriendData = class(require('app.data.dataList'))

addProperty(FacebookFriendData, "init", 0)

function FacebookFriendData:clear()
	self.super.clear(self);
	self:setInit(0);
end

return FacebookFriendData 