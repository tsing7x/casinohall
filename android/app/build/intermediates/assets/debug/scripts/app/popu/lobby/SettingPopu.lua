--
-- Author: TsingZhang@boyaa.com
-- Date: 2017-07-05 12:06:11
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: SettingPopu.lua Created && Reconstured By Tsing7x.
--

local langConfStr = require("app.res.config")

local GameWindow = require("app.popu.gameWindow")
local SettingPopu = class(GameWindow)

function SettingPopu:ctor(viewConf, data)
	-- body
end

function SettingPopu:initView(data)
	-- body
	local bgPanel = self.m_root:findChildByName("img_bgPanel")

	bgPanel:setEventTouch(self, function()
	end)

	bgPanel:findChildByName("btn_close"):setOnClick(self, handler(self, self.onBtnCloseCallBack_))

	local viewDent1 = bgPanel:findChildByName("img_bgDent1")

	local nickTv = viewDent1:findChildByName("tv_usrName")
	ToolKit.formatTextLength(MyUserData:getNick(), nickTv, nickTv:getSize())

	-- UIEx.bind(self, MyUserData, "nick", function(value)
	-- 	local nickTxt = viewDent1:findChildByName("txt_usrName")
 --        ToolKit.formatTextLength(value, nickTxt, nickTxt:getSize())
	-- end)

	-- MyUserData:setNick("tsing")

	local FBLoginHintTxt = viewDent1:findChildByName("txt_dscFBLoginHint")
	local btnLogout = viewDent1:findChildByName("btn_logout")
		-- :findChildByName("txt_logout")
	btnLogout:setOnClick(self, handler(self, self.onBtnLogoutCallBack_))
	
	FBLoginHintTxt:setText(langConfStr.str_set_FBLoginHint)
	-- btnLogoutTxt:setText(langConfStr.str_set_Logout)

	local viewDent2 = bgPanel:findChildByName("img_bgDent2")
	local ctrlItemTxts = {}

	for i = 1, #langConfStr.str_set_CtrlItemStrs do
		ctrlItemTxts[i] = viewDent2:findChildByName("txt_dscCtrlItem" .. i)
		ctrlItemTxts[i]:setText(langConfStr.str_set_CtrlItemStrs[i])
	end

	-- self.btnVolMute_ = viewDent2:findChildByName("btn_volMute")
	-- self.btnVolMax_ = viewDent2:findChildByName("btn_volMax")
	self.slidVolSet_ = viewDent2:findChildByName("vsdr_sysVolSet")

	self.chkBtnBGM_ = viewDent2:findChildByName("chkBtn_bgm")
	self.chkBtnGM_ = viewDent2:findChildByName("chkBtn_gm")

	-- self.btnVolMute_:setOnClick(self, handler(self, self.onBtnVolMuteCallBack_))
	-- self.btnVolMax_:setOnClick(self, handler(self, self.onBtnVolMaxCallBack_))
	self.slidVolSet_:setOnChange(self, handler(self, self.onSysVolValChanged_))
	self.chkBtnBGM_:setOnChange(self, handler(self, self.onSysBGMStateChanged_))
	self.chkBtnGM_:setOnChange(self, handler(self, self.onSysGMStateChanged_))

	viewDent2:findChildByName("chkBtn_cdVibr"):setOnChange(self, handler(self, self.onCDVibrStateChanged_))
	viewDent2:findChildByName("chkBtn_autoSit"):setOnChange(self, handler(self, self.onAutoSitStateChanged_))
	viewDent2:findChildByName("chkBtn_allowTrace"):setOnChange(self, handler(self, self.onStTraceStateChanged_))

	local sysMusicVolVal = GameSetting:getMusicVolume()
	local sysSoundVolVal = GameSetting:getSoundVolume()

	if sysMusicVolVal > 0 then
		--todo
		self.sysVolVal_ = sysMusicVolVal
	else
		if sysSoundVolVal > 0 then
			--todo
			self.sysVolVal_ = sysSoundVolVal
		else
			self.sysVolVal_ = 0
		end
	end

	self.sysBGMState_ = nil
	self.sysGMState_ = nil

	self.lastSysVolRecVal_ = 0
	if self.sysVolVal_ <= 0 then
		--todo
		self.sysBGMState_ = false
		self.sysGMState_ = false
	else
		self.lastSysVolRecVal_ = self.sysVolVal_
		self.sysBGMState_ = sysMusicVolVal > 0
		self.sysGMState_ = sysSoundVolVal > 0
	end
	
	-- Read From Local Cached Files --
	self.CDVibrState_ = GameSetting:getCDVibrate()
	self.autoSitState_ = GameSetting:getAutoSit()
	self.stTraceState_ = GameSetting:getStTrace()

	self.slidVolSet_:setProgress(self.sysVolVal_)
	self.chkBtnBGM_:setChecked(self.sysBGMState_)
	self.chkBtnGM_:setChecked(self.sysGMState_)

	viewDent2:findChildByName("chkBtn_cdVibr"):setChecked(self.CDVibrState_)
	viewDent2:findChildByName("chkBtn_autoSit"):setChecked(self.autoSitState_)
	viewDent2:findChildByName("chkBtn_allowTrace"):setChecked(self.stTraceState_)

	local viewDent3 = bgPanel:findChildByName("img_bgDent3")
	local btnGoFansWeb = viewDent3:findChildByName("btn_goFansPage")
	local btnVerCheck = viewDent3:findChildByName("btn_verCheck")
	local btnGameDsc = viewDent3:findChildByName("btn_gameAbout")

	local txtGoFansWebIns = viewDent3:findChildByName("txt_dscGoFansPage")
	local txtVerCheckIns = viewDent3:findChildByName("txt_dscVerCheck")
	local txtGameDscIns = viewDent3:findChildByName("txt_dscGameAbout")

	txtGoFansWebIns:setText(langConfStr.str_set_LinkInFansPage)
	txtVerCheckIns:setText(string.format(langConfStr.str_set_VerCheck, PhpManager:getVersionName()))
	txtGameDscIns:setText(langConfStr.str_set_GameAbout)

	btnGoFansWeb:setOnClick(self, handler(self, self.onBtnGoFansCallBack_))
	btnVerCheck:setOnClick(self, handler(self, self.onBtnVerCheckCallBack_))
	btnGameDsc:setOnClick(self, handler(self, self.onBtnGameDscCallBack_))
