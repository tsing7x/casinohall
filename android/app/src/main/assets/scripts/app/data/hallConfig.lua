local HallConfig = class()


--服务器地址
addProperty(HallConfig, "addrList", {})
addProperty(HallConfig, "gameList", {})

--消息 公告
addProperty(HallConfig, "newsList", nil)
addProperty(HallConfig, "noticeList", nil)
addProperty(HallConfig, "hasUnckeckMsg", false)
addProperty(HallConfig, "hasNewNotice", false)

--邀请
addProperty(HallConfig, "invitesum", 0)
addProperty(HallConfig, "invitemoney", 1000)
addProperty(HallConfig, "successmoney", 100000)
addProperty(HallConfig, "inviteMaxRewardNum", 50)
--召回
addProperty(HallConfig, "perReward", 1000)
addProperty(HallConfig, "perRewardMsg", "")
--任务
addProperty(HallConfig, "taskList", nil)
addProperty(HallConfig, "taskAward", 0)
--大厅列表
addProperty(HallConfig, "lobbyGames", {}) -- {gameid, path, updateline, icon}
--大厅更新
addProperty(HallConfig, "updateVerUrl", '')
addProperty(HallConfig, "updateZipUrl", '')
--现金币缓存
addProperty(HallConfig, "cashGoodsList", nil)
addProperty(HallConfig, "cashTaskList", nil)
addProperty(HallConfig, "hasFriendReward", false)
--签到奖励缓存
addProperty(HallConfig, "attendenceReward", nil)
--小喇叭缓存
addProperty(HallConfig, "showMsgNum", 0)
addProperty(HallConfig, "lastUserMsgTime", 0)
addProperty(HallConfig, "lastSysMsgTime", 0)
--活动中心是否有新活动
addProperty(HallConfig, "haveActivity", 0)
--当前是否五周年活动期间
addProperty(HallConfig, "isFifthAnniversary", 0)

function HallConfig:clear()
	self:setAddrList({})
	self:setGameList({})
	self:setLobbyGames({})
	self:setNewsList(nil)
	self:setNoticeList(nil)
	self:setHasUnckeckMsg(false)

	self:setTaskList(nil)
	self:setTaskAward(0)
	self:setShowMsgNum(0)
	self:setLastUserMsgTime(0)
	self:setLastSysMsgTime(0)
	self:setHaveActivity(0)
	self:setIsFifthAnniversary(0)
end

--设置大厅更新URL
function HallConfig:setUpdateUrl(data)
	-- body
	self:setUpdateVerUrl(data[1] or '')
	self:setUpdateZipUrl(data[2] or '')
end

function HallConfig:load()
	self.m_set = new(Dict, "HallConfig")
	self.m_set:load()

end

function HallConfig:save()
	self.m_set = new(Dict, "HallConfig")
	self.m_set:save()
end

return HallConfig
