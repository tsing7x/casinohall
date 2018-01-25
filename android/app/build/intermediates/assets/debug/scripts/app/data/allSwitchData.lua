--用于控制全局所有需要开关控制的功能或者活动

local AllSwitch = class()
addProperty(AllSwitch, "friendRoom", 0)             --用于控制好友房的开关
addProperty(AllSwitch, "showInviteReward", 0)				--是否显示邀请奖励，默认不显示
addProperty(AllSwitch, "adOrder", 0)				--广告播放顺序，0：不放广告，1：优先播放unity3d ads ,2：优先播放applovin广告
addProperty(AllSwitch, "activityTips", false)       --是否显示活动中心红点

function AllSwitch:ctor()

end

function AllSwitch:dtor()

end

function AllSwitch:init(param)
    self:setFriendRoom(tonumber(param.friendRoom) or 0)
    self:setShowInviteReward(tonumber(param.showInviteReward) or 0)
    self:setAdOrder(tonumber(param.vnAdOrder) or 0)
    self:setActivityTips(tonumber(param.activityTips) == 1)
end

function AllSwitch:clear()
    self:setFriendRoom(0)
end

return AllSwitch