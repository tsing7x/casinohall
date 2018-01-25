--
-- Author: TsingZhang@boyaa.com
-- Date: 2018-01-23 16:37:59
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: SuonaUsagePopu Redefined By Tsing7x.
--

local langConfStr = require("app.res.config")
local illegalWord = require("app.lobby.illegalWord")

local SuonaMsgRecListItem = import(".compViews.SuonaMsgRecListItem")

local GameWindow = require("app.popu.gameWindow")
local SuonaUsagePopu = class(GameWindow)

function SuonaUsagePopu:ctor(viewConf, data)
	-- body
	EventDispatcher.getInstance():register(HttpModule.s_event, self, self.onHttpRequestsCallBack)
end

function SuonaUsagePopu:initView(data)
	-- body
	local defaultTabIdx = data.tabIdx or 1

	local bgPanel = self.m_root:findChildByName("img_bgPanel")
	bgPanel:setEventTouch(self, function()
	end)

	local closeBtn = bgPanel:findChildByName("btn_close"):setOnClick(self, handler(self, self.onCloseBtnCallBack_))

	local tabView = bgPanel:findChildByName("vb_mainTab")
	local pageContView = bgPanel:findChildByName("vb_mainContPage")

	local bgTabView = tabView:findChildByName("img_bgMainTab")

	self.m_tabBtns = {}
	self.m_mainContPages = {}

	for i = 1, 2 do
		self.m_tabBtns[i] = bgTabView:findChildByName("btn_tabIdx" .. i)
		self.m_tabBtns[i].txtNor_ = self.m_tabBtns[i]:findChildByName("img_dscTabUnsel")
		self.m_tabBtns[i].txtSel_ = self.m_tabBtns[i]:findChildByName("img_dscTabSel")

		self.m_tabBtns[i]:setOnClick(self, function()
			-- body
			self:onMainTabSelChanged_(i)
		end)

		self.m_mainContPages[i] = pageContView:findChildByName("vb_pageIdx" .. i)
	end

	self.btnImgSel_ = bgTabView:findChildByName("img_tabSelHili")

	self:bindSuonaSendPageEvts()
	self.m_tabBtns[defaultTabIdx].m_eventCallback.func(self.m_tabBtns[defaultTabIdx].m_eventCallback.obj)
end

function SuonaUsagePopu:bindSuonaSendPageEvts()
	-- body
	local suonaSendPage = self.m_mainContPages[1]

	local bgSuonaMsgInput = suonaSendPage:findChildByName("img_bgSuonaMsgInput")
	local etvSuonaMsgInput = bgSuonaMsgInput:findChildByName("etv_suonaMsgCont")

	local tvSuonaUseTip = suonaSendPage:findChildByName("tv_suonaUseTip")

	self.m_btnSuonaSend = suonaSendPage:findChildByName("btn_suonaSend")
	local bgSuonaPropCount = self.m_btnSuonaSend:findChildByName("img_bgSuonaCount")
	local txtSuonaPropCount = bgSuonaPropCount:findChildByName("txt_suonaCount")

	local suonaMsgMaxLength = 49

	local suonaMsgInputTextColor = {
		r = 255,
		g = 255,
		b = 255
	}

	etvSuonaMsgInput:setMaxLength(suonaMsgMaxLength)
	etvSuonaMsgInput:setOnTextChange(self, handler(self, self.onSuonaMsgContChanged_))
	etvSuonaMsgInput:setHintText(langConfStr.str_Suona_ContHint, suonaMsgInputTextColor.r, suonaMsgInputTextColor.g, suonaMsgInputTextColor.b)

	tvSuonaUseTip:setText(langConfStr.str_Suona_UseTip)

	self.m_btnSuonaSend:setOnClick(self, handler(self, self.onBtnSendCallBack_))

	-- local defaultBtnSendUnablePath = "popu/v210/btn_grey.png"
	-- self.m_btnSuonaSend:setFile(defaultBtnSendUnablePath)
	-- self.m_btnSuonaSend:setEnable(false)

	local suonaPropNumStr = tostring(MyUserData:getPropNum(kIDSpeaker))
	txtSuonaPropCount:setText(suonaPropNumStr)
	
	self:fixSuonaPropNumBgSizeWidth()
