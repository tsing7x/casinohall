local RoomPlayerInfoPopu = class(require("app.popu.gameWindow"))
function RoomPlayerInfoPopu:ctor(viewConfig, data)
	EventDispatcher.getInstance():register(HttpModule.s_event, self, self.onHttpRequestsCallBack);
	EventDispatcher.getInstance():register(Event.Message, self, self.onMessageCallDone)
	self.playerInfo = data.player
	self.curPlayerData = nil
	self.seatId = data.seatId or 0
	local player = self.playerInfo
	if player:getId() == MyUserData:getId() then
		self.curPlayerData = self:initDataForSelf()
		--是他人的信息，用房间内的个人信息先初始化
	else
		self.curPlayerData = self:initDataForOther(player)
	end
	--制造好了数据，初始化页面，再请求php，有数据后再刷新数据
	self:initViewAfterGetData()
	self:execHttpCmd(HttpModule.s_cmds.GET_OTHER_FORM_FRIEND, {fid = player:getId()}, false, false)
end

function RoomPlayerInfoPopu:dtor()
	EventDispatcher.getInstance():unregister(HttpModule.s_event, self, self.onHttpRequestsCallBack);
	EventDispatcher.getInstance():unregister(Event.Message, self, self.onMessageCallDone)
end

function RoomPlayerInfoPopu:initViewAfterGetData()
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
	-- player:setSex(player:getSex())
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

	local headView = viewPlayer:findChildByName("img_head");
	local imgData = setProxy(new(require("app.data.imgData")))
	UIEx.bind(self, imgData, "imgName", function(value)
		if imgData:checkImg() then
			imgStr = imgData:getImgName()
		else
			imgStr = playerData:getSex() == 0 and "common/male.png" or "common/female.png"
		end
		headView:removeAllChildren();
		local width, height = headView:getSize()
		local imgHead = new(ImageMask, imgStr, "room/userInfo/img_headBg.png")
				:addTo(headView)
				:size(width-8, height-8)
				:pos(4,4)
    end)
	UIEx.bind(
		self,
		playerData,
		"headUrl",
		function(value)
			imgData:setImgUrl(value)
		end)
	imgData:setImgUrl(playerData:getHeadUrl())

	UIEx.bind(self, player, "level", function(value)
		viewPlayer:findChildByName("text_lv"):setText('LV.'..value)
	end)
	UIEx.bind(self, player, "canSendApply", function(value)
		local btnAdd = self:findChildByName("btn_addfriend")
		local btnNotAdd = self:findChildByName("img_notAddFriend")
		if player:getId() == MyUserData:getId() or value == 0 then
			btnAdd:setVisible(false)
			btnNotAdd:setVisible(true)
		else
			btnAdd:setVisible(true)
			btnNotAdd:setVisible(false)
		end
	end)
	player:setId(player:getId())
	player:setMoney(player:getMoney())
	player:setName(player:getName())
	player:setSex(player:getSex())
	player:setHeadUrl(player:getHeadUrl());
	player:setCanSendApply(player:getCanSendApply())
	player:setLevel(player:getLevel())
	player:setCashPoint(player:getCashPoint())

	self:findChildByName("btn_addfriend"):setOnClick(self, function ( self )
		HttpModule.getInstance():execute(HttpModule.s_cmds.ADD_FRIEND,{isroom = 1, fid = player:getId(), content = base64.encode(json.encode({
			id   = MyUserData:getId(),
			name = MyUserData:getNick()
		}))}, false, false)
		player:setCanSendApply(0)
	end)
	self:initLevel()
	self:initPropView()
end

function RoomPlayerInfoPopu:initLevel()
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
    local minLen = 5
    progress:setSize(minLen + (maxLen - minLen) * percent / 100, 13)
end



