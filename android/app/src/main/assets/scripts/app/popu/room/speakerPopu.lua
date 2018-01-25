local SpeakerPopu = class(require("app.popu.gameWindow"))
local Hall_string = require("app.res.config")
local speakerRecordItem=require("app.view.view.roomSpeakerRecordItem")
function SpeakerPopu:ctor()

end

function SpeakerPopu:dtor()

end

function SpeakerPopu:initView()
	local btnClose = self:findChildByName("btn_close")
	btnClose:setOnClick(
		nil,
		function()
			self:dismiss()
		end
	)

	local imgTabBg = self:findChildByName("img_tabBg")
	local btns = {
		imgTabBg:findChildByName("btn_speaker"),
		imgTabBg:findChildByName("btn_record"),
	}
	local views = {
		self:findChildByName("view_speaker"),
		self:findChildByName("view_record"),
	}
	for i = 1, #btns do
		local btn = btns[i]
		btn:setOnClick(
			nil,
			function()
				for j = 1, #btns do
					btns[j]:findChildByName("img_select"):setVisible(i == j)
				end
				for j = 1, #views do
					views[j]:setVisible(i == j)
				end
			end
		)
	end
	-- self:findChildByName("view_speaker"):setVisible(true)
	-- self:findChildByName("view_record"):setVisible(false)
	self:initSendSpeaker()
	self:initSpeakerRecord()
end

function SpeakerPopu:initSendSpeaker()
	local view = self:findChildByName("view_speaker")

	view:findChildByName("text_tips"):setText(Hall_string.str_speaker_use_tips)

	local btnSend = view:findChildByName("btn_send")
	btnSend:findChildByName("text_btn"):setText(Hall_string.str_send_chat)
	local etSpeaker = view:findChildByName("et_speaker")
	-- setMaxLength(50)限制的只有英文和数字
	etSpeaker:setMaxLength(49)
	etSpeaker:setOnTextChange(nil,function ()
		local realcount=string.lenutf8(etSpeaker:getText())
		if realcount >= 49 then
			AlarmTip.play(Hall_string.str_speaker_too_much_word)
		end
	end)
	view:findChildByName("text_msg_num"):setText(MyUserData:getPropNum(kIDSpeaker))
	btnSend:setOnClick(
		nil,
		function()
			local text = etSpeaker:getText()
			if string.lenutf8(text) > 49 then
				AlarmTip.play(Hall_string.str_speaker_too_much_word)
				return
			end
			local textWithoutSpace = string.ltrim(text)
			printInfo("zyh textWithoutSpace "..tostring(textWithoutSpace))
			if textWithoutSpace and textWithoutSpace ~= "" then
				--发送小喇叭
				printInfo("zyh self.isSpeakerNow "..tostring(self.isSpeakerNow))
				local illegalWord = require("app.lobby.illegalWord")
				if illegalWord then
					for i = 1, #illegalWord do
						text= string.gsub(text, illegalWord[i], "**")
					end
				end
				if MyUserData:getPropNum(kIDSpeaker) > 0 then
					HttpModule.getInstance():execute(HttpModule.s_cmds.SEND_SPEAKER, {content = text}, false, false)
					table.insert(MyUserData:getSpeakerRecord(), text)
					-- MySpeakerQueue:startSpeaker()
					self:dismiss()
				else
					AlarmTip.play(Hall_string.STR_SPEAKER_NUM_ZERO)
					WindowManager:showWindow(WindowTag.ShopPopu, {tab = 3}, WindowStyle.TRANSLATE_RIGHT)
				end

			else
				AlarmTip.play(Hall_string.str_chat_input_empty)
			end

		end
	)
end

