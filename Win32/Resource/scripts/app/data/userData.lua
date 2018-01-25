local HeadData = require("app.data.headData")
local UserData = class(HeadData)

addProperty(UserData, "id", 0)
addProperty(UserData, "siteId", 0)
addProperty(UserData, "seatId", 0)
addProperty(UserData, "money", 0)
addProperty(UserData, "exp", 0)
addProperty(UserData, "level", 0)
addProperty(UserData, "levelName", "")
addProperty(UserData, "nick", "")
addProperty(UserData, "isLogin", false)
addProperty(UserData, "wintimes", 0)
addProperty(UserData, "drawtimes", 0)
addProperty(UserData, "losetimes", 0)
addProperty(UserData, "regtime", 0)
addProperty(UserData, "sessionId", "")
addProperty(UserData, "status", 0)
addProperty(UserData, "userType", 2) -- 游客
addProperty(UserData, "isAult", 1)
addProperty(UserData, "curExp", 0)
addProperty(UserData, "needExp", 0)
addProperty(UserData, "title", "")
addProperty(UserData, "isbound", 0)
addProperty(UserData, "isRegister", 0)
addProperty(UserData, "avoidFirstPay", false)
addProperty(UserData, "tarr", {})
addProperty(UserData, "tid", 0)
addProperty(UserData, "boundmsg", "")
addProperty(UserData, 'maxMoney', 0)
addProperty(UserData, 'maxwMoney', 0)
addProperty(UserData, 'cashPoint', 0)

--头像上传临时图片名
addProperty(UserData, "uploadTemp", "")

addProperty(UserData, "thirdToken", "") --第三方token

addProperty(UserData, "urls", {})
addProperty(UserData, "hasUnckeckMsg", false)
addProperty(UserData, "hasNewNotice", false)

--未经php过滤的好友列表
addProperty(UserData, "originalInviteFriend", nil)
addProperty(UserData, "inviteFriend", nil)
addProperty(UserData, "leftInviteNum", 50)
addProperty(UserData, "leftCallbackNum", 50)
--可以召回的玩家列表
addProperty(UserData, "callbackFriend", nil)
-- --好友
addProperty(UserData, "unreadApply", 0)
addProperty(UserData, "unreadGigt", 0)

addProperty(UserData, "isVip", 0)
--礼物列表缓存
addProperty(UserData, "giftList", nil)
--当前自己的礼物，0表示没有
addProperty(UserData, "giftId", nil)
--邀请
addProperty(UserData, "invitesum", 0)
addProperty(UserData, "invitemoney", 1000)
addProperty(UserData, "successmoney", 100000)
--道具数量
addProperty(UserData, "propCount", 0)
--私人房卡
addProperty(UserData, "roomCardNum", 0)
--小喇叭数量
addProperty(UserData, "speakerNum", 0)
--记录玩家的小喇叭发送记录
addProperty(UserData, "speakerRecord", {})
--
addProperty(UserData, "propCfgList", {})

function UserData:ctor()
	
end


function UserData:addMoney(money, animFlag)
	local moneyPre = self:getMoney()
	local moneyNow = moneyPre + money
	if moneyNow < 0 then moneyNow = 0 end

	self:setMoney(moneyNow)
	if animFlag then
		-- 播放金币雨
		AnimationParticles.play(AnimationParticles.DropCoin)
		kEffectPlayer:play('audio_get_gold')
	end
end

local setMoney = UserData.setMoney
function UserData:setMoney(money, animFlag)
	if money < 0 then money = 0 end
	setMoney(self, money)
	-- if self:getMoney() >= MyBaseInfoData:getBrokenMoney() then
	-- 	self:setAvoidFirstPay(false)
	-- end
	if animFlag then
		-- 播放金币雨
		AnimationParticles.play(AnimationParticles.DropCoin)
	end
	return self
end

function UserData:addProp(prop)
	self:setPropCount(tonumber(self:getPropCount() or 0) + tonumber(prop or 0))
end

--对外统一的道具处理接口，避免道具的处理散落各处,保留的propCount这些数据只是为了给其他地方绑定用的，以后所有道具的变更用这3个接口处理
function UserData:setPropNum(pnid, count)
	local propId = tonumber(pnid)
	local number = tonumber(count) or 0
	if propId == kIDPrivateRoomCard then
		self:setRoomCardNum(number)
	elseif propId == kIDSpeaker then
		self:setSpeakerNum(number)
	elseif propId == kIDInteractiveProp then
		self:setPropCount(number)
	end
end

function UserData:getPropNum(pnid)
	local propId = tonumber(pnid)
	if propId == kIDPrivateRoomCard then
		return self:getRoomCardNum() or 0
	elseif propId == kIDSpeaker then
		return self:getSpeakerNum() or 0
	elseif propId == kIDInteractiveProp then
		return self:getPropCount() or 0
	end
end

function UserData:addPropNum(pnid, num)
	local propId = tonumber(pnid)
	local number = tonumber(num) or 0
	if propId == kIDPrivateRoomCard then
		self:setRoomCardNum(self:getRoomCardNum() + number)
	elseif propId == kIDSpeaker then
		self:setSpeakerNum(self:getSpeakerNum() + number)
	elseif propId == kIDInteractiveProp then
		self:setPropCount(self:getPropCount() + number)
	end
end

