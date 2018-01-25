local CashAwardData = class(require("app.data.imgData"))

addProperty(CashAwardData, "category", 0)  		--商品的种类，比如游戏礼包，现金卡、实物礼品类，同一种类放在一个列表
addProperty(CashAwardData, "id", 0) 			--商品在该种类下的ID，
addProperty(CashAwardData, "name", "")     	--商品名字
addProperty(CashAwardData, "remain", nil)		--剩余量
addProperty(CashAwardData, "price", 0)			--价格
addProperty(CashAwardData, "multiUse")              --1 商品后续会补货， 0商品买完即止
addProperty(CashAwardData, "other", nil)

function CashAwardData:init(data)
	self:setCategory(data.category or "")
	self:setId(data.id or 0)
	self:setImgUrl(data.image or "")
	self:setName(data.name or "")
	self:setRemain(tonumber(data.remain) or -1)     -- -1表示这个商品不需要remain也就是不限量
	self:setPrice(tonumber(data.score) or 0)
    self:setMultiUse(tonumber(data.multiUse) or 0)
	self:setOther(data.other or {})
end

return CashAwardData