end

function SuonaUsagePopu:fixSuonaPropNumBgSizeWidth()
	-- body
	local bgSuonaPropCount = self.m_btnSuonaSend:findChildByName("img_bgSuonaCount")
	local txtSuonaPropCount = bgSuonaPropCount:findChildByName("txt_suonaCount")

	local txtSuonaPropNumMagrinHoriz = 10
	local bgSuonaPropNumSizeWidth, bgSuonaPropNumSizeHeight = bgSuonaPropCount:getSize()

	local txtSuonaPropNumSizeWidth = txtSuonaPropCount:getSize()
	if txtSuonaPropNumSizeWidth + txtSuonaPropNumMagrinHoriz * 2 > bgSuonaPropNumSizeWidth then
		--todo
		bgSuonaPropCount:setSize(txtSuonaPropNumSizeWidth + txtSuonaPropNumMagrinHoriz * 2, bgSuonaPropNumSizeHeight)
	end
end

function SuonaUsagePopu:getSuonaRecPageData()
	-- body
	if self.mainTabIdx_ == 2 then
		--todo
		local suonaMsgRecBg = self.m_mainContPages[2]:findChildByName("img_bgMsgRec")
		local suonaMsgRecBgSizeWidth, suonaMsgRecBgSizeHeight = suonaMsgRecBg:getSize()

		if self.m_suonaMsgRecScrollView then
			--todo
			self.m_suonaMsgRecScrollView:removeSelf()
			self.m_suonaMsgRecScrollView = nil
		end

		local scrollBarWidth = 4

		self.m_suonaMsgRecScrollView = new(ScrollView, 0, 0, suonaMsgRecBgSizeWidth - 16, suonaMsgRecBgSizeHeight - 20, true)
			:addTo(suonaMsgRecBg)

		self.m_suonaMsgRecScrollView:setAlign(KAlignCenter)
		self.m_suonaMsgRecScrollView:setScrollBarWidth(scrollBarWidth)
		local scrollWidth, scrollHeight = self.m_suonaMsgRecScrollView:getSize()

		self.m_suonaMsgRecListItems = {}
		self.m_suonaMsgRecListItemNodes = {}

		local mySuonaMsgRecDataList = MySpeakerQueue:getSpeakerUser()

		-- Fake Data --
		-- local mySuonaMsgRecDataList = {{name = "tsisnh", content = "ahdkjwhkjadkjw ahdkjwahk!"}, {name = "kja kjh dksa jj",
		-- 	content = "dbawkj whjagda dkadk  jakddkj iuwd kadikh awd aoiadh ahwoadw oiaoiaw dhidahdk ahoid"}}

		for i = 1, #mySuonaMsgRecDataList do
			self.m_suonaMsgRecListItems[i] = new(SuonaMsgRecListItem, mySuonaMsgRecDataList[i])

			self.m_suonaMsgRecListItemNodes[i] = new(Node)
				:setSize(scrollWidth, self.m_suonaMsgRecListItems[i]:getItemContSize().height)
				:addTo(self.m_suonaMsgRecScrollView)

			self.m_suonaMsgRecListItems[i]:pos(scrollWidth / 2, self.m_suonaMsgRecListItems[i]:getItemContSize().height / 2)
				:addTo(self.m_suonaMsgRecListItemNodes[i])
		end
	end
end

