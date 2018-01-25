--
-- Author: TsingZhang@boyaa.com
-- Date: 2017-07-21 12:13:28
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: DailyTaskListItem.lua Created By Tsing7x.
--

local langConfStr = require("app.res.config")

local ITEMSIZE = nil

local DailyTaskListItem = class(Node)

function DailyTaskListItem:ctor()
	-- body
	local itemBgSize = {
		width = 610,
		height = 140
	}

	local itemGapVect = 2

	ITEMSIZE = {
		width = itemBgSize.width,
		height = itemBgSize.height + itemGapVect
	}

	local ViewLayout = require(ViewPath .. "popu.lobby.views.dailyTaskItem")

	self.mainContLayer_ = new(BaseLayer, ViewLayout)
	self:addChild(self.mainContLayer_)
end

function DailyTaskListItem:refreshItemData(data)
	-- body
	if self.data_ then
		--todo
		self.data_ = nil
	end

	self.data_ = data
	local bgItem = self.mainContLayer_:findChildByName("bg_item")

	self.taskIcon_ = bgItem:findChildByName("ic_task")
	self.taskName_ = bgItem:findChildByName("txt_taskName")
	self.taskTarget_ = bgItem:findChildByName("txt_target")
	self.taskRewDesc_ = bgItem:findChildByName("tv_rewDsc")
	self.taskProgress_ = bgItem:findChildByName("txt_taskProgress")

	self.itemActionBtn_ = bgItem:findChildByName("btn_itemAction")
	self.itemActionBtn_:setEnable(false)

	self.taskName_:setText(self.data_.name or "Name.")
	-- self.taskTarget_:setText(self.data_.description or "Dsc.")
	local rewDscTxtStr = nil
	if self.data_.reward then
		--todo
		local isRewChip = self.data_.reward.chips and tonumber(self.data_.reward.chips) > 0
		local isRewExp = self.data_.reward.exp and tonumber(self.data_.reward.exp) > 0

		if isRewChip then
			--todo
			rewDscTxtStr = string.format(langConfStr.str_dTask_RewChip, self.data_.reward.chips)
		end

		if isRewExp then
			--todo
			rewDscTxtStr = string.format(langConfStr.str_dTask_RewExp, self.data_.reward.exp)
		end

		if isRewChip and isRewExp then
			--todo
			rewDscTxtStr = string.format(langConfStr.str_dTask_RewChipExp, self.data_.reward.chips, self.data_.reward.exp)
		end

		if not isRewChip and not isRewExp then
			--todo
			rewDscTxtStr = langConfStr.str_dTask_RewNull
		end
	else
		rewDscTxtStr = "Rew Dsc."
	end

	self.taskRewDesc_:setScrollBarWidth(0)
	self.taskRewDesc_:setText(rewDscTxtStr)

	local taskNamePosX, taskNamePosY = self.taskName_:getPos()
	local taskNameWidth, taskNameHeight = self.taskName_:getSize()

	local taskProgressMagrinLeft = 5
	self.taskProgress_:setText("(" .. (self.data_.process or "0/0") .. ")")
	self.taskProgress_:pos(taskNamePosX + taskNameWidth + taskProgressMagrinLeft, taskNamePosY)

	self.itemActionBtn_:setOnClick(self, handler(self, self.onItemClkCallBack_))

	self:refreshBtnActionState(self.data_.rewardStatus)

	if self.data_.icon and string.len(self.data_.icon) >= 5 then
		--todo
		local imgData = setProxy(new(require("app.data.imgData")))
		UIEx.bind(self, imgData, "imgName", function(value)
			if imgData:checkImg() then
				self.taskIcon_:setFile(imgData:getImgName())
			end
	    end)
		imgData:setImgUrl(self.data_.icon)
	end
end

function DailyTaskListItem:refreshBtnActionState(state)
	-- body
	local btnActionTxt = self.itemActionBtn_:findChildByName("txt_btnAction")
	if state == 0 then
		--todo
		self.itemActionBtn_:setFile("popu/btn_rightAnglGreen.png")
		btnActionTxt:setText(langConfStr.str_dTask_StateDoing)

		self.itemActionBtn_:setEnable(true)
	elseif state == 1 then
		--todo
		self.itemActionBtn_:setFile("popu/btn_rightAnglYellow.png")
		btnActionTxt:setText(langConfStr.str_dTask_StateDone)

		self.itemActionBtn_:setEnable(true)
	elseif state == 2 then
		--todo
		self.itemActionBtn_:setFile("popu/btn_rightAnglGrey.png")
		btnActionTxt:setText(langConfStr.str_dTask_StateRewed)

		self.itemActionBtn_:setEnable(false)
	end
end

function DailyTaskListItem:onItemClkCallBack_(evt)
	-- body
	if self.itemClkCallBack_ then
		--todo
		self.itemClkCallBack_(self.data_)
	end
end

function DailyTaskListItem:setItemActionCallBack(callback)
	-- body
	self.itemClkCallBack_ = callback
end

function DailyTaskListItem:getItemContSize()
	-- body
	return ITEMSIZE
end

function DailyTaskListItem:dtor()
	-- body
	self.super.dtor()
end

return DailyTaskListItem