--
-- Author: TsingZhang@boyaa.com
-- Date: 2017-07-20 17:20:09
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: DailyTaskPopu.lua Created By Tsing7x.
--

local langConfStr = require("app.res.config")

local DailyTaskListItem = import(".compViews.DailyTaskListItem")

local GameWindow = require("app.popu.gameWindow")
local DailyTaskPopu = class(GameWindow)

function DailyTaskPopu:ctor()
	-- body
	EventDispatcher.getInstance():register(HttpModule.s_event, self, self.onHttpRequestsCallBack)
end

function DailyTaskPopu:initView(data)
	-- body
	local bgMainPanel = self.m_root:findChildByName("bg_mainPanel")

	bgMainPanel:setEventTouch(self, function()
		-- body
	end)

	local closeBtn = bgMainPanel:findChildByName("btn_close")
	closeBtn:setOnClick(self, handler(self, self.onCloseBtnCallBack_))

	self.viewBlkMain_ = bgMainPanel:findChildByName("vb_mainArea")

	self.noDailyTaskTip_ = self.viewBlkMain_:findChildByName("txt_noTaskDataHint")

	self.noDailyTaskTip_:setText(langConfStr.str_dTask_NoTaskDataTip)
	self.noDailyTaskTip_:hide()

	self:getContData()
end

function DailyTaskPopu:getContData()
	-- body
	self:execHttpCmd(HttpModule.s_cmds.DailyTask_Init, {}, false, true, self.viewBlkMain_)
	-- HttpModule.getInstance():execute(HttpModule.s_cmds.DailyTask_Init, {}, false, true)
end

function DailyTaskPopu:onCloseBtnCallBack_(evt)
	-- body
	self:dismiss()
end

function DailyTaskPopu:onHttpRequestsCallBack(command, isSucc, data)
	-- body
	-- dump(data, "DailyTaskPopu:onHttpRequestsCallBack(command :" .. command .. "isSucc :" .. tostring(isSucc) ..
	-- 	").data :===================")

	if command == HttpModule.s_cmds.DailyTask_Init then
		--todo
		if isSucc and data then
			--todo
			if self then
				--todo
				if data.code == 1 then
					--todo
					self.noDailyTaskTip_:hide()
					local dailyTaskDataList = data.data

					-- for i = 1, #dailyTaskDataList do
					-- 	dailyTaskDataList.sort = 10 - i
					-- end

					-- table.sort(dailyTaskDataList, function(tb1, tb2)
					-- 	-- body
					-- 	return (tb1.sort or 0) < (tb2.sort or 0)
					-- end)

					if dailyTaskDataList and #dailyTaskDataList > 0 then
						--todo
						local viewBlkSizeWidth, viewBlkSizeHeight = self.viewBlkMain_:getSize()
						if self.myDailyTaskSrcollView_ then
							--todo
							self.myDailyTaskSrcollView_:removeSelf()
							self.myDailyTaskSrcollView_ = nil
						end

						self.myDailyTaskSrcollView_ = new(ScrollView, 0, 0, viewBlkSizeWidth - 8, viewBlkSizeHeight - 8, true)
							:addTo(self.viewBlkMain_)

						self.myDailyTaskSrcollView_:setAlign(KAlignCenter)
						local scrollWidth, scrollHeight = self.myDailyTaskSrcollView_:getSize()
						local scrollViewItemGapVect = 0
						-- local scrollItemPosYAdj = 2

						self.dailyTaskItems_ = {}
						-- self.itemNodes_ = {}

						for i = 1, #dailyTaskDataList do
							self.dailyTaskItems_[i] = new(DailyTaskListItem)

							local scrollItem = new(Node)
								:setSize(self.dailyTaskItems_[i]:getItemContSize().width, self.dailyTaskItems_[i]:getItemContSize().height)
								:addTo(self.myDailyTaskSrcollView_)

							self.dailyTaskItems_[i]:pos(0, self.dailyTaskItems_[i]:getItemContSize().height)
								:addTo(scrollItem)

							self.dailyTaskItems_[i]:setItemActionCallBack(handler(self, self.onTaskItemEvtCallBack_))
							self.dailyTaskItems_[i]:refreshItemData(dailyTaskDataList[i])
						end
					end
				else
					self.noDailyTaskTip_:show()
					printInfo("Get DailyTaskInit Data Error, Msg :" .. tostring(data.codemsg))
				end
			end
		else
			AlarmTip.play(langConfStr.STR_SERVER_ERROR)
		end
	elseif command == HttpModule.s_cmds.DailyTask_getRew then
		--todo
		if isSucc and data then
			--todo
			if data.code == 1 then
				--todo
				if self then
					--todo

					AlarmTip.play(data.reward or langConfStr.str_dTask_GetRewSucc)
					if data.money then
						--todo
						MyUserData:setMoney(MyUserData:getMoney() + tonumber(data.money))
					end

					if data.exp then
						--todo
						MyUserData:setExp(MyUserData:getExp() + tonumber(data.exp))
					end

					if data.props then
						--todo
						MyUserData:setPropNum(kIDInteractiveProp, MyUserData:getPropNum() + tonumber(data.props))
					end

					AnimationParticles.play(AnimationParticles.DropCoin)
					kEffectPlayer:play('audio_get_gold')
					
					self:getContData()
				end
			else
				AlarmTip.play(langConfStr.STR_SERVER_ERROR)
				printInfo("Get DailyTaskInit Data Error, Msg :" .. tostring(data.codemsg))
			end
		else
			AlarmTip.play(langConfStr.str_dTask_GetRewFail)
		end
	end
end

function DailyTaskPopu:onTaskItemEvtCallBack_(itemData)
	-- body
	local itemRewState = itemData.rewardStatus or 0
	local jumpAction= itemData.other
	-- printInfo("itemRewState :" .. itemRewState)
	-- dump(jumpAction, "jumpAction :==============")

	if itemRewState == 0 then
		--todo
		local doActionByIdx = {
			[1] = function()
				-- body
				-- Play Game Task
				-- local gameId = tonumber(GAME_ID.Casinohall)

				local game = app:getGame(gameId)
				if game then 
					game:enterRoom()
				else
					AlarmTip.play(langConfStr.STR_GAMECLOSED)
				end
			end,

			[2] = function()
				-- body
				-- Invite Task
				WindowManager:showWindow(WindowTag.FbInvitePopu, {tabIdx = 2}, WindowStyle.POPUP)
			end,

			[3] = function()
				-- body
				-- Recall Task
				WindowManager:showWindow(WindowTag.FbInvitePopu, {tabIdx = 1}, WindowStyle.POPUP)
			end
		}

		if jumpAction and jumpAction.jump then

			if doActionByIdx[jumpAction.jump] then
				--todo
				self:dismiss()

				doActionByIdx[jumpAction.jump]()
			else
				printInfo("Not Defined Jump Action.")
			end
			--todo
		else
			printInfo("ItemData JumpAction Field Wrong.")
		end

	elseif itemRewState == 1 then
		--todo
		self:execHttpCmd(HttpModule.s_cmds.DailyTask_getRew, {tid = itemData.id}, false, true, self.viewBlkMain_)
		-- HttpModule.getInstance():execute(HttpModule.s_cmds.DailyTask_getRew, {tid = itemData.id}, false, true)
	end
end

function DailyTaskPopu:dtor()
	-- body
	self.super.dtor(self)

	EventDispatcher.getInstance():unregister(HttpModule.s_event, self, self.onHttpRequestsCallBack)
end

return DailyTaskPopu