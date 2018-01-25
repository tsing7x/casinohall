--
-- Author: TsingZhang@boyaa.com
-- Date: 2017-07-11 12:09:18
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: FeedBackPopu.lua Created && Reconstructed By Tsing7x.
--

local langConfStr = require("app.res.config")

local GameWindow = require("app.popu.gameWindow")
local FeedBackPopu = class(GameWindow)

function FeedBackPopu:ctor(viewConf, data)
	-- body
	self.feedbackId_ = data.feedbackId or FEEDBACK_APPID
	self.feedbackGame_ = data.feedbackGame or FEEDBACK_GAME

	EventDispatcher.getInstance():register(HttpModule.s_event, self, self.onHttpRequestsCallBack)
	EventDispatcher.getInstance():register(Event.Call, self, self.onNativeCallBack)
end

function FeedBackPopu:initView(data)
	-- body
	local defaultTabIdx = data.tabIdx or 1

	local bgPanel = self.m_root:findChildByName("img_bgPanel")
	local closeBtn = bgPanel:findChildByName("btn_close"):setOnClick(self, handler(self, self.onCloseBtnCallBack_))

	local tabView = bgPanel:findChildByName("vb_mainTab")
	local bgTabView = tabView:findChildByName("img_bgMainTab")

	local mainContPageView = bgPanel:findChildByName("vb_mainContPage")

	self.m_tabBtns = {}
	self.m_mainContPages = {}

	for i = 1, 2 do
		self.m_tabBtns[i] = bgTabView:findChildByName("btn_tabIdx" .. i)
		self.m_tabBtns[i].txtNor_ = self.m_tabBtns[i]:findChildByName("img_dscTabUnsel")
		self.m_tabBtns[i].txtSel_ = self.m_tabBtns[i]:findChildByName("img_dscTabSel")

		self.m_tabBtns[i]:setOnClick(self, function()
			-- body
			self:onMainTabSelChanged_(i)
		end)

		self.m_mainContPages[i] = mainContPageView:findChildByName("vb_pageIdx" .. i)
	end

	self.btnImgSel_ = bgTabView:findChildByName("img_tabSelHili")

	self:bindFeedBackPageEvts()
	self.m_tabBtns[defaultTabIdx].m_eventCallback.func(self.m_tabBtns[defaultTabIdx].m_eventCallback.obj)
end

