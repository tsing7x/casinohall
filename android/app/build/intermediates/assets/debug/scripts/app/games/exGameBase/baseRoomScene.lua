local AnimChat = require("app.animation/animChat")
local AnimFace = require("app.animation.animFace")
local AnimationFriend 		= require('app.animation.friendsAnim.animationFriend')

local Room_string = require("app.games.pokdeng.res.config")
local Command = require("app.games.exGameBase.commonProtocol")
local BaseRoomScene = class(BaseScene)
local FaceConfig = require("app.room.chat.faceConfig")

local SIT_ERROR_CODE = 
{	
	UNKNOWN_ERR= 300,
	SIT_AREADY_SEAT= 200,--已经坐下了
	SIT_UPBANKER_CANT_REQ_SEAT= 201,--庄家不需要自己点坐下
	SIT_NOT_EXIST= 202,--桌位不存在
	SIT_AREADY_HAS_USER= 203,--座位已经有人
	SIT_MONEY_NOT_ENOUGH= 204,--钱太少
	SIT_MONEY_TOO_MUCH= 205,--钱太多
}

local STANDUP_REASON = 
{
	STANDUP_BY_MYSELF = 1,--主动站起
	MONEY_NOT_ENOUGH = 2,--钱不够
	TRUSTEE_TOO_LONG = 3,--托管被站起
}

local cIndex = 0
local function getIndex()
	cIndex = cIndex + 1
	return cIndex
end
local EXIT_TYPE =
{
	NORMAL    = 0;--正常退出
	GO_LOW    = 1;--去低级场
	CHANGE    = 2;--换桌
}

function BaseRoomScene:ctor(viewConfig,controller)
	self:_initMaps()
	self:addEventListeners()
	EventDispatcher.getInstance():register(HttpModule.s_event, self, self.onHttpRequestsCallBack);
	EventDispatcher.getInstance():register(Event.onEventResume,self,self.onEventResume);
	EventDispatcher.getInstance():register(Event.onEventPause,self,self.onEventPause);
    EventDispatcher.getInstance():register(Event.Call, self, self.onNativeCallBack)

	self:initProtocol()
	self:initView()
	self.mAnimFriend = new(AnimationFriend, self)
	self.exitRoomType = EXIT_TYPE.NORMAL;--0
	JLog.d("BaseRoomScene ctor");
end

function BaseRoomScene:initProtocol()
	error("Derived class must implement this function")
end

function BaseRoomScene:resume(bundleData)
	BaseRoomScene.super.resume(self,bundleData)
	local config = bundleData and bundleData.config --建房参数
	if config then
		self.m_gameId = tonumber(bundleData.gameId)
		G_RoomCfg:init{gameId = tonumber(bundleData.gameId),createConfig = config,roomCode = bundleData.roomCode,enterType=bundleData.enterType}
	end

end

function BaseRoomScene:pause()
	BaseRoomScene.super.pause(self)
end

function BaseRoomScene:initView()
	G_GameScene = self
	self.mPlayer = {}
	--好友动画
	self.mAnimFriend = new(AnimationFriend, self)
	
	UIEx.bind(self, G_RoomCfg, "roundIndex", function(value)
		self:findChildByName("view_info"):findChildByName("text_round"):setText(string.format(Room_string.str_round_index,value,G_RoomCfg:getTotalRound()))
	end)

	UIEx.bind(self, G_RoomCfg, "roomCode", function(value)		
		self:findChildByName("view_info"):findChildByName("text_roomCode"):setText(string.format(Room_string.str_room_code,value))
	end)

	UIEx.bind(self, G_RoomCfg, "baseAnte", function(value)
		self:findChildByName("view_info"):findChildByName("text_baseAnte"):setText(string.format("%s：%s",Room_string.str_baseAnte,value))
	end)	

	--self:showDebugBtn()
	G_RoomCfg:setPlayStatus(0)
end

