local RoomChatAndSpeakerPopu = class(require("app.popu.gameWindow"))
--图标尚未放置
local speakerRecordItem=require("app.view.view.roomSpeakerRecordItem")
local Hall_string = require("app.res.config")

function RoomChatAndSpeakerPopu:ctor()
end
function RoomChatAndSpeakerPopu:dtor()
end
function RoomChatAndSpeakerPopu:initView(data)
	local viewBtn = self:findChildByName("view_button")
	local btns = {
		viewBtn:findChildByName("view_btn_expression"),
		viewBtn:findChildByName("view_btn_chat"),
		viewBtn:findChildByName("view_btn_speaker"),
	}
	self.viewExpression = self:findChildByName("view_expression")
	self.viewWord = self:findChildByName("view_word")
	self.viewSpeaker = self:findChildByName("view_speaker")
	self.svSpeaker = self:findChildByName("sv_speakerHistory")

	self.imgSendWord = self:findChildByName("img_sendWordBg")
	self.imgSendWord:setVisible(false)
	local iconSpeaker = self:findChildByName("img_speakerIcon")
	local countSpeaker= self:findChildByName("img_mark")
	self.isSpeakerNow = false
	-- iconSpeaker:setVisible(false)
	-- countSpeaker:setVisible(false)
	local views = {self.viewExpression, self.viewWord, self.viewSpeaker}
	local textNum = self.imgSendWord:findChildByName("text_num")
	UIEx.bind(self, MyUserData, "speakerNum", function(value)
							textNum:setText(value)
	end)
	textNum:setText(MyUserData:getPropNum(kIDSpeaker))
	for i = 1, #btns do
		btns[i]:findChildByName("btn_unselect"):setOnClick(self,function(self)
			--点击的是小喇叭，需要记录发送信息是小喇叭
			if i == 3 then
				-- if data.noSpeaker then
				-- 	AlarmTip.play(STR_GAME_NO_SPEAKER)
				-- 	return
				-- end
				self.isSpeakerNow = true
				iconSpeaker:setVisible(true)
				countSpeaker:setVisible(true)
			else
				self.isSpeakerNow = false
				iconSpeaker:setVisible(false)
				countSpeaker:setVisible(false)
			end
			if i == 1 then
				self.imgSendWord:setVisible(false)
			else
				self.imgSendWord:setVisible(true)
			end
			for j = 1, #btns do
				btns[j]:findChildByName("btn_unselect"):setVisible(i ~= j)
				btns[j]:findChildByName("img_select"):setVisible(i == j)
				views[j]:setVisible(i == j)
			end
		end																									)
	end
	if data.to=="face" then
		btns[2]:findChildByName("img_select"):setVisible(false)
		views[2]:setVisible(false)
		self.imgSendWord:setVisible(false)
		btns[1]:findChildByName("img_select"):setVisible(true)
		views[1]:setVisible(true)
	elseif data.to=="chat" then
		btns[1]:findChildByName("img_select"):setVisible(false)
		views[1]:setVisible(false)
		self.imgSendWord:setVisible(true)
		btns[2]:findChildByName("img_select"):setVisible(true)
		views[2]:setVisible(true)
	end

	self:findChildByName("btn_close"):setOnClick(self,function ( self )
		self:dismiss()
	end)

	self:initSendWord()
	self:initExpression()
	self:initWord(data.chatwords)
	self:initSpeaker()
end

function RoomChatAndSpeakerPopu:show(style)
	JLog.d("RoomChatAndSpeakerPopu:show");
	self.super.show(self,style);
	local img_popuBg = self:findChildByName("img_popuBg")
	self.isOpening = true;
	checkAndRemoveOneProp(img_popuBg, 1)
	local showAnim = img_popuBg:addPropScale(1, kAnimNormal, 300, 0, 0, 1, 0, 1, kCenterXY, 0, CONFIG_SCREEN_HEIGHT)
	if showAnim then
		showAnim:setEvent(
			self,
			function ( ... )
				self.isOpening = false;
				checkAndRemoveOneProp(img_popuBg, 1)
			end
		)
	end
