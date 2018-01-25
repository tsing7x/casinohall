local FriendData = class(require("data.headData"))

addProperty(FriendData, "id", 0)
addProperty(FriendData, "roomid", 0)
addProperty(FriendData, "gameid", 0)
addProperty(FriendData, "gameName", 0)
addProperty(FriendData, "name", "")
addProperty(FriendData, "money", 0)
addProperty(FriendData, "exp", 0)
addProperty(FriendData, "level", 0)     --个人的经验等级
addProperty(FriendData, "isOnline", 0)
addProperty(FriendData, "mltime", 0)
addProperty(FriendData, "visible", false)
addProperty(FriendData, "gift", false)
addProperty(FriendData, "canSendMoney", 0)
addProperty(FriendData, "giftid", 0)
addProperty(FriendData, "lv", 0)        --所在游戏房间的level，101， 102这种
addProperty(FriendData, "time", 0)
addProperty(FriendData, "bankrupt", 0)      --是否破产了
addProperty(FriendData, "giftId", nil)

function FriendData:ctor()

end

function FriendData:init(param)
	self:setId(param.fid)
	self:setName(param.name)
	self:setRoomid(param.roomid)
	self:setGameid(param.gameid)
	self:setGameName(param.gameName)
    if tonumber(param.msex) and tonumber(param.msex) > 0 then
        self:setSex(tonumber(param.msex) - 1)
    else
        self:setSex(0)
    end
	--self:setSex(tonumber(param.msex) or 0);
	self:setHeadUrl(param.micon);
	self:setMoney(param.money);
	self:setExp(param.exp);
	self:setLevel(param.level);
	self:setIsOnline(param.isOnline);
	self:setMltime(param.mltime);
	self:setVisible(true);
	self:setGift(param.gift == nil and true or false);
	self:setCanSendMoney(param.canSendMoney or 0);
	self:setGiftid(param.giftid or 0);
	self:setLv(param.lv or 0);
	self:setTime(param.time or os.time());
    self:setBankrupt(param.bankrupt or 0);
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
end

function FriendData:dtor()

end

return FriendData  