function SuonaUsagePopu:onMainTabSelChanged_(idx)
	-- body
	if not self.mainTabIdx_ then
		--todo
		self.m_tabBtns[idx].txtNor_:hide()
		self.m_tabBtns[idx].txtSel_:show()

		self.mainTabIdx_ = idx
	end

	local isTabSelChanged = self.mainTabIdx_ ~= idx

	if isTabSelChanged then
		--todo
		self.m_tabBtns[self.mainTabIdx_].txtNor_:show()
		self.m_tabBtns[self.mainTabIdx_].txtSel_:hide()

		self.m_tabBtns[idx].txtNor_:hide()
		self.m_tabBtns[idx].txtSel_:show()

		self.mainTabIdx_ = idx
	end

	local tabBtnWidth = self.m_tabBtns[1]:getSize()

	self.btnImgSel_:setPos(tabBtnWidth * (self.mainTabIdx_ * 2 - 3) / 2, 0)

	for i = 1, #self.m_mainContPages do
		self.m_mainContPages[i]:hide()
	end

	self.m_mainContPages[self.mainTabIdx_]:show()

	self:getSuonaRecPageData()
end

function SuonaUsagePopu:onSuonaMsgContChanged_(obj, inputStr)
	-- body
	if string.len(string.trim(inputStr)) > 0 then
		--todo
		self.suonaMsgStr_ = inputStr

		-- local suonaPropNum = MyUserData:getPropNum(kIDSpeaker)
		-- if suonaPropNum > 0 then
		-- 	--todo
		-- 	local defaultBtnSendEnablePath = "popu/v210/btn_green.png"

		-- 	self.m_btnSuonaSend:setFile(defaultBtnSendEnablePath)
		-- 	self.m_btnSuonaSend:setEnable(true)
		-- end
	end
end

function SuonaUsagePopu:onBtnSendCallBack_(evt)
	-- body
	if self.suonaMsgStr_ then
		--todo
		local suonaPropNum = MyUserData:getPropNum(kIDSpeaker)

		if suonaPropNum > 0 then
			--todo
			local sendContStr = nil
			for i = 1, #illegalWord do
				sendContStr = string.gsub(self.suonaMsgStr_, illegalWord[i], "**")
			end

			HttpModule.getInstance():execute(HttpModule.s_cmds.SEND_SPEAKER, {content = sendContStr}, false, false)
		else
			AlarmTip.play(langConfStr.str_Suona_NilContTip)
		end
	else
		JLog.d("Nil SuonaMsg Input Or Sapce Msg!")
		AlarmTip.play(langConfStr.str_Suona_NilContTip)
	end
end

function SuonaUsagePopu:onCloseBtnCallBack_(evt)
	-- body
	self:dismiss()
end

function SuonaUsagePopu:onHttpRequestsCallBack(command, isSucc, data)
	-- body
	-- printInfo("HttpModule.s_cmds.SEND_SPEAKER :" .. HttpModule.s_cmds.SEND_SPEAKER)

	-- dump(data, "FeedBackPopu:onHttpRequestsCallBack(command :" .. command .. "isSucc :" .. tostring(isSucc) ..
	-- 	").data :===================")

	if command == HttpModule.s_cmds.SEND_SPEAKER then
		--todo
		if app:checkResponseOk(isSucc, data) then
			--todo
			local sendContStr = nil
			for i = 1, #illegalWord do
				sendContStr = string.gsub(self.suonaMsgStr_, illegalWord[i], "**")
			end
			table.insert(MyUserData:getSpeakerRecord(), sendContStr)

			local etvMsgContInput = self.m_mainContPages[1]:findChildByName("img_bgSuonaMsgInput"):findChildByName("etv_suonaMsgCont")
			etvMsgContInput:setText("")

			MyUserData:setPropNum(kIDSpeaker, data.data.pcnter or 0)
			
			self:dismiss()

			AlarmTip.play(langConfStr.str_Suona_SendSucc)
		else
			AlarmTip.play(langConfStr.str_Suona_SendFail)
		end
	end
end

function SuonaUsagePopu:dtor()
	-- body
	self.super.dtor(self)
	EventDispatcher.getInstance():unregister(HttpModule.s_event, self, self.onHttpRequestsCallBack)
end

return SuonaUsagePopu