function BaseRoomScene:dtor()
	EventDispatcher.getInstance():unregister(HttpModule.s_event, self, self.onHttpRequestsCallBack);
	EventDispatcher.getInstance():unregister(Event.onEventResume,self,self.onEventResume);
	EventDispatcher.getInstance():unregister(Event.onEventPause,self,self.onEventPause);
	EventDispatcher.getInstance():unregister(Event.Call, self, self.onNativeCallBack);

	GameSocketMgr:removeCommonSocketReader(self.m_reader)
	GameSocketMgr:removeCommonSocketWriter(self.m_writer)
	GameSocketMgr:removeCommonSocketProcesser(self.m_processer)

	delete(self.m_reader)
	delete(self.m_writer)
	delete(self.m_processer)
	self.m_reader 	= nil
	self.m_writer 	= nil
	self.m_processer= nil
end

function BaseRoomScene:onBack()
	print("BaseRoomScene onBack()")
	if WindowManager and not WindowManager:onKeyBack() then
		if G_RoomCfg:getPlayStatus()==0 then --没开局
			self:requestExit()
			return
		else
			local text = Room_string.str_if_exit_room
			if G_RoomCfg:getPlayStatus()==2 then --下注结束才算游戏开始
				text = Room_string.str_cannot_exit_room
			end
			WindowManager:showWindow(WindowTag.MessageBox, {text = text,rightFunc=function()
		    	self:requestExit()
		    end}, WindowStyle.POPUP)
		end
	end
end

--相当于android的resume
function BaseRoomScene:onEventResume()
	GameSocketMgr:tryReconnect()
end


--相当于android的pause
function BaseRoomScene:onEventPause()
    
	GameSocketMgr:closeSocketSync()
end

--HTTP回调
function BaseRoomScene:onHttpRequestsCallBack(command, ...)
	if self.s_severCmdEventFuncMap[command] then
     	self.s_severCmdEventFuncMap[command](self,...)
	end 
end

--native callback
function BaseRoomScene:onNativeCallBack(key, data, result)
	
end

function BaseRoomScene:onFaceClick()
	
end

function BaseRoomScene:onFeedBackClick()
	
end

function BaseRoomScene:onHelpClick()
	
end

function BaseRoomScene:onChatClick()
	print("BaseRoomScene onChatClick")
end

function BaseRoomScene:onShopClick()
	print("BaseRoomScene:onShopClick")
end

function BaseRoomScene:_initMaps()
	self.s_controls = 
	{
		btn_back = getIndex(),
		btn_face = getIndex(),
		btn_feedback = getIndex(),
		btn_help = getIndex(),
		btn_chat = getIndex(),
		btn_shop = getIndex(),
		btn_detail = getIndex(),

		view_players = getIndex()
	}

	self.s_controlConfig = 
	{
		[self.s_controls.btn_back] 	= {"img_room_bg","btn_back"},
		[self.s_controls.btn_face] 	= {"img_room_bg","btn_face"},
		[self.s_controls.btn_feedback] 	= {"img_room_bg","btn_feedback"},
		[self.s_controls.btn_help] 	= {"img_room_bg","btn_help"},
		[self.s_controls.btn_chat] 	= {"img_room_bg","btn_chat"},
		[self.s_controls.btn_shop] 	= {"img_room_bg","btn_shop"},
		[self.s_controls.btn_detail] = {"img_room_bg","btn_detail"},

		[self.s_controls.view_players] 	= {"view_table","view_players"},
	}

	--控件回调
	self.s_controlFuncMap = 
	{
		[self.s_controls.btn_back] = self.onBack;
		[self.s_controls.btn_face] = self.onFaceClick;
		[self.s_controls.btn_feedback] = self.onFeedBackClick;
		[self.s_controls.btn_help] = self.onHelpClick;
		[self.s_controls.btn_chat] = self.onChatClick;
		[self.s_controls.btn_shop] = self.onShopClick;
		
	}
	--手动的Message消息回调
	self.messageFunMap = {
		["sendChatWord"]			= self.requestSendWord,
		["sendChatFace"]			= self.requestSendFace,
	}
	--http消息回调
	self.s_severCmdEventFuncMap = {
		SEND_FACE = BaseRoomScene.onSendFace,
		SEND_CHAT = BaseRoomScene.onSendChat,
		SEND_PROP_RSP =BaseRoomScene.onSendProp,
	}
end

