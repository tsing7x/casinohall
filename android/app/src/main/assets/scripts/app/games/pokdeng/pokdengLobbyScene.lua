local Command = require("app.lobby.command")
local chooseRoomItemLayout = requireview("app.view.games.view.view_chooseRoom")
local PokdengLobbyScene = class(BaseScene)

local cIndex = 0
local function getIndex()
	cIndex = cIndex + 1
	return cIndex
end

local LOGIN_ERROR_CODE = {
	ERROR_TABLE_MAX_COUNT    	= 2,          --桌子人满
	ERROR_NOT_ENOUGH_MONEY   	= 3,          --钱太少
	ERROR_TOO_MUCH_MONEY	 	= 4,         --钱太多
	ERROR_WRONG_UID				= 5,          --无效的用户ID
	ERROR_TABLE_NOT_EXIST	 	= 6,          --桌子不存在
	ERROR_ANTE_MONEY         	= 7,		   --携带金额错误
	ERROR_SEAT_HAS_PLAYER	 	= 8,		   --座位上有人
}

PokdengLobbyScene.s_controls =
{
	retBtn = getIndex(),
	roomList = getIndex(),
	quickStartBtn = getIndex(),
	headBtn = getIndex(),
	headBg = getIndex(),
	headName = getIndex(),
	chipBtn = getIndex(),
	chipTxt = getIndex(),
	cashBtn = getIndex(),
	cashTxt = getIndex(),
}

PokdengLobbyScene.s_controlConfig = 
{
	[PokdengLobbyScene.s_controls.retBtn] 	= {"retBtn"},
	[PokdengLobbyScene.s_controls.roomList] 	= {"roomList"},
	[PokdengLobbyScene.s_controls.quickStartBtn] 	= {"quickStartBtn"},
	[PokdengLobbyScene.s_controls.headBtn] 	= {"headBtn"},
	[PokdengLobbyScene.s_controls.headBg] 	= {"headBtn", "headBg"},
	[PokdengLobbyScene.s_controls.headName] 	= {"headBtn", "headBg", "headName"},
	[PokdengLobbyScene.s_controls.chipBtn] 	= {"chipBtn"},
	[PokdengLobbyScene.s_controls.chipTxt] 	= {"chipBtn", "chipTxt"},
	[PokdengLobbyScene.s_controls.cashBtn] 	= {"cashBtn"},
	[PokdengLobbyScene.s_controls.cashTxt] 	= {"cashBtn", "cashTxt"},
}

function PokdengLobbyScene:ctor(viewConfig,controller, param)
	EventDispatcher.getInstance():register(HttpModule.s_event, self, self.onHttpRequestsCallBack);
	
	self.m_GameId = tonumber(param[1].gameId);

	--初始化socket
	self:initSocket()

	if self.m_GameId == tonumber(GAME_ID.PokdengCash) then 		
		self:createCashRoomList()
	else		
		self:createChipRoomList()
	end	

	--初始化底部信息
	self:initBottom()
end

function PokdengLobbyScene:pause()
	PokdengLobbyScene.super.pause(self)
end

function PokdengLobbyScene:resume(bundleData)
	self.super.resume(self,bundleData)
end

function PokdengLobbyScene:dtor()
	EventDispatcher.getInstance():unregister(HttpModule.s_event, self, self.onHttpRequestsCallBack);
end

function PokdengLobbyScene:onHttpRequestsCallBack(command, ...)
	if self.s_severCmdEventFuncMap[command] then
		self.s_severCmdEventFuncMap[command](self, ...)
	end
end

function PokdengLobbyScene:initSocket()
	self.m_reader		= new(require('app.lobby.command_reader'))
	self.m_writer		= new(require('app.lobby.command_writer'))
	self.m_processer 	= new(require('app.lobby.command_processer'),self)

	GameSocketMgr:addCommonSocketReader(self.m_reader);
	GameSocketMgr:addCommonSocketWriter(self.m_writer);
	GameSocketMgr:addCommonSocketProcesser(self.m_processer);
end

