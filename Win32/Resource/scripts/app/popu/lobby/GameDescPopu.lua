--
-- Author: TsingZhang@boyaa.com
-- Date: 2017-08-15 11:22:18
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: GameDescPopu.lua Created By Tsing7x.
--

local langConfStr = require("app.res.config")

local GameWindow = require("app.popu.gameWindow")
local GameDescPopu = class(GameWindow)

function GameDescPopu:ctor(viewConf, data)
	-- body
end

function GameDescPopu:initView(data)
	-- body
	local bgPanel = self.m_root:findChildByName("img_bgPanel")
	bgPanel:setEventTouch(self, function()
		-- body
	end)

	bgPanel:findChildByName("btn_close"):setOnClick(self, handler(self, self.onBtnCloseCallBack_))

	local vicTitleTxt = bgPanel:findChildByName("txt_vicTitle")
	vicTitleTxt:setText(langConfStr.str_set_GameDscTitle)

	local bgContDent = bgPanel:findChildByName("img_bgMainDent")

	local termTitleTxt = bgContDent:findChildByName("txt_termsTitle")
	local termsvicDetailTxt = bgContDent:findChildByName("tv_termDetail")

	local btnOpenLawLink = bgContDent:findChildByName("btn_goLawLink")
	-- local termDecDots = {}
	local termContDscTvs = {}

	termTitleTxt:setText(langConfStr.str_set_GameDscVicTitle)
	termsvicDetailTxt:setText(langConfStr.str_set_GameDscVicTiCont)

	local termContTxtLine1Height = 30
	for i = 1, #langConfStr.str_set_GameDscContent do
		-- termDecDots[i] = bgContDent:findChildByName("dec_dot" .. i)
		termContDscTvs[i] = bgContDent:findChildByName("tv_termDet" .. i)

		termContDscTvs[i]:setText(langConfStr.str_set_GameDscContent[i])

		local termContDscTvShownLines = math.ceil(termContDscTvs[i]:getViewLength() / termContTxtLine1Height)
		if termContDscTvShownLines > 1 then
			--todo
			termContDscTvSizeWidth, termContDscTvSizeHeight = termContDscTvs[i]:getSize()

			termContDscTvs[i]:setSize(termContDscTvSizeWidth, termContDscTvShownLines * termContTxtLine1Height)

			local termContDscTvPosX, termContDscTvPosY = termContDscTvs[i]:getPos()

			termContDscTvs[i]:pos(termContDscTvPosX, termContDscTvPosY + (termContDscTvShownLines * termContTxtLine1Height - termContDscTvSizeHeight) / 2)
		end
	end

	local btnActionTxt = btnOpenLawLink:findChildByName("txt_dscLawLinkUrl")
	local btnActionUnderLineTxt = btnOpenLawLink:findChildByName("txt_underLine")
	btnOpenLawLink:setOnClick(self, handler(self, self.onBtnOpenLawLinkCallBack_))

	btnActionTxt:setText(langConfStr.str_set_GameDscLawCons)

	local signalUnderLine = new(Text, "_")
	local signalUnderLineWidth = signalUnderLine:getSize()

	local btnActionTxtWidth = btnActionTxt:getSize()
	local underLineWidth = math.ceil(btnActionTxtWidth / signalUnderLineWidth)

	local underLineStr = "_"
	for i = 1, underLineWidth - 1 do
		underLineStr = underLineStr .. "_"
	end

	btnActionUnderLineTxt:setText(underLineStr)
end

function GameDescPopu:onBtnOpenLawLinkCallBack_(evt)
	-- body
	-- NativeEvent.getInstance():showAd(false)
	NativeEvent.getInstance():openLink(langConfStr.str_set_GameDscLawLinkUrl)
	self:dismiss()
end

function GameDescPopu:onBtnCloseCallBack_(evt)
	-- body
	self:dismiss()
end

function GameDescPopu:dtor()
	-- body
end

return GameDescPopu