function BaseRoomScene:reLocateSeat(needAnim)
	local mySeatId 	= self:getMySeatId();
	if not mySeatId then return end
	local player 	= self.mPlayer[mySeatId];

	for i = 1, #self.mPlayer do
		local p 	 = self.mPlayer[i];
		local seatId = p:getSeatId();
		local targetSeat = nil
		if seatId ~= mySeatId then
			targetSeat = self:getLocalSeatId(seatId, mySeatId)
		else
			targetSeat = G_RoomCfg:getMyLocalSeat()
		end
		
		local fromX,fromY = p:getUi():getAbsolutePos()
		p:setLocalSeatId(targetSeat)
		local toX,toY = p:getUi():getAbsolutePos()
		if needAnim then
			if fromX-toX~=0 or fromY-toY~=0 then
				p:getUi():moveBy(Point(fromX-toX,fromY-toY),Point(0,0),0.2)
			end
		end
	end
end

function BaseRoomScene:getMySeatId()
	for i = 1, #self.mPlayer do
		local player = self.mPlayer[i];
		if player:getId() == MyUserData:getId() then
			return player:getSeatId();
		end
	end
	return nil
end

--把服务器座位id转换为本地座位id
function BaseRoomScene:getLocalSeatId(seatId)
	local mySeatId 	= self:getMySeatId()
	if seatId==mySeatId then --我的位置永恒为1
		return G_RoomCfg:getMyLocalSeat()
	end
	if seatId==G_RoomCfg:getBankerServerSeat() then --目标位是庄家
		return G_RoomCfg:getBankerLocalSeat()
	end
	if mySeatId then --我坐下了
		if mySeatId==G_RoomCfg:getBankerServerSeat() then--我是庄家
			return seatId+1
		else --我不是庄家
			return (seatId - self:getMySeatId() + G_RoomCfg:getSeatCount() ) % G_RoomCfg:getSeatCount() + G_RoomCfg:getMyLocalSeat()
		end
		
	else --我没坐下
		return seatId
	end
   	
end

local function debug_login()
	local onLoginGame = 
	{
        ExtraCardTime = 6,
        UserAnteTime = 8,
        banker_id = 1,
        baseAnte = 2000,
        curDealSeatId = 10,
        curRound = 5,
        defaultAnte = 5000,
        maxAnte = 10000,
        maxSeatCnt = 9,
        minAnte = 10000,
        playCount = 1,
        players = { {
                SeatId = 10,
                UserId = 1,
                UserInfo = '"micon":"","appid":0,"nick":"dealer","sex":0}',
                cardsCount = 0,
                isOnline = 1,
                isOutCard = 0,
                isPlay = 0,
                nCurAnte = 0,
                nLoseTimes = 11,
                nMoney = 79936000,
                nWinTimes = 4
            } },
        tableId = 327681,
        tableLevel = 205,
        tableStatus = 0,
        totalAnte = 0,
        totalRound = 10
    }

	G_GameScene:onLoginGame(onLoginGame)
end

local function debug_sitdown()
	local onSitDownInGame = 
	{
        retCode = 0,
        seatId = 1
    }


	G_GameScene:onSitDownInGame(onSitDownInGame)


	local onBroadcastSitDown = 
	{
        LoseTimes = 0,
        WinTimes = 0,
        ante = 192500,
        money = 192500,
        seatId = 1,
        uid = 11238,
        userInfo = '{"appid":0,"sex":0,"micon":"","nick":"4.1.1"}'
    }

	G_GameScene:onBroadcastSitDown(onBroadcastSitDown)
end

local function debug_bet()
	local tab = {1,4,8,7,5,9,6}
	for i=1,#tab do
		local onBroadcastBet = 
		{
		    ante = 120000,
		    seatid = tab[i]
		}
		G_GameScene:onBroadcastBet(onBroadcastBet)
	end	

end
local function debug_gamestart()
	local onGameStart = 
	{
        banker_id = 1,
        banker_info = '"micon":"","appid":0,"nick":"dealer","sex":0}',
        banker_money = 79942000,
        banker_seatid = 10,
        curRound = 5,
        is_new_banker = 0,
        playCount = 2,
        playerList = { {
                ante = 186500,
                seatid = 1
            }, {
                ante = 79942000,
                seatid = 10
            } }
    }
	G_GameScene:onGameStart(onGameStart)
end

local function debug_deal()
	local data = 
	{
        myCards = { 59, 6 },
        myCount = 2,
        pokdengCards = {},
        pokdengNum = 0,
        totalAnte = 6000
    }
	G_GameScene:onDeal2Cards(data)
