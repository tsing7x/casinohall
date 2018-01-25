local Shop = class()

addProperty(Shop, "id", 0)
addProperty(Shop, "pamount", 0)
addProperty(Shop, "pchips", 0)
addProperty(Shop, "currency", 0)
addProperty(Shop, "pdesc", "")
addProperty(Shop, "count", 0)
addProperty(Shop, "discount", 1)    --折扣
addProperty(Shop, "pcard", 0)       --商品的种类，0是换成金币，2001是换成互动道具，1000是大米的提示道具
addProperty(Shop, "name", "")       --商品名称
addProperty(Shop, "prevchips", "")  --原筹码
addProperty(Shop, "pcoins", "")  --现金币


return Shop