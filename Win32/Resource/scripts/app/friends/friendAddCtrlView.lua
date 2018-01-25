local friendAddCtrlView = class(BaseLayer, false)

local friendReqItemView = class(BaseLayer, false)

function friendReqItemView:ctor(data)
	super(self, requireview(ViewPath..'popu.lobby.friendReqItem'))
	self:setSize(self.m_root:getSize())
	self.data = data

	local imgData = setProxy(new(require("app.data.imgData")))
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
	UIEx.bind(self, imgData, "imgName", function(value)
		local img = nil
		if imgData:checkImg() then
			img = imgData:getImgName()
		else
			img = data.msex == 2 and "popu/friends/avatar_female.png" or "popu/friends/avatar_male.png"
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

	local text_name = self.m_root:findChildByName("text_name")
	text_name:setText(data.name)
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
	self.m_root:findChildByName("btn_ok"):setOnClick(self, function ()
		-- self:execHttpCmd(HttpModule.s_cmds.FRIEND_ACCEPT,{fid = data.fid, isagree = 1}, false)
		EventDispatcher.getInstance():dispatch(Event.Message, "friendAddCtrlView:requestCmd", HttpModule.s_cmds.FRIEND_ACCEPT,{fid = data.fid, isagree = 1}, false);
		-- HttpModule.getInstance():execute(HttpModule.s_cmds.FRIEND_ACCEPT,{fid = data.fid, isagree = 1}, true, false)
	end)
	self.m_root:findChildByName("btn_refuse"):setOnClick(self, function ()
		-- self:execHttpCmd(HttpModule.s_cmds.FRIEND_REFUSE,{fid = data.fid, isagree = 0}, false)
		EventDispatcher.getInstance():dispatch(Event.Message, "friendAddCtrlView:requestCmd", HttpModule.s_cmds.FRIEND_REFUSE,{fid = data.fid, isagree = 0}, false);
		-- HttpModule.getInstance():execute(HttpModule.s_cmds.FRIEND_REFUSE,{fid = data.fid, isagree = 0}, true, false)
	end)
end

local friendSearchItemView = class(BaseLayer, false)

function friendSearchItemView:ctor(data)
	super(self, requireview(ViewPath..'popu.lobby.friendSearchItem'))
	JLog.d("friendSearchItemView", data)
	self:setSize(self.m_root:getSize())
	self.data = data

	local imgData = setProxy(new(require("app.data.imgData")))
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
	UIEx.bind(self, imgData, "imgName", function(value)
		local img = nil
		if imgData:checkImg() then
			img = imgData:getImgName()
		else
			img = data.msex == 2 and "popu/friends/avatar_female.png" or "popu/friends/avatar_male.png"
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

	local text_name = self.m_root:findChildByName("text_name")
	text_name:setText(data.name)
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
	self.m_root:findChildByName("btn_requst"):setOnClick(self, function ()
		-- self:execHttpCmd(HttpModule.s_cmds.ADD_FRIEND, {fid = self.data.fid, content = "", isroom = 0}, true)
		EventDispatcher.getInstance():dispatch(Event.Message, "friendAddCtrlView:requestCmd", HttpModule.s_cmds.ADD_FRIEND, {fid = self.data.fid, content = "", isroom = 0}, true);
		-- HttpModule.getInstance():execute(HttpModule.s_cmds.ADD_FRIEND, {fid = self.data.fid, content = "", isroom = 0}, false, true);
	end)
end

function friendAddCtrlView:ctor(itemData)
	super(self, requireview(ViewPath.."popu.lobby.friendAddCtrlView"))
	self.loadingNode = {}
	EventDispatcher.getInstance():register(HttpModule.s_event, self, self.onPHPRequestsCallBack);
	EventDispatcher.getInstance():register(Event.Message, self, self.onMessageCallDone)

	-- HttpModule.getInstance():execute(HttpModule.s_cmds.APPLY_ADD_FRIENDS_LIST, {gameid = PhpManager:getGame()}, false, true);
	
	self.m_root:findChildByName("text_request_empty"):setText(Hall_string.str_friend_request_empty)
	-- self.m_root:findChildByName("text_result_empty"):setText(Hall_string.str_friend_result_empty)
	self.et_id = self.m_root:findChildByName("et_id")
	self.et_id:setHintText(Hall_string.str_friend_input_id_hint)
	self.m_root:findChildByName("text_request"):setText(Hall_string.str_friend_request)
	self.btn_search = self.m_root:findChildByName("btn_search")
	self.btn_cancel = self.m_root:findChildByName("btn_cancel")
	self.view_request = self.m_root:findChildByName("view_request")
	self.view_result = self.m_root:findChildByName("view_result")
	self.listview_request = self.m_root:findChildByName("listview_request")
	self.listview_result = self.m_root:findChildByName("listview_result")
	self.view_request_empty = self.m_root:findChildByName("view_request_empty")
	-- self.view_result_empty = self.m_root:findChildByName("view_result_empty")

	self.btn_search:setOnClick(self, self.searchClick)
	self.btn_cancel:setOnClick(self, self.searchCancelClick)

	UIEx.bind(self, MyUserData, "unreadApply", function (value)
		self:onChangeData()
	end)
end

function friendAddCtrlView:dtor()
	EventDispatcher.getInstance():unregister(HttpModule.s_event, self, self.onPHPRequestsCallBack);
	EventDispatcher.getInstance():unregister(Event.Message, self, self.onMessageCallDone);
end

function friendAddCtrlView:onShowEnd()
	self:execHttpCmd(HttpModule.s_cmds.APPLY_ADD_FRIENDS_LIST, {gameid = PhpManager:getGame()}, true)	
end

function friendAddCtrlView:searchCancelClick()
	self.view_request:setVisible(true)
	self.view_result:setVisible(false)
	self.btn_search:setVisible(true)
	self.btn_cancel:setVisible(false)
	self.listview_result:setAdapter(nil)
	self.et_id:setText("")
end

function friendAddCtrlView:searchClick()
	local text = self.et_id:getText()
	if text == nil or #text == 0 then
		AlarmTip.play(Hall_string.str_friend_input_id_hint)
		return
	end
	-- self.view_request:setVisible(false)
	-- self.view_result:setVisible(true)
	-- self.text_search:setText(Hall_string.str_cancel)
	self:execHttpCmd(HttpModule.s_cmds.SEARCH_FRIEND, {userid = text, gameid = PhpManager:getGame()}, true)
	-- HttpModule.getInstance():execute(HttpModule.s_cmds.SEARCH_FRIEND, {userid = text, gameid = PhpManager:getGame()}, true, true);
end

function friendAddCtrlView:onChangeData()
	if MyUserData:getUnreadApply() > 0 then
		JLog.d("new Friend Data")
		self:execHttpCmd(HttpModule.s_cmds.APPLY_ADD_FRIENDS_LIST, {gameid = PhpManager:getGame()}, true)
	else
		JLog.d("not Friend Data")
		self.applyAddFriends = nil
		self.listview_request:setAdapter(nil)
		self.view_request_empty:setVisible(true)
	end
end

function friendAddCtrlView:onApplyAddFriendsList(isSuccess, data)
	if app:checkResponseOk(isSuccess, data) then
		self.applyAddFriends = nil
		if #data.data ~= 0 then
			self.applyAddFriends = data.data
			self.listview_request:setAdapter(new(CacheAdapter, friendReqItemView, data.data))
			self.view_request_empty:setVisible(false)
		else
			self.listview_request:setAdapter(nil)
			self.view_request_empty:setVisible(true)
		end
	end
end

function friendAddCtrlView:onSearchFriend(isSuccess, data)
	-- JLog.d("friendAddCtrlView:onSearchFriend", isSuccess, data)
	if app:checkResponseOk(isSuccess, data) then
		if data.data then
			self.view_request:setVisible(false)
			self.view_result:setVisible(true)
			self.btn_search:setVisible(false)
			self.btn_cancel:setVisible(true)
			self.listview_result:setAdapter(new(CacheAdapter, friendSearchItemView, {data.data}))
			-- self.view_result_empty:setVisible(false)
			return
		end
	end
	AlarmTip.play(Hall_string.str_friend_result_empty)
	self.listview_result:setAdapter(nil)
	-- self.view_result_empty:setVisible(true)
end

function friendAddCtrlView:searchFriendIndex(list, fid)
	for i,item in ipairs(list) do
		if item.fid == fid then
			return i
		end
	end
	return -1
end

function friendAddCtrlView:onFriendAccept(isSuccess, data)
	if app:checkResponseOk(isSuccess, data) then
		local value = MyUserData:getUnreadApply() - 1
		if value < 0 then
			value = 0
		end
		MyUserData:setUnreadApply(value);
		HttpModule.getInstance():execute(HttpModule.s_cmds.GET_FRIENDS_LIST, {gameid = PhpManager:getGame()}, true, true)
		-- if self.applyAddFriends then
		-- 	local deleteIndex = self:searchFriendIndex(self.applyAddFriends, data.data.fid)
		-- 	if deleteIndex ~= -1 then
		-- 		table.remove(self.applyAddFriends, deleteIndex)
		-- 		if #self.applyAddFriends > 0 then
		-- 			self.listview_request:setAdapter(new(CacheAdapter, friendReqItemView, self.applyAddFriends))
		-- 		else
		-- 			self.listview_request:setAdapter(nil)
		-- 		end
		-- 	end
		-- end
	else
		--失败
		-- 1：成功 -3:自己达到好友上限 -4:好友达到好友上限 -5:已经是好友 -6,-7,-8,-9:插入数据库错误
		local code = data and data.code or 0
		local errText = {
			[-3] = Hall_string.STR_MY_FRIEND_COUNT_LIMIT,
			[-4] = Hall_string.STR_YOUR_FRIEND_COUNT_LIMIT,
			[-5] = Hall_string.STR_BE_FRIEND_ALREADY,
			[-6] = Hall_string.STR_SERVER_ERROR,
			[-7] = Hall_string.STR_SERVER_ERROR,
			[-8] = Hall_string.STR_SERVER_ERROR,
			[-9] = Hall_string.STR_SERVER_ERROR,
			[0] = Hall_string.STR_UNKNOWN_ERROR,
		}
		AlarmTip.play(errText[code or 0])
	end
end

function friendAddCtrlView:onFriendRefuse(isSuccess, data)
	if app:checkResponseOk(isSuccess, data) then
		local value = MyUserData:getUnreadApply() - 1
		if value < 0 then
			value = 0
		end
		MyUserData:setUnreadApply(value);
		-- self:execHttpCmd(HttpModule.s_cmds.APPLY_ADD_FRIENDS_LIST, {gameid = PhpManager:getGame()}, true)
		-- HttpModule.getInstance():execute(HttpModule.s_cmds.APPLY_ADD_FRIENDS_LIST, {gameid = PhpManager:getGame()}, false, true);
	else
		--失败
		-- 1：成功 -3:自己达到好友上限 -4:好友达到好友上限 -5:已经是好友 -6,-7,-8,-9:插入数据库错误
		local code = data and data.code or 0
		local errText = {
			[-3] = Hall_string.STR_MY_FRIEND_COUNT_LIMIT,
			[-4] = Hall_string.STR_YOUR_FRIEND_COUNT_LIMIT,
			[-5] = Hall_string.STR_BE_FRIEND_ALREADY,
			[-6] = Hall_string.STR_SERVER_ERROR,
			[-7] = Hall_string.STR_SERVER_ERROR,
			[-8] = Hall_string.STR_SERVER_ERROR,
			[-9] = Hall_string.STR_SERVER_ERROR,
			[0] = Hall_string.STR_UNKNOWN_ERROR,
		}
		AlarmTip.play(errText[code or 0])
	end
end

function friendAddCtrlView:execHttpCmd(command, data, continueLast, isShowLoading, parentNode)
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

function friendAddCtrlView:onRequestCmd(command, data, continueLast, isShowLoading)
	self:execHttpCmd(command, data, continueLast, isShowLoading)
end

function friendAddCtrlView:onMessageCallDone(param, ...)
	if self.messageFunMap[param] then
		self.messageFunMap[param](self,...)
	end
end

friendAddCtrlView.messageFunMap = {
	["friendAddCtrlView:requestCmd"] = friendAddCtrlView.onRequestCmd,
}

----------------------------  config  --------------------------------------------------------
function friendAddCtrlView:onPHPRequestsCallBack(command, ...)
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
friendAddCtrlView.s_severCmdEventFuncMap = {
    [HttpModule.s_cmds.APPLY_ADD_FRIENDS_LIST] 	= friendAddCtrlView.onApplyAddFriendsList,
    [HttpModule.s_cmds.SEARCH_FRIEND] 	= friendAddCtrlView.onSearchFriend,
    [HttpModule.s_cmds.FRIEND_ACCEPT] 	= friendAddCtrlView.onFriendAccept,
    [HttpModule.s_cmds.FRIEND_REFUSE] 	= friendAddCtrlView.onFriendRefuse,
}

return friendAddCtrlView