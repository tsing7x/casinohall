
local GiftItemData = class(require("app.data.imgData"))

addProperty(GiftItemData, "id", 0)             -- 礼物的id，编号唯一
addProperty(GiftItemData, "type", 0)           -- 礼物类型，小吃类，道具类，保留字段，暂时不用
addProperty(GiftItemData, "name", "")           -- 礼物名字
addProperty(GiftItemData, "expireTime", "")     -- 有效期，过期后礼物消失,转换后的字符串，方便显示
addProperty(GiftItemData, "price", "")          -- 礼物价格
addProperty(GiftItemData, "costType", 0)       -- 货币类型，可能是金币或者现金币，暂时只有金币
addProperty(GiftItemData, "count", 0)          -- 礼物数量
addProperty(GiftItemData, "time", 0)            --有效期，单位为秒，

function GiftItemData:init(param)
    self:setId(tonumber(param.giftId) or 0)
    self:setType(tonumber(param.giftType) or 0)
    self:setName(tostring(param.tName) or "")
    self:setImgUrl(param.icon or "")
    local time = tonumber(param.time) or 0
    self:setTime(time)
    --少于一天，以小时为单位显示，多余一天，以天为单位
    if time < 86400 then
        self:setExpireTime(math.ceil(time / 3600)..STR_HOUR)
    else
        self:setExpireTime(math.ceil(time / 86400)..STR_DAY)
    end
--    self:setExpireTime(param.time or "")
    self:setPrice(tonumber(param.price) or 0)
    self:setCostType(tonumber(param.costType) or 0)
    self:setCount(tonumber(param.count) or 0)
end

return GiftItemData