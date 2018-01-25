require("uiEx.scrollViewEx")
local fbFriendItem = require("app.view.popu.lobby.invite.fbFriendItem")
local FbInvitePopu = class(require("app.popu.gameWindow"))
local Hall_string = require("app.res.config")

local gTipsData = setProxy({})
gTipsData.inviteNum = 0
gTipsData.callbackNum = 0
gTipsData.selectInviteAll = false
gTipsData.selectCallbackAll = false

local gPerLoad = 15

function FbInvitePopu:ctor()
	self.hasLoadedFbFriend = 0
	self.hasLoadedCallback	= 0

	self.callbackFriendList = {}
	self.hasCallbackIds = {}
	self.mFacebookFriendData = {}
	--读取已经邀请过和召回过的好友ID
	local str = GameSetting:getCallbackIdGuest()
	for id in string.gmatch(str, "(%d*),") do
		self.hasCallbackIds[id] = true
	end
	EventDispatcher.getInstance():register(Event.Message, self, self.onEventCallback)
end

function FbInvitePopu:dtor()
	EventDispatcher.getInstance():unregister(Event.Message, self, self.onEventCallback)
	--保存新邀请的好友信息
	local str = ""
	local callbackStr = ""
	for k, v in pairs(self.hasCallbackIds) do
		callbackStr = callbackStr..k..","
	end
	GameSetting:setCallbackIdGuest(callbackStr)
	GameSetting:save()
end

function FbInvitePopu:initView(data)
	gTipsData.inviteNum = 0
	gTipsData.callbackNum = 0
	gTipsData.selectInviteAll = false
	gTipsData.selectCallbackAll = false
	
	local imgTitle = self:findChildByName("img_titleBg")
	self.m_root:findChildByName("btn_close"):setOnClick(self, self.onCloseBtnClick)
	self.tabBtns_ = {
		imgTitle:findChildByName("btn_fbInvite"),
		imgTitle:findChildByName("btn_callback"),
	}

	self.tabViews_ = {
		self:findChildByName("view_fbFriend"),
		self:findChildByName("view_callback"),
	}
	for i = 1, #self.tabBtns_ do
		self.tabBtns_[i]:setOnClick(nil, function()
			self:onTabBtnSelChanged_(i)
		end)
	end

	local defaultTabIdx = data and data.tabIdx or 1

	self:onTabBtnSelChanged_(defaultTabIdx)

	self:initFbFriendView()
	self:initCallbackView()

	if MyUserData:getInviteFriend() then
		self:onGetFbFriendCallback()
	else
		NativeEvent.getInstance():getFbFriend()
	end

	-- if MyUserData:getCallbackFriend() then
	-- 	self.callbackFriendList = MyUserData:getCallbackFriend()
	-- 	for i = 1, #self.callbackFriendList do
	-- 		self.callbackFriendList[i]:setCheck(false)
	-- 	end
	-- 	self:initCallbackFriendList()
	-- else
		HttpModule.getInstance():execute(HttpModule.s_cmds.GET_FB_CALLBACK_LIST, {}, false, false)
	-- end
end

function FbInvitePopu:onCloseBtnClick()
	self:dismiss()
end

