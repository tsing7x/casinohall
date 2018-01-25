--
-- Author: TsingZhang@boyaa.com
-- Date: 2017-09-21 18:22:50
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: UsrGameInfoListItem.lua Created By Tsing7x.
--

local langConfStr = require("app.res.config")

local UsrGameInfoListItem = class(Node)

function UsrGameInfoListItem:ctor()
	-- body
	local itemSizeNor = {
		width = 632,
		height = 146
	}

	self.itemBgSizeNorHeight_ = itemSizeNor.height

	local itemGapVect = 4

	self.itemSize_ = {
		width = itemSizeNor.width,
		height = itemSizeNor.height + itemGapVect
	}

	self.itemSizeFolded_ = self.itemSize_

	self.m_itemBg = new(Image, "popu/usrInfo/usrInfo_bgDentGameInfo.png", nil, nil, 12, 12, 12, 12)
		:setSize(self.itemSize_.width, itemSizeNor.height)
		:align(kAlignCenter)
		:addTo(self)

	self.m_itemFlodBtn = new(Button, "common/blank.png")
		:size(self.itemSize_.width, itemSizeNor.height)
		:addTo(self.m_itemBg)

	self.m_itemFlodBtn:setOnClick(self, handler(self, self.onItemFlodCallBack_))

	self.isItemFloded_ = true

	local gameIcMagrinLeft = 14
	self.m_gameIcon = new(Image, "popu/usrInfo/usrInfo_icItemGame.png")
		:align(kAlignCenter)

	local gameIconSizeWidth, gameIconSizeHeight = self.m_gameIcon:getSize()
	self.m_gameIcon:pos(- self.itemSize_.width / 2 + gameIcMagrinLeft + gameIconSizeWidth / 2, 0)
		:addTo(self.m_itemBg)

	local labelParam = {
		fontSize = 0,
		color = {
			r = 0,
			g = 0,
			b = 0
		}
	}

	local gameNameDscImgMagrinLeft = 24
	self.m_gameNameImg = new(Image, "language/thai/popu/usrInfo/usrInfo_dscGameInfoName_1017.png")
		:align(kAlignCenter)

	local nameImgSizeWidth, nameImgSizeHeight = self.m_gameNameImg:getSize()
	self.m_gameNameImg:pos(- self.itemSize_.width / 2 + gameIcMagrinLeft + gameIconSizeWidth + gameNameDscImgMagrinLeft + nameImgSizeWidth / 2, 0)
		:addTo(self.m_itemBg)

	local arrowCntMagrinRight = 62
	local arrowCntMagrinBot = 36

	self.m_infoDetailArrow = new(Image, "popu/usrInfo/usrInfo_decGameInfoArroeDown.png")
		:align(kAlignCenter)
		:pos(self.itemSize_.width / 2 - arrowCntMagrinRight, itemSizeNor.height / 2 - arrowCntMagrinBot)
		:addTo(self.m_itemBg)

	self.m_infoDivLine = new(Image, "popu/usrInfo/usrInfo_decInfoDivLine.png")
		:align(kAlignCenter)
		:pos(0, itemSizeNor.height / 2)
		:addTo(self.m_itemBg)
		:hide()

	labelParam.fontSize = 25
	labelParam.color.r = 75
	labelParam.color.g = 70
	labelParam.color.b = 65

	self.m_pokerRound = new(Text, "Game Round: 0", nil, nil, kAlignLeft, nil, labelParam.fontSize, labelParam.color.r, labelParam.color.g,
		labelParam.color.b)
		:addTo(self.m_itemBg)
		:hide()

	self.m_winRate = new(Text, "WinRate: 0%", nil, nil, kAlignLeft, nil, labelParam.fontSize, labelParam.color.r, labelParam.color.g,
		labelParam.color.b)
		:addTo(self.m_itemBg)
		:hide()

	self.m_maxWinCurrencyTitle = new(Text, langConfStr.str_userMaxWin, nil, nil, kAlignLeft, nil, labelParam.fontSize, labelParam.color.r, labelParam.color.g,
		labelParam.color.b)
		:addTo(self.m_itemBg)
		:hide()

	self.m_currencyIcImg = new(Image, "popu/usrInfo/usrInfo_icChip.png")
		:align(kAlignCenter)
		:addTo(self.m_itemBg)
		:hide()

	self.m_maxWinCurrencyNum = new(Text, "0", nil, nil, kAlignLeft, nil, labelParam.fontSize, labelParam.color.r, labelParam.color.g,
		labelParam.color.b)
		:addTo(self.m_itemBg)
		:hide()

	self.itemSizeUnfloded_ = {
		width = self.itemSize_.width, 
		height = itemSizeNor.height * 2 + itemGapVect
	}
