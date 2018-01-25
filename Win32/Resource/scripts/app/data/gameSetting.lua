local GameSetting = class()

addProperty(GameSetting, "isSecondScene", false)
addProperty(GameSetting, "updateTime", 0)
addProperty(GameSetting, "soundVolume", 0.5)
addProperty(GameSetting, "musicVolume", 0.5)
addProperty(GameSetting, "loginType", 0)
addProperty(GameSetting, "millionaireGuest", 0)
addProperty(GameSetting, "multimillionaireGuest", 0)
addProperty(GameSetting, "millionaireFb", 0)
addProperty(GameSetting, "multimillionaireFb", 0)
addProperty(GameSetting, "level", 1)

addProperty(GameSetting, "dateFb", 0)
addProperty(GameSetting, "shareTimesFb", 0)
addProperty(GameSetting, "dateGuest", 0)
addProperty(GameSetting, "shareTimesGuest", 0)
addProperty(GameSetting, "totalNewsNumFb", 0)
addProperty(GameSetting, "totalNoticeNumFb", 0)
addProperty(GameSetting, "totalNewsNumGuest", 0)
addProperty(GameSetting, "totalNoticeNumGuest", 0)
--邀请好友的日期，过0点重置，才可以继续邀请该好友
addProperty(GameSetting, "inviteDateGuest", 0)
addProperty(GameSetting, "inviteIdGuest", "")
addProperty(GameSetting, "inviteDateFb", 0)
addProperty(GameSetting, "inviteIdFb", "")
addProperty(GameSetting, "sesskey", "")         --用于提升FB用户的登陆速度
addProperty(GameSetting, "gcmToken", "")        --个人推送token号
addProperty(GameSetting, "callbackIdGuest", "")     --记录已经发出召回的ID
addProperty(GameSetting, "callbackIdFb", "")
addProperty(GameSetting, "unfinishPayOrder", 0)         --记录未完成的订单数量，每次下单的时候+1，收到发货的时候-1，用来第二天上报给appsflyer
addProperty(GameSetting, "hasReportOrder", 1)           --是否已经上报过未支付数据，

addProperty(GameSetting, "isNewUser", "1")           --是不是新用户,1新用户，0老用户

addProperty(GameSetting, "CDVibrate", true)
addProperty(GameSetting, "autoSit", true)
addProperty(GameSetting, "stTrace", false)
addProperty(GameSetting, "recentPlayGame", "")      --记录最近玩的游戏

local kMaxRecentGame = 6

function GameSetting:load()
	self.m_set = new(Dict, "gameSetting")
	self.m_set:load()

	self:setUpdateTime(self.m_set:getInt("updateTime", 0))
	self:setSoundVolume(self.m_set:getDouble("soundVolume", 0.5))
	self:setMusicVolume(self.m_set:getDouble("musicVolume", 0.5))

	self:setLoginType(self.m_set:getInt("loginType", 0));
	self:setMillionaireGuest(self.m_set:getInt("millionaireGuest", 0))
	self:setMultimillionaireGuest(self.m_set:getInt("multimillionaireGuest", 0))
	self:setMillionaireFb(self.m_set:getInt("millionaireFb", 0))
	self:setMultimillionaireFb(self.m_set:getInt("multimillionaireFb", 0))
	self:setLevel(self.m_set:getInt("level"))
	self:setDateFb(self.m_set:getInt("dateFb", 0))
	local curDay = os.date("!*t").day
	if self:getDateFb() ~= curDay then
		self:setDateFb(curDay)
		self:setShareTimesFb(0)
		self:setInviteIdFb("")
		self:setCallbackIdFb("")
	else
		self:setShareTimesFb(self.m_set:getInt("shareTimesFb", 0))
		self:setInviteIdFb(self.m_set:getString("inviteIdFb"), "")
		self:setCallbackIdFb(self.m_set:getString("callbackIdFb"), "")
	end
	self:setDateGuest(self.m_set:getInt("dateGuest", 0))
	if self:getDateGuest() ~= curDay then
		self:setDateGuest(curDay)
		self:setShareTimesGuest(0)
		self:setInviteIdGuest("")
		self:setCallbackIdGuest("")
	else
		self:setShareTimesGuest(self.m_set:getInt("shareTimesGuest", 0))
		self:setInviteIdGuest(self.m_set:getString("inviteIdGuest"), "")
		self:setCallbackIdGuest(self.m_set:getString("callbackIdGuest"), "")
	end

	--记录当前存留的消息数量，用来决定大厅图标上是否显示红点
	self:setTotalNewsNumFb(self.m_set:getInt("totalNewsNumFb"), 0)
	self:setTotalNoticeNumFb(self.m_set:getInt("totalNoticeNumFb"), 0)
	self:setTotalNewsNumGuest(self.m_set:getInt("totalNewsNumGuest"), 0)
	self:setTotalNoticeNumGuest(self.m_set:getInt("totalNoticeNumGuest"), 0)

	--facebook登陆用sesskey
	self:setSesskey(self.m_set:getString("sesskey"), "")
	self:setGcmToken(self.m_set:getString("gcmToken"), "")

	self:setIsNewUser(self.m_set:getString("isNewUser")=="" and "1" or self.m_set:getString("isNewUser"))

    self:setCDVibrate(self.m_set:getBoolean("CDVibrate", true))
    self:setAutoSit(self.m_set:getBoolean("autoSit", true))
    self:setStTrace(self.m_set:getBoolean("stTrace", false))

    --读取玩过的游戏记录
	self:setRecentPlayGame(self.m_set:getString("recentPlayGame"), "")