function RoomPlayerInfoPopu:initPropView()
	local player = self.curPlayerData
	local btnName = {
		[1] = 'btn_egg',
		[2] = 'btn_pouwater',
		[3] = 'btn_rose',
		[4] = 'btn_kiss',
		[5] = 'btn_beer',
		[6] = 'btn_tomoto',
		[7] = 'btn_dog',
		[8] = 'btn_harmmer',
		[9] = 'btn_bom',
		[10] = 'btn_tissue',
	}
	for i, v in pairs(btnName) do
		self:findChildByName(btnName[i]):setOnClick(self, function ( self )
			local count = MyUserData:getPropNum(kIDInteractiveProp)
			self:findChildByName(btnName[i]):setEnable(true)
			if self.seatId <= 0 then
				AlarmTip.play('ขอโทษค่ะ กรุณานั่งลงก่อนส่งไอเทมค่ะ');
				return
			end
			if count > 0 then
				HttpModule.getInstance():execute(HttpModule.s_cmds.GET_SEND_PROP,{id=2000+i,fid=player:getId()}, false, true);
				self:findChildByName(btnName[i]):setEnable(false)
				self:dismiss();
			else
				WindowManager:showWindow(WindowTag.MessageBox, {
					leftText="ยกเลิก",
					text = "ขอโทษค่ะ ไอเทมของคุณใช้หมดแล้ว",
					rightText="ซื้อ",
					rightFunc=function()
			    	WindowManager:showWindow(WindowTag.ShopPopu, {tab=3}, WindowStyle.TRANSLATE_RIGHT)
			    end}, WindowStyle.POPUP)
				self:dismiss(true)
			end
		end);
	end
end

--加好友
function RoomPlayerInfoPopu:onAddFriend(issuccess,data)
	if issuccess and data and data.code == 1 then
		self:dismiss()
	else
		self:findChildByName("btn_addfriend"):setVisible(true)
		self:findChildByName("img_notAddFriend"):setVisible(false)
	end
end

--HTTP回调
function RoomPlayerInfoPopu:onHttpRequestsCallBack(command, ...)
	if self.s_httpEventFuncMap[command] then
		self.s_httpEventFuncMap[command](self,...)
	end
end

function RoomPlayerInfoPopu:onGetFriendInfo(isSuccess, data)
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

function RoomPlayerInfoPopu:initDataForSelf()
	local playerInfo = setProxy(new(require("app.data.playerInfoData")))
	playerInfo:setId(MyUserData:getId())
	playerInfo:setName(MyUserData:getNick())
	playerInfo:setMoney(MyUserData:getMoney())
	playerInfo:setLevel(MyUserData:getLevel())
	playerInfo:setSex(MyUserData:getSex())
	playerInfo:setHeadUrl(MyUserData:getHeadUrl())
	playerInfo:setGiftId(MyUserData:getGiftId() and {MyUserData:getGiftId()[1], MyUserData:getGiftId()[2]})
	playerInfo:setCanSendApply(0)
	playerInfo:setWintimes(-1)
	playerInfo:setExp(MyUserData:getExp())
	playerInfo:setCashPoint(MyUserData:getCashPoint())
	return playerInfo
end

function RoomPlayerInfoPopu:initDataForOther(player)
	local playerInfo = setProxy(new(require("app.data.playerInfoData")))
	playerInfo:setId(player:getId())
	playerInfo:setName(player:getNick())
	playerInfo:setMoney(player:getChip())
	playerInfo:setSex(player:getSex())
	playerInfo:setHeadUrl(player:getHeadUrl())
	playerInfo:setLevel("...")
	playerInfo:setWintimes(-1)
	playerInfo:setCanSendApply(0)
	playerInfo:setGiftId(player.giftId and {player:getGiftId()[1], player:getGiftId()[2]})
	playerInfo:setExp(0)
	playerInfo:setCashPoint(0)
	return playerInfo
end

--Http响应
RoomPlayerInfoPopu.s_httpEventFuncMap = {
	[HttpModule.s_cmds.GET_SEND_PROP]        = RoomPlayerInfoPopu.onSendProp,
	[HttpModule.s_cmds.ADD_FRIEND]           = RoomPlayerInfoPopu.onAddFriend,
	[HttpModule.s_cmds.GET_OTHER_FORM_FRIEND]   = RoomPlayerInfoPopu.onGetFriendInfo,
}

return RoomPlayerInfoPopu