end

local function debug_get3thcard()
	local onGetThirdCard = 
	{
        card = 3
    }
	G_GameScene:onGetThirdCard(onGetThirdCard)
end

local function debug_gameend()
	local onGameEnd = 
	{
	    _11_time = "06/20/17 12:01:11",
	    banker_continue = 0,
	    banker_fee = 0,
	    banker_remain = 62955252,
	    banker_turnMoney = -221000,
	    playCount = 8,
	    playerList = { {
	            cards = { 35, 50, 7 },
	            count = 3,
	            exp = 298,
	            getexp = 10,
	            money = 698786,
	            seatid = 1,
	            turnMoney = -3000,
	            uid = 8778344
	        }, {
	            cards = { 18, 43, 52 },
	            count = 3,
	            exp = 178498,
	            getexp = 210,
	            money = 1148750,
	            seatid = 4,
	            turnMoney = 190000,
	            uid = 6137920
	        }, {
	            cards = { 26, 4, 61 },
	            count = 3,
	            exp = 328782,
	            getexp = 126,
	            money = 307100,
	            seatid = 5,
	            turnMoney = -12000,
	            uid = 10273015
	        }, {
	            cards = { 27, 20 },
	            count = 2,
	            exp = 2576374,
	            getexp = 210,
	            money = 510448,
	            seatid = 6,
	            turnMoney = -3000,
	            uid = 5000354
	        }, {
	            cards = { 33, 51, 17 },
	            count = 3,
	            exp = 52664,
	            getexp = 168,
	            money = 544000,
	            seatid = 7,
	            turnMoney = 0,
	            uid = 2296557
	        }, {
	            cards = { 34, 3, 36 },
	            count = 3,
	            exp = 105435,
	            getexp = 189,
	            money = 1292550,
	            seatid = 8,
	            turnMoney = 8550,
	            uid = 4167730
	        }, {
	            cards = { 59, 24 },
	            count = 2,
	            exp = 72053,
	            getexp = 168,
	            money = 1491550,
	            seatid = 9,
	            turnMoney = 28500,
	            uid = 10515835
	        }, {
	            cards = { 29, 53 },
	            count = 2,
	            exp = 0,
	            getexp = 0,
	            money = 62734252,
	            seatid = 10,
	            turnMoney = -221000,
	            uid = 1
	        } }
	}
	G_GameScene:onGameEnd(onGameEnd)
end

function BaseRoomScene:showDebugBtn()
	local btn_debug = self:findChildByName("btn_debug")
	if btn_debug==nil then
		btn_debug = new(Button,"ui/button.png")
			:addTo(self)
			:name("btn_debug")
			:align(kAlignLeft)

		btn_debug:setOnClick(self,function()
			-- WindowManager:showWindow(WindowTag.DebugPopu, {
			-- 	{text="登录",callback = function()
			-- 			debug_login()
			-- 		end},
			-- 	{text="坐下",callback = function()
			-- 			debug_sitdown()
			-- 		end},
			-- 	{text="开局",callback = function()
			-- 			debug_gamestart()
			-- 		end},
			-- 	{text="下注",callback = function()
			-- 			debug_bet()
			-- 		end},
			-- 	{text="发牌",callback = function()
			-- 			debug_deal()
			-- 		end},
			-- 	{text="要牌",callback = function()
			-- 			debug_get3thcard()
			-- 		end},
			-- 	{text="结算",callback = function()
			-- 			debug_gameend()
			-- 		end},
			-- }, WindowStyle.NORMAL,true)	
		end)
	end
end


function BaseRoomScene:showStandUpPopu()
	WindowManager:showWindow(WindowTag.StandUpPopu, {
	goLowFunc = function ()		
		self.exitRoomType = EXIT_TYPE.GO_LOW;
		GameSocketMgr:sendMsg(Command.EXIT_ROOM_REQ);		
	end
	}, WindowStyle.POPUP);
end