function FeedBackPopu:bindFeedBackPageEvts()
	-- body`
	local commitPage = self.m_mainContPages[1]

	local mainContBg = commitPage:findChildByName("img_bgMainFedBakCont")
	local commitBtn = commitPage:findChildByName("btn_commit")

	commitBtn:setOnClick(self, handler(self, self.onBtnCommitCallBack_))

	local bgViceTitleFeedCont = mainContBg:findChildByName("img_decVicTitleCont")
	local viceTitleFeedContText = bgViceTitleFeedCont:findChildByName("txt_vicTitleFeedCont")

	local bgFeedContInput = mainContBg:findChildByName("img_bgFeedContInput")
	local feedContInputEdtView = bgFeedContInput:findChildByName("etv_feedCont")

	local bgViceTitleContact = mainContBg:findChildByName("img_decBgTitleContact")
	local viceTitleContactText = bgViceTitleContact:findChildByName("txt_vicTitleContact")

	local bgUsrTelNumInput = mainContBg:findChildByName("img_bgTelInput")
	local usrTelNumInputEdtView = bgUsrTelNumInput:findChildByName("etv_usrTel")

	local contactTelNumText = mainContBg:findChildByName("txt_contactTelNum")
	local contactEmailText = mainContBg:findChildByName("txt_contactEmail")

	self.m_uploadImgBtn = mainContBg:findChildByName("btn_uploadFeedImg")

	local uploadImgBtnSizeWidth, uploadImgBtnSizeHeight = self.m_uploadImgBtn:getSize()
	self.uploadImgBtnSize_ = {
		width = uploadImgBtnSizeWidth,
		height = uploadImgBtnSizeHeight
	}

	viceTitleFeedContText:setText(langConfStr.str_FedBak_DscProCont)
	viceTitleContactText:setText(langConfStr.str_FedBak_UsrTelNum)
	contactTelNumText:setText(langConfStr.str_FedBak_FeedBackTel)
	contactEmailText:setText(langConfStr.str_FedBak_FeedBackEmail)

	local etvHintTextColor = {
		r = 152,
		g = 111,
		b = 79
	}

	feedContInputEdtView:setOnTextChange(self, handler(self, self.onFeedContChanged_))
	feedContInputEdtView:setHintText(langConfStr.str_FedBak_ProContHint, etvHintTextColor.r, etvHintTextColor.g, etvHintTextColor.b)

	usrTelNumInputEdtView:setOnTextChange(self, handler(self, self.onUsrTelEdtChanged_))
	usrTelNumInputEdtView:setHintText(langConfStr.str_FedBak_UsrTelNumHint, etvHintTextColor.r, etvHintTextColor.g, etvHintTextColor.b)
	usrTelNumInputEdtView:setInputMode(kEditBoxInputModePhoneNumber)

	self.m_uploadImgBtn:setOnClick(self, handler(self, self.onBtnUploadImgCallBack_))

	-- self.uploadedFeedBackImgPath_ = ""

	local contactCusPage = self.m_mainContPages[2]

	local contactCusSdkBtn = contactCusPage:findChildByName("btn_contactCus")
	contactCusSdkBtn:setOnClick(self, handler(self, self.onBtnContactCusCallBack_))
end

function FeedBackPopu:onMainTabSelChanged_(idx)
	-- body
	if not self.mainTabIdx_ then
		--todo
		self.m_tabBtns[idx].txtNor_:hide()
		self.m_tabBtns[idx].txtSel_:show()

		self.mainTabIdx_ = idx
	end

	local isTabSelChanged = self.mainTabIdx_ ~= idx

	if isTabSelChanged then
		--todo
		self.m_tabBtns[self.mainTabIdx_].txtNor_:show()
		self.m_tabBtns[self.mainTabIdx_].txtSel_:hide()

		self.m_tabBtns[idx].txtNor_:hide()
		self.m_tabBtns[idx].txtSel_:show()

		self.mainTabIdx_ = idx
	end

	local tabBtnWidth = self.m_tabBtns[1]:getSize()

	self.btnImgSel_:setPos(tabBtnWidth * (self.mainTabIdx_ * 2 - 3) / 2, 0)

	for i = 1, #self.m_mainContPages do
		self.m_mainContPages[i]:hide()
	end

	self.m_mainContPages[self.mainTabIdx_]:show()
end

function FeedBackPopu:onNativeCallBack(key, result)
	-- body
	-- dump(result, "FeedBackPopu:onNativeCallBack.key " .. tostring(key) .. " :===========")
	if key == KChooseFeedBackImg then
		--todo
		if result then
			--todo
			-- JLog.d(result, "FeedBackPopu:onNativeCallBack.key :kPickPhoto")
			if NativeEvent.s_platform == kPlatformIOS then
				local isSucc = result.isSucc:get_value()
				local fromPhoto = result.fromPhoto:get_value()
				local imgName = result.imgName:get_value()
				local folder = result.folder:get_value()
				local basePath = result.basePath:get_value()
				local tag = result.tag:get_value()
				if isSucc == "true" and tag == "feedback" then
					basePath = basePath or ""
					folder = folder or ""
					imgName = imgName or ""
					local fname = folder .. imgName

					self.m_uploadImgBtn:setFile(fname)
					self.m_uploadImgBtn:setSize(self.uploadImgBtnSize_.width, self.uploadImgBtnSize_.height)
					-- self.m_uploadImgBtn:setVisible(true)
					--upload image
					self.uploadedFeedBackImgPath_ = imgName
					self.uploadFeedbackBasePath_ = basePath
					self.uploadFeedbackfolder_ = folder
				end

			else
				-- printInfo("result.name:get_value() :" .. result.name:get_value())
				self.m_uploadImgBtn:setFile(result.name:get_value())
				self.m_uploadImgBtn:setSize(self.uploadImgBtnSize_.width, self.uploadImgBtnSize_.height)
				-- self.m_uploadImgBtn:setVisible(true)
				--upload image 
				self.uploadedFeedBackImgPath_ = result.name:get_value()
			end
		else
			AlarmTip.play(langConfStr.str_FedBak_SavePicFail)
		end
	elseif key == kUploadFeedbackImage then
		--todo
		if result then
			AlarmTip.play(langConfStr.str_FedBak_UploadPicSucc)
			self.uploadedFeedBackImgPath_ = ""
			local defaultUploadIcPath = "language/thai/popu/feedback/fedbak_btnUploadImg.png"

			self.m_uploadImgBtn:setFile(defaultUploadIcPath)
			-- self.m_uploadImgBtn:setVisible(false)
		else
			AlarmTip.play(langConfStr.str_FedBak_UploadPicFail)
		end
	end
end

function FeedBackPopu:onHttpRequestsCallBack(command, isSucc, data)
	-- body
	-- printInfo("HttpModule.s_cmds.SendFeedback :" .. HttpModule.s_cmds.SendFeedback)

	-- dump(data, "FeedBackPopu:onHttpRequestsCallBack(command :" .. command .. "isSucc :" .. tostring(isSucc) ..
	-- 	").data :===================")
	if command == HttpModule.s_cmds.SendFeedback then
		--todo
		if isSucc and data and data.ret then
			--todo
			if self then
				--todo
				AlarmTip.play(langConfStr.str_FedBak_SendFedBakSucc)

				self.fid_ = data.ret.fid or 0

				if self.fid_ == 0 then
					--todo
					self.lastFeedContStr_ = ""
					AlarmTip.play(langConfStr.str_FedBak_GetFedBakDataFail)
					return
				end

				if self.uploadedFeedBackImgPath_ and string.len(self.uploadedFeedBackImgPath_) > 0 then
					--todo
					self:sendFeedbackImg(self.uploadedFeedBackImgPath_, self.fid_, self.uploadFeedbackBasePath_, self.uploadFeedbackfolder_)
				end

				local commitPage = self.m_mainContPages[1]
				local mainContBg = commitPage:findChildByName("img_bgMainFedBakCont")
				
				local bgFeedContInput = mainContBg:findChildByName("img_bgFeedContInput")
				local feedContInputEdtView = bgFeedContInput:findChildByName("etv_feedCont")

				local bgUsrTelNumInput = mainContBg:findChildByName("img_bgTelInput")
				local usrTelNumInputEdtView = bgUsrTelNumInput:findChildByName("etv_usrTel")

				feedContInputEdtView:setText("")
				usrTelNumInputEdtView:setText("")
			end
		else
			AlarmTip.play(langConfStr.STR_SERVER_ERROR)
		end
	end
	
end

function FeedBackPopu:onFeedContChanged_(obj, inputStr)
	-- body
	self.feedContStr_ = inputStr
end

function FeedBackPopu:onUsrTelEdtChanged_(obj, inputStr)
	-- body
	self.usrTelStr_ = inputStr
end

function FeedBackPopu:onBtnUploadImgCallBack_(evt)
	-- body
	self.uploadedFeedBackImgPath_ = ""
	NativeEvent.getInstance():chooseFeedBackImg()
	-- NativeEvent.getInstance():pickPhoto("feedback", "feedbackImage/", "/user/images/", nil, "feedback")
end

function FeedBackPopu:onBtnCommitCallBack_(evt)
	-- body
	if self.lastFeedContStr_ == self.feedContStr_ or string.len(string.trim(self.feedContStr_)) <= 0 then
		AlarmTip.play(langConfStr.str_FedBak_AlreadyFeeded)
		return
	end

	if not self.feedContStr_ or string.len(string.trim(self.feedContStr_)) <= 0 then
		--todo
		AlarmTip.play(langConfStr.str_FedBak_InvalidFeedHint)
		return
	end

	self.lastFeedContStr_ = self.feedContStr_

	local feedStr = GameString.convert2UTF8(self.feedContStr_)

	local param_post = {
		appid 	 = self.feedbackId_,
		ftype 	 = FEEDBACK_FTYPE,
		game 	 = self.feedbackGame_,
		-- proType = self.proType_,
		title 	 = langConfStr.str_FedBak_CommitTitle,
		fwords 	 = feedStr,
		fcontact = self.usrTelStr_,
		mid 	 = MyUserData:getId(),
		username = MyUserData:getNick()
	}

    -- app:postFrontStaticstics("clickFeedBackGameType"..tostring(self.mGameId))
	-- HttpModule.getInstance():execute(HttpModule.s_cmds.SendFeedback, param_post, false, true)

	self:execHttpCmd(HttpModule.s_cmds.SendFeedback, param_post, nil, true, self.m_mainContPages[1])
end

function FeedBackPopu:onBtnContactCusCallBack_(evt)
	-- body
end

function FeedBackPopu:sendFeedbackImg(fileName, fid, basePath, folder)
	-- body
	local param_post = {
		param = {
			appid 	 = self.feedbackId_,
			ftype 	 = FEEDBACK_IMG_FTYPE,
			game 	 = self.feedbackGame_,
			fid 	 = fid,
			pfile 	 = fileName
		},
		method 	 = "Feedback.mSendFeedBackPicture"
	}
	
	NativeEvent.getInstance():uploadFeedbackImage('http://feedback.kx88.net/api/api.php', fileName, param_post, basePath, folder)
end

function FeedBackPopu:onCloseBtnCallBack_(evt)
	-- body
	self:dismiss()
end

function FeedBackPopu:dtor()
	-- body
	self.super.dtor(self)
	EventDispatcher.getInstance():unregister(Event.Call, self, self.onNativeCallBack)
	EventDispatcher.getInstance():unregister(HttpModule.s_event, self, self.onHttpRequestsCallBack)
end

return FeedBackPopu