function SpeakerPopu:initSpeakerRecord()
	local view = self:findChildByName("view_record")
	local svRecord = view:findChildByName("sv_record")
	svRecord:removeAllChildren()
	svRecord:setDirection(kVertical)
	svRecord:setAutoPosition(true)
	local userRecord = MySpeakerQueue:getSpeakerUser()
	for i = 1, #userRecord do
		local name = "["..(userRecord[i].name or "").."]"..":"
		local content = name..userRecord[i].content or ""
		content = string.lower(content)
		local illegalWord = require("app.lobby.illegalWord")
		if illegalWord then
			for i = 1, #illegalWord do
				content = string.gsub(content, illegalWord[i], "**")
			end
		end
		local item = SceneLoader.load(speakerRecordItem)
		local imgTextBg = item:findChildByName("recordItem")
		local maxWidth = imgTextBg:getSize() - 5
		local textView = new(TextView, content, maxWidth, 0, kAlignTopLeft, "", 24, 0x66, 0x87, 0xcf)
		-- local x, y = textName:getPos()
		textView:setPos(5, 0)
		imgTextBg:addChild(textView)
		local _, h = textView:getSize()
		imgTextBg:setSize(nil, h + 30)
		item:setSize(nil, h + 30)
		svRecord:addChild(item)
		item:setAlign(kAlignTopLeft)
		-- svRecord:scrollItemToView(item)
	end
	-- for i = 1, #userRecord do
	-- 	local item = SceneLoader.load(viewRecoreItem)
	-- 	local imgTextBg = item:findChildByName("img_textBg")
	-- 	local textName = item:findChildByName("text_name")
	-- 	textName:setText(name)
	-- 	local maxWidth = imgTextBg:getSize() - textName.m_res.m_width - 10
	-- 	local textView = new(TextView, content, maxWidth, 0, kAlignTopLeft, "", 24, 0x66, 0x87, 0xcf)
	-- 	local x, y = textName:getPos()
	-- 	textView:setPos(textName.m_res.m_width + x + 5, y)
	-- 	imgTextBg:addChild(textView)
	-- 	local _, h = textView:getSize()
	-- 	imgTextBg:setSize(nil, h + 10)
	-- 	item:setSize(nil, h + 10)
	-- 	svRecord:addChild(item)
	-- end
end
-- function SpeakerPopu:onSendSpeaker(isSuccess, data)
-- 	if app:checkResponseOk(isSuccess, data) then
-- 		local etWord = self:findChildByName("et_speaker")
-- 		local word = etWord:getText()
-- 		-- self:addRecord(word)
-- 		etWord:setText("")
-- 		MyUserData:setPropNum(kIDSpeaker,data.data.pcnter)
-- 		self:dismiss()
-- 	end
-- end

-- function SpeakerPopu:addRecord( str )
-- 	local svRecord = self:findChildByName("sv_record")
-- 	local name = "["..(MyUserData:getNick() or "").."]"..":"
-- 	local content = name..str or ""
-- 	content = string.lower(content)
-- 	local illegalWord = require("app.lobby.illegalWord")
-- 	if illegalWord then
-- 		for i = 1, #illegalWord do
-- 			content = string.gsub(content, illegalWord[i], "**")
-- 		end
-- 	end
-- 	local item = SceneLoader.load(speakerRecordItem)
-- 	local imgTextBg = item:findChildByName("recordItem")
-- 	local maxWidth = imgTextBg:getSize() - 5
-- 	local textView = new(TextView, content, maxWidth, 0, kAlignTopLeft, "", 24, 0x66, 0x87, 0xcf)
-- 	textView:setPos(5, 0)
-- 	imgTextBg:addChild(textView)
-- 	local _, h = textView:getSize()
-- 	imgTextBg:setSize(nil, h + 30)
-- 	item:setSize(nil, h + 30)
-- 	svRecord:addChild(item)
-- 	item:setAlign(kAlignTopLeft)
-- 	-- svRecord:scrollItemToView(item)
-- end
SpeakerPopu.s_severCmdEventFuncMap = {

-- [HttpModule.s_cmds.SEND_SPEAKER]      = SpeakerPopu.onSendSpeaker,

}

return SpeakerPopu
