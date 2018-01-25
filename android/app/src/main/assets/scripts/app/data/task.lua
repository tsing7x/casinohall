local Task = class()

addProperty(Task, "id", 0) 				--任务ID
addProperty(Task, "name", "") 			--任务名称
addProperty(Task, "icon", "") 			--任务图标
addProperty(Task, "description", "") 	--任务描述
addProperty(Task, "cycle", 0) 			--任务周期（1长期或者单次任务，2每日任务，3版本任务）
addProperty(Task, "type", 0) 			--任务分类
addProperty(Task, "aim", 0) 			--任务目标
addProperty(Task, "reward", "") 		--任务奖励,json格式，暂时只有游戏币即coins
addProperty(Task, "activated", 0) 		--任务激活情况，1已激活，0未激活
addProperty(Task, "utime", 0) 			--任务更新时间
addProperty(Task, "process", '') 		--任务进度
addProperty(Task, "rewardStatus", 0) 	--领奖状态 0未完成任务，1已完成任务，2已领奖
-- addProperty(Task, "gameId", 0) 			--游戏ID
addProperty(Task, "other", 0) 			--游戏ID

function Task:init(data)
	-- body
	self:setId(data.id)
	self:setName(data.name)
	self:setIcon(data.icon)
	self:setDescription(data.description)
	self:setCycle(data.cycle)
	self:setType(data.type)
	self:setAim(data.aim)
	self:setReward(data.reward)
	self:setActivated(data.activated)
	self:setUtime(data.utime)
	self:setProcess(data.process)
	self:setRewardStatus(data.rewardStatus)
	-- self:setGameId(tonumber(data.gameid))
	self:setOther(data.other or {})
end

return Task