end

function RoomChatAndSpeakerPopu:dismiss(directFlag, isOtherDismiss, dismissStyle)
	if self.isOpening or self.isClosing then
		return
	end

	local img_popuBg = self:findChildByName("img_popuBg")

	self.isClosing = true
	checkAndRemoveOneProp(img_popuBg, 1)
	local hideAnim = img_popuBg:addPropScale(1, kAnimNormal, 200, 0, 1, 0, 1, 0, kCenterXY, 0, CONFIG_SCREEN_HEIGHT)
	if hideAnim then
		hideAnim:setEvent(
			nil,
			function()
				self.isClosing = false
				checkAndRemoveOneProp(img_popuBg, 1)
				self.super.dismiss(self,directFlag, isOtherDismiss, dismissStyle)
			end
		)
	end
end

function RoomChatAndSpeakerPopu:initSendWord()
	--初始化发送消息
	local inputText = self:findChildByName("et_sendWord")
	inputText:setMaxLength(49)
	inputText:setOnTextChange(nil,function ()
		local realcount=string.lenutf8(inputText:getText())
		if realcount >= 49 then
			AlarmTip.play(Hall_string.str_speaker_too_much_word)
		end
	end)
	local btnSendWord = self:findChildByName("btn_sendWord")
	-- inputText.setHintText("1234566")
	btnSendWord:setOnClick(
		nil,
		function()
			printInfo("zyh btnSendWord click ")
			local text = inputText:getText()
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

				if self.isSpeakerNow then
					if MyUserData:getPropNum(kIDSpeaker) > 0 then
						HttpModule.getInstance():execute(HttpModule.s_cmds.SEND_SPEAKER, {content = text}, false, false)
						table.insert(MyUserData:getSpeakerRecord(), text)
					else
						AlarmTip.play(Hall_string.STR_SPEAKER_NUM_ZERO)
						WindowManager:showWindow(WindowTag.ShopPopu, {tab = 3}, WindowStyle.TRANSLATE_RIGHT)
					end
				else
					EventDispatcher.getInstance():dispatch(Event.Message, "sendChatWord", text)
					--requestSendWord
					self:dismiss()
				end
			else
				AlarmTip.play(Hall_string.str_chat_input_empty)
			end
		end
	)
end

