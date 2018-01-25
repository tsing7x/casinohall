--
-- Author: TsingZhang@boyaa.com
-- Date: 2017-09-19 15:19:41
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: UsrInfoPopu.lua Reconstructed By Tsing7x.
--

local langConfStr = require("app.res.config")
local PaopHintFlwnd = require("app.popu.PaopHintFlwnd")

local UsrGameInfoListItem = import(".compViews.UsrGameInfoListItem")
local UsrPropLineListItem = import(".compViews.UsrPropListLineItem")

local GameWindow = require("app.popu.gameWindow")
local UsrInfoPopu = class(GameWindow)

function UsrInfoPopu:ctor(viewConf, data)
	-- body
end

function UsrInfoPopu:initView(data)
	local bgMainPanel = self.m_root:findChildByName("bg_mainPanel")
	bgMainPanel:setEventTouch(self, function()
	end)

	local closeBtn = bgMainPanel:findChildByName("btn_close"):setOnClick(self, handler(self, self.onBtnCloseCallBack_))
	
	local usrHeadBlk = bgMainPanel:findChildByName("bg_usrHeadBor")
	local usrHeadImg = usrHeadBlk:findChildByName("img_usrHead")

	UIEx.bind(self, MyUserData, "headName", function(fileName)
		if self.m_headImage then
			self.m_headImage:removeSelf()
			self.m_headImage = nil
		end

	    local width, height = usrHeadImg:getSize()
	    self.m_headImage = new(Mask, fileName, "lobby/hall_avator_bg.png")
	    self.m_headImage:setSize(width, height)
	    self.m_headImage:setName("img_head")
	    self.m_headImage:setAlign(kAlignCenter)
	    self.m_headImage:addTo(usrHeadImg)

	    MyUserData:checkHeadAndDownload()
	end)

	local usrHeadAlertBtn = usrHeadBlk:findChildByName("btn_headAlert")
	local usrHeadAlertBtnTxt = usrHeadAlertBtn:findChildByName("txt_headAltert")

	usrHeadAlertBtnTxt:setText(langConfStr.str_changeHead)
	usrHeadAlertBtn:setOnClick(self, handler(self, self.onUsrHeadAlertBtnCallBack_))

	local usrIdTxt = bgMainPanel:findChildByName("txt_usrInfoID")
	UIEx.bind(self, MyUserData, "id", function(value)
		if value then
			--todo
			usrIdTxt:setText(string.format("ID:%s", value))
		else
			usrIdTxt:setText("ID:0")
		end
	end)

	local alertNameBtn = bgMainPanel:findChildByName("btn_nameAlert")
	alertNameBtn:setOnClick(self, handler(self, self.onUsrNameAlertBtnCallBack_))
	local usrSexIc = bgMainPanel:findChildByName("ic_usrSex")
	local usrNameTv = bgMainPanel:findChildByName("tv_usrName")
	local usrNameAlertPenIc = bgMainPanel:findChildByName("ic_nameAlertPen")

	UIEx.bind(self, MyUserData, "sex", function(value)
    	if value == 2 then
    		usrSexIc:setFile("popu/usrInfo/usrInfo_icFemale.png")
    	else
    		usrSexIc:setFile("popu/usrInfo/usrInfo_icMale.png")
    	end
	end)

	UIEx.bind(self, MyUserData, "nick", function(value)
		if value then
			--todo
			ToolKit.formatTextLength(value, usrNameTv, usrNameTv:getSize())
		else
			usrNameTv:setText("Name.")
		end
	end)

	if UserType.Facebook == MyUserData:getUserType() then
		usrHeadAlertBtn:setEnable(false)
		usrHeadAlertBtn:setVisible(false)

        alertNameBtn:setEnable(false)
        usrNameAlertPenIc:setVisible(false)
	end

	local usrLevelTxt = bgMainPanel:findChildByName("txt_usrLevel")
	local usrLevelPrgbLayerImg = bgMainPanel:findChildByName("img_usrExpLayer")
	local usrLevelPrgbFillerImg = usrLevelPrgbLayerImg:findChildByName("img_usrExpFiller")
	self.m_usrLevelAboutBtn = bgMainPanel:findChildByName("btn_usrExpAbout")
	self.m_usrLevelAboutBtn:setOnClick(self, handler(self, self.onUsrLvAboutBtnCallBack_))

	UIEx.bind(self, MyUserData, "level", function(value)
		if value then
			--todo
			usrLevelTxt:setText("Lv." .. value)

		    local exp = tonumber(MyUserData:getExp()) 
		    local percent = 0
			if value then
				local index = tonumber(value)
				if index > 0 and index < 60 then
					local x1 = userLevelExp[index].x1 
					local x2 = userLevelExp[index].x2
					if exp > x1 then
						percent = math.ceil(((exp - x1) / (x2 - x1)) * 100)
						if percent >= 100 then
							percent = 99
						end
					end
				elseif index == 60 then
					percent = 99
				end
			end

		    local maxLen, bgHeight = usrLevelPrgbLayerImg:getSize()
		    local minLen, fillerHeight = usrLevelPrgbFillerImg:getSize()
		    usrLevelPrgbFillerImg:setSize(minLen + (maxLen - minLen) * percent / 100, fillerHeight)
		else
			usrLevelTxt:setText("Lv.0")
			local defShownLvPrgbLen = 12
			local minLen, fillerHeight = usrLevelPrgbFillerImg:getSize()

			usrLevelPrgbFillerImg:setSize(defShownLvPrgbLen, fillerHeight)
		end
    end)

	local usrChipNumTv = bgMainPanel:findChildByName("tv_usrChipNum")
	local usrCashNumTv = bgMainPanel:findChildByName("tv_usrCashNum")
	local usrChipAddBtn = bgMainPanel:findChildByName("btn_getCurrencyChip")
	local usrCashAddBtn = bgMainPanel:findChildByName("btn_getCurrencyCash")
	usrChipAddBtn:setOnClick(self, handler(self, self.onGetCurrencyChipBtnCallBack_))
	usrCashAddBtn:setOnClick(self, handler(self, self.onGetCurrencyCashBtnCallBack_))

	UIEx.bind(self, MyUserData, "money", function(value)
		if value then
			--todo
			usrChipNumTv:setText(ToolKit.formatMoney(value))
		else
			usrChipNumTv:setText("0")
		end
	end)

	UIEx.bind(self, MyUserData, "cashPoint", function(value)
		if value then
			--todo
			usrCashNumTv:setText(ToolKit.formatMoney(value))
		else
			usrCashNumTv:setText("0")
		end
	end)

	MyUserData:setCashPoint(MyUserData:getCashPoint())
	MyUserData:setNick(MyUserData:getNick())
	MyUserData:setMoney(MyUserData:getMoney())
	-- MyUserData:setRoomCardNum(MyUserData:getRoomCardNum())

	MyUserData:setSex(MyUserData:getSex())
	MyUserData:setLevel(MyUserData:getLevel())
	MyUserData:setHeadName(MyUserData:getHeadName())
	MyUserData:setId(MyUserData:getId())

	local defaultabIdx = data.tabIdx or 1
	local usrGameInfoTabView = bgMainPanel:findChildByName("vb_usrGameInfoTab")

	local tabViewBtns = usrGameInfoTabView:getChildren()
	self.m_tabBtns = {}
	for i = 1, #tabViewBtns do
		self.m_tabBtns[i] = usrGameInfoTabView:findChildByName("btn_tabIdx" .. i)
		self.m_tabBtns[i].m_stateImgSel = self.m_tabBtns[i]:findChildByName("img_tabBtnSel")
		self.m_tabBtns[i].m_stateImgNor = self.m_tabBtns[i]:findChildByName("img_tabBtnNor")

		self.m_tabBtns[i]:setOnClick(self, function(obj)
			-- body
			self:onInfoTabSelChanged_(i)
		end)
	end

	self.m_infoContPageViews = {
		bgMainPanel:findChildByName("vb_usrGameInfo"),
		bgMainPanel:findChildByName("vb_usrPropInfo")
	}

	self.m_noPropHintTxt = self.m_infoContPageViews[2]:findChildByName("txt_noPropHint")
	self.m_noPropHintTxt:setText(langConfStr.str_noPropHint)
	self.m_noPropHintTxt:hide()

	self.m_tabBtns[defaultabIdx].m_eventCallback.func(self.m_tabBtns[defaultabIdx].m_eventCallback.obj)