function FbInvitePopu:initFbFriendView()
	print("zyh initFbFriendView")
	local view = self:findChildByName("view_fbFriend")
	local etName = view:findChildByName("et_searchName")
	etName:setHintText(Hall_string.str_fb_invite_search_hint)
	local viewInviteNum = view:findChildByName("view_inviteNum")
	printInfo("view is "..tostring(view).." viewInviteNum "..tostring(viewInviteNum))
	UIEx.bind(
		self,
		gTipsData,
		"inviteNum",
		function(value)
			if value > 0 then
				local actualRewardNum = value > MyUserData:getLeftInviteNum() and MyUserData:getLeftInviteNum() or value
				actualRewardNum = actualRewardNum > 0 and actualRewardNum or 0
				viewInviteNum:removeAllChildren()
				local str = string.format(Hall_string.str_invite_num, value, "%s")
				ToolKit.formatRichText(viewInviteNum, str, (HallConfig:getInvitemoney() or 1000) * actualRewardNum, {24, 0x54, 0x54, 0x51}, {26, 0xd8, 0xad, 0x3f})
			else
				viewInviteNum:removeAllChildren()
			end
		end
	)
	gTipsData.inviteNum = gTipsData.inviteNum


	local viewTop = view:findChildByName("view_top")
	local btnSearch = viewTop:findChildByName("btn_search")
	btnSearch:setOnClick(
		nil,
		function()
			self:initFbFriendList()
		end
	)

	local btnSelectAll = viewTop:findChildByName("btn_selectAll")
	local imgSelectAll = btnSelectAll:findChildByName("img_selectAll")
	btnSelectAll:setOnClick(
		nil,
		function()
			gTipsData.selectInviteAll = not gTipsData.selectInviteAll
			print("click select all "..tostring(gTipsData.selectInviteAll))
			if not gTipsData.selectInviteAll then
				for i = 1, #self.mFacebookFriendData do
					self.mFacebookFriendData[i]:setCheck(false);
				end
				gTipsData.inviteNum = 0
			else
				if #self.mFacebookFriendData >= 51 then
					for i = 1, 50 do
						self.mFacebookFriendData[i]:setCheck(true);
					end
					for i = 51, #self.mFacebookFriendData do
						self.mFacebookFriendData[i]:setCheck(false);
					end
					gTipsData.inviteNum = 50
				else
					printInfo("set inviteNum "..#self.mFacebookFriendData)
					for i = 1, #self.mFacebookFriendData do
						self.mFacebookFriendData[i]:setCheck(true);
					end
					gTipsData.inviteNum = #self.mFacebookFriendData
				end
			end
		end
	)
	UIEx.bind(
		self,
		gTipsData,
		"selectInviteAll",
		function(value)
			print("selectInviteAll change to "..tostring(value))
			if value then
				imgSelectAll:setVisible(true)
			else
				imgSelectAll:setVisible(false)
			end
		end
	)
	gTipsData.selectInviteAll = gTipsData.selectInviteAll

	local btnInvite = view:findChildByName("btn_invite")
	btnInvite:setOnClick(
		nil,
		function()
			local inviteToIds = "";
			local count = 0;
			local inviteMax = 50;
			for i = 1, #self.mFacebookFriendData do
				local data = self.mFacebookFriendData[i];
				if data:getCheck() then
					if count < inviteMax then
						if inviteToIds ~= "" then
							inviteToIds = inviteToIds .. "," .. data:getId();
						else
							inviteToIds = data:getId();
						end
					end
					count = count + 1;
				end
			end

			local gameList = HallConfig:getGameList();
			local gateway  = gameList and gameList[PhpManager:getGame()] or {};
			if string.len(inviteToIds) > 0 then
				NativeEvent.getInstance():inviteFbFriend(
					{
						title = "facebook",
						content = string.format(Hall_string.str_share_friend, PhpManager:getGameName()),
						url = gateway['gateway'] or '',
						inviteToIds = inviteToIds,
						expandData = MyUserData:getId(),
						action = "invite",
					}
																								);
			end
		end
	)

	local inviteMoney = HallConfig:getInvitemoney()
	view:findChildByName("text_rewardTip"):setText(string.format(Hall_string.str_invite_reward_tip, inviteMoney))--, HallConfig:getInviteMaxRewardNum() * inviteMoney))
	view:findChildByName("text_sucTip"):setText(string.format(Hall_string.str_invite_suc_tip, HallConfig:getSuccessmoney() or 120000))
end

function FbInvitePopu:initFbFriendList()
	local view = self:findChildByName("view_fbFriend")
	local imgBg = view:findChildByName("img_friendList")
	imgBg:removeAllChildren()
	local w, h = imgBg:getSize()
	local svFbFriendList = new(ScrollViewEx, 0, 0, w, h, false)
	svFbFriendList:setDirection(kVertical)
	svFbFriendList:setName("sv_fbFriend")
	svFbFriendList:setOnReachBottom(
		nil,
		function()
			print("fb setOnReachBottom "..self.hasLoadedFbFriend)
			if self.hasLoadedFbFriend < #self.mFacebookFriendData then
				self:loadFbFriendList(self.hasLoadedFbFriend + 1, self.hasLoadedFbFriend + gPerLoad)
			end
		end
	)
	svFbFriendList:setPos(0, 0)
	imgBg:addChild(svFbFriendList)

	local text_fb_friend_empty = view:findChildByName("text_fb_friend_empty")
	if #self.mFacebookFriendData == 0 then
		text_fb_friend_empty:setText(Hall_string.str_empty_fb_friend)
		text_fb_friend_empty:setVisible(true)
	else
		text_fb_friend_empty:setVisible(false)
	end

	self:loadFbFriendList(1, gPerLoad)
