--
-- Author: TsingZhang@boyaa.com
-- Date: 2017-08-16 15:53:32
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: MessagePopu.lua Midifyied By Tsing7x.
--

local langConfStr = require("app.res.config")

local viewGameMsgItem = require(ViewPath .. "popu.lobby.message.gameMsgItem")
local viewSysMsgItem = require(ViewPath .. "popu.lobby.message.sysMsgItem")

local MsgContPopu = import(".MessageContPopu")

local windowManager = require("app.popu.gameWindow")
local MessagePopu = class(windowManager)

function MessagePopu:ctor()
	self.sysMsg = nil
	self.gameMsg = nil
	self.annoucement = nil
end

function MessagePopu:initView(data)
	self:findChildByName("btn_close"):setOnClick(nil, function()
		self:dismiss()
	end)

	local imgTabBg = self:findChildByName("img_tabs")
	local tabBtns = {
		imgTabBg:findChildByName("btn_system"),
		imgTabBg:findChildByName("btn_game"),
	}

	local tabMsgViews = {
		self:findChildByName("img_sysMsg"),
		self:findChildByName("img_gameMsg"),
	}

	local msgDatas = {self.sysMsg, self.gameMsg}

	local httpCmd = {
		HttpModule.s_cmds.GET_HALL_SYS_MESSAGE,
		HttpModule.s_cmds.GET_HALL_GAME_MESSAGE
		-- HttpModule.s_cmds.GET_HALL_ANNOUCEMENT,
	}

	for i = 1, #tabBtns do
		local btn = tabBtns[i]
		btn:setOnClick(nil, function()
			for j = 1, #tabMsgViews do
				tabMsgViews[j]:setVisible(i == j)
			end

			for j = 1, #tabBtns do
				tabBtns[j]:findChildByName("img_select"):setVisible(i == j)
			end

			if not msgDatas[i] then
				-- HttpModule.getInstance():execute(httpCmd[i], {}, false, false)
				self:execHttpCmd(httpCmd[i], {}, false, true, tabMsgViews[i])
			end
		end)
	end

	self.noSysMsgTipTxt_ = tabMsgViews[1]:findChildByName("txt_noSysMsgHint")
	self.noGameMsgTipTxt_ = tabMsgViews[2]:findChildByName("txt_noGameMsgHint")

	self.noSysMsgTipTxt_:setText(langConfStr.str_msg_noSysMsgDataTip)
	self.noSysMsgTipTxt_:hide()

	self.noGameMsgTipTxt_:setText(langConfStr.str_msg_noGameMsgDataTip)
	self.noGameMsgTipTxt_:hide()

	local defaultTabIdx = data.tabIdx or 1

	tabBtns[defaultTabIdx].m_eventCallback.func(tabBtns[defaultTabIdx].m_eventCallback.obj)
end