end

function UsrInfoPopu:renderMainInfoViewPages(tabIdx)
	-- body
	-- if tabIdx == 1 then
	-- 	--todo
	-- elseif tabIdx == 2 then
	-- 	--todo
	-- end
end


function UsrInfoPopu:getUsrInfoPageDatas()
	-- body
	if self.mainTabIdx_ == 1 then
		--todo
		if not self.myGameInfoDataList_ or #self.myGameInfoDataList_ <= 0 then
			--todo
			local gameIds = ""
			for k, v in pairs(GAME_ID) do
				if string.len(gameIds) > 0 then
					gameIds = gameIds .. ","
				end
				gameIds = gameIds .. v
			end

			local param = {gameid = gameIds}
			self:execHttpCmd(HttpModule.s_cmds.GET_GAMEINFO, param, nil, true, self.m_infoContPageViews[1])

			-- self.myGameInfoDataList_ = self.myGameInfoDataList_ or {}

			-- Fake Datas --
			-- for i = 1, 10 do
			-- 	self.myGameInfoDataList_[i] = {}
			-- 	self.myGameInfoDataList_[i].index_ = i
			-- 	self.myGameInfoDataList_[i].gameId = i % 2 == 0 and 1017 or 1018
			-- 	self.myGameInfoDataList_[i].gameCurrencyType = i % 2
			-- 	self.myGameInfoDataList_[i].gameRound = i * 10
			-- 	self.myGameInfoDataList_[i].winRate = 0.5 + i / 100
			-- 	self.myGameInfoDataList_[i].maxwCurrency = 100000 + i * 100
			-- end

			-- self:refreshGameInfoListView()
			-- End --
		end
	elseif self.mainTabIdx_ == 2 then
		--todo
		if not self.myPropInfoDataList_ or #self.myPropInfoDataList_ <= 0 then
			--todo
			self:execHttpCmd(HttpModule.s_cmds.PROPS_GET_USERPROPS_LIST, {}, nil, true, self.m_infoContPageViews[2])
		end
	end
