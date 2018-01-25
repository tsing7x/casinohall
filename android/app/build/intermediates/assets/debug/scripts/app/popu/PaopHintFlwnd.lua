--
-- Author: TsingZhang@boyaa.com
-- Date: 2017-09-29 16:02:03
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: PaopHintFlwnd.lua Created By Tsing7x.
--

local PaopHintFlwnd = class(Node)

-- STANDARD POS --
PaopHintFlwnd.LEFT_CENTER = 1; PaopHintFlwnd.CENTER_LEFT = 1
PaopHintFlwnd.BOTTOM_CENTER = 2; PaopHintFlwnd.CENTER_BOTTOM = 2
PaopHintFlwnd.RIGHT_CENTER = 3; PaopHintFlwnd.CENTER_RIGHT = 3
PaopHintFlwnd.TOP_CENTER = 4; PaopHintFlwnd.CENTER_TOP = 4

-- ARROW POS DIRECTION --
PaopHintFlwnd.DIRECTION_TOP = 1
PaopHintFlwnd.DIRECTION_BOTTOM = 2
PaopHintFlwnd.DIRECTION_LEFT = 3
PaopHintFlwnd.DIRECTION_RIGHT = 4

-- ARROW MAGRIN TOWARD --
PaopHintFlwnd.TOWARD_UP = 1
PaopHintFlwnd.TOWARD_DOWN = 2
PaopHintFlwnd.TOWARD_LEFT = 3
PaopHintFlwnd.TOWARD_RIGHT = 4

local ARROW_DIRECTION_HORIZONTAL = 1
local ARROW_DIRECTION_VERTIACL = 2

-- @param tipsLabel: tips文本标签, Needed!; arrowAlign: 箭头指示对齐方式, arrowAlign
-- 可能出现的参数 1. type(arrowAlign) == "number" [STANDARD POS] <详见参数 STANDARD POS>

-- 2.type(arrowAlign) == "table" 要求数据格式:
-- 	{direction: [ARROW POS DIRECTION] <详见参数 ARROW POS DIRECTION>,
-- 		toward: [ARROW MAGRIN TOWARD] <详见参数 ARROW MAGRIN TOWARD>,
-- 		magrin: type(magrin) == "number", 箭头固定边距距离.
-- 	}

-- magrins 文字距离边框边缘的边距,可能出现的参数 1.type(magrins) == "number" 统一设置内部距离上下左右的边距,
-- 2.type(magrins) == "table", 数据格式:
-- {left: type(left) == "number", 左边距;
-- 	right: type(right) == "number", 右边距;
-- 	top: type(top) == "number", 上边距;
-- 	bottom: type(bottom) == "number", 下边距.
-- }
function PaopHintFlwnd:ctor(tipsObj, arrowAlign, magrins)
	-- body
	local tipsLabelNil = new(Text, "tips", nil, nil, kAlignCenter, nil, 26)
	self.tipsLabel_ = tipsObj or tipsLabelNil
	self:buildView(arrowAlign, magrins)
end