function RoomChatAndSpeakerPopu:initExpression()
	-- local switchBtns = self.viewExpression:findChildByName("img_switchBg")
	-- local btns = {
	-- 	switchBtns:findChildByName("btn_normal"),
	-- 	switchBtns:findChildByName("btn_elephant"),
	-- 	switchBtns:findChildByName("btn_special"),
	-- }
	local viewList = {
		self.viewExpression:findChildByName("view_normalList"),
		-- self.viewExpression:findChildByName("view_elephantList"),
		-- self.viewExpression:findChildByName("view_specialList"),
	}
	-- local textBtn = {STR_CHAT_FACE_TEXT, STR_EXPRESSION_ELEPHANT, STR_EXPRESSION_KING}
	-- for i = 1, #btns do
	-- 	btns[i]:findChildByName("text_btn"):setText(textBtn[i])
	-- 	btns[i]:setOnClick(
	-- 		self,
	-- 		function()
	-- 			for j = 1, #btns do
	-- 				btns[j]:findChildByName("img_select"):setVisible(i == j)
	-- 				viewList[j]:setVisible(i == j)
	-- 			end
	-- 		end
	-- 										)
	-- end

	--初始化默认表情
	local EXP_COUNT_IN_LINE = 4
	local FACE_ITEM_HEIGHT = 95

	local svNormal = viewList[1]:findChildByName("sv_normalList")
	local wInterVal = svNormal:getSize() / EXP_COUNT_IN_LINE
	--
	local faceq_res_map_new = require("app.room.chat.faceq_res_new")
	--用faceShowIndex来自定义修改表情在输入框的显示顺序，资源文件里的索引和原来的保持一致，兼容线上的
	local faceShowIndex = {1, 11, 3, 4, 17, 15, 14, 19, 6, 7, 16, 2, 21, 9, 20, 5, 13, 10, 12, 18, 8}
	local x, y = 10, 0
	for i = 1, #faceShowIndex do
		local index = faceShowIndex[i]
		local faceBtn = new(Button, "ui/blank.png")
		faceBtn:setSize(76,76)
		local faceImg = new(Image, faceq_res_map_new[string.format("expression%d.png", index)] or "")
		faceImg:setAlign(kAlignCenter)
		faceBtn:addChild(faceImg)
		faceBtn:setOnClick(
			nil,
			function()
				EventDispatcher.getInstance():dispatch(Event.Message, "sendChatFace", index)
				self:dismiss()
			end
		)
		faceBtn:setPos(x, y)
		--ScrowView中点击
		svNormal:addChild(faceBtn)
		if i % EXP_COUNT_IN_LINE ~= 0 then
			x = x + wInterVal
		else
			x = 10
			y = y + FACE_ITEM_HEIGHT
		end
	end

	-- local EXP_COUNT_IN_LINE = 3
	-- local FACE_ITEM_HEIGHT = 120
	-- --定义大象表情, 预设的显示顺序用了这个指定的顺序，faceShowIndex是为了方便以后调整位置，但索引不可再变更，为了兼容原来的
	-- local faceShowIndex = {1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008, 1009, 1010, 1011, 1012}
	-- local svElephant = viewList[2]:findChildByName("sv_elephantList")
	-- local wInterVal = svElephant:getSize() / EXP_COUNT_IN_LINE
	-- local x, y = 10, 0
	-- for i = 1, #faceShowIndex do
	-- 	local index = faceShowIndex[i]
	-- 	local faceBtn = new(Button, "room/roomChat/item_bg.png")
	-- 	faceBtn:setSize(100, 100)
	-- 	local faceImg = new(Image, string.format("room/chat/elephant/%d.png", index))
	-- 	faceImg:setSize(faceImg.m_res.m_width * 0.8, faceImg.m_res.m_height * 0.8)
	-- 	faceImg:setAlign(kAlignCenter)
	-- 	faceBtn:addChild(faceImg)
	-- 	--自己拥有这个表情才可以发送
	-- 	faceBtn:setOnClick(
	-- 		nil,
	-- 		function()
	-- 			if MyUserData:getPropNum(kIDElephantExpression) > 0 then
	-- 				HttpModule.getInstance():execute(HttpModule.s_cmds.DUMMY_GET_TIPS_COUNT,{pnid = kIDElephantExpression, id = index}, false, true);
	-- 				self:dismiss()
	-- 			else
	-- 				AlarmTip.play(STR_EXPRESSION_NO_ENOUGH)
	-- 			end
	-- 		end
	-- 	)
	-- 	faceBtn:setPos(x, y)
	-- 	svElephant:addChild(faceBtn)
	-- 	if i % EXP_COUNT_IN_LINE ~= 0 then
	-- 		x = x + wInterVal
	-- 	else
	-- 		x = 10
	-- 		y = y + FACE_ITEM_HEIGHT
	-- 	end
	-- end
	-- --再增加一个购买按钮
	-- local btnBuy = new(Button, "room/roomChat/item_bg.png")
	-- btnBuy:setSize(100, 100)
	-- local imgBuy = new(Image, "room/roomChat/btn_buy.png")
	-- imgBuy:setAlign(kAlignCenter)
	-- btnBuy:addChild(imgBuy)
	-- btnBuy:setOnClick(
	-- 	nil,
	-- 	function()
	-- 		WindowManager:showWindow(WindowTag.ShopPopu, {to = "props"}, WindowStyle.TRANSLATE_RIGHT)
	-- 	end
	-- )
	-- btnBuy:setPos(x, y)
	-- svElephant:addChild(btnBuy)
	-- svElephant:setSize(svElephant:getSize())

	-- --定义国王表情
	-- local faceShowIndex = {2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008}
	-- local x, y = 10, 0
	-- local svSpecial = viewList[3]:findChildByName("sv_specialList")
	-- for i = 1, #faceShowIndex do
	-- 	local index = faceShowIndex[i]
	-- 	local faceBtn = new(Button, "room/roomChat/item_bg.png")
	-- 	faceBtn:setSize(100, 100)
	-- 	local faceImg = new(Image, string.format("room/chat/ks/%d.png", index))
	-- 	faceImg:setSize(faceImg.m_res.m_width * 0.8, faceImg.m_res.m_height * 0.8)
	-- 	faceImg:setAlign(kAlignCenter)
	-- 	faceBtn:addChild(faceImg)
	-- 	faceBtn:setOnClick(
	-- 		nil,
	-- 		function()
	-- 			if MyUserData:getPropNum(kIDKSExpression) > 0 then
	-- 				HttpModule.getInstance():execute(HttpModule.s_cmds.DUMMY_GET_TIPS_COUNT,{pnid = kIDKSExpression, id = index}, false, true);
	-- 				self:dismiss()
	-- 			else
	-- 				AlarmTip.play(STR_EXPRESSION_NO_ENOUGH)
	-- 			end
	-- 		end
	-- 	)
	-- 	faceBtn:setPos(x, y)
	-- 	svSpecial:addChild(faceBtn)
	-- 	if i % EXP_COUNT_IN_LINE ~= 0 then
	-- 		x = x + wInterVal
	-- 	else
	-- 		x = 10
	-- 		y = y + FACE_ITEM_HEIGHT
	-- 	end
	-- end
	-- --再增加一个购买按钮
	-- local btnBuy = new(Button, "room/roomChat/item_bg.png")
	-- btnBuy:setSize(100, 100)
	-- local imgBuy = new(Image, "room/roomChat/btn_buy.png")
	-- imgBuy:setAlign(kAlignCenter)
	-- btnBuy:addChild(imgBuy)
	-- btnBuy:setOnClick(
	-- 	nil,
	-- 	function()
	-- 		WindowManager:showWindow(WindowTag.ShopPopu, {to = "props"}, WindowStyle.TRANSLATE_RIGHT)
	-- 	end
	-- )
	-- btnBuy:setPos(x, y)
	-- svSpecial:addChild(btnBuy)
	-- svSpecial:setSize(svElephant:getSize())