end

function UsrGameInfoListItem:refreshItemData(data)
	-- body
	self.gameInfoItemIdx_ = data.index_

	local function getGameCurrencyIcPathByType(type)
		-- body
		if type == 0 then
			--todo
			return "popu/usrInfo/usrInfo_icChip.png"
		elseif type == 1 then
			--todo
			return "popu/usrInfo/usrInfo_icCash.png"
		else
			return nil
		end
	end

	local gameNameImgName = "usrInfo_dscGameInfoName_" .. (data.gameId or 1017) .. ".png"

	local gameNameImgFolder = "language/thai/popu/usrInfo/"

	if NativeEvent.getInstance():isFileExist(gameNameImgName, gameNameImgFolder) == 1 then
		--todo
		-- printInfo("file Exist :" .. gameNamePath)

		self.m_gameNameImg:setFile(gameNameImgFolder .. gameNameImgName)
	end

	-- Release Note In Win32 --
	-- self.m_gameNameImg:setFile(gameNamePath)

	self.m_pokerRound:setText(string.format(langConfStr.str_usrGameRound, data.gameRound or 0))
	self.m_winRate:setText(string.format(langConfStr.str_usrWinRate, tostring(((data.winRate or 0) * 100)) .. "%"))

	local gameCurrencyIcPath = getGameCurrencyIcPathByType(data.gameCurrencyType or 0)
	if gameCurrencyIcPath then
		--todo
		self.m_currencyIcImg:setFile(gameCurrencyIcPath)
	end
	self.m_maxWinCurrencyNum:setText(tostring(data.maxwCurrency or 0))
end