end

function UsrInfoPopu:refreshGameInfoListView()
	-- body
	local pageContViewWidth, pageContViewHeight = self.m_infoContPageViews[1]:getSize()

	if self.m_myGameInfoScrollView then
		--todo
		self.m_myGameInfoScrollView:removeSelf()
		self.m_myGameInfoScrollView = nil
	end

	local scrollBarWidth = 4

	self.m_myGameInfoScrollView = new(ScrollView, 0, 0, pageContViewWidth - 12, pageContViewHeight - 10, true)
		:addTo(self.m_infoContPageViews[1])

	self.m_myGameInfoScrollView:setAlign(KAlignCenter)
	self.m_myGameInfoScrollView:setScrollBarWidth(scrollBarWidth)
	local scrollWidth, scrollHeight = self.m_myGameInfoScrollView:getSize()

	self.m_myGameInfoListItems = {}
	self.m_myGameInfoListItemNodes = {}

	for i = 1, #self.myGameInfoDataList_ do
		self.m_myGameInfoListItems[i] = new(UsrGameInfoListItem)

		self.m_myGameInfoListItemNodes[i] = new(Node)
			:setSize(scrollWidth, self.m_myGameInfoListItems[i]:getItemContSize().height)
			:addTo(self.m_myGameInfoScrollView)

		self.m_myGameInfoListItems[i]:pos(scrollWidth / 2, self.m_myGameInfoListItems[i]:getItemContSize().height / 2)
			:addTo(self.m_myGameInfoListItemNodes[i])

		self.m_myGameInfoListItems[i]:setItemClkCallBack(handler(self, self.onGameInfoItemClkEvtCallBack_))
		self.m_myGameInfoListItems[i]:refreshItemData(self.myGameInfoDataList_[i])
	end
end