end

function RoomChatAndSpeakerPopu:initWord(strUsual)
	local svWordUsual = self.viewWord:findChildByName("sv_wordUsual")
	local wordUsual = strUsual or {}
	local y = 0
	for i = 1, #wordUsual do
		local btnWordBg = new(Button, "ui/blank.png")
		btnWordBg:setSize(400, 50)
		local imgLine = new(Image, "room/chat/img_line.png")
		imgLine:setAlign(kAlignBottom)
		btnWordBg:addChild(imgLine)
		btnWordBg:enableAnim(false)
		btnWordBg:setOnClick(
			self,
			function()
				EventDispatcher.getInstance():dispatch(Event.Message, "sendChatWord", wordUsual[i])
				self:dismiss()
			end
		)
		local textWord = new(Text, wordUsual[i], 0, 0, kAlignLeft, "", 30, 0xfe, 0xee, 0xa2)
		btnWordBg:addChild(textWord)
		btnWordBg:setPos(0, y)
		svWordUsual:addChild(btnWordBg)
		y = y + 60
	end
end

function RoomChatAndSpeakerPopu:initSpeaker()
	-- local svSpeaker = self.viewSpeaker:findChildByName("sv_speakerHistory")
	self.svSpeaker:removeAllChildren()
	self.svSpeaker.m_nodeH = 0
	self.svSpeaker:setDirection(kVertical)
	local userRecord = MySpeakerQueue:getSpeakerUser()
    self.svSpeaker:setAutoPosition(true)
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
		local maxWidth = imgTextBg:getSize() - 120
		local textView = new(TextView, content, maxWidth, 0, kAlignTopLeft, "", 24, 0x66, 0x87, 0xcf)
		textView:setPos(5, 0)
		imgTextBg:addChild(textView)
		local _, h = textView:getSize()
		imgTextBg:setSize(nil, h + 30)
		item:setSize(nil, h + 30)
		self.svSpeaker:addChild(item)
		item:setAlign(kAlignTopLeft)
		-- self.svSpeaker:scrollItemToView(item)
	end