end

function FbInvitePopu:onTabBtnSelChanged_(idx)
	-- body
	for i = 1, #self.tabBtns_ do
		self.tabBtns_[i]:findChildByName("img_select"):setVisible(i == idx)
	end

	for i = 1, #self.tabViews_ do
		self.tabViews_[i]:setVisible(i == idx)
	end
end

function FbInvitePopu:loadFbFriendList(from, to)
	local kNumOneLine = 4
	local view = self:findChildByName("view_fbFriend")
	local svFbFriendList = view:findChildByName("sv_fbFriend")
	local etName = view:findChildByName("et_searchName")
	local text = string.ltrim(string.lower(etName:getText()))

	local scrollviewW = svFbFriendList:getSize()
	if from == 1 then
		self.hasLoadedFbFriend = 0
	end
	local curLoadCount = 0
	for i = self.hasLoadedFbFriend + 1, #self.mFacebookFriendData do
		if curLoadCount < gPerLoad then
			self.hasLoadedFbFriend = self.hasLoadedFbFriend + 1
			local data = self.mFacebookFriendData[i]
			if text == "" or (text ~= "" and string.match(string.lower(data:getNickname()), text)) then
				print("load fb friend name "..data:getNickname())
				local children = svFbFriendList:getChildren()
				local curNum = children and #children or 0
				local columns = curNum % kNumOneLine
				local rows = math.floor(curNum / kNumOneLine)
				curLoadCount = curLoadCount + 1
				local item = self:initFbFriendItem(data)
				local w, h = item:getSize()
				local delta = (scrollviewW - 32 - w * kNumOneLine) / (kNumOneLine - 1)
				item:setPos(columns * (w + delta) + 16, (h + 10) * rows + 16)
				svFbFriendList:addChild(item)
			end
		end
	end
	print("loadFbFriendList finish "..self.hasLoadedFbFriend)

end

function FbInvitePopu:initFbFriendItem(data, isCallback)
	local item = SceneLoader.load(fbFriendItem)
	local btn = item:findChildByName("btn_select")
	local iconSelect = btn:findChildByName("icon_select")

	btn:setOnClick(
		nil,
		function()
			data:setCheck(not data:getCheck())
			if data:getCheck() then
				if isCallback then
					gTipsData.callbackNum = gTipsData.callbackNum + 1
				else
					gTipsData.inviteNum = gTipsData.inviteNum + 1
				end
			else
				if isCallback then
					gTipsData.callbackNum = gTipsData.callbackNum - 1
					gTipsData.selectCallbackAll = false
				else
					gTipsData.inviteNum = gTipsData.inviteNum - 1
					gTipsData.selectInviteAll = false
				end
			end
		end
	)

	UIEx.bind(
		item,
		data,
		"check",
		function(value)
			iconSelect:setVisible(value)
		end
	)
	data:setCheck(data:getCheck())

	-- --目前数据里没有性别的概念。
	-- local imgSex = viewNick:findChildByName("img_sex")
	-- UIEx.bind(
	-- 	item,
	-- 	data,
	-- 	"sex",
	-- 	function(value)
	-- 		if value == 1 then
	-- 			imgSex:setFile("common/tag_female.png")
	-- 		end
	-- 	end
	-- )

	local imgHead = item:findChildByName("img_head")
	-- UIEx.bind(
	-- 	item,
	-- 	data,
	-- 	"headName",
	-- 	function(value)
	-- 		printInfo("headName is "..value)
	-- 		viewHead:removeAllChildren()
	-- 		local img = new(Mask, value, "popu/fbinvite/head_mask.png")
	-- 		img:setSize(viewHead:getSize())
	-- 		viewHead:addChild(img)
	-- 		-- data:checkHeadAndDownload()
	-- 	end
	-- )
	local imgData = setProxy(new(require("app.data.imgData")))
	UIEx.bind(item, imgData, "imgName", function(value)
		local imgStr = nil
		if imgData:checkImg() then
			imgStr = imgData:getImgName()
		else
			-- return
			-- img = data.msex == 2 and "popu/friends/avatar_female.png" or "popu/friends/avatar_male.png"
			imgStr = "popu/friends/avatar_male.png"
		end
		imgHead:removeAllChildren()
		local width, height = imgHead:getSize()
		-- local imgHead = new(ImageMask, imgStr, "games/common/head_mask.png")
		-- 			:addTo(viewHead)
		-- 			:size(width-8, height-8)
		-- 			:pos(4,4)
		local img = new(Image, imgStr)
		imgHead:addChild(img)
		img:setSize(width-6, height-6)
		img:setPos(3, 3)
    end)
	UIEx.bind(
		item,
		data,
		"headUrl",
		function(value)
			imgData:setImgUrl(value)
		end)
	imgData:setImgUrl(data:getHeadUrl())

	local viewNick = item:findChildByName("view_nick")
	local textNick = viewNick:findChildByName("text_nick")
	UIEx.bind(
		item,
		data,
		"nickname",
		function(value)
			textNick:setText(ToolKit.formatNick(value, 7))
		end
	)
	data:setNickname(data:getNickname())

	btn:findChildByName("text_reward"):setText("+"..data:getMoney())

	return item