end

function SettingPopu:onBtnLogoutCallBack_(evt)
	-- JLog.d("SettingPopu:onBtnLogoutCallBack_")
	GameSetting:setSesskey("")
    GameSetting:save()
	kMusicPlayer:stop(true)

    MyRoomConfig:clear()
    MyUserData:clear()
    StateChange.changeState(States.Login)
	self:dismiss()

	NativeEvent.getInstance():logout({})
	EventDispatcher.getInstance():dispatch(Event.Message, "logout", 0)
end

function SettingPopu:onBtnVolMuteCallBack_(evt)
	-- body
	-- if self.sysVolVal_ == 0 then
	-- 	--todo
	-- 	return
	-- end

	-- self.sysVolVal_ = 0
	-- self.slidVolSet_:setProgress(self.sysVolVal_)

	-- self:onSysVolValChanged_(self.slidVolSet_, self.sysVolVal_)
end

function SettingPopu:onBtnVolMaxCallBack_(evt)
	-- body
	-- if self.sysVolVal_ == 1 then
	-- 	--todo
	-- 	return
	-- end

	-- self.sysVolVal_ = 1
	-- self.slidVolSet_:setProgress(self.sysVolVal_)

	-- self:onSysVolValChanged_(self.slidVolSet_, self.sysVolVal_)
end

