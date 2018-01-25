local CashTask = class(require('app.data.imgData'))

addProperty(CashTask, "id", 0) 				--任务ID
addProperty(CashTask, "title", "") 			--任务名称
addProperty(CashTask, "content", "") 	    --任务描述
addProperty(CashTask, "type", 0) 			--任务分类
addProperty(CashTask, "reward", "") 		--任务奖励,json格式，暂时只有游戏币即coins
addProperty(CashTask, "image", "")
addProperty(CashTask, "process", '') 		--任务进度

function CashTask:init(data)
	-- body
	self:setId(data.id)
	self:setTitle(data.title)
    self:setContent(data.content)
    self:setType(data.type)
	self:setReward(data.reward)
	self:setProcess(data.process)
end

return CashTask