function UsrInfoPopu:refreshUsrPropListView()
	-- body
	self.m_noPropHintTxt:hide()

	local pageContViewWidth, pageContViewHeight = self.m_infoContPageViews[2]:getSize()

	if self.m_myPropScrollView then
		--todo
		self.m_myPropScrollView:removeSelf()
		self.m_myPropScrollView = nil
	end

	local scrollBarWidth = 4

	self.m_myPropScrollView = new(ScrollView, 0, 0, pageContViewWidth - 12, pageContViewHeight - 10, true)
		:addTo(self.m_infoContPageViews[2])

	self.m_myPropScrollView:setAlign(KAlignCenter)
	self.m_myPropScrollView:setScrollBarWidth(scrollBarWidth)
	local scrollWidth, scrollHeight = self.m_myPropScrollView:getSize()

	self.m_myPropListLineItems = {}

	local lineItemsYFall = 2
	for i = 1, #self.myPropInfoDataList_ do
		self.m_myPropListLineItems[i] = new(UsrPropLineListItem)

		local scrollNode = new(Node)
			:setSize(self.m_myPropListLineItems[i]:getLineItemContSize().width, self.m_myPropListLineItems[i]:getLineItemContSize().height)
			:addTo(self.m_myPropScrollView)

		self.m_myPropListLineItems[i]:pos(self.m_myPropListLineItems[i]:getLineItemContSize().width / 2,
			self.m_myPropListLineItems[i]:getLineItemContSize().height / 2 + lineItemsYFall)
			:addTo(scrollNode)
		self.m_myPropListLineItems[i]:setListLineItemData(self.myPropInfoDataList_[i])
	end
end

function UsrInfoPopu:onUsrGameInfoDataGet(isSuccess, data)
	-- JLog.d("UsrInfoPopu:onUsrGameInfoDataGet(isSuccess :" .. tostring(isSuccess) .. ").data :=============", data)
	if app:checkResponseOk(isSuccess, data) then
		local userData = data.data
		MyUserData:setHeadUrl(userData.micon or "")
		MyUserData:setId(tonumber(userData.mid or 0))
		MyUserData:setSex(tonumber(userData.msex or 2))
		MyUserData:setNick(userData.name or "Unknow")
		MyUserData:setLevel(tonumber(userData.level or 0))
		MyUserData:setExp(tonumber(userData.exp or 0))
		MyUserData:setMoney(tonumber(userData.money or 0))
		MyUserData:setCashPoint(tonumber(userData.diamond or 0))

		self.myGameInfoDataList_ = self.myGameInfoDataList_ or {}

		local usrGameInfoDataList = data.data.gameInfo
		if usrGameInfoDataList and #usrGameInfoDataList > 0 then
			--todo
			for i = 1, #usrGameInfoDataList do
				self.myGameInfoDataList_[i] = {}
				self.myGameInfoDataList_[i].index_ = i
				self.myGameInfoDataList_[i].gameId = tonumber(usrGameInfoDataList[i].gameid or 1017)
				self.myGameInfoDataList_[i].gameCurrencyType = tonumber(usrGameInfoDataList[i].moneyType or 0)

				local usrWinTimes = tonumber(usrGameInfoDataList[i].wintimes or 0)
				local usrLoseTimes = tonumber(usrGameInfoDataList[i].losetimes or 0)
				local usrWinRate = 0
				if usrWinTimes + usrLoseTimes > 0 then
					--todo
					usrWinRate = tonumber(string.format("%.4f", usrWinTimes / (usrWinTimes + usrLoseTimes)))
				end
				self.myGameInfoDataList_[i].gameRound = usrWinTimes + usrLoseTimes
				self.myGameInfoDataList_[i].winRate = usrWinRate
				self.myGameInfoDataList_[i].maxwCurrency = tonumber(usrGameInfoDataList[i].maxwmoney or 0)
			end

			self:refreshGameInfoListView()
		else
			self.myGameInfoDataList_ = nil
		end
	else
		AlarmTip.play(langConfStr.STR_SERVER_ERROR)
	end
end