end

function GameSetting:save()
	-- self.m_set = new(Dict, "gameSetting")
	-- self.m_set:load()

	self.m_set:setInt("updateTime", self:getUpdateTime() or 0)
	self.m_set:setDouble("soundVolume", self:getSoundVolume() or 0.5)
	self.m_set:setDouble("musicVolume", self:getMusicVolume() or 0.5)
	self.m_set:setInt("loginType", self:getLoginType());
	self.m_set:setInt("millionaireGuest", self:getMillionaireGuest() or 0)
	self.m_set:setInt("multimillionaireGuest", self:getMultimillionaireGuest() or 0)
	self.m_set:setInt("millionaireFb", self:getMillionaireFb() or 0)
	self.m_set:setInt("multimillionaireFb", self:getMultimillionaireFb() or 0)
	self.m_set:setInt("level", self:getLevel() or 1)
	self.m_set:setInt("dateFb", self:getDateFb() or 0)
	self.m_set:setInt("shareTimesFb", self:getShareTimesFb() or 0)
	self.m_set:setInt("dateGuest", self:getDateGuest() or 0)
	self.m_set:setInt("shareTimesGuest", self:getShareTimesGuest() or 0)
	self.m_set:setInt("totalNewsNumFb", self:getTotalNewsNumFb() or 0)
	self.m_set:setInt("totalNoticeNumFb", self:getTotalNoticeNumFb() or 0)
	self.m_set:setInt("totalNewsNumGuest", self:getTotalNewsNumGuest() or 0)
	self.m_set:setInt("totalNoticeNumGuest", self:getTotalNoticeNumGuest() or 0)
	--已经邀请的ID保存
	self.m_set:setInt("inviteDateGuest", self:getInviteDateGuest() or 0)
	self.m_set:setString("inviteIdGuest", self:getInviteIdGuest() or "")
	self.m_set:setInt("inviteDateFb", self:getInviteDateFb() or 0)
	self.m_set:setString("inviteIdFb", self:getInviteIdFb() or "")
	self.m_set:setString("sesskey", self:getSesskey() or "")
	self.m_set:setString("gcmToken", self:getGcmToken() or "")
	self.m_set:setString("callbackIdFb", self:getCallbackIdFb() or "")
	self.m_set:setString("callbackIdGuest", self:getCallbackIdGuest() or "")
	self.m_set:setInt("hasReportOrder", self:getHasReportOrder() or 0)
	self.m_set:setInt("unfinishPayOrder", self:getUnfinishPayOrder() or 0)
	self.m_set:setString("isNewUser", self:getIsNewUser())

    self.m_set:setBoolean("CDVibrate", self:getCDVibrate())
    self.m_set:setBoolean("autoSit", self:getAutoSit())
    self.m_set:setBoolean("stTrace", self:getStTrace())

	self.m_set:setString("recentPlayGame", self:getRecentPlayGame() or "")

	self.m_set:save()
end

function GameSetting:addGameRecord(gameId)
	local gameRecord = self:playRecord()
	local newGameRecord = {}
	table.insert(newGameRecord, gameId)
	for i = 1, #gameRecord do
		if gameRecord[i] ~= gameId and #newGameRecord < kMaxRecentGame then
			table.insert(newGameRecord, gameRecord[i])
		end
	end
	local str = table.concat(newGameRecord, "#")
	self:setRecentPlayGame(str)
	self:save()
end

--最近玩的游戏放在字符串的最前面
function GameSetting:playRecord()
	--记录最近玩的6个游戏
	local str = self:getRecentPlayGame()	
	local gameRecord = {}
	local gameExists = {}
	for gameId in string.gmatch(str,"(%d+)") do
		if not gameExists[gameId] and #gameRecord < kMaxRecentGame then
			table.insert(gameRecord, tonumber(gameId))
			gameExists[gameId] = true
		end
	end
	return gameRecord
end

--
function GameSetting:getCurrentUIDShareHonourEmblemInfo(uid)
	local str = self:getShareHonourEmblem() or ""
	if str and str ~= "" then
		local info
		local list = string.split(str, "|")
		for i=1,#list do
			info = string.trim(list[i])
			if info and info ~= "" then
				local arr = string.split(info, "_")
				if #arr >= 2 and tostring(uid) == arr[1] then
					return arr[2]
				end
			end
		end
	end
	return nil
end
--


return GameSetting
