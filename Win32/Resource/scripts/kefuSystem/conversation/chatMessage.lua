local UI = require('byui/basic')
local AL = require('byui/autolayout')
local Layout = require('byui/layout')
local Am = require('animation')--require('kefuSystem/animation)
local class, mixin, super = unpack(require('byui/class'))
local kefuCommon = require('kefuSystem/kefuCommon')

local KefuEmoji = require('kefuSystem/common/kefuEmojiCfg')

local chatMessage
chatMessage = class('chatMessage', nil, {
	__init__ = function (self, seqId, types, msg, sessionId, isClient)
		self.seqId = tonumber(seqId)
		self.types = tonumber(types)
		self.msg = msg
		self.sessionId = sessionId
		self.isClient = isClient or 1 			--1. 用户消息  0. 客服端消息
	end,

	getStringTime = function (self)
		local msgTime = tonumber(self.seqId)/1000
		msgTime = math.floor(msgTime)

		return kefuCommon.getStringTime(msgTime)
	end,

	saveToDict = function (self, isSave)
		local UserData = require('kefuSystem/conversation/sessionData')
		if self.m_jsonStr then
			UserData.insertHistoryMsg(self.m_jsonStr, isSave)
			return
		end
		
		--如果是机器人消息或者不是vip聊天，则不保存
		local data = UserData.getStatusData() or {}
		-- if not data.isVip then return end
		if tonumber(self.types) == 4 then return end 

		local tb = {}
		tb.msg = string.gsub(self.msg, [[\]], [[\\]])
		tb.isClient = self.isClient
		tb.seqId = self.seqId
		tb.types = self.types


		self.m_jsonStr = cjson.encode(tb)

		UserData.insertHistoryMsg(self.m_jsonStr, isSave)

	end,

	--把表情名字转为unicode字符
	faceChar2UnicodeChar = function (self)
		if self.types == 1 and self.msg then
			self.msg = string.gsub(self.msg, "%[(.-)%]", function (char)
				if KefuEmoji.NameToId[char] then
					return kefuCommon.unicodeToChar(KefuEmoji.NameToId[char])
				else
					return string.format("[%s]", char)
				end
			end)
		end
	end,

	--把表情unicode码值转为emoji名字
	--输入的时候记下表情字符，之后在这里直接替换相应的字符
	unicode2Emoji = function (self)
		if self.types == 1 and self.faceChars then
			local msg = self.msg
			for i, v in ipairs(self.faceChars) do
				local u = kefuCommon.utf8to32(v)
				local idx = tonumber(u[1]) - KefuEmoji.StartIdx + 1
				local emojiName = string.format("[e%s]", KefuEmoji.Name[idx])
				msg = string.gsub(msg, v, emojiName)
			end

			return msg
		end

		return self.msg
	end,
})


return chatMessage