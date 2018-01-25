local PlayerInfoData = class(require("app.data.headData"))

addProperty(PlayerInfoData, "id", 0)
addProperty(PlayerInfoData, "name", 0)
addProperty(PlayerInfoData, "money", 0)
addProperty(PlayerInfoData, "exp", 0)
addProperty(PlayerInfoData, "level", 0)
addProperty(PlayerInfoData, "wintimes", 0)
addProperty(PlayerInfoData, "losetimes", 0)
addProperty(PlayerInfoData, "maxMoney", 0)
addProperty(PlayerInfoData, "maxwMoney", 0)
addProperty(PlayerInfoData, "canSendApply", 0)
addProperty(PlayerInfoData, "from", "")
addProperty(PlayerInfoData, "winRate", nil)
addProperty(PlayerInfoData, "giftId", nil)
--添加现金币属性
addProperty(PlayerInfoData, 'cashPoint', 0)



function PlayerInfoData:ctor()

end

function PlayerInfoData:init(param)
	self:setId(param.mid or 0)
	self:setName(param.name or "")
	--self:setSex(param.msex or 0);
    if tonumber(param.msex) and tonumber(param.msex) > 0 then
        self:setSex(tonumber(param.msex) - 1)
    else
        self:setSex(0)
    end
	self:setHeadUrl(param.micon or ""); 
	self:setMoney(param.money or 0);
	self:setExp(param.exp or 0);
	self:setLevel(param.level or 0);
	self:setWintimes(param.wintimes or 0);
	self:setLosetimes(param.losetimes or 0);
	self:setMaxMoney(param.maxmoney or 0);
	self:setMaxwMoney(param.maxwoney or 0);
	self:setCanSendApply(param.canSendApply or 0);
    self:setCashPoint(param.diamond or 0);
--新的使用gameid获取胜率
    local winRate = {}
    local gameId = app:getGameIds()
    for i = 1, #gameId do
        if gameId[i] > 0 then
            local curGameRate = param[tostring(gameId[i])]
            winRate[gameId[i]] = {}
            winRate[gameId[i]].winTimes = curGameRate and tonumber(curGameRate.wintimes) or 0
            winRate[gameId[i]].loseTimes = curGameRate and tonumber(curGameRate.losetimes) or 0
            winRate[gameId[i]].maxWinMoney = tonumber(param.maxwmoney) or 0
        end
    end
    self:setWinRate(winRate)
    --礼物列表，如果过期了就显示空图标，没过期就显示对应的。
    local wearGift = param.wearGift or {}
    local expireTime = tonumber(wearGift.expireTime) or 0
    if expireTime > os.time() then 
        local giftType = tonumber(wearGift.giftType)
        local giftId = tonumber(wearGift.giftId)
        if giftType and giftId then
            self:setGiftId({giftType, giftId})
        end
    end
    
--    self:setGiftId(param.giftId)
end

function PlayerInfoData:dtor()

end

return PlayerInfoData  