function PokdengLobbyScene:createCashRoomList()
	self:getControl(PokdengLobbyScene.s_controls.quickStartBtn):hide()

	local itemPos = {
		{x = 0, y = -250}, {x = 150, y = 370}, 
		{x = -150, y = 50}, {x = 150, y = 50}, 
		{x = -150, y = 350}
	}

	--增加创建房间按钮
	local roomList = self:getControl(PokdengLobbyScene.s_controls.roomList)
	local createRoomBtn = new(Button, "common/blank.png")
			:align(kAlignCenter)
			:addTo(roomList)
	local bg = new(Image, "popu/chooseRoom/img_create_room.png")
			:addTo(createRoomBtn)
			:align(kAlignCenter)
	local txt = new(Image, "popu/chooseRoom/img_create_room_txt.png")
			:pos(-120, 0)
			:addTo(createRoomBtn)
			:align(kAlignCenter)
	createRoomBtn:setOnClick(self,function()
		--创建现金币场
		JLog.d("onCreateCashRoomClick");
		if not MyRoomConfig:get(self.m_GameId) then
			if DEBUG_MODE then
				AlarmTip.play("PHP没有返回建房参数")
			end
			return
		end
		
		local callback = function(param)
			self:requestCreateRoom(param)
			WindowManager:closeWindowByTag(WindowTag.CreateRoomPopu)
		end
		WindowManager:showWindow(WindowTag.CreateRoomPopu, {gameId = self.m_GameId,createType ="cashType",callback = callback}, WindowStyle.POPUP)
	end)
	local w,h = bg:getSize()
	createRoomBtn:setSize(w,h)
	createRoomBtn:setPos(itemPos[1].x, itemPos[1].y)

	--增加根据密码查找房间按钮
	local findRoomBtn = new(Button, "common/blank.png")
			:align(kAlignCenter)
			:addTo(roomList)
	bg = new(Image, "popu/chooseRoom/img_find_room.png")
			:addTo(findRoomBtn)
			:align(kAlignCenter)
	txt = new(Image, "popu/chooseRoom/img_find_room_txt.png")
			:pos(0, 50)
			:addTo(findRoomBtn)
			:align(kAlignCenter)
	findRoomBtn:setOnClick(self,function()
		local callback = function(param)			
			JLog.d("PokdengLobbyScene:onEnterCashRoomClick callback", param);
			if param then
				WindowManager:closeWindowByTag(WindowTag.EnterRoomPopu)
				if param.enterType == "roomCode" then --通过房间code进房
					local codeParam = {};
					codeParam.gameid = param.gameid;
					codeParam.password = param.password;
					self:requestRoomByCode(codeParam)
				end
			end
		end
		WindowManager:showWindow(WindowTag.EnterRoomPopu, {gameId = tonumber(GAME_ID.PokdengCash),callback = callback}, WindowStyle.POPUP)
	end)
	local w,h = bg:getSize()
	findRoomBtn:setSize(w,h)
	findRoomBtn:setPos(itemPos[2].x, itemPos[2].y)

	local game 	= app:getGame(self.m_GameId)
	if game then
		local roomDataList 	= game:getRoomList()
		for i = 1, roomDataList and roomDataList:count() or 0 do 
			--创建列表项
			local item 	= SceneLoader.load(chooseRoomItemLayout)
			item:pos(itemPos[i + 2].x, itemPos[i + 2].y)
			roomList:addChild(item)

			--获取房间数据
			local roomData = roomDataList:get(i)
			item:findChildByName("bg"):setFile("popu/chooseRoom/img_poker_room" .. i .. ".png")

			--设置筹码显示值
			local baseAnte = tonumber(roomData:getAnte())
			if baseAnte < 10 then 
				item:findChildByName("numPic2"):setFile("popu/chooseRoom/img_num_" .. baseAnte .. ".png")

				item:findChildByName("numPic1"):setPos(53)
				item:findChildByName("numPic2"):setPos(106)
				item:findChildByName("numPic3"):setPos(159)
				item:findChildByName("numPic1"):hide()
				item:findChildByName("numPic3"):hide()
			else
				item:findChildByName("numPic1"):setFile("popu/chooseRoom/img_num_" .. baseAnte/10 .. ".png")
				item:findChildByName("numPic2"):setFile("popu/chooseRoom/img_num_" .. (baseAnte - 10) .. ".png")

				item:findChildByName("numPic1"):setPos(83)
				item:findChildByName("numPic2"):setPos(141)
				item:findChildByName("numPic3"):setPos(199)
				item:findChildByName("numPic1"):show()
				item:findChildByName("numPic2"):show()
				item:findChildByName("numPic3"):hide()
			end

			--设置筹码的最小最大要求
			item:findChildByName("minReqTxt"):setText(Hall_string.STR_MIN_LIMIT..ToolKit.formatAnteWithoutFloor(roomData:getMinChip()));
			item:findChildByName("maxReqTxt"):hide()--setText(Hall_string.STR_MAX_LIMIT..ToolKit.formatAnteWithoutFloor(roomData:getMaxChip()));

			--设置按钮的点击效果
			item:findChildByName("chooseRoomBtn"):setOnClick(self, function (self)
				local myMoney = MyUserData:getCashPoint()
				local content = nil
				if myMoney < roomData:getMinChip() then
					AlarmTip.play(string.format(Hall_string.STR_MONEY_LESS_THAN_ANTE, roomData:getMinChip()));	
				else
					local level = roomData:getLevel();
					self:requestRoomByLevel(self.m_GameId,level);
				end
			 end);
		end
	else
		JLog.d("获取不到"..self.m_gameId.." 的房间列表");
	end	