end

function FbInvitePopu:initCallbackView()
	local view = self:findChildByName("view_callback")
	local etName = view:findChildByName("et_searchName")
	etName:setHintText(Hall_string.str_fb_invite_search_hint)
	local viewCallbackNum = view:findChildByName("view_inviteNum")
	UIEx.bind(
		self,
		gTipsData,
		"callbackNum",
		function(value)
			if value > 0 then
				local actualRewardNum = value > MyUserData:getLeftCallbackNum() and MyUserData:getLeftCallbackNum() or value
				printInfo("initCallbackView actualRewardNum is "..actualRewardNum)
				actualRewardNum = actualRewardNum > 0 and actualRewardNum or 0
				viewCallbackNum:removeAllChildren()
				local str = string.format(Hall_string.str_callback_num, value, "%s")
				ToolKit.formatRichText(viewCallbackNum, str, (HallConfig:getInvitemoney() or 1000) * actualRewardNum, {24, 0x54, 0x54, 0x51}, {26, 0xd8, 0xad, 0x3f})
			else
				viewCallbackNum:removeAllChildren()
			end
		end
	)
	gTipsData.callbackNum = gTipsData.callbackNum

	local viewTop = view:findChildByName("view_top")
	local btnSearch = viewTop:findChildByName("btn_search")
	btnSearch:setOnClick(
		nil,
		function()
			self:initCallbackFriendList()
		end
	)


	local btnSelectAll = viewTop:findChildByName("btn_selectAll")
	local imgSelectAll = btnSelectAll:findChildByName("img_selectAll")
	btnSelectAll:setOnClick(
		nil,
		function()
			gTipsData.selectCallbackAll = not gTipsData.selectCallbackAll
			print("click select all "..tostring(gTipsData.selectCallbackAll))
			if not gTipsData.selectCallbackAll then
				for i = 1, #self.callbackFriendList do
					self.callbackFriendList[i]:setCheck(false);
				end
				gTipsData.callbackNum = 0
			else
				if #self.callbackFriendList >= 51 then
					for i = 1, 50 do
						self.callbackFriendList[i]:setCheck(true);
					end
					for i = 51, #self.callbackFriendList do
						self.callbackFriendList[i]:setCheck(false);
					end
					gTipsData.callbackNum = 50
				else
					printInfo("set inviteNum "..#self.callbackFriendList)
					for i = 1, #self.callbackFriendList do
						self.callbackFriendList[i]:setCheck(true);
					end
					gTipsData.callbackNum = #self.callbackFriendList
				end
			end
		end
	)
	UIEx.bind(
		self,
		gTipsData,
		"selectCallbackAll",
		function(value)
			print("selectCallbackAll change to "..tostring(value))
			if value then
				imgSelectAll:setVisible(true)
			else
				imgSelectAll:setVisible(false)
			end
		end
	)
	gTipsData.selectCallbackAll = gTipsData.selectCallbackAll

	local btnInvite = view:findChildByName("btn_invite")
	btnInvite:setOnClick(
		nil,
		function()
			local inviteToIds = "";
			local count = 0;
			local inviteMax = 50;
			for i = 1, #self.callbackFriendList do
				local data = self.callbackFriendList[i];
				if data:getCheck() then
					if count < inviteMax then
						if inviteToIds ~= "" then
							inviteToIds = inviteToIds .. "," .. data:getId();
						else
							inviteToIds = data:getId();
						end
					end
					count = count + 1;
				end
			end

			local gameList = HallConfig:getGameList();
			local gateway  = gameList and gameList[PhpManager:getGame()] or {};
			if string.len(inviteToIds) > 0 then
				NativeEvent.getInstance():inviteFbFriend(
					{
						title = "facebook",
						content = string.format(Hall_string.str_share_friend, PhpManager:getGameName()),
						url = gateway['gateway'] or '',
						inviteToIds = inviteToIds,
						expandData = MyUserData:getId(),
						action = "recall",
					}
																								);
			end
		end
	)
	view:findChildByName("text_rewardTip"):setText(string.format(Hall_string.str_callback_reward_tip, HallConfig:getPerReward()))
	view:findChildByName("text_sucTip"):setText("· "..HallConfig:getPerRewardMsg())
end

function FbInvitePopu:initCallbackFriendList()
	local view = self:findChildByName("view_callback")
	local imgBg = view:findChildByName("img_callbackList")
	imgBg:removeAllChildren()
	local w, h = imgBg:getSize()
	local svFbFriendList = new(ScrollViewEx, 0, 0, w, h, false)
	svFbFriendList:setDirection(kVertical)
	svFbFriendList:setName("sv_callbackFriendList")
	svFbFriendList:setOnReachBottom(
		nil,
		function()
			if self.hasLoadedCallback < #self.callbackFriendList then
				self:loadCallbackFriendList(self.hasLoadedFbFriend + 1, self.hasLoadedFbFriend + gPerLoad)
			end
		end
	)
	svFbFriendList:setPos(0, 0)
	imgBg:addChild(svFbFriendList)

	local text_fb_callback_empty = view:findChildByName("text_fb_callback_empty")
	if #self.callbackFriendList == 0 then
		text_fb_callback_empty:setText(Hall_string.str_empty_fb_callback)
		text_fb_callback_empty:setVisible(true)
	else
		text_fb_callback_empty:setVisible(false)
	end

	self:loadCallbackFriendList(1, gPerLoad)
end

function FbInvitePopu:loadCallbackFriendList(from, to)
	local kNumOneLine = 4
	local view = self:findChildByName("view_callback")
	local svFbFriendList = view:findChildByName("sv_callbackFriendList")
	local scrollviewW = svFbFriendList:getSize()
	local etName = view:findChildByName("et_searchName")
	local text = string.ltrim(string.lower(etName:getText()))
	if from == 1 then
		self.hasLoadedCallback = 0
	end

	local curLoadCount = 0
	for i = self.hasLoadedCallback + 1, #self.callbackFriendList do
		if curLoadCount < gPerLoad then
			self.hasLoadedCallback = self.hasLoadedCallback + 1
			local data = self.callbackFriendList[i]
			if text == "" or (text ~= "" and string.match(string.lower(data:getNickname()), text)) then
				local children = svFbFriendList:getChildren()
				local curNum = children and #children or 0

				local columns = curNum % kNumOneLine
				local rows = math.floor(curNum / kNumOneLine)
				local item = self:initFbFriendItem(data, true)
				local w, h = item:getSize()
				local delta = (scrollviewW - 24 - w * kNumOneLine) / (kNumOneLine - 1)
				item:setPos(columns * (w + delta) + 12, (h + 10) * rows + 12)
				svFbFriendList:addChild(item)
			end
		end
	end

end

function FbInvitePopu:onEventCallback(key, data)
	if self.callEventFuncMap[key] then
		self.callEventFuncMap[key](self, data)
	end
end

function FbInvitePopu:onGetFbFriendCallback()
	local data = MyUserData:getInviteFriend()
	print_string("zyh data is "..tostring(data).." status is "..tostring(data and data.status or "data is nil"))
	if data and data.status == 0 then
		for i = 1, #data do
			local swapIndex = math.random(#data)
			local tmp = data[i]
			data[i] = data[swapIndex]
			data[swapIndex] = tmp
		end
		self.mFacebookFriendData = data
		local autoSelectNum = 0
		for i = 1, #data do
			autoSelectNum = autoSelectNum + 1
			data[i]:setCheck(false)
			if autoSelectNum < 51 then
				data[i]:setCheck(gTipsData.selectInviteAll)
			end
		end
		if gTipsData.selectInviteAll then
			gTipsData.inviteNum = autoSelectNum > 50 and 50 or autoSelectNum
		else
			gTipsData.inviteNum = 0
		end
		printInfo("friend num is "..#self.mFacebookFriendData)
		-- self:initFbFriendView()
		self:initFbFriendList(1, gPerLoad);
		gTipsData.selectInviteAll = false
		local btnSelectAll = self:findChildByName("view_fbFriend"):findChildByName("btn_selectAll")
		btnSelectAll.m_eventCallback.func(btnSelectAll.m_eventCallback.obj)
	else
		AlarmTip.play(STR_GET_INVITED_FRIEND_ERR);
	end
end

function FbInvitePopu:onSendRecallSuccess(data)
	local ids = {}
	local newCallBackList = {}
	for i = 1, #self.callbackFriendList do
		--没选中的玩家就重新刷新列表，选中的玩家用来发奖励请求
		if not self.callbackFriendList[i]:getCheck() then
			table.insert(newCallBackList, self.callbackFriendList[i])
		else
			table.insert(ids, self.callbackFriendList[i].userId)
			self.hasCallbackIds[tostring(self.callbackFriendList[i]:getId())] = true
		end
	end
	JLog.d("FbInvitePopu:onSendRecallSuccess", ids)
	HttpModule.getInstance():execute(HttpModule.s_cmds.GET_FB_CALLBACK_REWARD, {fids = ids}, false, false)
	local leftNum = MyUserData:getLeftCallbackNum() - #ids
	if leftNum < 0 then
		leftNum = 0
	end
	MyUserData:setLeftCallbackNum(leftNum)
	self.callbackFriendList = newCallBackList
	MyUserData:setCallbackFriend(self.callbackFriendList)
	self:initCallbackFriendList()
	gTipsData.callbackNum = 0
end

function FbInvitePopu:onGetFbCallbackList(isSuccess, data)
	-- isSuccess = true
	-- local str = [=[{"code":1,"codemsg":"","data":[{"mid":"10015","micon":"https:\/\/graph.facebook.com\/1482731352050719\/picture?type=normal","name":"Timi Zou1","sitemid":"1482731352050719"},{"mid":"2085774","micon":"https:\/\/graph.facebook.com\/206817506346157\/picture?type=normal","name":"Doria Wu","sitemid":"206817506346157"},{"mid":"556481","micon":"https:\/\/graph.facebook.com\/161119950929662\/picture?type=normal","name":"\u949f\u96e8\u5b8f","sitemid":"161119950929662"},{"mid":"10015","micon":"https:\/\/graph.facebook.com\/1482731352050719\/picture?type=normal","name":"Timi Zou1","sitemid":"1482731352050719"},{"mid":"10015","micon":"https:\/\/graph.facebook.com\/1482731352050719\/picture?type=normal","name":"Timi Zou1","sitemid":"1482731352050719"},{"mid":"10015","micon":"https:\/\/graph.facebook.com\/1482731352050719\/picture?type=normal","name":"Timi Zou1","sitemid":"1482731352050719"},{"mid":"10015","micon":"https:\/\/graph.facebook.com\/1482731352050719\/picture?type=normal","name":"Timi Zou1","sitemid":"1482731352050719"},{"mid":"10015","micon":"https:\/\/graph.facebook.com\/1482731352050719\/picture?type=normal","name":"Timi Zou1","sitemid":"1482731352050719"},{"mid":"10015","micon":"https:\/\/graph.facebook.com\/1482731352050719\/picture?type=normal","name":"Timi Zou1","sitemid":"1482731352050719"},{"mid":"10015","micon":"https:\/\/graph.facebook.com\/1482731352050719\/picture?type=normal","name":"Timi Zou1","sitemid":"1482731352050719"},{"mid":"10015","micon":"https:\/\/graph.facebook.com\/1482731352050719\/picture?type=normal","name":"Timi Zou1","sitemid":"1482731352050719"},{"mid":"10015","micon":"https:\/\/graph.facebook.com\/1482731352050719\/picture?type=normal","name":"Timi Zou1","sitemid":"1482731352050719"},{"mid":"10015","micon":"https:\/\/graph.facebook.com\/1482731352050719\/picture?type=normal","name":"Timi Zou1","sitemid":"1482731352050719"},{"mid":"10015","micon":"https:\/\/graph.facebook.com\/1482731352050719\/picture?type=normal","name":"Timi Zou1","sitemid":"1482731352050719"},{"mid":"10015","micon":"https:\/\/graph.facebook.com\/1482731352050719\/picture?type=normal","name":"Timi Zou1","sitemid":"1482731352050719"},{"mid":"10015","micon":"https:\/\/graph.facebook.com\/1482731352050719\/picture?type=normal","name":"Timi Zou1","sitemid":"1482731352050719"},{"mid":"10015","micon":"https:\/\/graph.facebook.com\/1482731352050719\/picture?type=normal","name":"Timi Zou1","sitemid":"1482731352050719"}],"time":1501570887,"exetime":0.011751890182495}]=]
	-- data = json.decode(str)
	-- print("onGetFbCallbackList")
	-- dump(data)
	JLog.d("FbInvitePopu:onGetFbCallbackList", isSuccess, data)
	if app:checkResponseOk(isSuccess, data) then
		self.callbackFriendList = {}
		local friendList = data.data or {}
		local noinvitecount = 0
		for i = 1, #friendList do
			local friend = friendList[i]
			local callbackFriend = setProxy(new(require("app.data.facebookFriend")))
			callbackFriend:setId(tostring(friend.sitemid) or "")
			callbackFriend:setNickname(friend.name or "")
			callbackFriend:setHeadUrl(friend.micon or "")
			callbackFriend:setMoney(self.callbackReward or 1000)
			callbackFriend:setCheck(false)
			callbackFriend.userId = tonumber(friend.mid) or 0
			callbackFriend:setSex(1)
			--这个号今天还没有召回过，才显示
			if not self.hasCallbackIds[callbackFriend:getId()] then
				noinvitecount = noinvitecount + 1
				table.insert(self.callbackFriendList, callbackFriend)
				if noinvitecount < 51 then
					callbackFriend:setCheck(gTipsData.selectCallbackAll)
				end
			end
		end
		--如果当前设置为选中，刷新召回选中的人数
		if gTipsData.selectCallbackAll then
			gTipsData.callbackNum = noinvitecount > 50 and 50 or noinvitecount
		else
			gTipsData.callbackNum = 0
		end
		MyUserData:setCallbackFriend(self.callbackFriendList)
		self:initCallbackFriendList()
		gTipsData.selectCallbackAll = false
		local btnSelectAll = self:findChildByName("view_callback"):findChildByName("btn_selectAll")
		btnSelectAll.m_eventCallback.func(btnSelectAll.m_eventCallback.obj)
	end
end

FbInvitePopu.callEventFuncMap = {
	[kGetFbFriend] = FbInvitePopu.onGetFbFriendCallback,
	["sendFBRecallSuccess"] = FbInvitePopu.onSendRecallSuccess,
}

FbInvitePopu.s_severCmdEventFuncMap = {
	[HttpModule.s_cmds.GET_FB_CALLBACK_LIST]    = FbInvitePopu.onGetFbCallbackList,
}

return FbInvitePopu


