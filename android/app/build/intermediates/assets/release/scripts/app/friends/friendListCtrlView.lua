local friendListCtrlView = class(BaseLayer, false)

local friendItemView = class(BaseLayer, false)

function friendItemView:ctor(data)
	super(self, requireview(ViewPath..'popu.lobby.friendItemView'))
	self:setSize(self.m_root:getSize())
	self.data = data
	if data.isOnline == 1 then
		self.m_root:findChildByName("online"):setFile("popu/friends/online.png")
	else
		self.m_root:findChildByName("online"):setFile("popu/friends/not_online.png")
	end
	local avatar_bg = self.m_root:findChildByName("avatar_bg")
	avatar_bg:removeAllChildren();
	local width, height = avatar_bg:getSize()
	-- local imgHead = new(ImageMask, data.msex == 2 and "popu/friends/avatar_female.png" or "popu/friends/avatar_male.png", "games/common/head_mask.png")
	-- 			:addTo(avatar_bg)
	-- 			:size(width-8, height-8)
	-- 			:pos(4,4)
	local imgHead = new(Image, data.msex == 2 and "popu/friends/avatar_female.png" or "popu/friends/avatar_male.png")
	avatar_bg:addChild(imgHead)
	imgHead:setSize(width-8, height-8)
	imgHead:setPos(4, 4)
	if data.micon and data.micon ~= "" then
		local imgData = setProxy(new(require("app.data.imgData")))
		UIEx.bind(self, imgData, "imgName", function(value)
			local img = nil
			if imgData:checkImg() then
				img = imgData:getImgName()
			else
				return
				-- img = data.msex == 2 and "popu/friends/avatar_female.png" or "popu/friends/avatar_male.png"
			end
			avatar_bg:removeAllChildren();
			local width, height = avatar_bg:getSize()
			-- local imgHead = new(ImageMask, img, "games/common/head_mask.png")
			-- 			:addTo(avatar_bg)
			-- 			:size(width-8, height-8)
			-- 			:pos(4,4)
			local imgHead = new(Image, img)
			avatar_bg:addChild(imgHead)
			imgHead:setSize(width-8, height-8)
			imgHead:setPos(4, 4)
	    end)
    	imgData:setImgUrl(data.micon)
	end
    self.m_root:findChildByName("btn_avatar"):setOnClick(self, function (self)
    	WindowManager:showWindow(WindowTag.FriendInfoPopu, data, WindowStyle.POPUP)
    end)
	local text_name = self.m_root:findChildByName("text_name")
	-- text_name:setText(data.name)
	
	local newText = new(Text, nil, 0, 0, kAlignCenter, "", text_name.m_fontSize, 0xff, 0xff, 0xff)
	ToolKit.formatTextLength(data.name, newText, 90)
	text_name:setText(newText:getText())
	delete(newText)

	self.m_root:findChildByName("text_chip"):setText(ToolKit.formatMoney(data.money))
	local sex = self.m_root:findChildByName("sex")
	local text_name_x, text_name_y = text_name:getPos()
	local text_name_w, text_name_h = text_name:getSize()
	local sex_x, sex_y = sex:getPos()
	sex:setPos(text_name_x + text_name_w + 5, sex_y)
	if tonumber(data.msex) == 2 then
		sex:setFile("popu/friends/female.png")
		sex:setSize(16, 22)
	end
	local btn_follow = self.m_root:findChildByName("btn_follow")
	local btn_recall = self.m_root:findChildByName("btn_recall")
	local text_ing = self.m_root:findChildByName("text_ing")
	local text_game = self.m_root:findChildByName("text_game")
	self.m_root:findChildByName("text_ing")

	if data.isOnline == 1 and data.gameName and #data.gameName > 0 then
		btn_follow:setVisible(true)
		text_ing:setText(Hall_string.str_friend_game_ing)
		text_game:setText(data.gameName)
		btn_follow:setOnClick(self, function (self)
			local game = app:getGame(data.gameid) --鱼虾蟹
			if game then
				local room = game:getRoomFromLevel(data.lv)
				if room then
					-- room.tableId = data.roomid or 0
					-- game:enterRoom(States.Lobby, room, data.fid, data.name)
					game:enterRoom(room)
				end
			else
				AlarmTip.play(Hall_string.STR_NOT_DOWNLOAD_RRIEND_GAME)
			end
		end)
	else
		text_ing:setVisible(false)
		text_game:setVisible(false)
		btn_follow:setVisible(false)
	end

	if data.isOnline == 1 or canSendRecall == 0 then
		btn_recall:setVisible(false)
	else
		btn_recall:setVisible(true)
		btn_recall:setOnClick(self, function (self)
			EventDispatcher.getInstance():dispatch(Event.Message, "friendListCtrlView:requestCmd", HttpModule.s_cmds.FRIEND_SEND_RECALL, {fid = data.fid}, false);
			-- HttpModule.getInstance():execute(HttpModule.s_cmds.FRIEND_SEND_RECALL, {fid = data.fid}, false, false)
		end)
	end
end