function MessagePopu:initSysMsg()
	local svSysMsg = self:findChildByName("sv_sysMsg")
	svSysMsg:removeAllChildren()
	svSysMsg:setDirection(kVertical)
	svSysMsg:setAutoPosition(true)

	self.btnConfirm_ = {}

	local msgContShown1LineHeight = 28

	if #self.sysMsg <= 0 then
		--todo
		self.noSysMsgTipTxt_:show()
	else
		for i = 1, #self.sysMsg do
			local msg = self.sysMsg[i]
			local item = SceneLoader.load(viewSysMsgItem)
			local viewContent = item:findChildByName("view_content")
			local imgReward = viewContent:findChildByName("img_rewardBg")
			local textContent = viewContent:findChildByName("text_content")
			textContent:setText(msg.content)

			textContent:setScrollBarWidth(0)
			local msgContViewShownLines = math.ceil(textContent:getViewLength() / msgContShown1LineHeight)

			self.btnConfirm_[msg.id] = item:findChildByName("btn_confirm")
			local textBtn = self.btnConfirm_[msg.id]:findChildByName("text_btn")

			self.btnConfirm_[msg.id]:setOnClick(self, function()
				-- body
				-- self.btnConfirm_[msg.id]:setEnable(false)
				if tonumber(msg.reward) == 1 and tonumber(msg.isreward) == 0 then
					--todo
					-- self:execHttpCmd(HttpModule.s_cmds.GET_HALL_USER_NOTICES_AWARD, {nid = msg.id}, false, true, svSysMsg)

					HttpModule.getInstance():execute(HttpModule.s_cmds.GET_HALL_USER_NOTICES_AWARD, {nid = msg.id}, false, false)
				else
					if tonumber(msg.islook) == 0 then
						--todo
						-- self:execHttpCmd(HttpModule.s_cmds.GET_HALL_USER_NOTICES_READED, {id = msg.id}, false, true, svSysMsg)

						HttpModule.getInstance():execute(HttpModule.s_cmds.GET_HALL_USER_NOTICES_READED, {id = msg.id}, false, false)
					end
				end
			end)

			local btnItemEvt = item:findChildByName("btn_itemEvt")
			btnItemEvt:setOnClick(self, function()
				-- body
				local data = {
					msgType = MsgContPopu.MSGTYPE_SYS,
					title = msg.title,
					content = msg.content
				}

				WindowManager:showWindow(WindowTag.MsgContPopu, data, WindowStyle.POPUP)
			end)

			if tonumber(msg.reward) == 1 then
				local w = 0
				local textReward = imgReward:findChildByName("text_rewardName")
				textReward:setText(langConfStr.str_reward)
				w = textReward.m_res.m_width + 10
				local imgChip = imgReward:findChildByName("img_chip")
				imgChip:setPos(w)
				w = w + imgChip.m_res.m_width + 10
				local textRewardNum = imgReward:findChildByName("text_rewardNum")
				textRewardNum:setText("×" .. (msg.award and msg.award.money or 0))
				textRewardNum:setPos(w)

				if tonumber(msg.isreward) == 0 then
					textBtn:setText(langConfStr.str_get_reward)
					self.btnConfirm_[msg.id]:setFile("popu/btn_green.png")
				else
					textBtn:setText(langConfStr.str_confirm)
					self.btnConfirm_[msg.id]:setFile("popu/btn_blue.png")
				end
			else
				imgReward:setVisible(false)
				-- textContent:setAlign(kAlignLeft)
				textBtn:setText(langConfStr.str_confirm)

				if msgContViewShownLines > 1 then
					--todo
					textContent:setSize(viewContent:getSize())
				end
			end

			if tonumber(msg.islook) == 1 then
				--todo
				textBtn:setText(langConfStr.str_msg_readed)
				self.btnConfirm_[msg.id]:setFile("popu/btn_rightAnglGrey.png")

				self.btnConfirm_[msg.id]:setEnable(false)
			end
			svSysMsg:addChild(item)
		end
	end
end

function MessagePopu:initGameMsg()
	local svGameMsg = self:findChildByName("sv_gameMsg")
	svGameMsg:removeAllChildren()
	svGameMsg:setDirection(kVertical)
	svGameMsg:setAutoPosition(true)

	-- self.itemBgBtns_ = {}
	if #self.gameMsg <= 0 then
		--todo
		self.noGameMsgTipTxt_:show()
	else
		for i = 1, #self.gameMsg do
			local itemData = self.gameMsg[i]

			local item = SceneLoader.load(viewGameMsgItem)
			local viewContent = item:findChildByName("view_content")
			viewContent:findChildByName("text_content"):setText(itemData.content)
			viewContent:findChildByName("text_content"):setScrollBarWidth(0)

			viewContent:findChildByName("text_time"):setText(os.date("%Y/%m/%d", itemData.time))

			-- self.itemBgBtns_[itemData.id] = item:findChildByName("btn_itemEvt")
			-- self.itemBgBtns_[itemData.id]:setOnClick(self, function()
			-- 	-- body
			-- 	self.itemBgBtns_[itemData.id]:setEnable(false)
			-- 	if itemData.reward == 0 then
			-- 		--todo
			-- 		HttpModule.getInstance():execute(HttpModule.s_cmds.GET_GAMEMSG_READED, {id = itemData.id}, false, false)
			-- 	else
			-- 		HttpModule.getInstance():execute(HttpModule.s_cmds.GET_GAMEMSG_REW, {id = itemData.id}, false, false)
			-- 	end
			-- end)

			local btnItemEvt = item:findChildByName("btn_itemEvt")
			btnItemEvt:setOnClick(self, function()
				-- body
				local data = {
					msgType = MsgContPopu.MSGTYPE_GAME,
					title = itemData.title,
					content = itemData.content
				}

				if itemData.reward == 0 then
					--todo
					data.dtorActionCallBack = function()
						-- body
						HttpModule.getInstance():execute(HttpModule.s_cmds.GET_GAMEMSG_READED, {id = itemData.id}, false, false)
					end
				else
					data.dtorActionCallBack = function()
						-- body
						HttpModule.getInstance():execute(HttpModule.s_cmds.GET_GAMEMSG_REW, {id = itemData.id}, false, false)
					end
				end

				WindowManager:showWindow(WindowTag.MsgContPopu, data, WindowStyle.POPUP)
			end)

			-- if itemData.status ~= 0 then
			-- 	--todo
			-- 	self.itemBgBtns_[itemData.id]:setEnable(false)
			-- end

			svGameMsg:addChild(item)
		end
	end