function UsrInfoPopu:onUsrPropInfoDataListGet(isSuccess, data)
	-- JLog.d("UsrInfoPopu:onUsrPropInfoDataListGet(isSuccess :" .. tostring(isSuccess) .. ").data :=============", data)
	if app:checkResponseOk(isSuccess, data) then
		self.myPropInfoDataList_ = self.myPropInfoDataList_ or {}

		if data.data and #data.data > 0 then
			--todo
			for i = 1, #data.data do
				data.data[i].callback_ = handler(self, self.onPropItemClkEvtCallBack_)
			end

			self.myPropInfoDataList_ = self:formatPropDataListToGroup(data.data)

			-- Fake Data --
			-- self.myPropInfoDataList_ = {{1, 2, 3}, {4, 5, 6}, {7, 8, 9}}
			-- local fakeData = {{1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}}
			-- for i = 1, #fakeData do
			-- 	fakeData[i].callback_ = handler(self, self.onPropItemClkEvtCallBack_)
			-- end

			-- self.myPropInfoDataList_ = self:formatPropDataListToGroup(fakeData)

			self:refreshUsrPropListView()
		else
			self.myPropInfoDataList_ = nil

			if self.m_myPropScrollView then
				--todo
				self.m_myPropScrollView:removeSelf()
				self.m_myPropScrollView = nil
			end
			self.m_noPropHintTxt:show()
		end
	else
		AlarmTip.play(langConfStr.STR_SERVER_ERROR)
	end
end

