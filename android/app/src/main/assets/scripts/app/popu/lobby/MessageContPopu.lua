--
-- Author: TsingZhang@boyaa.com
-- Date: 2017-08-16 16:19:40
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: MessageContPopu.lua Created By Tsing7x.
--

local langConfStr = require("app.res.config")

local windowManager = require("app.popu.gameWindow")
local MessageContPopu = class(windowManager)

MessageContPopu.MSGTYPE_ANNOUNCE = 0  -- Type Sys Announce
MessageContPopu.MSGTYPE_SYS = 1  -- Type Message Sys
MessageContPopu.MSGTYPE_GAME = 2  -- Type Message Game

function MessageContPopu:ctor(viewConf, data)
	-- body
end

function MessageContPopu:initView(data)
	-- body
	local msgType = data.msgType or MessageContPopu.MSGTYPE_SYS
	self.dtorEvtCallBack_ = data.dtorActionCallBack
	self.confrimEvtCallBack_ = data.confrimActionCallBack

	local bgMainPanel = self.m_root:findChildByName("bg_mainPanel")

	bgMainPanel:setEventTouch(self, function()
		-- body
	end)

	local btnClose = bgMainPanel:findChildByName("btn_close")
	local titleDscImg = bgMainPanel:findChildByName("bg_titleBar"):findChildByName("img_dscTitle")

	btnClose:setOnClick(self, handler(self, self.onCloseBtnCallBack_))

	local titleDscImgPath = nil
	local renderPopuContTitleDscImgByMsgType = {
		[MessageContPopu.MSGTYPE_ANNOUNCE] = function()
			-- body
			titleDscImgPath = "language/thai/popu/message/msg_decTitleAnnounce.png"

			printInfo("MsgType :MSGTYPE_ANNOUNCE")
		end,

		[MessageContPopu.MSGTYPE_SYS] = function()
			-- body
			printInfo("MsgType :MSGTYPE_SYS,Default Title Dsc.")
		end,

		[MessageContPopu.MSGTYPE_GAME] = function()
			-- body
			titleDscImgPath = "language/thai/popu/message/msg_dscTitleGame.png"

			printInfo("MsgType :MSGTYPE_GAME")
		end,

		[3] = function()
			-- body
			titleDscImgPath = "language/thai/popu/message/msg_dscTitleMsgDetail.png"

			printInfo("MsgType :3,Customize Title,Res Add :" .. titleDscImgPath)

		end
	}

	if renderPopuContTitleDscImgByMsgType[msgType] then
		--todo
		renderPopuContTitleDscImgByMsgType[msgType]()
	end

	if titleDscImgPath then
		--todo
		local titleImg = new(Image, titleDscImgPath)
		local imageWidth, imgHeight = titleImg:getSize()

		titleDscImg:setFile(titleDscImgPath)
		titleDscImg:setSize(imageWidth, imgHeight)
	end

	local bgMainContDent = bgMainPanel:findChildByName("bg_mainContDent")
	local msgTitleTv = bgMainContDent:findChildByName("tv_msgTitle")
	local msgContTv = bgMainContDent:findChildByName("tv_msgCont")

	-- local sysAnnounceTitleFontColor = {
	-- 	r = 255,
	-- 	g = 255,
	-- 	b = 255
	-- }

	-- local sysAnnounceContFontColor = {
	-- 	r = 255,
	-- 	g = 255,
	-- 	b = 255
	-- }

	-- if msgType == self.MSGTYPE_ANNOUNCE then
	-- 	--todo
	-- 	msgTitleTv:setText(data.title, nil, nil, sysAnnounceTitleFontColor.r, sysAnnounceTitleFontColor.g, sysAnnounceTitleFontColor.b)
	-- 	msgContTv:setText(data.content, nil, nil, sysAnnounceContFontColor.r, sysAnnounceContFontColor.g, sysAnnounceContFontColor.b)
	-- else
	-- 	msgTitleTv:setText(data.title)
	-- 	msgContTv:setText(data.content)
	-- end

	msgTitleTv:setText(data.title)
	msgContTv:setText(data.content)

	msgTitleTv:setScrollBarWidth(0)
	msgContTv:setScrollBarWidth(0)

	local btnConfirm = bgMainPanel:findChildByName("btn_confirm")
	local btnTxt = btnConfirm:findChildByName("txt_confrim")

	btnConfirm:setOnClick(self, handler(self, self.onConfirmBtnCallBack_))
	btnTxt:setText(langConfStr.str_confirm)
end

function MessageContPopu:onConfirmBtnCallBack_(evt)
	-- body
	if self.confrimEvtCallBack_ then
		--todo
		self.confrimEvtCallBack_()
	end

	self:dismiss()
end

function MessageContPopu:onCloseBtnCallBack_(evt)
	-- body
	self:dismiss()
end

function MessageContPopu:dtor()
	-- body
	if self.dtorEvtCallBack_ then
		--todo
		self.dtorEvtCallBack_()
	end

	self.super.dtor(self)
end

return MessageContPopu