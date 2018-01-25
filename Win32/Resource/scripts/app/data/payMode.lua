local PayMode = class()

addProperty(PayMode, "id", 0)
addProperty(PayMode, "name", "")
addProperty(PayMode, "time", 0)
addProperty(PayMode, "status", 0)
addProperty(PayMode, "goods", nil)
addProperty(PayMode, "pay", nil)            --金币商品
addProperty(PayMode, "prop", nil)           --筹码商品
addProperty(PayMode, "cash", nil)           --现金币商品


return PayMode
