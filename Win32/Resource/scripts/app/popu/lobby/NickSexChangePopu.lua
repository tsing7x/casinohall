--
-- Author: TsingZhang@boyaa.com
-- Date: 2017-09-28 17:44:59
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: NickSexChangePopu.lua Created By Tsing7x.
--

local langConfStr = require("app.res.config")

local GameWindow = require("app.popu.gameWindow")
local NickSexChangePopu = class(GameWindow)

function NickSexChangePopu:ctor(viewConf, data)
	-- body
end

function NickSexChangePopu:initView(data)
	self.actionCallback_ = data.callback

	local bgPanel = self.m_root:findChildByName("img_bgPanel")
	bgPanel:setEventTouch(self, function()

	end)
	
	local closeBtn = bgPanel:findChildByName("btn_close")
		:setOnClick(self, handler(self, self.onCloseBtnCallBack_))

	local usrNameEdtMaxLength = 30

	local usrNameEtv = bgPanel:findChildByName("img_bgUsrNameEtv"):findChildByName("etv_usrNameAlert")
	usrNameEtv:setOnTextChange(self, handler(self, self.onUsrNameEtvChanged_))
	usrNameEtv:setHintText(langConfStr.str_createRole_inputinck)
	usrNameEtv:setMaxLength(usrNameEdtMaxLength)

	local usrSecSelRdBtnGroup = bgPanel:findChildByName("rdBtnGp_usrSexSel")
	usrSecSelRdBtnGroup:setOnChange(self, handler(self, self.onUsrSexTypeSelChanged_))

	local usrSexTypeIdx = MyUserData:getSex()
	usrSecSelRdBtnGroup:setSelected(usrSexTypeIdx)

	local commitBtn = bgPanel:findChildByName("btn_commit")
	local btnActionTxt = commitBtn:findChildByName("txt_action")

	commitBtn:setOnClick(self, handler(self, self.onCommitBtnCallBack_))
	btnActionTxt:setText(langConfStr.str_confirm)
end

function NickSexChangePopu:onUsrNameEtvChanged_(obj, inputStr)
	-- body
	self.usrNameStr_ = inputStr
end

function NickSexChangePopu:onUsrSexTypeSelChanged_(obj, selIdx, lastBtn)
	-- body
	self.usrSexSel_ = selIdx
end

function NickSexChangePopu:onCommitBtnCallBack_(evt)
	-- body
	if not self.usrNameStr_ or string.len(string.trim(self.usrNameStr_)) <= 0 then
		--todo
		if self.usrSexSel_ == MyUserData:getSex() then
			--todo
			AlarmTip.play(Hall_string.str_chat_input_emptay)
			return
		else
			self.usrNameStr_ = MyUserData:getNick()
		end
	end

	-- if (not self.usrNameStr_ or string.len(string.trim(self.usrNameStr_)) <= 0) and self.usrSexSel_ == MyUserData:getSex() then
	-- 	--todo
	-- 	AlarmTip.play(Hall_string.str_chat_input_emptay)
	-- 	return
	-- end

	if self.actionCallback_ then
		--todo
		self.actionCallback_(self.usrNameStr_, self.usrSexSel_)

		self:dismiss()
	end
end

function NickSexChangePopu:onCloseBtnCallBack_(evt)
	-- body
	self:dismiss()
end

function NickSexChangePopu:dtor()
	-- body
end

return NickSexChangePopu