end

function MessagePopu:initAnnoucement()
end

function MessagePopu:checkMsgAllReaded()
	-- body
	local unreadMsgCheck = false

	for i = 1, #self.sysMsg do
		if tonumber(self.sysMsg[i].islook) == 0 then
			--todo
			unreadMsgCheck = true
		end
	end

	MyUserData:setHasUnckeckMsg(unreadMsgCheck)
end

function MessagePopu:onGetHallSysMessage(isSuccess, data)
	-- dump(data, "MessagePopu:onGetHallSysMessage(isSucc :" .. tostring(isSuccess) .. ").data :=================")

	if app:checkResponseOk(isSuccess, data) then
		if self.sysMsg then
			--todo
			self.sysMsg = nil
		end

		self.sysMsg = {}
		local messages = data.data

		for i = 1, #messages do
			--图片公告，不显示在消息列表里, --getway 1 是图片公告， 0是普通公告 ， 2 是跑马灯公告
			if tonumber(messages[i].getway) ~= 1 then
				local message = {}
				message.id = tonumber(messages[i].id or 0)
				message.title = messages[i].title or ""
				message.content = messages[i].content or ""
				message.popup = messages[i].popup or 0
				message.islook = messages[i].islook or 0
				message.reward = messages[i].reward or 0
				message.isreward = messages[i].isreward or 0
				message.time = messages[i].time or 0

				message.award = messages[i].award
				message.delete = false

				table.insert(self.sysMsg, message)
			end
		end

		table.sort(self.sysMsg, function(msga, msgb)
			return tonumber(msga.time) > tonumber(msgb.time)
		end)

		self:initSysMsg()
	end
end

function MessagePopu:onGetHallGameMessage(isSuccess, data)
	-- dump(data, "MessagePopu:onGetHallGameMessage(isSucc :" .. tostring(isSuccess) .. ").data :=================")
	if app:checkResponseOk(isSuccess, data) then
		if self.gameMsg then
			--todo
			self.gameMsg = nil
		end

		self.gameMsg = {}
		local messages = data.data
		for i = 1, #messages do
			local message = {}
			message.id = tonumber(messages[i].id or 0)
			message.title = messages[i].title or ""
			message.type = messages[i].type or 0
			message.content = messages[i].content or ""
			message.status = tonumber(messages[i].status or 0)
			message.from = messages[i].from or 0
			message.time = messages[i].time or 0
			message.reward = tonumber(messages[i].reward or 0)
			message.rewardtype = tonumber(messages[i].rewardtype or 0)
			message.delete = false
			table.insert(self.gameMsg, message)
		end

		table.sort(self.gameMsg, function(msga, msgb)
			return tonumber(msga.time) > tonumber(msgb.time)
		end)

		self:initGameMsg()
	end
end

function MessagePopu:onGetHallAnnoucement(isSuccess, data)
	-- if app:checkResponseOk(isSuccess, data) then
	-- 	self.annoucement = {}
	-- end
end