function UsrInfoPopu:formatPropDataListToGroup(propDataList)
	-- body
	local numIn1Group = 3
	local groupNum = math.ceil(#propDataList / numIn1Group)

	local retGroupDataList = {}

	for i = 1, groupNum do
		retGroupDataList[i] = {}
		for j = 1, numIn1Group do
			if propDataList[(i - 1) * numIn1Group + j] then
				--todo
				propDataList[(i - 1) * numIn1Group + j].line = i
				propDataList[(i - 1) * numIn1Group + j].column = j
				table.insert(retGroupDataList[i], propDataList[(i - 1) * numIn1Group + j])
			end
		end
	end

	return retGroupDataList
end

function UsrInfoPopu:onInfoTabSelChanged_(idx)
	-- body
	if not self.mainTabIdx_ then
		--todo
		self.m_tabBtns[idx].m_stateImgSel:show()
		self.m_tabBtns[idx].m_stateImgNor:hide()
		self.mainTabIdx_ = idx
	end

	local isSelChanged = self.mainTabIdx_ ~= idx

	if isSelChanged then
		--todo
		self.m_tabBtns[self.mainTabIdx_].m_stateImgNor:show()
		self.m_tabBtns[self.mainTabIdx_].m_stateImgSel:hide()

		self.m_tabBtns[idx].m_stateImgNor:hide()
		self.m_tabBtns[idx].m_stateImgSel:show()

		self.mainTabIdx_ = idx
	end

	-- self:renderMainInfoViewPages(self.mainTabIdx_)
	for i = 1, #self.m_infoContPageViews do
		self.m_infoContPageViews[i]:hide()
	end

	self.m_infoContPageViews[self.mainTabIdx_]:show()

	self:getUsrInfoPageDatas()
end

function UsrInfoPopu:onBtnCloseCallBack_(evt)
	-- body
	self:dismiss()
end

function UsrInfoPopu:onUsrHeadAlertBtnCallBack_(evt)
	-- body
	WindowManager:showWindow(WindowTag.ChangeHeadPopu, nil, WindowStyle.POPUP)
end

function UsrInfoPopu:onUsrNameAlertBtnCallBack_(evt)
	-- body
	WindowManager:showWindow(WindowTag.ChangeNickPopu, {callback = handler(self, self.onUsrNickSexChangeCallBack_)}, WindowStyle.POPUP)
end

function UsrInfoPopu:onUsrLvAboutBtnCallBack_(evt)
	-- body
	local lvAboutTextNode = new(Node)
	lvAboutTextNode:align(kAlignCenter)

	local labelParam = {
		fontSize = 0,
		color = {
			r = 0,
			g = 0,
			b = 0
		}
	}

	labelParam.fontSize = 26
	labelParam.color.r = 166
	labelParam.color.g = 239
	labelParam.color.b = 255
	local lvAboutTxtTitle = new(Text, langConfStr.str_lvHintTitle, nil, nil, kAlignCenter, nil, labelParam.fontSize, labelParam.color.r,
		labelParam.color.g,	labelParam.color.b)
	lvAboutTxtTitle:align(kAlignCenter)
	local lvAboutTxtTitleWidth, lvAboutTxtTitleHeight = lvAboutTxtTitle:getSize()

	labelParam.fontSize = 25
	labelParam.color.r = 246
	labelParam.color.g = 233
	labelParam.color.b = 208
	local lvAboutTxtShownWidth = 388

	local lvAboutTxtCont = new(TextView, langConfStr.str_level_help, lvAboutTxtShownWidth, nil, kAlignLeft, nil, labelParam.fontSize,
		labelParam.color.r,	labelParam.color.g,	labelParam.color.b)
	lvAboutTxtCont:align(kAlignLeft)
	lvAboutTxtCont:setScrollBarWidth(0)
	local lvAboutTxtContWidth, lvAboutTxtContHeight = lvAboutTxtCont:getSize()
	
	local lvAboutTipFlwndInnerMagrinRound = 16
	local lvAboutTitleContMagrinVect = 10

	local lvAboutTxtHeight = lvAboutTxtTitleHeight + lvAboutTxtContHeight + lvAboutTitleContMagrinVect

	lvAboutTxtTitle:pos(- lvAboutTxtShownWidth / 2 + lvAboutTxtTitleWidth / 2, - lvAboutTxtHeight / 2 + lvAboutTxtTitleHeight / 2)
		:addTo(lvAboutTextNode)

	lvAboutTxtCont:pos(0, lvAboutTxtHeight / 2 - lvAboutTxtContHeight / 2)
		:addTo(lvAboutTextNode)

	lvAboutTextNode:setSize(lvAboutTxtShownWidth, lvAboutTxtHeight)
	if not self.m_infoHintPaopTipModel then
		--todo
		self.m_infoHintPaopTipModel = UIFactory.createImage("ui/blank.png")
		self.m_infoHintPaopTipModel:setFillParent(true, true)
		self.m_infoHintPaopTipModel:setLevel(250)
		self.m_infoHintPaopTipModel:setEventTouch(self, handler(self, self.onInfoPaopHintBgTouched_))
		self.m_infoHintPaopTipModel:addTo(self.m_root)

		local arrowTowardRightDistance = 14

		local paopArrowAlign = {
			direction = PaopHintFlwnd.DIRECTION_TOP,
			toward = PaopHintFlwnd.TOWARD_RIGHT,
			magrin = arrowTowardRightDistance
		}

		local bgPanel = self.m_root:findChildByName("bg_mainPanel")
		-- local bgPanelSizeWidth, bgPanelSizeHeight = bgPanel:getSize()

		local usrLvAboutBtnPosX, usrLvAboutBtnPosY = self.m_usrLevelAboutBtn:getPos()
		local usrLvAboutBtnSizeWidth, usrLvAboutBtnSizeHeight = self.m_usrLevelAboutBtn:getSize()

		local screenWidth = System.getScreenScaleWidth()
        local screenHeight = System.getScreenScaleHeight()

		local lvHintPaopHintPosAdj = {
			x = 8,
			y = 10
		}
		local lvAboutPaopHint = new(PaopHintFlwnd, lvAboutTextNode, paopArrowAlign, lvAboutTipFlwndInnerMagrinRound)
		local lvAboutPaopHintContSize = lvAboutPaopHint:getPaopTipSize()
		lvAboutPaopHint:pos(screenWidth / 2 + math.abs(usrLvAboutBtnPosX) - lvAboutPaopHintContSize.width / 2 + arrowTowardRightDistance +
			lvHintPaopHintPosAdj.x,	screenHeight / 2 - math.abs(usrLvAboutBtnPosY) + lvAboutPaopHintContSize.height / 2 + usrLvAboutBtnSizeHeight / 2 +
				lvHintPaopHintPosAdj.y)
			:addTo(self.m_infoHintPaopTipModel)

	else
		self.m_infoHintPaopTipModel:removeSelf()
		self.m_infoHintPaopTipModel = nil
	end
end

function UsrInfoPopu:onGetCurrencyChipBtnCallBack_(evt)
	-- body
	WindowManager:showWindow(WindowTag.ShopPopu, nil, WindowStyle.TRANSLATE_RIGHT)
	self:dismiss()
end

function UsrInfoPopu:onGetCurrencyCashBtnCallBack_(evt)
	-- body
	local tabCashPayIdx = 2
	WindowManager:showWindow(WindowTag.ShopPopu, {tab = tabCashPayIdx}, WindowStyle.TRANSLATE_RIGHT)
	self:dismiss()
end

function UsrInfoPopu:onInfoPaopHintBgTouched_(evt)
	-- body
	self.m_infoHintPaopTipModel:removeSelf()
	self.m_infoHintPaopTipModel = nil
end

function UsrInfoPopu:onGameInfoItemClkEvtCallBack_(data)
	-- body
	local isFlodUp = data.isFloded
	local idx = data.itemIdx
	local itemHeightCal = data.itemContHeight
	local itemHeightNor = data.itemHeightNor
	local itemSizeWidth = data.itemSizeWidth

	local heightAboveSum = 0
	for i = 1, idx - 1 do
		heightAboveSum = heightAboveSum + self.m_myGameInfoListItems[i]:getItemContSize().height
	end

	if isFlodUp then
		--todo
		self.m_myGameInfoListItemNodes[idx]:setSize(itemSizeWidth, itemHeightCal)
		self.m_myGameInfoListItemNodes[idx]:pos(0, (itemHeightCal - itemHeightNor) / 2 + heightAboveSum)

		self.m_myGameInfoListItems[idx]:refreshItemHeight()
		for i = idx + 1, #self.myGameInfoDataList_ do
			local itemNodePosX, itemNodePosY = self.m_myGameInfoListItemNodes[i]:getPos()

			self.m_myGameInfoListItemNodes[i]:pos(0, itemNodePosY + (itemHeightCal - itemHeightNor))
		end

		local pageContViewWidth, pageContViewHeight = self.m_infoContPageViews[1]:getSize()
		self.m_myGameInfoScrollView:resetScrollContentSize(pageContViewWidth, self.m_myGameInfoScrollView:getViewLength() + itemHeightCal - itemHeightNor)
	else
		self.m_myGameInfoListItemNodes[idx]:setSize(itemSizeWidth, itemHeightNor)
		self.m_myGameInfoListItemNodes[idx]:pos(0, heightAboveSum)

		self.m_myGameInfoListItems[idx]:refreshItemHeight()
		for i = idx + 1, #self.myGameInfoDataList_ do
			local itemNodePosX, itemNodePosY = self.m_myGameInfoListItemNodes[i]:getPos()

			self.m_myGameInfoListItemNodes[i]:pos(0, itemNodePosY - (itemHeightCal - itemHeightNor))
		end

		local pageContViewWidth, pageContViewHeight = self.m_infoContPageViews[1]:getSize()
		self.m_myGameInfoScrollView:resetScrollContentSize(pageContViewWidth, self.m_myGameInfoScrollView:getViewLength() - (itemHeightCal - itemHeightNor))
	end
end

function UsrInfoPopu:onPropItemClkEvtCallBack_(data)
	-- body
	local itemLine = data.line
	local itemColumn = data.column

	local labelParam = {
		fontSize = 0,
		color = {
			r = 0,
			g = 0,
			b = 0
		}
	}

	labelParam.fontSize = 26
	labelParam.color.r = 246
	labelParam.color.g = 233
	labelParam.color.b = 208
	local propPOrignHintText = new(Text, langConfStr.str_question_des, nil, nil, kAlignCenter, nil, labelParam.fontSize, labelParam.color.r,
		labelParam.color.g,	labelParam.color.b)
	propPOrignHintText:align(kAlignCenter)

	if not self.m_infoHintPaopTipModel then
		--todo
		self.m_infoHintPaopTipModel = UIFactory.createImage("ui/blank.png")
		self.m_infoHintPaopTipModel:setFillParent(true, true)
		self.m_infoHintPaopTipModel:setLevel(255)
		self.m_infoHintPaopTipModel:setEventTouch(self, handler(self, self.onInfoPaopHintBgTouched_))
		self.m_infoHintPaopTipModel:addTo(self.m_root)

		local arrowTowardRightDistance = 14

		local paopArrowAlign = nil

		local getPaopArrowAlignParam = {
			[1] = function()
				-- body
				paopArrowAlign = {
					direction = PaopHintFlwnd.DIRECTION_BOTTOM,
					toward = PaopHintFlwnd.TOWARD_LEFT,
					magrin = arrowTowardRightDistance
				}
			end,

			[2] = function()
				-- body
				paopArrowAlign = PaopHintFlwnd.BOTTOM_CENTER
			end,

			[3] = function()
				-- body
				paopArrowAlign = {
					direction = PaopHintFlwnd.DIRECTION_BOTTOM,
					toward = PaopHintFlwnd.TOWARD_RIGHT,
					magrin = arrowTowardRightDistance
				}
			end
		}

		getPaopArrowAlignParam[itemColumn]()

		local propItemSize = {
			width = 210,
			height = 210
		}
		local propItemGap = 8

		local propItemQBtnSize = {
			width = 56,
			height = 56
		}
		local propQBtnMagrinTopRight = 8

		local screenWidth = System.getScreenScaleWidth()
        local screenHeight = System.getScreenScaleHeight()

		local bgPanel = self.m_root:findChildByName("bg_mainPanel")
		local bgPanelSizeWidth, bgPanelSizeHeight = bgPanel:getSize()

		local propListViewBlk = bgPanel:findChildByName("vb_usrPropInfo")
		local propListViewBlkPosX, propListViewBlkPosY = propListViewBlk:getPos()
		local propListViewSizeWidth, propListViewSizeHeight = propListViewBlk:getSize()

  		local lvAboutTipFlwndInnerMagrinRound = 25

  		local bgPanelBorderWidth = 25

		local lvHintPaopHintPosAdj = {
			x = 4.8,
			y = 22
		}

		local propOrignPaopHint = new(PaopHintFlwnd, propPOrignHintText, paopArrowAlign, lvAboutTipFlwndInnerMagrinRound)
		local propOrignPaopHintContSize = propOrignPaopHint:getPaopTipSize()

		local propPaopHintPosX = screenWidth / 2 - bgPanelSizeWidth / 2 + bgPanelBorderWidth + propItemGap * (itemColumn * 2 - 1) / 2 +
			propItemSize.width * itemColumn + propOrignPaopHintContSize.width / 2 - propQBtnMagrinTopRight - propItemQBtnSize.width / 2 -
				arrowTowardRightDistance + lvHintPaopHintPosAdj.x * itemColumn

		local totalScrollOffset = self.m_myPropScrollView:getContScrollOffset()

		local propPaopHintPosY = screenHeight / 2 + bgPanelSizeHeight / 2 - bgPanelBorderWidth - propListViewBlkPosY - propListViewSizeHeight -
			propOrignPaopHintContSize.height / 2 + propItemGap * itemLine + propItemSize.height * (itemLine - 1) + lvHintPaopHintPosAdj.y +
				totalScrollOffset

		local getPropPaopHintPosX = {
			[1] = function()
				-- body
				printInfo("Do Nothing!")
			end,

			[2] = function()
				-- body
				propPaopHintPosX = propPaopHintPosX - propOrignPaopHintContSize.width / 2 + arrowTowardRightDistance
			end,

			[3] = function()
				-- body
				propPaopHintPosX = propPaopHintPosX - propOrignPaopHintContSize.width + arrowTowardRightDistance * 2
			end
		}

		getPropPaopHintPosX[itemColumn]()

		propOrignPaopHint:pos(propPaopHintPosX, propPaopHintPosY)
			:addTo(self.m_infoHintPaopTipModel)
	else
		self.m_infoHintPaopTipModel:removeSelf()
		self.m_infoHintPaopTipModel = nil
	end
end

function UsrInfoPopu:onUsrNickSexChangeCallBack_(usrName, usrSex)
	-- body
	HttpModule.getInstance():execute(HttpModule.s_cmds.PERINFO_UPDATE_USERIINFO, {name = usrName, msex = usrSex}, false, true)
end

function UsrInfoPopu:dtor()
	-- body
	self.super.dtor(self)
end

UsrInfoPopu.s_severCmdEventFuncMap = {
	[HttpModule.s_cmds.GET_GAMEINFO]						= UsrInfoPopu.onUsrGameInfoDataGet,
	[HttpModule.s_cmds.PROPS_GET_USERPROPS_LIST]			= UsrInfoPopu.onUsrPropInfoDataListGet
	-- [HttpModule.s_cmds.GIFT_SYSTEM_GET_USERGIFT_LIST]		= UsrInfoPopu.onGetUserGiftList
}

return UsrInfoPopu