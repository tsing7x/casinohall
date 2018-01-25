local FriendInfoPopu = class(require("app.popu.gameWindow"))
function FriendInfoPopu:ctor(viewConfig, data)
	EventDispatcher.getInstance():register(HttpModule.s_event, self, self.onHttpRequestsCallBack);
	EventDispatcher.getInstance():register(Event.Message, self, self.onMessageCallDone)
	--首先初步初始化	
	self.curPlayerData = self:initDataForOther(data)

	self:initViewAfterGetData()
	self:execHttpCmd(HttpModule.s_cmds.GET_OTHER_FORM_FRIEND, {fid = data.fid }, false, false)
end

function FriendInfoPopu:dtor()
	EventDispatcher.getInstance():unregister(HttpModule.s_event, self, self.onHttpRequestsCallBack);
	EventDispatcher.getInstance():unregister(Event.Message, self, self.onMessageCallDone)
end

function FriendInfoPopu:initViewAfterGetData()
	local player     = self.curPlayerData
	local viewPlayer = self:findChildByName("view_top")
	UIEx.bind(self, player, "money", function(value)
		viewPlayer:findChildByName('text_chip'):setText(ToolKit.skipMoney(value))
	end)

	UIEx.bind(self,player,"cashPoint",function ( value )
		viewPlayer:findChildByName('text_goldCoin'):setText(ToolKit.skipMoney(value))
	end)

	local maxLen = viewPlayer:findChildByName("view_nick"):getSize() - viewPlayer:findChildByName("img_male"):getSize()-2
	UIEx.bind(self, player, "name", function(value)
		ToolKit.formatTextLength(value, viewPlayer:findChildByName('text_name'), maxLen)
	end)
	UIEx.bind(self, player, "sex", function(value)
		if value == 0 then
			viewPlayer:findChildByName("img_male"):setVisible(true)
			viewPlayer:findChildByName("img_female"):setVisible(false)
		else
			viewPlayer:findChildByName("img_male"):setVisible(false)
			viewPlayer:findChildByName("img_female"):setVisible(true)
		end
	end)

	UIEx.bind(self, player, "id", function(value)
		if value == 0 then
			self:dismiss();
		else
			viewPlayer:findChildByName('text_id'):setText('ID:'..value);
		end
	end)

	UIEx.bind(self, player, "headName", function(value)
		local headView = viewPlayer:findChildByName("img_head");--view_phead
		headView:removeAllChildren();
		local width, height = headView:getSize()
		headView:setSize(width,height)
		local imgHead     = new(ImageMask, value, "room/userInfo/img_headBg.png");
		imgHead:setSize(width, height)
		headView:addChild(imgHead)
		player:checkHeadAndDownload()
	end)

	UIEx.bind(self, player, "level", function(value)
		viewPlayer:findChildByName("text_lv"):setText('LV.'..value)
	end)
	player:setId(player:getId())
	player:setMoney(player:getMoney())
	player:setName(player:getName())
	player:setSex(player:getSex())
	player:setHeadUrl(player:getHeadUrl());
	player:setLevel(player:getLevel())
	player:setCashPoint(player:getCashPoint())

	self:findChildByName("btn_delfriend"):setOnClick(self, function ( self )
    	HttpModule.getInstance():execute(HttpModule.s_cmds.FRIEND_DELETE, {fid=player:getId()}, false, true)
	end)
	-- self:initLevel()
end


function FriendInfoPopu:initLevel()
	local player = self.curPlayerData
	local lv = tonumber(player:getLevel())
    local exp = tonumber(player:getExp()) 
    local percent = 0
	if lv then
		local index = tonumber(lv)
		if index > 0 and index < 60 then
			local x1 = userLevelExp[index].x1 
			local x2 = userLevelExp[index].x2
			if exp > x1 then
				percent = math.ceil(((exp - x1)/(x2 - x1))*100)
				if percent >= 100 then
					percent = 99
				end
			end
		elseif index == 60 then
			percent = 99
		end
	end
    local progress = self:findChildByName("img_progress")
    --经验的底图和背景一起，写死长度
    local maxLen = 212
    local minLen = progress:getSize()
    progress:setSize(minLen + (maxLen - minLen) * percent / 100, 13)
end




--加好友
function FriendInfoPopu:onDelFriend(isSuccess , data)
	if app:checkResponseOk(isSuccess, data) then
		if data.code == 1 then
		AlarmTip.play("ลบเพื่อนสำเร็จ")
		HttpModule.getInstance():execute(HttpModule.s_cmds.GET_FRIENDS_LIST, {gameid = PhpManager:getGame()}, true, true)
		self:dismiss()
		else
		AlarmTip.play("ลบเพื่อนล้มเหลว")
		self:dismiss()
		end
	else
		AlarmTip.play('ลบเพื่อนล้มเหลว');
	end
end

--HTTP回调
function FriendInfoPopu:onHttpRequestsCallBack(command, ...)
	if self.s_httpEventFuncMap[command] then
		self.s_httpEventFuncMap[command](self,...)
	end
end

function FriendInfoPopu:onGetFriendInfo(isSuccess, data)
	dump(data)
	if app:checkResponseOk(isSuccess, data) then
		if self.curPlayerData then
			self.curPlayerData:init(data.data)
			self:initLevel()
		end
	else
		AlarmTip.play('wrong');
	end
end

function FriendInfoPopu:initDataForOther(data)
	local playerInfo = setProxy(new(require("app.data.playerInfoData")))
	playerInfo:setId(data.fid)
	playerInfo:setName(data.name)
	playerInfo:setMoney(data.money)
	playerInfo:setSex(data.msex)
	playerInfo:setHeadUrl(data.micon)
	playerInfo:setLevel(data.level)
	playerInfo:setExp(0)
	playerInfo:setCashPoint(0)
	return playerInfo
end

--Http响应
FriendInfoPopu.s_httpEventFuncMap = {
	[HttpModule.s_cmds.FRIEND_DELETE]           = FriendInfoPopu.onDelFriend,
	[HttpModule.s_cmds.GET_OTHER_FORM_FRIEND]   = FriendInfoPopu.onGetFriendInfo,
}

return FriendInfoPopu