function BaseRoomScene:showExpPopu(exp)
	local level = MyUserData:getLevel()
	if type(exp) == "number" then
		for i = 1, #userLevelExp do
			local x1 = userLevelExp[i].x1 
			local x2 = userLevelExp[i].x2 
			if exp >= x1 and exp < x2 then
				if level == i then
					--AlarmTip.play('已领取等级奖励')
				else
                    MyUserData:setExp(exp)
                    MyUserData:setLevel(i)
	                GameSetting:setLevel(i)
	                GameSetting:save()
					HttpModule.getInstance():execute(HttpModule.s_cmds.GET_UPGRADE_REWARD, {level = i}, false, true)
				end
			end 
		end
	end		
end

-- function BaseRoomScene:onExitRoom()
-- --先暂时这么写，后面修改
-- 	if self.exitRoomType == EXIT_TYPE.GO_LOW then --跳去低级场
-- 		self.exitRoomType = EXIT_TYPE.NORMAL;
-- 		local game = app:getGame(self.mGameId)
-- 		if game then
-- 			local room = game:getRoomFromMoney(MyUserData:getMoney());
-- 			if room then
--              --现在没有self:clearGame()
-- 				self:clearGame();
-- 				checkAndRemoveOneProp(self, 111);--添加100ms延时,防止服务器房间状态还没同步
-- 				local delayAnim = self:addPropTranslate(111, kAnimNormal, 0, 100, 0, 0, 0, 0);
-- 				delayAnim:setEvent(nil,function ()
-- 					GameSocketMgr:sendMsg(GET_TABLEID_REQ, { u16_gameLevel = room:getLevel(), u32_gameId = self.mGameId });
-- 					checkAndRemoveOneProp(self, 111);
-- 				end)
-- 			end
-- 		end
-- 	end
-- end
--======================================网络消息=================================
function BaseRoomScene:requestSitdown(targetSeat)
	if self:getMySeatId() then
		return
	end
	if targetSeat then
		GameSocketMgr:sendMsg(Command.SITDOWN_IN_GAME_REQ, {u32_seatId = targetSeat, u64_ante = MyUserData:getMoney()});
	else
		for i = 1, #self.mPlayer do
			if self.mPlayer[i]:getId() == 0 and (not self.mFollowId) then
				GameSocketMgr:sendMsg(Command.SITDOWN_IN_GAME_REQ, {u32_seatId = i, u64_ante = MyUserData:getMoney()})
				break
			end
		end
	end
end

function BaseRoomScene:requestSendFace(faceType)
	GameSocketMgr:sendMsg(Command.SEND_FACE, {iFaceType=faceType,isVipFace = 0})
end
function BaseRoomScene:requestSendChat(msg)
	GameSocketMgr:sendMsg(Command.SEND_CHAT, {iChatInfo=msg})
end

--退出房间
function BaseRoomScene:requestExit()
	self.exitRoomType = EXIT_TYPE.NORMAL
	GameSocketMgr:sendMsg(Command.EXIT_ROOM_REQ, {})
	StateChange.changeState(self.mStateFrom or States.Lobby,{},StateStyle.TRANSLATE_BACK)
end

function BaseRoomScene:onGetTableId(data)
	
end
function BaseRoomScene:onFollow(data)
	
end
function BaseRoomScene:onFollowed(data)
	
end
function BaseRoomScene:onLoginGame(data)
	
end
function BaseRoomScene:onLoginErrorGame(data)
	JLog.d(" BaseRoomScene:onLoginErrorGame",data);
end
function BaseRoomScene:onExitRoom(data)
	-- StateChange.changeState(self.mStateFrom or States.Lobby,{},StateStyle.TRANSLATE_BACK);
	if self.exitRoomType == EXIT_TYPE.GO_LOW then --跳转至低级场未添加，暂时先退出房间
		local userInfo = {appid = 0, nick = MyUserData:getNick(), sex = MyUserData:getSex(), micon = MyUserData:getHeadUrl(), giftId = MyUserData:getGiftId()}
		cmd = 0x0117
		local level = self.m_Level - 1
		if level < 201 then
			level = 201
		end
		GameSocketMgr:sendMsg(cmd,{gameid = self.m_gameId, level = level, userInfo=json.encode(userInfo)})
		self.exitRoomType = EXIT_TYPE.NORMAL
	elseif self.exitRoomType == EXIT_TYPE.NORMAL then
		StateChange.changeState(self.mStateFrom or States.Lobby,{},StateStyle.TRANSLATE_BACK);
	else
		WindowManager:showWindow(WindowTag.MessageBox, {
				singleBtn = true,
				titleText = Hall_string.STR_EXIT_ROOM_TITLE,
				text = "คุณถูกเตะออกจากห้อง กรุณาเข้าห้องใหม่ค่ะ",
				leftText = "ยืนยัน",
				leftFunc = function ()
					StateChange.changeState(self.mStateFrom or States.Lobby,{},StateStyle.TRANSLATE_BACK);
				end
			}, WindowStyle.POPUP)
		if MyUserData:getMoney() < gBankrupt then
			WindowManager:showWindow(WindowTag.BankruptPopu, {state = 1, gameId = self.m_gameId, level = nil}, WindowStyle.POPUP)
		end
	end	
