local BasePlayer = class(require("data.headData"))

addProperty(BasePlayer, "id", 0)
addProperty(BasePlayer, "seatId", 0)
addProperty(BasePlayer, "chip", 0)
addProperty(BasePlayer, "nick", "")
addProperty(BasePlayer, "localSeatId", 0)
addProperty(BasePlayer, "ui", nil)
addProperty(BasePlayer, "goodCount",0)
addProperty(BasePlayer, "alarmTime", 0) --闹钟时间
addProperty(BasePlayer, "giftId", nil) 
addProperty(BasePlayer, "sitdownAnim", false)
addProperty(BasePlayer, "inAnim", false)
addProperty(BasePlayer, "winMoney", 0)  --输赢
addProperty(BasePlayer, "curTurn", 0)  --轮到当前玩家
addProperty(BasePlayer, "trustee", false) --是否托管


function BasePlayer:ctor()
end

function BasePlayer:clear()
	self:setNick("")
	self:setSitdownAnim(false)
	self:setInAnim(false)
    self:setGoodCount(0);--清除道具
    self:setWinMoney(0);--输赢
    self:setTrustee(false);
    self:setAlarmTime(0);
    self:setId(0)
    self:setChip(0)
    self:setGiftId(nil);
end

function BasePlayer:initUserInfo(data)
	self:setId(data.uid)
	self:setSeatId(data.seatId)
	self:setBet(data.bet)
end

function BasePlayer:addChip(chip)
    -- body
    local oldChip = self:getChip();
    local chip  = oldChip + chip;
    if chip < 0 then
        chip = 0;
    end
    self:setChip(chip)
end

return BasePlayer  