end

function PokdengLobbyScene:createChipRoomList()

	self:getControl(PokdengLobbyScene.s_controls.quickStartBtn):show()

	local itemPos = {
		{x = -150, y = -300}, {x = 150, y = -300}, 
		{x = -150, y = 0}, {x = 150, y = 0}, 
		{x = -150, y = 300}, {x = 150, y = 300},
	}

	local roomList = self:getControl(PokdengLobbyScene.s_controls.roomList)
	local game 	= app:getGame(self.m_GameId)
	if game then
		local roomDataList 	= game:getRoomList()
		for i = 1, roomDataList and roomDataList:count() or 0 do 
			--创建列表项
			local item 	= SceneLoader.load(chooseRoomItemLayout)
			item:pos(itemPos[i].x, itemPos[i].y)
			roomList:addChild(item)

			--获取房间数据
			local roomData = roomDataList:get(i)
			item:findChildByName("bg"):setFile("popu/chooseRoom/img_poker_room" .. i .. ".png")

			--设置筹码显示值
			local baseAnte = tonumber(roomData:getAnte())
			if baseAnte < 1000 then 
				item:findChildByName("numPic1"):setFile("popu/chooseRoom/img_num_" .. baseAnte/100 .. ".png")
				item:findChildByName("numPic2"):setFile("popu/chooseRoom/img_num_0.png")
				item:findChildByName("numPic3"):setFile("popu/chooseRoom/img_num_0.png")

				item:findChildByName("numPic1"):setPos(53)
				item:findChildByName("numPic2"):setPos(106)
				item:findChildByName("numPic3"):setPos(159)
				item:findChildByName("numPic3"):show()
			elseif baseAnte < 10000 then 
				item:findChildByName("numPic1"):setFile("popu/chooseRoom/img_num_" .. baseAnte/1000 .. ".png")
				item:findChildByName("numPic2"):setFile("popu/chooseRoom/img_num_k.png")

				item:findChildByName("numPic1"):setPos(83)
				item:findChildByName("numPic2"):setPos(141)
				item:findChildByName("numPic3"):setPos(199)
				item:findChildByName("numPic3"):hide()
			else
				item:findChildByName("numPic1"):setFile("popu/chooseRoom/img_num_" .. baseAnte/10000 .. ".png")
				item:findChildByName("numPic2"):setFile("popu/chooseRoom/img_num_0.png")
				item:findChildByName("numPic3"):setFile("popu/chooseRoom/img_num_k.png")

				item:findChildByName("numPic1"):setPos(58)
				item:findChildByName("numPic2"):setPos(106)
				item:findChildByName("numPic3"):setPos(159)
				item:findChildByName("numPic3"):show()
			end

			--设置筹码的最小最大要求
			item:findChildByName("minReqTxt"):setText(Hall_string.STR_MIN_LIMIT..ToolKit.formatAnteWithoutFloor(roomData:getMinChip()));
			item:findChildByName("maxReqTxt"):setText(Hall_string.STR_MAX_LIMIT..ToolKit.formatAnteWithoutFloor(roomData:getMaxChip()));

			--设置按钮的点击效果
			item:findChildByName("chooseRoomBtn"):setOnClick(self, function (self)
				local myMoney = MyUserData:getMoney()
				if myMoney < gBankrupt then
					WindowManager:showWindow(WindowTag.BankruptPopu, {state = 1, gameId = self.m_gameId, level = nil}, WindowStyle.POPUP)
				end
				local content = nil
				if myMoney < roomData:getMinChip() then
					AlarmTip.play(string.format(Hall_string.STR_MONEY_LESS_THAN_ANTE, roomData:getMinChip()));	
				else
					local level = roomData:getLevel();
					self:requestRoomByLevel(self.m_GameId,level);
				end
			end);
		end
	else
		JLog.d("获取不到"..self.m_gameId.." 的房间列表");
	end	