end
function BaseRoomScene:onBroadcastExitRoom(data)
	
end
function BaseRoomScene:onSitDownInGame(data)
	JLog.d("onSitDownInGame",data)
	if data.retCode ~= 0 then
		if DEBUG_MODE then
			AlarmTip.play(string.format("นั่งลงล้มเหลว,code=0x%x,%s",data.retCode,data.retCode))
		end

		if data.retCode == SIT_ERROR_CODE.SIT_NOT_EXIST then
			--重新坐下
			WindowManager:showWindow(WindowTag.MessageBox, {
				titleText 	= Hall_string.STR_EXIT_ROOM_TITLE,
				text = Hall_string.STR_SITDOWN_FAILED,
				rightText = Hall_string.STR_EXIT_GAME_CONFIRM,
				rightFunc = function ()
					-- body
					GameSocketMgr:sendMsg(Command.EXIT_ROOM_REQ, {})
					StateChange.changeState(self.mStateFrom or States.Lobby,{},StateStyle.TRANSLATE_BACK);		
				end
			}, WindowStyle.POPUP);
		elseif SIT_ERROR_CODE.SIT_MONEY_NOT_ENOUGH then
			if MyUserData:getMoney() < gBankrupt then
				--破产弹框
				WindowManager:showWindow(WindowTag.BankruptPopu, {state = 1, gameId = self.m_gameId, level = nil}, WindowStyle.POPUP)
			else
				WindowManager:showWindow(WindowTag.MessageBox, {
					titleText 	= Hall_string.STR_NOT_ENOUGH_MONEY_TITLE,
					text = Hall_string.STR_MONEY_NOT_ENOUGH,
					rightText = Hall_string.STR_EXIT_GAME_CONFIRM,
					rightFunc = function ()
						-- body
						GameSocketMgr:sendMsg(Command.EXIT_ROOM_REQ, {})
						StateChange.changeState(self.mStateFrom or States.Lobby,{},StateStyle.TRANSLATE_BACK);	
					end
				}, WindowStyle.POPUP);
			end
		elseif data.retCode == SIT_ERROR_CODE.SIT_MONEY_TOO_MUCH then
			WindowManager:showWindow(WindowTag.MessageBox, {
				titleText 	= Hall_string.STR_EXIT_ROOM_TITLE,
				text = Hall_string.STR_TOO_MUCH_MONEY,
				rightText = Hall_string.STR_EXIT_GAME_CONFIRM,
				rightFunc = function ()
					-- body
					GameSocketMgr:sendMsg(Command.EXIT_ROOM_REQ, {})
					StateChange.changeState(self.mStateFrom or States.Lobby,{},StateStyle.TRANSLATE_BACK);	
				end
			}, WindowStyle.POPUP);
		elseif data.retCode == SIT_ERROR_CODE.SIT_AREADY_HAS_USER then
			WindowManager:showWindow(WindowTag.MessageBox, {
				close 	= true,
				titleText 	= Hall_string.STR_EXIT_ROOM_TITLE,
				text = Hall_string.STR_SEAT_ROBBED,
				rightText = Hall_string.STR_EXIT_GAME_CONFIRM,
				rightFunc = function ()
					-- body
				end
			}, WindowStyle.POPUP);
		end
	end
