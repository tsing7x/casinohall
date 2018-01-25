--
-- Author: TsingZhang@boyaa.com
-- Date: 2017-09-25 18:45:50
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: UsrPropListComponItem.lua Created By Tsing7x.
--

local UsrPropListComponItem = class(Node)

function UsrPropListComponItem:ctor()
	-- body
	local itemBg = new(Image, "popu/usrInfo/usrInfo_bgPropItem.png")
		:align(kAlignCenter)
		:addTo(self)

	local itemGapRound = - 8
	local itemBgSizeWidth, itemBgSizeHeight = itemBg:getSize()

	self.itemBgSizeHeight_ = itemBgSizeHeight

	self.itemSize_ = {
		width = itemBgSizeWidth + itemGapRound,
		height = itemBgSizeHeight + itemGapRound
	}

	local labelParam = {
		fontSize = 0,
		color = {
			r = 0,
			g = 0,
			b = 0
		}
	}

	labelParam.fontSize = 26
	labelParam.color.r = 0
	labelParam.color.g = 0
	labelParam.color.b = 0

	self.m_propName = new(Text, "PropName", nil, nil, kAlignCenter, nil, labelParam.fontSize, labelParam.color.r, labelParam.color.g, labelParam.color.b)

	local txtPropNameCntPaddingBot = 80	
	local txtPropNameSizeWidth, txtPropNameSizeHeight = self.m_propName:getSize()
	self.m_propName:pos(- txtPropNameSizeWidth / 2, itemBgSizeHeight / 2 - txtPropNameCntPaddingBot)
		:addTo(self)

	labelParam.fontSize = 25
	labelParam.color.r = 153
	labelParam.color.g = 67
	labelParam.color.b = 38

	local txtPropNumMagrinBot = 32
	self.m_propNum = new(Text, "X 0", nil, nil, kAlignCenter, nil, labelParam.fontSize, labelParam.color.r, labelParam.color.g, labelParam.color.b)
	
	local txtPropNumSizeWidth, txtPropNumSizeHeight = self.m_propNum:getSize()
	self.m_propNum:pos(- txtPropNumSizeWidth / 2, itemBgSizeHeight / 2 - txtPropNumMagrinBot - txtPropNumSizeHeight / 2)
		:addTo(self)

	local icPropYAdj = - 18
	self.m_icProp = new(Image, "popu/usrInfo/usrInfo_icPropDef.png")
		:align(kAlignCenter)
		:pos(0, icPropYAdj)
		:addTo(itemBg)

	local QBtnCntMagrinRightTop = 44

	self.m_QBtn = new(Button, "popu/usrInfo/usrInfo_btnQPropItem.png")
		:align(kAlignCenter)
		:pos(itemBgSizeWidth / 2 - QBtnCntMagrinRightTop, - itemBgSizeHeight / 2 + QBtnCntMagrinRightTop)
		:addTo(itemBg)

	self.m_QBtn:setOnClick(self, handler(self, self.onQBtnCallBack_))
	self.m_QBtn:setEnable(false)
end

function UsrPropListComponItem:setItemData(data)
	-- body
	local orignDesc = data.des

	self.QBtnActionCallBack_ = data.callback_
	self.itemLine_ = data.line
	self.itemColumn_ = data.column

	self.m_QBtn:setEnable(true)

	local txtPropNameCntPaddingBot = 80
	self.m_propName:setText(data.keyName or "PropName.")
	local txtPropNameSizeWidth, txtPropNameSizeHeight = self.m_propName:getSize()
	self.m_propName:pos(- txtPropNameSizeWidth / 2, self.itemBgSizeHeight_ / 2 - txtPropNameCntPaddingBot)

	local txtPropNumMagrinBot = 32
	self.m_propNum:setText("X " .. (data.pcnter or 0))
	local txtPropNumSizeWidth, txtPropNumSizeHeight = self.m_propNum:getSize()
	self.m_propNum:pos(- txtPropNumSizeWidth / 2, self.itemBgSizeHeight_ / 2 - txtPropNumMagrinBot - txtPropNumSizeHeight / 2)

	if data.image and string.len(data.image) >= 5 then
		--todo
		local imgData = setProxy(new(require("app.data.imgData")))
		UIEx.bind(self, imgData, "imgName", function(value)
			if imgData:checkImg() then
				self.m_icProp:setFile(imgData:getImgName())
			end
	    end)
		imgData:setImgUrl(data.image)
	end
end

function UsrPropListComponItem:onQBtnCallBack_(evt)
	-- body
	local actionParam = {
		line = self.itemLine_,
		column = self.itemColumn_,
	}

	if self.QBtnActionCallBack_ then
		--todo
		self.QBtnActionCallBack_(actionParam)
	end
end

function UsrPropListComponItem:onPropOrignDescHintBgTouched_(evt)
	-- body
	self.m_propOrignDescTipModel:removeSelf()
	self.m_propOrignDescTipModel = nil
end

function UsrPropListComponItem:getListComponItemSize()
	-- body
	return self.itemSize_
end

function UsrPropListComponItem:dtor()
	-- body
end

return UsrPropListComponItem