end

function PokdengLobbyScene:initBottom()
	--初始化头像
	if self.m_headImage then
		self.m_headImage:removeSelf()
		self.m_headImage = nil;
	end

    local headBg = self:getControl(PokdengLobbyScene.s_controls.headBg)
    local width, height = headBg:getSize()
    
    self.m_headImage = new(ImageMask, MyUserData:getHeadName(), "lobby/hall_avator_bg.png");
    self.m_headImage:setSize(width - 8, height - 8)
    self.m_headImage:setName("headImage")
    self.m_headImage:pos(4, 4)
    self.m_headImage:addTo(headBg)

	--初始化昵称、筹码、现金币
	self:getControl(PokdengLobbyScene.s_controls.headName):setText(MyUserData:getNick())
	self:getControl(PokdengLobbyScene.s_controls.chipTxt):setText(ToolKit.formatMoney(MyUserData:getMoney()))
	self:getControl(PokdengLobbyScene.s_controls.cashTxt):setText(MyUserData:getCashPoint())
end

function PokdengLobbyScene:showLoadingAnim(value)
	if value then
		JLog.d("显示loading！！！！！");

		local loadingStr = Hall_string.STR_LOGIN_LOADING
		app:showLoadingTip(loadingStr,true)
	else
		app:hideLoadingTip()
	end
end

--返回按钮点击
function PokdengLobbyScene:onRetBtnClick()
	StateChange.changeState(self.mStateFrom or States.Lobby,{},StateStyle.TRANSLATE_BACK)
end

--快速开始游戏按钮点击
function PokdengLobbyScene:onQuickStartBtnClick()
	local pokdengGame = app:getGame(self.m_GameId);
	if MyUserData:getMoney() < gBankrupt then
		WindowManager:showWindow(WindowTag.BankruptPopu, {state = 1, gameId = self.m_gameId, level = nil}, WindowStyle.POPUP)
	end

	if pokdengGame then
		JLog.d("exist this game!",gameId);
		local money = MyUserData:getMoney();
		local config = pokdengGame:getRoomFromMoney(money);
		if config then
			JLog.d("exist this room!");
			local gameId = GAME_ID.Casinohall;
			self:requestRoomByLevel(gameId,config:getLevel())
		else
			JLog.d("not exist this room!");
		end
	else
		JLog.d("not exist this game!",gameId);
	end
end

function PokdengLobbyScene:requestCreateRoom(param)
	self:showLoadingAnim(true)
	local userInfo = {appid = 0, nick = MyUserData:getNick(), sex = MyUserData:getSex(), micon = MyUserData:getHeadUrl(), giftId = MyUserData:getGiftId()}
	param.userInfo = json.encode(userInfo)
	JLog.d("PokdengLobbyScene:requestCreateRoom",param);
	GameSocketMgr:sendMsg(Command.CREATE_PRIVATEROOM_REQ, param)
end

function PokdengLobbyScene:requestRoomByLevel(gameId,level)
	self:showLoadingAnim(true)
	JLog.d("LobbyScene:requestRoomByLevel gameId", gameId, "level", level);
	if not level then return end
	local userInfo = {appid = 0, nick = MyUserData:getNick(), sex = MyUserData:getSex(), micon = MyUserData:getHeadUrl() or "", giftId = MyUserData:getGiftId()}
	GameSocketMgr:sendMsg(Command.RANDOM_ENTER_PRIVATEROOM_ERQ,{gameid=tonumber(gameId),level = level,userInfo=json.encode(userInfo), is_reconnect = 0})
end

function PokdengLobbyScene:requestRoomByCode(param)
	self:showLoadingAnim(true)
	local userInfo = {appid = 0, nick = MyUserData:getNick(), sex = MyUserData:getSex(), micon = MyUserData:getHeadUrl(), giftId = MyUserData:getGiftId()}
	param.userInfo = json.encode(userInfo)
	JLog.d("PokdengLobbyScene:requestRoomByCode",param);
	GameSocketMgr:sendMsg(Command.ENTER_PRIVATEROOM_ERQ, param)