end
function BaseRoomScene:onBroadcastSitDown(data)
	JLog.d("BaseRoomScene:onBroadcastSitDown",data);
	local player = self.mPlayer[data.seatId];
	player:setId(data.uid);
	local userInfo = json.decode(data.userInfo) or {};
	player:setSex(userInfo.sex or 0);
	player:setNick(userInfo.nick or "");
	player:setHeadUrl(userInfo.micon or "");

    player:setGiftId(userInfo.giftId)
	player:setChip(data.ante);

	player:setSeatId(data.seatId);
	
	if data.seatId == G_RoomCfg:getBankerLocalSeat()  then
		local handCard = player:getHandCardUi();
		if handCard then handCard:clear() end
		G_RoomCfg:setBankerId(data.uid)
	end
	
	if player:getId()==MyUserData:getId() then
		self:reLocateSeat(true)
	end

	
end
function BaseRoomScene:onBroadcastStandup(data)
	JLog.d("BaseBaseRoomScene onBroadcastStandup",data);
	self.mPlayer[data.seatId]:clear()
	self:checkNeedClear()
end

function BaseRoomScene:checkNeedClear()
	--判断是否要清除界面
	local needClear = true;
	for i = 1, #self.mPlayer do
		if self.mPlayer[i]:getId() > 1 then
			needClear = false;
			break;
		end
	end

	if needClear then --桌子上没有半个人了
		self:resetUi();
	end
end

function BaseRoomScene:resetUi()
end

function BaseRoomScene:onGameStart(data)
	G_RoomCfg:setPlayStatus(1)	--游戏开始
end

function BaseRoomScene:onGameBegin(data)
	G_RoomCfg:setPlayStatus(2)	--下注结束
end

function BaseRoomScene:onGameEnd(data)
	G_RoomCfg:setPlayStatus(3)	--游戏结束
end

function BaseRoomScene:onStandUp(data)
	JLog.d("BaseRoomScene onStandUp",data);
end

function BaseRoomScene:onSendProp( data )
	-- body
	local msgInfo = json.decode(data.msg_info);
	if data.mid ~= 0 and data.dest_mid == 0 then
		local srcPlayer = self:getUserByUid(data.mid)
		local dstPlayer = self:getUserByUid(data.dest_mid)
		if not srcPlayer or not dstPlayer then
			return
		end
	else
	local srcPlayer = self:getUserByUid(data.mid)
	local dstPlayer = self:getUserByUid(data.dest_mid)
		if not srcPlayer or not dstPlayer then
			return
		end
		if data.type == 1 then
			local srcx, srcy = srcPlayer:getUi():getAbsolutePos()
			local dstx, dsty = dstPlayer:getUi():getAbsolutePos()
			-- -- jaywillou-20160124-因调整头像大小，调整道具位置
			dstx = dstx - 50;
			dsty = dsty - 50;
			self.mAnimFriend:play(msgInfo.id, { x = srcx, y = srcy }, { x = dstx, y = dsty })
		elseif data.type == 4 then
			-- 添加好友
			local srcx, srcy = srcPlayer:getUi():getAbsolutePos()
			local dstx, dsty = dstPlayer:getUi():getAbsolutePos()
			self.mAnimFriend:play(3000, { x = srcx, y = srcy }, { x = dstx, y = dsty })
		end
	end
end

function BaseRoomScene:onSendFace(data)
	if data.mid and data.type and data.isVipFace then
		self:showChatFace(data.type, data.mid);
	else
	end
end

function BaseRoomScene:onSendChat(data)
	JLog.d("BaseRoomScene:onSendChat",data)
	if data.mid and data.msg then
		local player = self:getUserByUid(data.mid);
		if not player then return end
		local srcx, srcy = player:getUi():getAbsolutePos();
		local srcw, srch = player:getUi():getSize();
		local localSeatId = player:getLocalSeatId();
		self:showChatWord(data.msg, srcx, srcy, srcw, srch, localSeatId);
		local player = self:getUserByUid(data.mid);
		if player then
			G_RoomCfg:addChatRecord(player:getNick(), data.msg)
		end
	end
end
--取得用户 
function BaseRoomScene:getUserByUid(uid,players)
	local playerList = players or self.mPlayer;
    for k, v in pairs(playerList) do
		if v:getId() == uid then
			return v
		end
	end
    return nil;
end

function BaseRoomScene:requestSendWord(chatInfo)
	if not chatInfo then return end
	GameSocketMgr:sendMsg(Command.SEND_CHAT, {
		iChatInfo = chatInfo,
	})
end

