--
-- Author: TsingZhang@boyaa.com
-- Date: 2017-09-26 18:15:27
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: HeadChangePopu.lua Created By Tsing7x.
--

local GameWindow = require("app.popu.gameWindow")
local HeadChangePopu = class(GameWindow)

function HeadChangePopu:ctor(viewConf, data)
	-- body
end

function HeadChangePopu:initView(data)
	local bgPanel = self.m_root:findChildByName("img_bgPanel")
	bgPanel:setEventTouch(self, function()
	end)

	local closeBtn = bgPanel:findChildByName("btn_close")
		:setOnClick(self, handler(self, self.onCloseBtnCallBack_))

	local btnChooseImgByTakePhoto = bgPanel:findChildByName("btn_changeHeadCamera")
		:setOnClick(self, handler(self, self.onBtnPhotoTakeCallBack_))

	local btnChooseImgFromGallery = bgPanel:findChildByName("btn_changeHeadGallery")
		:setOnClick(self, handler(self, self.onBtnChooseGalleryCallBack_))
end

function HeadChangePopu:onBtnPhotoTakeCallBack_(evt)
	-- body
	NativeEvent.getInstance():takePhoto(MyUserData:getId())
	self:dismiss()
end

function HeadChangePopu:onBtnChooseGalleryCallBack_(evt)
	-- body
	NativeEvent.getInstance():pickPhoto(MyUserData:getId())
	self:dismiss()
end

function HeadChangePopu:onCloseBtnCallBack_(evt)
	-- body
	self:dismiss()
end

function HeadChangePopu:dtor()
	-- body
	self.super.dtor(self)
end

return HeadChangePopu