function MessagePopu:onHallGetMsgReadRes(isSucc, data)
	-- body
	-- dump(data, "MessagePopu:onHallGetMsgReadRes(isSucc :" .. tostring(isSucc) .. ").data :=================")

	if app:checkResponseOk(isSucc, data) then
		--todobtnId
		local retData = data.data
		local btnId = tonumber(retData.nid)

		if self.btnConfirm_[btnId] then
			--todo
			self.btnConfirm_[btnId]:setFile("popu/btn_rightAnglGrey.png")
			self.btnConfirm_[btnId]:findChildByName("text_btn"):setText(langConfStr.str_msg_readed)
			self.btnConfirm_[btnId]:setEnable(false)
		end

		for i = 1, #self.sysMsg do
			local msgId = self.sysMsg[i].id
			if msgId == btnId then
				--todo
				self.sysMsg[i].islook = 1
			end
		end

		self:checkMsgAllReaded()
	else
		printInfo("Get Data @index[HttpModule.s_cmds.GET_HALL_USER_NOTICES_READED] Failed!")
		-- self.btnConfirm_[btnId]:setEnable(true)
	end
end

function MessagePopu:onHallGetMsgRewRes(isSucc, data)
	-- body
	-- dump(data, "MessagePopu:ononHallGetMsgRewRes(isSucc :" .. tostring(isSucc) .. ").data :=================")
	if isSucc and data then
		--todo
		local retData = data.data
		local btnId = tonumber(retData.nid)

		if self.btnConfirm_[btnId] then
			--todo
			self.btnConfirm_[btnId]:setFile("popu/btn_rightAnglGrey.png")
			self.btnConfirm_[btnId]:findChildByName("text_btn"):setText(langConfStr.str_msg_readed)
			self.btnConfirm_[btnId]:setEnable(false)
		end

		for i = 1, #self.sysMsg do
			local msgId = self.sysMsg[i].id
			if msgId == tonumber(retData.nid) then
				--todo
				self.sysMsg[i].islook = 1
				self.sysMsg[i].isreward = 1
			end
		end

		self:checkMsgAllReaded()

		-- printInfo("Get Data @index[HttpModule.s_cmds.GET_HALL_USER_NOTICES_AWARD] Succ!")
	else
		printInfo("Get Data @index[HttpModule.s_cmds.GET_HALL_USER_NOTICES_AWARD] Failed!")
		-- self.btnConfirm_[msg.id]:setEnable(true)
	end
end

function MessagePopu:onGetGameMsgReadRes(isSucc, data)
	-- body
	-- dump(data, "MessagePopu:onGetGameMsgReadRes(isSucc :" .. tostring(isSucc) .. ").data :=================")

	if isSucc and data then
		--todo
		printInfo("Get Data @index[HttpModule.s_cmds.GET_GAMEMSG_READED] Succ!")
	else
		printInfo("Get Data @index[HttpModule.s_cmds.GET_GAMEMSG_READED] Failed!")
	end
end

function MessagePopu:onGetGameMsgRewRes(isSucc, data)
	-- body
	-- dump(data, "MessagePopu:onGetGameMsgRewRes(isSucc :" .. tostring(isSucc) .. ").data :=================")

	if isSucc and data then
		--todo
		printInfo("Get Data @index[HttpModule.s_cmds.GET_GAMEMSG_REW] Succ!")
	else
		printInfo("Get Data @index[HttpModule.s_cmds.GET_GAMEMSG_REW] Failed!")
	end
end

function MessagePopu:dtor()

end

MessagePopu.s_severCmdEventFuncMap = {
	[HttpModule.s_cmds.GET_HALL_GAME_MESSAGE] = MessagePopu.onGetHallGameMessage,
	-- [HttpModule.s_cmds.GET_HALL_ANNOUCEMENT] = MessagePopu.onGetHallAnnoucement,
	[HttpModule.s_cmds.GET_HALL_SYS_MESSAGE] = MessagePopu.onGetHallSysMessage,
	[HttpModule.s_cmds.GET_HALL_USER_NOTICES_READED] = MessagePopu.onHallGetMsgReadRes,
	[HttpModule.s_cmds.GET_HALL_USER_NOTICES_AWARD] = MessagePopu.onHallGetMsgRewRes,
	[HttpModule.s_cmds.GET_GAMEMSG_READED] = MessagePopu.onGetGameMsgReadRes,
	[HttpModule.s_cmds.GET_GAMEMSG_REW] = MessagePopu.onGetGameMsgRewRes
}

return MessagePopu