function BaseRoomScene:requestSendFace(faceType)
	if not faceType then return end
	GameSocketMgr:sendMsg(Command.SEND_FACE, {
		iFaceType = faceType,
		isVipFace = 0,
	})
end


--展示表情
function BaseRoomScene:showChatFace(faceIndex, mid)
	local player = self:getUserByUid(mid);
	if not player then return end
	local srcx, srcy = player:getUi():getAbsolutePos();
	local srcw, srch = player:getUi():getSize();
	if not srcx or not srcy then return end

	local faceName = nil;
	
	local facePrefix = FaceConfig[1].expNamePrefix
	local img = FaceConfig[1].expressInfo .. faceIndex .. "0%02d.png"
	if type(facePrefix) == "table" then
		faceName = facePrefix[img]
	elseif type(facePrefix) == "string" then
		faceName = img
	end
	local imgCount = FaceConfig[1][faceIndex].imgCount
	local playCount = FaceConfig[1][faceIndex].playCount
	local playTime = FaceConfig[1][faceIndex].ms
	local x, y = srcx +(srcw - 100) / 2, srcy +(srch - 100) / 2
	local params = {
		num = imgCount,
		playCount = playCount,
		faceName = faceName,
		duration = playTime,
		pos = ccp(x,y),
	}
	new(AnimFace):addTo(self,1001)
		:play(params)
end
-- 聊天相关
function BaseRoomScene:showChatWord(chatInfo, x, y, w, h, seatId)
	JLog.d("BaseRoomScene:showChatWord",x,y,w,h,seatId)
	local srcx, srcy = x, y
	local srcw, srch = w, h

	local localSeatId = seatId
	local imgFace = new(Image, 'animation/roomAnim/word_bg_left.png')
	local imgChipW, imgChipH = imgFace.m_width, imgFace.m_height
	if not self.m_chatWord then
		self.m_chatWord = new(Node)
			:addTo(self, 1000)
			-- :align(kAlignBottom)
	end
	self.m_chatWord:removeAllChildren()
	local x, y = self:getChatPosition(localSeatId, srcx, srcy, srcw, srch, imgChipW, imgChipH)
	if not x or not y then return end
	local params = {
		seat = localSeatId,
		-- seat = self.m_seat,
		chatInfo = chatInfo,
		pos = ccp(x,y),
		isGame = true
		-- isGame = self:getIsInGamePos(),
	}
	new(AnimChat):addTo(self.m_chatWord, 1000)
		:play(params)
		-- :align(kAlignTop)

	-- playChatSound(chatInfo, self.m_userData:getSex())
	self:playChatSound(chatInfo)
end

function BaseRoomScene:playChatSound(chatInfo)
	if SysChatArray[1] == chatInfo then
		kEffectPlayer:play(Effects.AudioChatCommon1);
	elseif SysChatArray[2] == chatInfo then
		kEffectPlayer:play(Effects.AudioChatCommon2);
	elseif SysChatArray[3] == chatInfo then
		kEffectPlayer:play(Effects.AudioChatCommon7);
	elseif SysChatArray[4] == chatInfo then
		kEffectPlayer:play(Effects.AudioChatCommon8);
	elseif SysChatArray[5] == chatInfo then
		kEffectPlayer:play(Effects.AudioChatCommon10);
	elseif SysChatArray[6] == chatInfo then
		kEffectPlayer:play(Effects.AudioChatCommon11);
	end
end
function BaseRoomScene:getChatPosition(seatId, x, y, w, h, mx, my)
	if seatId == 1 then
		return(x-w),(y-h/2-my)
	elseif seatId == 2 then
		return(x - w),(y - h-my)
	elseif seatId == 3 then
		return(x - w),(y - h-my)
	elseif seatId == 4 then
		return(x - w),(y - h-my)
	elseif seatId == 5 then
		return(x - w),(y - h-my)
	elseif seatId == 6 then
		return(x-w),(y-h/2-my)
	elseif seatId == 7 then
		return(x-w/3-mx),(y-my)
	elseif seatId == 8 then
		return(x-w-mx),(y-my)
	elseif seatId == 9 then
		return(x-w-mx),(y-my)
	elseif seatId == 10 then
		return(x-w-mx),(y-my)
	end
end
return BaseRoomScene