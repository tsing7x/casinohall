--
-- Author: TsingZhang@boyaa.com
-- Date: 2017-10-09 15:50:21
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: UpgradePopu.lua Reconstructed By Tsing7x.
--

local langConfStr = require("app.res.config")

local GameWindow = require("app.popu.gameWindow")
local UpgradePopu = class(GameWindow)

function UpgradePopu:ctor(viewConf, data)
	-- body
end

function UpgradePopu:initView(data)
	if not data then return end
	self.data_ = data

	local bgPanel = self.m_root:findChildByName("img_bgPanel")
	bgPanel:setEventTouch(self, function()
	end)

	local closeBtn = bgPanel:findChildByName("btn_close"):setOnClick(self, handler(self, self.onCloseBtnCallBack_))

	local usrLvNumResPath = "popu/upgrade/levelNum/"

	local usrUpgradedLv = data.level or 0

	local bgDecHalfTop = bgPanel:findChildByName("img_decTop")
	local usrLvShowView = bgDecHalfTop:findChildByName("vb_usrLv")

	local usrHeadImgBor = bgDecHalfTop:findChildByName("img_usrHead")
	local usrNameDentBg = usrHeadImgBor:findChildByName("img_bgDecName")
	local usrNameTxt = usrNameDentBg:findChildByName("txt_usrName")

	local usrUpgradedLvStr = tostring(usrUpgradedLv)
	local usrUpgradedStrLen = string.len(usrUpgradedLvStr)

	local usrUpgrdLvImgMagrin = - 2

	local usrLvBitValStr = nil
	local usrLvShownImg = {}

	local usrLvShownWidth = 0
	for i = 1, usrUpgradedStrLen do
		usrLvBitValStr = string.sub(usrUpgradedLvStr, i, i)

		usrLvShownImg[i] = new(Image, usrLvNumResPath .. "num_" .. usrLvBitValStr .. ".png")
			:align(kAlignCenter)

		local usrLvShownImgWidth, usrLvShownImgHeight = usrLvShownImg[i]:getSize()
		usrLvShownWidth = usrLvShownWidth + usrLvShownImgWidth
	end

	if usrUpgradedStrLen > 1 then
		--todo
		usrLvShownWidth = usrLvShownWidth + usrUpgrdLvImgMagrin * (usrUpgradedStrLen - 1)
	end

	local usrLvShownImgModelWidth = usrLvShownImg[1]:getSize()

	for i = 1, #usrLvShownImg do
		usrLvShownImg[i]:pos(- usrLvShownWidth / 2 + (i * 2 - 1) * usrLvShownImgModelWidth / 2 + (i - 1) * usrUpgrdLvImgMagrin, 0)
			:addTo(usrLvShowView)
	end

	UIEx.bind(self, MyUserData, "headName", function(fileName)
		-- if self.m_headImage then
		-- 	self.m_headImage:removeSelf()
		-- 	self.m_headImage = nil
		-- end
	 --    local width, height = usrHeadImgBor:getSize()
	 --    local imgHead = new(ImageMask, fileName, "games/common/head_mask.png")
		-- 	:addTo(usrHeadImgBor)
		-- 	:size(width - 8, height - 8)
		local imgBorSizeWidth, imgBorSizeHeight = usrHeadImgBor:getSize()

		usrHeadImgBor:setFile(fileName)
		usrHeadImgBor:setSize(imgBorSizeWidth, imgBorSizeHeight)
		MyUserData:checkHeadAndDownload()
	end)

	UIEx.bind(self, MyUserData, "nick", function(value)
		if value then
			--todo
			ToolKit.formatTextLength(value, usrNameTxt, usrNameTxt:getSize())
		else
			usrNameTxt:setText("Name.")
		end
	end)

	MyUserData:setHeadName(MyUserData:getHeadName())
	MyUserData:setNick(MyUserData:getNick())
	
	-- local rewContTitleTxt = bgPanel:findChildByName("txt_dscTitleRew"):setText(langConfStr.str_upgrdRew)
	local rewContChipNumTxt = bgPanel:findChildByName("txt_chipRewNum"):setText("X " .. (data.addMoney or 0))

	local rewContIcProp = bgPanel:findChildByName("img_icRewProp")
	local rewContPropNumTxt = bgPanel:findChildByName("txt_propRewNum")
	local rewContPropDivLine = bgPanel:findChildByName("img_decDivLineRew2")

	local propId, propNum, propData = nil, nil, nil
	if data.props then
		--todo
		for key, val in pairs(data.props) do
			propId = key
			propNum = val

			local propConfData = MyUserData.propCfgList or {}
			propData = propConfData[tostring(propId)]
		end
	end

	local imgFile = nil
	if propData then
		--todo
		if NativeEvent.getInstance():isFileExist((propData.keyName or "") .. ".png", "popu/shop/propIcon/") == 1 then
			imgFile = string.format("popu/shop/propIcon/%s.png", propData.keyName or "")
		else
			imgFile = propData:getImgName()
		end

		local icPropSizeWidth, icPropSizeHeight = rewContIcProp:getSize()
		rewContIcProp:setFile(imgFile)
		rewContIcProp:setSize(icPropSizeWidth, icPropSizeHeight)

		rewContPropNumTxt:setText("X " .. (propNum or 0))
	else
		rewContIcProp:hide()
		rewContPropNumTxt:hide()
		rewContPropDivLine:hide()
	end

	local shareBtn = bgPanel:findChildByName("btn_share"):setOnClick(self, handler(self, self.onShareBtnCallBack_))
end

function UpgradePopu:onShareBtnCallBack_(evt)
	-- body
	self:dismiss()
	local shareFeed = {}

	shareFeed.name = string.format(langConfStr.str_upgrade_share, self.data_.level or 0, self.data_.addMoney or 0)
	shareFeed.link = langConfStr.str_updgrdFeedLink
	shareFeed.from = "gameShare"
	shareFeed.caption = shareFeed.name

	NativeEvent.getInstance():share(shareFeed)
	app:postFrontStaticstics("shareClick")
end

function UpgradePopu:onCloseBtnCallBack_(evt)
	-- body
	self:dismiss()
end

function UpgradePopu:dtor()
	-- body
	self.super.dtor(self)
end

return UpgradePopu