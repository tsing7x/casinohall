local ChatPopu = class(require("app.popu.gameWindow"))

local viewQuickChatItem = require("app.view.popu.room.chat.quickChatItem")
local viewRecordOtherItem = require("app.view.popu.room.chat.recordChatOtherItem")
local viewRecordMineItem = require("app.view.popu.room.chat.recordChatMineItem")

local Hall_string = require("app.res.config")

function ChatPopu:ctor()

end

function ChatPopu:dtor()

end

function ChatPopu:initView(data)
	data.chatWords = {
		"111",
		"222",
		"dsjadsjkdsaklas",
	}

	local imgTabBg = self:findChildByName("img_tabBg")
	local btns = {
		imgTabBg:findChildByName("btn_quickChat"),
		imgTabBg:findChildByName("btn_record"),
	}
	local imgFrame = self:findChildByName("img_frameBg")
	local views = {
		imgFrame:findChildByName("view_quick"),
		imgFrame:findChildByName("view_record"),
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

	local viewBottom = self:findChildByName("view_bottom")
	local etInput = viewBottom:findChildByName("et_content")
	local btnSend = viewBottom:findChildByName("btn_send")
	btnSend:findChildByName("text_btn"):setText(Hall_string.str_send_chat)
	btnSend:setOnClick(
		nil,
		function()
			local text = etInput:getText()
			local ltrimText = string.ltrim(text)
			if not ToolKit.isValidString(ltrimText) then
				AlarmTip.play(Hall_string.str_chat_input_empty)
				return
			end
			EventDispatcher.getInstance():dispatch(Event.Message, "sendChatWord", text)
			self:dismiss(true)
		end
	)

	self:initRecordView()

	--快捷聊天
	local chatWords = data.chatWords or {}
	local svQuick = views[1]:findChildByName("sv_quickChat")
	svQuick:setDirection(kVertical)
	svQuick:setAutoPosition(true)
	for i = 1, #chatWords do
		local quickItem = SceneLoader.load(viewQuickChatItem)
		local btnQuick = quickItem:findChildByName("btn_quickWord")
		btnQuick:findChildByName("text_word"):setText(chatWords[i])
		btnQuick:enableAnim(false)
		btnQuick:setOnClick(
			nil,
			function()
				EventDispatcher.getInstance():dispatch(Event.Message, "sendChatWord", chatWords[i])
				self:dismiss(true)
			end
		)
		svQuick:addChild(quickItem)
	end
	svQuick:setSize(svQuick:getSize())

end

function ChatPopu:initRecordView()
	--数据格式以此类推，这只是测试数据
	local records = {
		{
			id = 11248,
			nick = "",
			word = "lalala",
			headUrl = "",
		},
		{
			id = 11249,
			nick = "",
			word = "纵使相逢应不识 尘满面 鬓如霜",
			headUrl = "",
		},
		{
			id = 11248,
			nick = "",
			word = "昔人已乘黄鹤去，此地空余黄鹤楼",
			headUrl = "",
		},
		{
			id = 11249,
			nick = "",
			word = "重帏深下莫愁堂，卧后清宵细细长。神女生涯原是梦，小姑居处本无郎。风波不信菱叶弱，月露谁教桂叶香。直道相思了无益，未妨惆怅是清狂。",
			headUrl = "",
		},
		{
			id = 11248,
			nick = "",
			word = [[千古江山，英雄无觅，孙仲谋处。舞榭歌台，风流总被雨打风吹去。斜阳草树，寻常巷陌，人道寄奴曾住。想当年，金戈铁马，气吞万里如虎,
				元嘉草草，封狼居胥，赢得仓皇北顾。四十三年，望中犹记，烽火扬州路。可堪回首，佛狸祠下，一片神鸦社鼓。凭谁问，廉颇老矣，尚能饭否。]],
			headUrl = "",
		},
	}


	local svRecord = self:findChildByName("sv_record")
	svRecord:setDirection(kVertical)
	svRecord:setAutoPosition(true)

	for i = 1, #records do
		local record = records[i]
		local item = nil
		if record.id == MyUserData:getId() then
			item = self:initRecordMine(record)
		else
			item = self:initRecordOther(record)
		end
		svRecord:addChild(item)
	end
	svRecord:setSize(svRecord:getSize())
end

function ChatPopu:initRecordOther(record)
	local nick = record.nick or ""
	local headUrl = record.headUrl or ""
	local word = record.word or ""

	local item = SceneLoader.load(viewRecordOtherItem)
	local headData = setProxy(require("app.data.headData"))
	local imgHeadBg = item:findChildByName("img_head")
	UIEx.bind(
		item,
		headData,
		"headName",
		function(value)
			if value and value~= "" then
				local img = new(Mask, value, "common/headMask.png")
				img:setSize(imgHeadBg:getSize())
				imgHeadBg:removeAllChildren()
				imgHeadBg:addChild(img)
				headData:checkHeadAndDownload()
			end
		end
	)
	headData:setHeadUrl(headUrl)

	item:findChildByName("text_nick"):setText(nick)

	local imgWordBg = item:findChildByName("img_wordBg")
	local maxWidth = imgWordBg:getSize() - 10
	local text = self:initRecordWord(word, maxWidth)
	imgWordBg:addChild(text)
	local w, h = text:getSize()
	local _, minHeight = imgWordBg:getSize()
	print("text size h "..h.." minHeight "..minHeight)
	if h < minHeight then
		text:setAlign(kAlignLeft)
		text:setPos(10, 0)
		imgWordBg:setSize(w + 15, minHeight)
	else
		text:setPos(10, 10)
		imgWordBg:setSize(w + 15, h + 20)
	end
	local _, h = imgWordBg:getSize()
	item:setSize(nil, h + 50)
	print(string.format("itemSize %s %s", item:getSize()))
	return item
end

function ChatPopu:initRecordMine(record)
	local nick = record.nick or ""
	local word = record.word or ""

	local item = SceneLoader.load(viewRecordMineItem)
	local imgHeadBg = item:findChildByName("img_head")
	UIEx.bind(
		item,
		MyUserData,
		"headName",
		function(value)
			if value and value~= "" then
				local img = new(Mask, value, "common/headMask.png")
				img:setSize(imgHeadBg:getSize())
				imgHeadBg:removeAllChildren()
				imgHeadBg:addChild(img)
				MyUserData:checkHeadAndDownload()
			end
		end
	)
	MyUserData:setHeadUrl(MyUserData:getHeadUrl())
	item:findChildByName("text_nick"):setText(MyUserData:getNick())

	local imgWordBg = item:findChildByName("img_wordBg")
	local maxWidth = imgWordBg:getSize() - 10
	local text = self:initRecordWord(word, maxWidth)
	imgWordBg:addChild(text)
	local w, h = text:getSize()
	local _, minHeight = imgWordBg:getSize()
	print("text size h "..h.." minHeight "..minHeight)
	if h < minHeight then
		text:setAlign(kAlignLeft)
		text:setPos(5, 0)
		imgWordBg:setSize(w + 15, minHeight)
	else
		text:setPos(5, 10)
		imgWordBg:setSize(w + 15, h + 20)
	end
	local _, h = imgWordBg:getSize()
	item:setSize(nil, h + 50)

	return item
end

function ChatPopu:initRecordWord(word, maxWidth)
	local textWord = new(Text, word, 0, 0, kAlignLeft, "", 24, 0x3f, 0x65, 0xb9)
	local w = textWord.m_res.m_width
	if w > maxWidth then
		local line = math.ceil(w / maxWidth)
		print("initRecordWord line "..line.." maxWidth "..maxWidth)
		local textView = new(TextView, word, maxWidth, 0, kAlignTopLeft, "", 24, 0x3f, 0x65, 0xb9)
		delete(textWord)
		return textView
	else
		return textWord
	end
end

ChatPopu.s_severCmdEventFuncMap = {

}


return ChatPopu