end

function PokdengLobbyScene:onEnterRoom(data)
	self:showLoadingAnim(false)

	--进房出错
	if data.reason==0 then
	else
		if data.reason==1 then --创建房间进来的
			WindowManager:closeWindowByTag(WindowTag.CreateRoomPopu)
		elseif data.reason==2 then --输入房号进来的
			WindowManager:closeWindowByTag(WindowTag.EnterRoomPopu)
		end		

		--将当前游戏id存储至全局
		G_CUR_GAME_ID = data.gameId

		local pokdengGame = app:getGame(tonumber(data.gameId));
		if pokdengGame then
			local config = pokdengGame:getRoomFromLevel(data.level);
			if config then
				JLog.d("onEnterRoom:exist this room!");
			else
				JLog.d("onEnterRoom:not exist this room!");
			end

			if data.tableId == -1 then
				AlarmTip.play(Hall_string.str_tbId_error)
			else
				pokdengGame:enterRoomWithData({gameId = data.gameId, level = data.level, config=config,roomCode = data.roomCode, enterType=data.reason, tableId = data.tableId});
			end			
		else
			JLog.d("onEnterRoom:not exist this game!",data.gameId);
		end
	end	
end

function PokdengLobbyScene:onLoginError(data)
	JLog.d("LobbyScene:onLoginError.data :===============", data)
	if DEBUG_MODE then
		AlarmTip.play("code = "..data.errCode)
	end
	self:showLoadingAnim(false)
	if data.errCode then
		if data.errCode == LOGIN_ERROR_CODE.ERROR_TABLE_MAX_COUNT then --2
			AlarmTip.play(Hall_string.STR_TABLE_LIMITED)
		elseif data.errCode == LOGIN_ERROR_CODE.ERROR_NOT_ENOUGH_MONEY then--3
			AlarmTip.play(Hall_string.STR_MONEY_NOT_ENOUGH)
		elseif data.errCode == LOGIN_ERROR_CODE.ERROR_TOO_MUCH_MONEY 
			or data.errCode == LOGIN_ERROR_CODE.ERROR_ANTE_MONEY then--4 or 7
			AlarmTip.play(Hall_string.STR_TOO_MUCH_MONEY)
		elseif data.errCode == LOGIN_ERROR_CODE.ERROR_WRONG_UID 
			or data.errCode == LOGIN_ERROR_CODE.ERROR_TABLE_NOT_EXIST then --5 or 6
			AlarmTip.play(Hall_string.STR_SITDOWN_FAILED)
		elseif data.errCode == LOGIN_ERROR_CODE.ERROR_SEAT_HAS_PLAYER then
			AlarmTip.play(Hall_string.STR_SEAT_ROBBED)
		else
			AlarmTip.play("onLoginError:"..data.errCode)
		end
	end
end

function PokdengLobbyScene:onHeadBtnClick()
	WindowManager:showWindow(WindowTag.UserInfoPopu, {singleBtn=true,text="uid="..MyUserData:getId()}, WindowStyle.TRANSLATE_RIGHT)
end

function PokdengLobbyScene:onChipBtnClick()
	WindowManager:showWindow(WindowTag.ShopPopu, {}, WindowStyle.TRANSLATE_RIGHT)
end

function PokdengLobbyScene:onCashBtnClick()
	WindowManager:showWindow(WindowTag.ShopPopu, {tab = 2}, WindowStyle.TRANSLATE_RIGHT)
end

function PokdengLobbyScene:onBack()
	-- JLog.d("LobbyScene:onBack",WindowManager:onKeyBack());
	if WindowManager and not WindowManager:onKeyBack() then
	end
end

PokdengLobbyScene.s_controlFuncMap =
{
	[PokdengLobbyScene.s_controls.retBtn] = PokdengLobbyScene.onRetBtnClick;
	[PokdengLobbyScene.s_controls.quickStartBtn] = PokdengLobbyScene.onQuickStartBtnClick;
	[PokdengLobbyScene.s_controls.headBtn] = PokdengLobbyScene.onHeadBtnClick;
	[PokdengLobbyScene.s_controls.chipBtn] = PokdengLobbyScene.onChipBtnClick;
	[PokdengLobbyScene.s_controls.cashBtn] = PokdengLobbyScene.onCashBtnClick;
}

PokdengLobbyScene.s_severCmdEventFuncMap = {
}

return PokdengLobbyScene