function friendListCtrlView:ctor(itemData)
	super(self, requireview(ViewPath.."popu.lobby.friendListCtrlView"))
	self.loadingNode = {}
	self.m_root:findChildByName("text_result_empty"):setText(Hall_string.str_friend_empty)
	self.view_empty = self.m_root:findChildByName("view_empty")
	EventDispatcher.getInstance():register(HttpModule.s_event, self, self.onPHPRequestsCallBack);
	EventDispatcher.getInstance():register(Event.Message, self, self.onMessageCallDone)
	-- HttpModule.getInstance():execute(HttpModule.s_cmds.GET_FRIENDS_LIST, {gameid = PhpManager:getGame()}, showLoading, true);
end

function friendListCtrlView:dtor()
	EventDispatcher.getInstance():unregister(HttpModule.s_event, self, self.onPHPRequestsCallBack);
	EventDispatcher.getInstance():unregister(Event.Message, self, self.onMessageCallDone);
end

function friendListCtrlView:onShowEnd()
	self:execHttpCmd(HttpModule.s_cmds.GET_FRIENDS_LIST, {gameid = PhpManager:getGame()}, true)
end

function friendListCtrlView:onGetFriendsList( isSuccess, data )
	JLog.d("friendListCtrlView:onGetFriendsList", isSuccess, data)
	if app:checkResponseOk(isSuccess, data) then
		self.friendsList = nil
		self.m_root:setAdapter(nil)
		self.view_empty:setVisible(true)
		if #(data.data.friendsList) ~= 0 then
			table.sort(data.data.friendsList, function (a, b)
				if a == nil then
					return false
				end
				if b == nil then
					return true
				end
				if a.isOnline ~= b.isOnline then
					if b.isOnline == 1 then
						return false;
					end
					return true;
				end
				if a.isOnlien == 1 and a.gameName ~= b.gameName then
					if b.gameName ~= nil and b.gameName > 0 then 
						return false
					end
					return true;
				end
				return false
			end)
			self.friendsList = data.data.friendsList
			self.m_root:setAdapter(new(CacheAdapter, friendItemView, data.data.friendsList))
			self.view_empty:setVisible(false)
		end
	end
end

function friendListCtrlView:onSendRecall(isSuccess, data)
	JLog.d("friendListCtrlView:onSendRecall", isSuccess, data)
	if app:checkResponseOk(isSuccess, data) then
		if data.data.addMoney then
			local money = tonumber(data.data.addMoney) or 0
			if money > 0 then
				MyUserData:addMoney(money, true)
			end
		end
		AlarmTip.play(data.codemsg or "")
		if self.friendsList then
			for i = 1, #self.friendsList do
				local friend = self.friendsList[i]
				if tonumber(friend.fid) == tonumber(data.data.fid) then
					friend.canSendRecall = 0
					self.m_root:getAdapter():updateData(i, friend)
					break
				end
			end
		end
	end
end

function friendListCtrlView:execHttpCmd(command, data, continueLast, isShowLoading, parentNode)
    for k, v in pairs(self.loadingNode) do
        v.node:stop()
    end
	
    HttpModule.getInstance():execute(command, data, true, continueLast)
    
    if isShowLoading or (isShowLoading == nil) then
        local loadingParent = parentNode or self.m_root
        --loading has exist
        if self.loadingNode[loadingParent] then
            self.loadingNode[loadingParent].command = command
            self.loadingNode[loadingParent].node:play()
        else
            local toastShadeBg = new(ToastShade,false)
            toastShadeBg:findChildByName("view_loading"):addPropScaleSolid(1, 0.8, 0.8, kCenterDrawing)
            self.loadingNode[loadingParent] = {}
            self.loadingNode[loadingParent].command = command
            self.loadingNode[loadingParent].node = toastShadeBg
            loadingParent:addChild(toastShadeBg)
            toastShadeBg:play()
        end
        
    end
end

function friendListCtrlView:onRequestCmd(command, data, continueLast, isShowLoading)
	self:execHttpCmd(command, data, continueLast, isShowLoading)
end

function friendListCtrlView:onMessageCallDone(param, ...)
	if self.messageFunMap[param] then
		self.messageFunMap[param](self,...)
	end
end

friendListCtrlView.messageFunMap = {
	["friendListCtrlView:requestCmd"] = friendListCtrlView.onRequestCmd,
}

----------------------------  config  --------------------------------------------------------
function friendListCtrlView:onPHPRequestsCallBack(command, ...)
    for k, v in pairs(self.loadingNode) do
        if v.command == command then
            (v.node):stop()
        end
    end
	if self.s_severCmdEventFuncMap[command] then
     	self.s_severCmdEventFuncMap[command](self,...)
	end 
end 

--[[
	通用的（大厅）协议
]]
friendListCtrlView.s_severCmdEventFuncMap = {
    [HttpModule.s_cmds.GET_FRIENDS_LIST] 	= friendListCtrlView.onGetFriendsList,
	[HttpModule.s_cmds.FRIEND_SEND_RECALL] = friendListCtrlView.onSendRecall,

}


return friendListCtrlView