function UserData:clear()
	self:setIsLogin(false)
	self:setId(0)
	self:setMoney(0)
	self:setCashPoint(0)
	self:setSex(1)
	self:setNick("")
	self:setIsbound(0)
	self:setSessionId("")
	self:setAvoidFirstPay(false)
	self:setBoundmsg("");
	self:setHeadUrl("");
	-- self:setAddrList({});
	self:setOriginalInviteFriend(nil)
	self:setLeftInviteNum(50)
	self:setLeftCallbackNum(50)
	self:setInviteFriend(nil);
	self:setCallbackFriend(nil);

	self:setUnreadApply(0)
	self:setUnreadGigt(0)
	self:setHasUnckeckMsg(false)

	self:setIsVip(0);
	--支付
	MyPayMode = nil
	self:setGiftList(nil)
	self:setGiftId(nil)
	self:setRoomCardNum(0);
	self:setSpeakerNum(0)
	self:setSpeakerRecord({});
end

function UserData:initUserInfo(data)
	self:setIsLogin(true)
	self:setId(tonumber(data.mid or 0))
	self:setSiteId(tostring(data.sitemid or ""))
	self:setNick(data.name or "")
	self:setMoney(data.money or 0)
	self:setCashPoint(data.diamond or 0)
	--后台数据库按1是男、2是女存储性别
	if data.msex and tonumber(data.msex) > 0 then
		self:setSex(tonumber(data.msex) - 1)
	else
		self:setSex(0)
	end

	self:setUserType(tonumber(data.lid))
	self:setLevel(data.level or 0)
	-- 头像
	if ToolKit.isValidString(data.miconbig) then
		self:setHeadUrl(data.micon)
	else
		self:setHeadUrl(data.micon)
	end
	-- 胜负平
	self:setWintimes(data.wintimes or 0)
	self:setLosetimes(data.losetimes or 0)
	self:setDrawtimes(data.drawtimes or 0)
	self:setRegtime(data.regtime or 0)
	self:setSessionId(data.sesskey or "")
	self:setStatus(data.status or 0)
	-- 是否绑定
	self:setIsbound(data.isbound or 0)
	self:setBoundmsg(data.boundmsg or "");
	
	self:setIsRegister(data.register or 0)
	self:setExp(data.exp or 0)
	self:setMaxMoney(data.maxmoney or 0)
	self:setMaxwMoney(data.maxwmoney or 0)
	self:setUnreadApply(0);
	self:setUnreadGigt(0);
end

function UserData:getFormatMoney()
	return ToolKit.formatMoney(self:getMoney())
end

function UserData:getSkipMoney()
	return ToolKit.skipMoney(self:getMoney())
end

function UserData:getFormatNick(num)
	return ToolKit.subStr(self:getNick(), num or 9)
end

--根据输赢的金币 更新战绩
function UserData:freshZhanjiByTurnMoney(turnMoney)
	if not turnMoney then return end
	if turnMoney > 0 then
		self:setWintimes(self:getWintimes() + 1)
	elseif turnMoney == 0 then
		self:setDrawtimes(self:getDrawtimes() + 1)
	else
		self:setLosetimes(self:getLosetimes() + 1)
	end
end

function UserData:setZhanji(wintimes, losetimes, drawtimes)
	self:setWintimes(wintimes or 0)
	self:setLosetimes(losetimes or 0)
	self:setDrawtimes(drawtimes or 0)
end

function UserData:getZhanji()
	return self:getWintimes() or 0, self:getLosetimes() or 0, self:getDrawtimes() or 0
end

function UserData:getZhanjiRate()
	local total = self:getWintimes() + self:getLosetimes() + self:getDrawtimes()
	local rate = total == 0 and 0 or self:getWintimes() / total 
	return string.format("%.01f%%", rate * 100)
end

-- 刷新数据源
function UserData:refreshInfo()
	self:setNick(self:getNick())
		:setSex(self:getSex())
		:setExp(self:getExp())
		:setLevel(self:getLevel())
		:setWintimes(self:getWintimes())
		:setLosetimes(self:getLosetimes())
		:setDrawtimes(self:getDrawtimes())
		:setHeadUrl(self:getHeadUrl())
end

function UserData:initPlayerInfo(data)
	local iUserInfo = json.decode(data.iUserInfo) or {}
	self:setId(data.iUserId)
		:setMoney(data.iMoney)
		:setSeatId(data.iSeatId)
		:setNick(iUserInfo.nickName or "")
		:setSex(iUserInfo.sex or 1)
		:setLevel(iUserInfo.level or 1)
		:setWintimes(iUserInfo.winCount or 0)
		:setLosetimes(iUserInfo.loseCount or 0)
		:setDrawtimes(iUserInfo.deuceCount or 0)
		:setLevelName(iUserInfo.levelName or "")
	-- 头像
	if ToolKit.isValidString(iUserInfo.bimg) then
		self:setHeadUrl(iUserInfo.bimg)
	else
		self:setHeadUrl(iUserInfo.simg)
	end
end

function UserData:packPlayerInfo()
	return {
		nickName 		= self:getNick(),
		sex 			= self:getSex(),
		level 			= self:getLevel(),
		winCount 		= self:getWintimes(),
		loseCount 		= self:getLosetimes(),
		deuceCount 		= self:getDrawtimes(),
		bimg 			= self:getHeadUrl(),
		simg 			= self:getHeadUrl(),
	}
end

return UserData  
