local langConf = require("app.res.config")

local SpeakerQueue = class()

local KSYSURGENT = 3    --系统紧急公告
local KUSERSPEAKER = 4  --玩家小喇叭广播
local KGAMETRIGGER = 5  --游戏中触发的事件
local KSYSSEND = 6      --系统运营活动广播

function SpeakerQueue:ctor()
	self.msgQueue = {}
	self.timerStop = true
	self.speakerSys = {}
	self.speakerUser = {}
end

--对外提供的唯一接口，增加新的需要显示的小喇叭消息
function SpeakerQueue:addNewMsg(data)
	--按系统消息和用户消息分类记录，最多30条
	local dataType = data and tonumber(data.type) or 0
	if dataType == KSYSURGENT or dataType == KGAMETRIGGER or dataType == KSYSSEND then
		table.insert(self.speakerSys, data)
		if #self.speakerSys > 30 then
			table.remove(self.speakerSys, 1)
		end
	elseif dataType == KUSERSPEAKER then
		table.insert(self.speakerUser, data)
		if #self.speakerUser > 30 then
			table.remove(self.speakerUser, 1)
		end
	end
	--self.msgQueue是类似堆栈的结构，尾部是weight值最小的，也就是优先级最高的，播放的时候从尾部开始播放
	for i = 1, #self.msgQueue do
		local msg = self.msgQueue[i]
		if tonumber(msg.weight or 0) <= tonumber(data.weight or 0) then
			table.insert(self.msgQueue, i, data)
			self:startSpeaker()
			return
		end
	end
	table.insert(self.msgQueue, data)
	self:startSpeaker()
end

function SpeakerQueue:getSpeakerSys()
	return self.speakerSys
end

function SpeakerQueue:getSpeakerUser()
	return self.speakerUser
end

function SpeakerQueue:startSpeaker()
	--正在播放期间不需要处理，等候自动轮询
	if self.timerStop then
		--消息隔10秒显示一条
		self:showMsg()
		self.showAnim = new(AnimInt, kAnimRepeat, 0, 1, 10000, 0);
		self.showAnim:setEvent(
			nil,
			function()
				self:showMsg()
			end
		)
	end
end

function SpeakerQueue:stopSpeaker()
	delete(self.showAnim)
	self.showAnim = nil
end

function SpeakerQueue:getTextNode(msg)
	--系统紧急公告，全部使用黄色字体
	local dataType = tonumber(msg.type)
	if dataType == KSYSURGENT then
		local content = msg.content or ""
		content = string.format("[%s]%s", "ข่าวระบบ", content)
		local textNode = new(Text, content, 0, 0, kAlignLeft, "", 24, 0xff, 0xff, 0x00)
		return textNode
		--玩家小喇叭广播
	elseif dataType == KUSERSPEAKER then
		local name = msg.name or ""
		local id = msg.id or ""
		local content = msg.content or ""
		content = string.lower(content)
		local illegalWord = require("app.lobby.illegalWord")
		if illegalWord then
			for i = 1, #illegalWord do
				content = string.gsub(content, illegalWord[i], "**")
			end
		end

		local textNode = ToolKit.createTexts({{text = name.."("..id.."): ", size = 24, r = 0xff, g = 0xff, b = 0x00},
				{text = content, size = 22, r = 0xff, g = 0xff, g = 0xff},
		})
		return textNode
		--玩家触发特定场景发送的小喇叭
	elseif dataType == KGAMETRIGGER then
		local textParam = {}
		table.insert(textParam, {text = string.format("【%s】", langConf.str_BorCast_MsgSys), size = 24, r = 0xff, g = 0xff, b = 0xff})
		local content = msg.content or ""
		local params = msg.params or {}
		--由于玩家触发的小喇叭的格式不是一致的，需要替换的变量放在params里
		for param1, param2 in string.gmatch(content, "(.-)<#(.-)#>") do
			if param1 ~= "" then
				table.insert(textParam, {text = param1, size = 24, r = 0xff, g = 0xff, b = 0xff})
			end
			local value = params[tostring(param2)]
			if value and value ~= "" then
				table.insert(textParam, {text = " "..value.." ", size = 22, r = 0xff, g = 0xff, b = 0x00})
			end
		end
		local leftWord = string.match(content, ".*#>(.*)")
		if leftWord and leftWord ~= "" then
			table.insert(textParam, {text = leftWord, size = 22, r = 0xff, g = 0xff, b = 0xff})
		end
		local textNode = ToolKit.createTexts(textParam)
		return textNode
		--系统发送的广播
	elseif dataType == KSYSSEND then
		local content = msg.content or ""
		content = string.format("【%s】%s", langConf.str_BorCast_MsgSys, content)
		local textNode = new(Text, content, 0, 0, kAlignLeft, "", 22, 0xff, 0xff, 0xff)
		return textNode
	end

end

function SpeakerQueue:showMsg()
	local msg = self.msgQueue[#self.msgQueue]
	if not msg then
		--消息播放完了
		self:stopSpeaker()
		self.timerStop = true
		return
	end

	table.remove(self.msgQueue, #self.msgQueue)
	self.timerStop = false
	local textNode = self:getTextNode(msg)
	if textNode then
		EventDispatcher.getInstance():dispatch(Event.Message, "showSpeakerMsg", textNode)
	end

end

function SpeakerQueue:dtor()

end

return SpeakerQueue
