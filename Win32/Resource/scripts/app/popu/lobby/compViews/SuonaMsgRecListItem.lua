--
-- Author: TsingZhang@boyaa.com
-- Date: 2018-01-23 16:55:03
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: SuonaMsgRecListItem.lua Created By Tsing7x.
--

local SuonaMsgRecListItem = class(Node)

function SuonaMsgRecListItem:ctor(msgData)
	-- body
	local defaultItemSize = {
		width = 606,
		height = 0
	}

	local itemGapVect = 4

	self.itemSize_ = {
		width = defaultItemSize.width,
		height = defaultItemSize.height + itemGapVect * 2
	}

	local suonaMsgTxtMagrinVect = 20

	local labelParam = {
		fontSize = 0,
		color = {
			r = 0,
			g = 0,
			b = 0
		}
	}

	labelParam.fontSize = 26
	labelParam.color.r = 192
	labelParam.color.g = 115
	labelParam.color.b = 85

	local suonaMsgSenderNameShownWidth = 98
	local suonaMsgSenderNameStr =  msgData.name or "Name"

	-- local suonaMsgSenderNameCutColon = 35
	-- local suonaMsgSenderNameSubStr = ToolKit.utf8_subStringByLen(suonaMsgSenderNameStr, suonaMsgSenderNameShownWidth - suonaMsgSenderNameCutColon)
	local suonaSendNameTv = new(TextView, "Name.", suonaMsgSenderNameShownWidth, nil, kAlignLeft, nil, labelParam.fontSize,
		labelParam.color.r,	labelParam.color.g,	labelParam.color.b)
	suonaSendNameTv:align(kAlignLeft)
	suonaSendNameTv:setScrollBarWidth(0)

	ToolKit.formatTextLength(suonaMsgSenderNameStr, suonaSendNameTv, suonaMsgSenderNameShownWidth)
	local colonTxt = new(Text, ":", nil, nil, kAlignLeft, nil, labelParam.fontSize, labelParam.color.r, labelParam.color.g,
		labelParam.color.b)
	colonTxt:align(kAlignLeft)

	local suonaMsgContTvShownWidth = 460
	local suonaMsgContStr = msgData.content or "msg content"
	local suonaMsgContTv = new(TextView, suonaMsgContStr, suonaMsgContTvShownWidth, nil, kAlignLeft, nil, labelParam.fontSize,
		labelParam.color.r,	labelParam.color.g,	labelParam.color.b)
	suonaMsgContTv:align(kAlignLeft)
	suonaMsgContTv:setScrollBarWidth(0)

	local msgRecBgHeight = suonaMsgContTv:getViewLength() + suonaMsgTxtMagrinVect * 2

	self.itemSize_.height = msgRecBgHeight + self.itemSize_.height
	local suonaMsgRecBg = new(Image, "popu/speaker/suona_bgSuonaMsgRec.png", nil, nil, 8, 8, 8, 8)
		:setSize(self.itemSize_.width, msgRecBgHeight)
		:align(kAlignCenter)
		:addTo(self)

	local suonaMsgSenderNameTvMagrinLeft = 15
	local suonaMsgRecContMagrinLeft = 16

	local suonaSenderNameTvSizeWidth, suonaSenderNameTvSizeHeight = suonaSendNameTv:getSize()

	suonaSendNameTv:pos(suonaMsgSenderNameTvMagrinLeft, - msgRecBgHeight / 2 + suonaMsgTxtMagrinVect + suonaSenderNameTvSizeHeight / 2)
		:addTo(suonaMsgRecBg)

	colonTxt:pos(suonaMsgSenderNameTvMagrinLeft + suonaMsgSenderNameShownWidth, - msgRecBgHeight / 2 + suonaMsgTxtMagrinVect + suonaSenderNameTvSizeHeight / 2)
		:addTo(suonaMsgRecBg)

	suonaMsgContTv:pos(suonaMsgSenderNameTvMagrinLeft + suonaMsgSenderNameShownWidth + suonaMsgRecContMagrinLeft, 0)
		:addTo(suonaMsgRecBg)
end

function SuonaMsgRecListItem:getItemContSize()
	-- body
	return self.itemSize_
end

function SuonaMsgRecListItem:dtor()
	-- body
end

return SuonaMsgRecListItem