function SettingPopu:onSysVolValChanged_(obj, prgVal)
	-- body
	-- dump(obj, "SettingPopu:onSysVolValChanged_.param obj :===============")
	-- dump(prgVal, "SettingPopu:onSysVolValChanged_.param prgVal :===============")

	self.sysVolVal_ = prgVal

	if self.sysVolVal_ <= 0 then
		--todo
		self.sysBGMState_ = false
		self.sysGMState_ = false
		self.chkBtnBGM_:setChecked(self.sysBGMState_)
		self.chkBtnGM_:setChecked(self.sysGMState_)
	else

		self.lastSysVolRecVal_ = self.sysVolVal_
		if not self.sysBGMState_ and not self.sysGMState_ then
			--todo
			self.sysBGMState_ = true
			self.sysGMState_ = true
			self.chkBtnBGM_:setChecked(self.sysBGMState_)
			self.chkBtnGM_:setChecked(self.sysGMState_)
		end
	end

	if self.sysBGMState_ then
		--todo
		GameSetting:setMusicVolume(self.sysVolVal_)
	else
		GameSetting:setMusicVolume(0)
	end

	if self.sysGMState_ then
		--todo
		GameSetting:setSoundVolume(self.sysVolVal_)
	else
		GameSetting:setSoundVolume(0)
	end

	kMusicPlayer:setVolume(GameSetting:getMusicVolume())
	kEffectPlayer:setVolume(GameSetting:getSoundVolume())
end

function SettingPopu:onSysBGMStateChanged_(obj, val)
	-- body
	-- dump(val, "SettingPopu:onSysBGMStateChanged_.val :===============")
	local defaultSysVolVal = .5

	self.sysBGMState_ = val
	if self.sysBGMState_ then
		--todo
		if self.lastSysVolRecVal_ <= 0 then
			--todo
			self.sysVolVal_ = defaultSysVolVal
		else
			self.sysVolVal_ = self.lastSysVolRecVal_
		end

		self.slidVolSet_:setProgress(self.sysVolVal_)

		self:onSysVolValChanged_(self.slidVolSet_, self.sysVolVal_)
	else
		if not self.sysGMState_ then
			--todo
			self.slidVolSet_:setProgress(0)

			self:onSysVolValChanged_(self.slidVolSet_, 0)
		else
			GameSetting:setMusicVolume(0)
			kMusicPlayer:setVolume(GameSetting:getMusicVolume())
		end
	end
end

function SettingPopu:onSysGMStateChanged_(obj, val)
	-- body
	local defaultSysVolVal = .5

	self.sysGMState_ = val
	if self.sysGMState_ then
		--todo
		if self.lastSysVolRecVal_ <= 0 then
			--todo
			self.sysVolVal_ = defaultSysVolVal
		else
			self.sysVolVal_ = self.lastSysVolRecVal_
		end

		self.slidVolSet_:setProgress(self.sysVolVal_)

		self:onSysVolValChanged_(self.slidVolSet_, self.sysVolVal_)
	else
		if not self.sysBGMState_ then
			--todo
			self.slidVolSet_:setProgress(0)

			self:onSysVolValChanged_(self.slidVolSet_, 0)
		else
			GameSetting:setSoundVolume(0)
			kEffectPlayer:setVolume(GameSetting:getSoundVolume())
		end
	end
end

function SettingPopu:onCDVibrStateChanged_(obj, val)
	-- body
	self.CDVibrState_ = val

	GameSetting:setCDVibrate(self.CDVibrState_)
end

function SettingPopu:onAutoSitStateChanged_(obj, val)
	-- body
	self.autoSitState_ = val

	GameSetting:setAutoSit(self.autoSitState_)
end

function SettingPopu:onStTraceStateChanged_(obj, val)
	-- body
	self.stTraceState_ = val

	GameSetting:setStTrace(self.stTraceState_)
end

function SettingPopu:onBtnGoFansCallBack_(evt)
	-- body
	NativeEvent.getInstance():openLink(langConfStr.str_set_goFansUrl)

	self:dismiss()
end

function SettingPopu:onBtnVerCheckCallBack_(evt)
	-- body
	AlarmTip.play(langConfStr.str_set_AreadyNewVersion)

	-- WindowManager:showWindow(WindowTag.UpdatePopu, {}, WindowStyle.POPUP)
end

function SettingPopu:onBtnGameDscCallBack_(evt)
	-- body
	WindowManager:showWindow(WindowTag.GameDescPopu, {}, WindowStyle.POPUP)
end

function SettingPopu:onBtnCloseCallBack_(evt)
	-- body
	-- dump(evt, "SettingPopu:onBtnCloseCallBack_ :=============", 3)
	self:dismiss()
end

function SettingPopu:dtor()
	-- body
	-- printInfo("self.sysVolVal_ :" .. self.sysVolVal_)

	GameSetting:save()
	self.super.dtor(self)
end

return SettingPopu