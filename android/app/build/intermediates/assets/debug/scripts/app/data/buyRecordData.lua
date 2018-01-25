local BuyRecordData = class()

addProperty(BuyRecordData, "shopType", 0)
addProperty(BuyRecordData, "shopName", "")
addProperty(BuyRecordData, "buyTime", 0)
addProperty(BuyRecordData, "num", 0)
addProperty(BuyRecordData, "orderStatus", 0) --1是已到账，2是未发货


function BuyRecordData:ctor()
end

function BuyRecordData:dtor()

end

return BuyRecordData