end

function RoomChatAndSpeakerPopu:addHistorySpeaker(data)
	-- local gridSize = 5
	-- local wordHeight = 40
	-- local svSpeaker = self.viewSpeaker:findChildByName("sv_speakerHistory")
	-- local svSpeaker = self.viewSpeaker:findChildByName("sv_speakerHistory")
	-- local maxWidth = svSpeaker:getSize() - gridSize * 2
	-- local wordBg = new(Image, "ui/blank.png", nil, nil, gridSize * 4, gridSize * 4, gridSize, gridSize)
	-- local text = new(Text, str, 0, 0, kAlignLeft, "", 26, 0x00, 0x00, 0x00)
	-- local w = text.m_res.m_width
	-- if w > maxWidth then
	-- 	local line = math.ceil(w / maxWidth)
	-- 	local textView = new(TextView, str, maxWidth, wordHeight * line + 10, kAlignTopLeft, "", 26, 0x00, 0x00, 0x00)
	-- 	textView:setPos(5, 5)
	-- 	wordBg:setSize(maxWidth, wordHeight * line + 10)
	-- 	wordBg:addChild(textView)
	-- 	textView:setFillParent(1, 1)
	-- 	wordBg:setPos(0, svSpeaker:getViewLength() + 10)
	-- 	delete(text)
	-- else
	-- 	wordBg:setSize(text.m_res.m_width + 20, text.m_res.m_height + 10)
	-- 	text:setPos(5, 5)
	-- 	wordBg:addChild(text)
	-- 	wordBg:setPos(20, svSpeaker:getViewLength() + 10)
	-- end
	-- svSpeaker:addChild(wordBg)
	-- svSpeaker:scrollItemToView(wordBg)
	local name = "["..(data.name or "").."]"..":"
	local content = name..data.content or ""
	content = string.lower(content)
	local illegalWord = require("app.lobby.illegalWord")
	if illegalWord then
		for i = 1, #illegalWord do
			content = string.gsub(content, illegalWord[i], "**")
		end
	end
	local item = SceneLoader.load(speakerRecordItem)
	local imgTextBg = item:findChildByName("recordItem")
	local maxWidth = imgTextBg:getSize() - 120
	local textView = new(TextView, content, maxWidth, 0, kAlignTopLeft, "", 24, 0x66, 0x87, 0xcf)
	textView:setPos(5, 0)
	imgTextBg:addChild(textView)
	local _, h = textView:getSize()
	imgTextBg:setSize(nil, h + 30)
	item:setSize(nil, h + 30)
	self.svSpeaker:addChild(item)
	item:setAlign(kAlignTopLeft)
	-- self.svSpeaker:scrollItemToView(item)
end


function RoomChatAndSpeakerPopu:onSendSpeaker(isSuccess, data)
	if app:checkResponseOk(isSuccess, data) then
		local etWord = self:findChildByName("et_sendWord")
		local word = etWord:getText()
		-- self:addHistorySpeaker(word)
		etWord:setText("")
		etWord:setPos(0, 0)
	end
end

RoomChatAndSpeakerPopu.s_severCmdEventFuncMap = {
	[HttpModule.s_cmds.SEND_SPEAKER]      = RoomChatAndSpeakerPopu.onSendSpeaker,
}

return RoomChatAndSpeakerPopu