function PaopHintFlwnd:buildView(arrAlign, magrins)
	-- body
	local tipsLabelContSizeWidth, tipsLabelContSizeHeight = self.tipsLabel_:getSize()

	local borderSize = {
		width = 0,
		height = 0
	}

	if type(magrins) == "number" then
		--todo
		borderSize.width = tipsLabelContSizeWidth + magrins * 2
		borderSize.height = tipsLabelContSizeHeight + magrins * 2
	elseif type(magrins) == "table" then
		--todo
		borderSize.width = tipsLabelContSizeWidth + (magrins.left or 0) + (magrins.right or 0)
		borderSize.height = tipsLabelContSizeHeight + (magrins.top or 0) + (magrins.bottom or 0)

		self.tipsLabel_:pos((magrins.left - magrins.right) / 2, (magrins.bottom - magrins.top) / 2)
	else
		dump("Wrong type magrins！")
	end

	local bgTipBorSentcil = {
		left = 6,
		right = 6,
		top = 8,
		bottom = 8
	}

	self.borderMain_ = new(Image, "popu/usrInfo/usrInfo_bgTip.png", nil, nil, bgTipBorSentcil.left, bgTipBorSentcil.right, bgTipBorSentcil.top,
		bgTipBorSentcil.bottom)
		:align(kAlignCenter)
		:setSize(borderSize.width, borderSize.height)
		:addTo(self)

	self.tipsLabel_:addTo(self.borderMain_)

	self.tipsArrow_ = new(Image, "popu/usrInfo/usrInfo_decTipArrowDown.png")
		:align(kAlignCenter)

	local tipsArrowSizeWidth, tipsArrowSizeHeight = self.tipsArrow_:getSize()
	local tipsArrowPosFix = 3.2

	self.arrowDirection_ = 0

	if type(arrAlign) == "number" then
		--todo
		local adjArrowPos = {
			[PaopHintFlwnd.LEFT_CENTER] = function()
				-- body

				self.tipsArrow_:addPropRotate(0, kAnimNormal, 0, 0, 0, 90, kCenterDrawing)
				self.tipsArrow_:pos(- borderSize.width / 2 - tipsArrowSizeHeight / 2 + tipsArrowPosFix, 0)
					:addTo(self.borderMain_)

				self.arrowDirection_ = ARROW_DIRECTION_HORIZONTAL
			end,

			[PaopHintFlwnd.BOTTOM_CENTER] = function()
				-- body
				-- self.tipsArrow_:rotation(90)
				self.tipsArrow_:pos(0, borderSize.height / 2 + tipsArrowSizeHeight / 2 - tipsArrowPosFix)
					:addTo(self.borderMain_)

				self.arrowDirection_ = ARROW_DIRECTION_VERTIACL
			end,

			[PaopHintFlwnd.RIGHT_CENTER] = function()
				-- body
				self.tipsArrow_:addPropRotate(0, kAnimNormal, 0, 0, 0, 270, kCenterDrawing)
				self.tipsArrow_:pos(borderSize.width / 2 + tipsArrowSizeHeight / 2 - tipsArrowPosFix, 0)
					:addTo(self.borderMain_)

				self.arrowDirection_ = ARROW_DIRECTION_HORIZONTAL
			end,

			[PaopHintFlwnd.TOP_CENTER] = function()
				-- body
				self.tipsArrow_:addPropRotate(0, kAnimNormal, 0, 0, 0, 180, kCenterDrawing)
				self.tipsArrow_:pos(0, - borderSize.height / 2 - tipsArrowSizeHeight / 2 + tipsArrowPosFix)
					:addTo(self.borderMain_)

				self.arrowDirection_ = ARROW_DIRECTION_VERTIACL
			end
		}

		if adjArrowPos[arrAlign] then
			--todo
			adjArrowPos[arrAlign]()
		end

	elseif type(arrAlign) == "table" then
		--todo
		local setArrowPos = {
			[PaopHintFlwnd.DIRECTION_TOP] = function(toward, magrin)
				-- body
				-- toward == PaopHintFlwnd.TOWARD_LEFT or toward == PaopHintFlwnd.TOWARD_RIGHT
				self.tipsArrow_:addPropRotate(0, kAnimNormal, 0, 0, 0, 180, kCenterDrawing)

				if toward == PaopHintFlwnd.TOWARD_LEFT then
					--todo
					self.tipsArrow_:pos(- (borderSize.width / 2 - magrin - tipsArrowSizeWidth / 2), borderSize.height / 2 +	
						tipsArrowSizeHeight / 2 - tipsArrowPosFix)
						:addTo(self.borderMain_)
				elseif toward == PaopHintFlwnd.TOWARD_RIGHT then
					--todo
					self.tipsArrow_:pos(borderSize.width / 2 - magrin - tipsArrowSizeWidth / 2, - borderSize.height / 2 - tipsArrowSizeHeight /
						2 + tipsArrowPosFix)
						:addTo(self.borderMain_)
				else
					dump("Wrong toward Value！")
				end

				self.arrowDirection_ = ARROW_DIRECTION_VERTIACL
			end,

			[PaopHintFlwnd.DIRECTION_BOTTOM] = function(toward, magrin)
				-- body
				-- toward == PaopHintFlwnd.TOWARD_LEFT or toward == PaopHintFlwnd.TOWARD_RIGHT

				if toward == PaopHintFlwnd.TOWARD_LEFT then
					--todo
					self.tipsArrow_:pos(- (borderSize.width / 2 - magrin - tipsArrowSizeWidth / 2), borderSize.height / 2 +
						tipsArrowSizeHeight / 2 - tipsArrowPosFix)
						:addTo(self.borderMain_)
				elseif toward == PaopHintFlwnd.TOWARD_RIGHT then
					--todo
					self.tipsArrow_:pos(borderSize.width / 2 - magrin - tipsArrowSizeWidth / 2, borderSize.height / 2 +
						tipsArrowSizeHeight / 2 - tipsArrowPosFix)
						:addTo(self.borderMain_)
				else
					dump("Wrong toward Value！")
				end

				self.arrowDirection_ = ARROW_DIRECTION_VERTIACL
			end,

			[PaopHintFlwnd.DIRECTION_LEFT] = function(toward, magrin)
				-- body
				-- toward == PaopHintFlwnd.TOWARD_UP or toward == PaopHintFlwnd.TOWARD_DOWN

				self.tipsArrow_:addPropRotate(0, kAnimNormal, 0, 0, 0, 90, kCenterDrawing)

				if toward == PaopHintFlwnd.TOWARD_UP then
					--todo
					self.tipsArrow_:pos(- borderSize.width / 2 - tipsArrowSizeHeight / 2 + tipsArrowPosFix,	- borderSize.height / 2 + magrin +
						tipsArrowSizeWidth / 2)
						:addTo(self.borderMain_)
				elseif toward == PaopHintFlwnd.TOWARD_DOWN then
					--todo
					self.tipsArrow_:pos(- borderSize.width / 2 - tipsArrowSizeHeight / 2 + tipsArrowPosFix,	borderSize.height / 2 -
						magrin - tipsArrowSizeWidth / 2)
						:addTo(self.borderMain_)
				else
					dump("Wrong toward Value！")
				end

				self.arrowDirection_ = ARROW_DIRECTION_HORIZONTAL
			end,

			[PaopHintFlwnd.DIRECTION_RIGHT] = function(toward, magrin)
				-- body
				-- toward == PaopHintFlwnd.TOWARD_UP or toward == PaopHintFlwnd.TOWARD_DOWN

				self.tipsArrow_:addPropRotate(0, kAnimNormal, 0, 0, 0, 270, kCenterDrawing)

				if toward == PaopHintFlwnd.TOWARD_UP then
					--todo
					self.tipsArrow_:pos(borderSize.width / 2 + tipsArrowSizeHeight / 2 - tipsArrowPosFix, - borderSize.height / 2 +
						magrin + tipsArrowSizeWidth / 2)
						:addTo(self.borderMain_)
				elseif toward == PaopHintFlwnd.TOWARD_DOWN then
					--todo
					self.tipsArrow_:pos(borderSize.width / 2 + tipsArrowSizeHeight / 2 - tipsArrowPosFix, borderSize.height / 2 - magrin -
						tipsArrowSizeWidth / 2)
						:addTo(self.borderMain_)
				else
					dump("Wrong toward Value！")
				end

				self.arrowDirection_ = ARROW_DIRECTION_HORIZONTAL
			end
		}

		if arrAlign.direction and setArrowPos[arrAlign.direction] then
			--todo
			setArrowPos[arrAlign.direction](arrAlign.toward or 0, arrAlign.magrin or 0)
		end

	else
		dump("Wrong Type align！")
	end

