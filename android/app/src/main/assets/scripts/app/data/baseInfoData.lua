local BaseInfoData = class(require('app.data.dataList'))

addProperty(BaseInfoData, "bindTip", "")
addProperty(BaseInfoData, "defaultImage", "")
addProperty(BaseInfoData, "brokenMoney", 2000)
addProperty(BaseInfoData, "bind", 0)
addProperty(BaseInfoData, "firstPay", 0)
addProperty(BaseInfoData, "taskAward", 0)
addProperty(BaseInfoData, "rcTaskAward", 0)
addProperty(BaseInfoData, "czTaskAward", 0)
addProperty(BaseInfoData, "rankAward", 0)
addProperty(BaseInfoData, "feedBack", 0)
addProperty(BaseInfoData, "antiAddiction", 0)
addProperty(BaseInfoData, "tomorrowAward", 0)
addProperty(BaseInfoData, "maxWin", 0)
addProperty(BaseInfoData, "netUpdateTime", -1)  --网络配置更新时间

function BaseInfoData:clear()
	self.super.clear(self);
	self:setBindTip("")
	self:setDefaultImage("")
	self:setBind(0)
	self:setFirstPay(0)
	self:setTaskAward(0)
	self:setRankAward(0)
	self:setAntiAddiction(0)
	self:setTomorrowAward(0)
	self:setMaxWin(0)
	self:setBrokenMoney(2000)
end

return BaseInfoData