function UsrGameInfoListItem:refreshItemHeight()
	-- body
	local gameIcMagrinLeft = 14
	local gameNameDscImgMagrinLeft = 24

	local arrowCntMagrinRight = 62
	local arrowFlodInfoCntMagrinBot = 36
	local arrowUnflodCntMagrinBot = 40

	if self.isItemFloded_ then
		--todo
		local gameInfoTxtMagrinTop = 16
		local gameInfoTxtMagrinLeft = 20
		local gameInfoMagrinEachVect = 8
		local gameInfoMaxWinIcMagrinHoriz = 10

		self.m_infoDetailArrow:addPropRotate(0, kAnimNormal, 10, 0, 0, 180, kCenterDrawing)
		self.m_itemBg:setSize(self.itemSizeUnfloded_.width, self.itemBgSizeNorHeight_ * 2)
		
		self.m_infoDetailArrow:pos(self.itemSize_.width / 2 - arrowCntMagrinRight, self.itemBgSizeNorHeight_ - arrowUnflodCntMagrinBot)

		local gameIconSizeWidth, gameIconSizeHeight = self.m_gameIcon:getSize()
		self.m_gameIcon:pos(- self.itemSize_.width / 2 + gameIcMagrinLeft + gameIconSizeWidth / 2, - self.itemBgSizeNorHeight_ / 2)

		local nameImgSizeWidth, nameImgSizeHeight = self.m_gameNameImg:getSize()
		self.m_gameNameImg:pos(- self.itemSize_.width / 2 + gameIcMagrinLeft + gameIconSizeWidth + gameNameDscImgMagrinLeft + nameImgSizeWidth /
			2, - self.itemBgSizeNorHeight_ / 2)

		self.m_infoDivLine:pos(0, 0)
			:show()

		self.m_pokerRound:pos(gameInfoTxtMagrinLeft, self.itemBgSizeNorHeight_ + gameInfoTxtMagrinTop)
			:show()

		local pokerRoundTxtSizeWidth, pokerRoundTxtSizeHeight = self.m_pokerRound:getSize()
		self.m_winRate:pos(gameInfoTxtMagrinLeft, self.itemBgSizeNorHeight_ + gameInfoTxtMagrinTop + pokerRoundTxtSizeHeight +
			gameInfoMagrinEachVect)
			:show()

		local winRateTxtSizeWidth, winRateTxtSizeHeight = self.m_winRate:getSize()
		self.m_maxWinCurrencyTitle:pos(gameInfoTxtMagrinLeft, self.itemBgSizeNorHeight_ + gameInfoTxtMagrinTop + pokerRoundTxtSizeHeight +
			winRateTxtSizeHeight + gameInfoMagrinEachVect * 2)
			:show()

		local maxWinCurcyTitleTxtSizeWidth, maxWinCurcyTitleTxtSizeHeight = self.m_maxWinCurrencyTitle:getSize()
		local curcyIcImgSizeWidth, curcyIcImgSizeHeight = self.m_currencyIcImg:getSize()

		self.m_currencyIcImg:pos(- self.itemSize_.width / 2 + gameInfoTxtMagrinLeft + maxWinCurcyTitleTxtSizeWidth + gameInfoMaxWinIcMagrinHoriz +
			curcyIcImgSizeWidth / 2, gameInfoTxtMagrinTop + pokerRoundTxtSizeHeight + winRateTxtSizeHeight + gameInfoMagrinEachVect * 2 +
				maxWinCurcyTitleTxtSizeHeight / 2)
			:show()

		local maxWinCurcyNumTxtSizeWidth, maxWinCurcyNumTxtSizeWidth = self.m_maxWinCurrencyNum:getSize()
		self.m_maxWinCurrencyNum:pos(gameInfoTxtMagrinLeft + maxWinCurcyTitleTxtSizeWidth + gameInfoMaxWinIcMagrinHoriz * 2 + curcyIcImgSizeWidth,
			self.itemBgSizeNorHeight_ + gameInfoTxtMagrinTop + pokerRoundTxtSizeHeight + winRateTxtSizeHeight +	gameInfoMagrinEachVect * 2)
			:show()

		self.m_itemFlodBtn:pos(0, self.itemBgSizeNorHeight_)

		self.itemSize_ = self.itemSizeUnfloded_
	else
		self.m_infoDetailArrow:addPropRotate(0, kAnimNormal, 10, 0, 180, 0, kCenterDrawing)

		self.m_itemBg:setSize(self.itemSize_.width, self.itemBgSizeNorHeight_)

		self.m_infoDetailArrow:pos(self.itemSize_.width / 2 - arrowCntMagrinRight, self.itemBgSizeNorHeight_ / 2 - arrowFlodInfoCntMagrinBot)
		
		local gameIconSizeWidth, gameIconSizeHeight = self.m_gameIcon:getSize()
		self.m_gameIcon:pos(- self.itemSize_.width / 2 + gameIcMagrinLeft + gameIconSizeWidth / 2, 0)

		local nameImgSizeWidth, nameImgSizeHeight = self.m_gameNameImg:getSize()
		self.m_gameNameImg:pos(- self.itemSize_.width / 2 + gameIcMagrinLeft + gameIconSizeWidth + gameNameDscImgMagrinLeft + nameImgSizeWidth /
			2, 0)

		self.m_infoDivLine:hide()
		self.m_pokerRound:hide()
		self.m_winRate:hide()
		self.m_maxWinCurrencyTitle:hide()
		self.m_currencyIcImg:hide()
		self.m_maxWinCurrencyNum:hide()

		self.m_itemFlodBtn:pos(0,0)

		self.itemSize_ = self.itemSizeFolded_
	end
end

function UsrGameInfoListItem:onItemFlodCallBack_(evt)
	-- body
	if self.itemEvtClkCallBack_ then
		--todo
		local data = {
			isFloded = self.isItemFloded_,
			itemIdx = self.gameInfoItemIdx_,
			itemContHeight = self.itemSizeUnfloded_.height,
			itemHeightNor = self.itemSizeFolded_.height,
			itemSizeWidth = self.itemSize_.width
		}

		self.itemEvtClkCallBack_(data)
		self.isItemFloded_ = not self.isItemFloded_
	end
end

function UsrGameInfoListItem:setItemClkCallBack(callback)
	-- body
	self.itemEvtClkCallBack_ = callback
end

function UsrGameInfoListItem:getItemContSize()
	-- body
	return self.itemSize_
end

function UsrGameInfoListItem:dtor()
	-- body
	self.super.dtor()
end

return UsrGameInfoListItem