end

function PaopHintFlwnd:setPaopTipBg(bgRes, sentcil)
	-- body
end

function PaopHintFlwnd:setTipsFontNameAndSize(name, size)
	-- body
	self.tipsLabel_:setFontAndSize(name, size or 28)

	return self
end

function PaopHintFlwnd:setTipsColor(ccc3ColorTab)
	-- body
	self.tipsLabel_:setColor(ccc3ColorTab.r or 255, ccc3ColorTab.g or 255, ccc3ColorTab.b or 255)

	return self
end

function PaopHintFlwnd:setPaopTipOpacity(opacity)
	-- body
	-- Need To Complish --
	-- self.tipsLabel_:opacity(opacity)
	-- self.borderMain_:opacity(opacity)
	-- self.tipsArrow_:opacity(opacity)
	return self
end

function PaopHintFlwnd:getPaopTipSize()
	-- body
	local size = {}

	local tipsArrowPosFix = 3.2

	local bordMainContSizeWidth, bordMainContSizeHeight = self.borderMain_:getSize()
	local tipsArrowSizeWidth, tipsArrowSizeHeight = self.tipsArrow_:getSize()

	if self.arrowDirection_ == ARROW_DIRECTION_HORIZONTAL then
		--todo
		size.width = bordMainContSizeWidth + tipsArrowSizeHeight - tipsArrowPosFix
		size.height = bordMainContSizeHeight

	elseif self.arrowDirection_ == ARROW_DIRECTION_VERTIACL then
		--todo
		size.width = bordMainContSizeWidth
		size.height = bordMainContSizeHeight + tipsArrowSizeHeight - tipsArrowPosFix
	
	else
		size.width = 0
		size.height = 0
	end

	return size
end

function PaopHintFlwnd:getPaopTipLabelString()
	-- body
	return self.tipsLabel_:getText()
end

function PaopHintFlwnd:playFadeInAnim(time, delay, opacity)
	-- body
	-- self.tipsLabel_:opacity(0)
	-- self.borderMain_:opacity(0)
	-- self.tipsArrow_:opacity(0)

	-- transition.fadeIn(self.tipsLabel_, {time = time, delay = delay, opacity = opacity})
	-- transition.fadeIn(self.borderMain_, {time = time, delay = delay, opacity = opacity})
	-- transition.fadeIn(self.tipsArrow_, {time = time, delay = delay, opacity = opacity})
	return self
end

-- Need To Add More Api Func --

function PaopHintFlwnd:dtor()
	-- body
	self.super.dtor()
end

return PaopHintFlwnd