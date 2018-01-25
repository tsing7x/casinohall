local Player = require("app.games.view.playerUi")
local HandCard = require("app.games.pokdeng.card.handCard")
local ViewBet = require("app.games.view.view_bet")
local ViewCardDealer = require("app.games.view.view_cardDealer")
local ViewCardType = require("app.games.pokdeng.card.view_cardType")
local RoundClock = require("app.games.view.roundClock")
local BaseRoomScene = require("app.games.exGameBase.baseRoomScene")
local RoomScene = class(BaseRoomScene)

local Room_string = require("app.games.pokdeng.res.config")
local ViewChipIn = require("app.games.view.viewChipIn")
local Command = require("app.games.pokdeng.network.command")
require('app.games.pokdeng.popu.config')

local AUDIO = require("app.games.pokdeng.res.audio_config")

local ERROR_CODE = 
{	
	UPBANKER_MIN_MONEY_REQ= 301,--上庄最低钱要求
	UPBANKER_AREADY_REQ= 302,--已经请求过上庄了
	UPBANKER_MONEY_LESS_CUR_BANKER= 303,--钱数低于当前庄家携带的1.5倍
	UPBANKER_REQ_LIST_FULL= 304,--上庄请求队列已满
	UPBANKER_BANKER_CANT_LOGOUT= 305,--游戏过程中庄家不能退出游戏
	UPBANKER_BET_BANKER_CANT_BET= 306,--庄家不能下注(庄家不能操作)
	UPBANKER_AREADY_UPBANKER= 307,--已经是庄家了
	UPBANKER_BET_TOTAL_TOO_MUCH= 308,--玩家所有下注数量不能超过庄家下注数量的1/3
	UPBANKER_BET_TIMES_TOO_MANY= 309,--下注次数超过50次
	UPBANKER_BET_TYPE= 310,--下注类型错误
	UPBANKER_BET_MONEY= 311,--下注钱错误,玩家下注钱数不在玩家拥有的钱范围
	UPBANKER_BET_NOT_BET_STATE= 312,--不是下注时间	

}

local MAX_PLAYER_NUM = 10

local cIndex = 100
local function getIndex()
	cIndex = cIndex + 1
	return cIndex
end

--[[
	构造函数
--]]
function RoomScene:ctor(viewConfig,controller,param)
	JLog.d("RoomScene ctor",param);

	--数据初始化
	pokdengPopuInit();
	self.detailListTb = {}
	self.m_Level = param[1].level
	self.m_gameId = tonumber(param[1].gameId)
	self.tableId = tonumber(param[1].tableId)
	self.enterType = tonumber(param[1].enterType)

	if GameSetting.addGameRecord then
  		GameSetting:addGameRecord(self.m_gameId)
  	end

	--根据游戏类型决定回合与code的显示隐藏
	if GAME_ID.Casinohall == tostring(self.m_gameId) then
		self:findChildByName("view_info"):findChildByName("text_round"):hide()
		self:findChildByName("view_info"):findChildByName("text_roomCode"):setVisible(false)
	else
		self:findChildByName("view_info"):findChildByName("text_round"):show()
		self:findChildByName("view_info"):findChildByName("text_roomCode"):setVisible(value~=0)
	end
end

--[[
	初始化socket网络协议
--]]
function RoomScene:initProtocol()
	JLog.d("RoomScene initProtocol")

	self.m_reader		= new(require('app.games.pokdeng.network.command_reader'))
	self.m_writer		= new(require('app.games.pokdeng.network.command_writer'))
	self.m_processer 	= new(require('app.games.pokdeng.network.command_processer'),self)

	GameSocketMgr:addCommonSocketReader(self.m_reader);
	GameSocketMgr:addCommonSocketWriter(self.m_writer);
	GameSocketMgr:addCommonSocketProcesser(self.m_processer);
end

--[[
	初始化界面，绑定数据
--]]
function RoomScene:initView()
	JLog.d("RoomScene initView")
	RoomScene.super.initView(self)

	--常量初始化
	G_RoomCfg:setBankerLocalSeat(10)
	G_RoomCfg:setBankerServerSeat(10)
	G_RoomCfg:setMyLocalSeat(1)
	G_RoomCfg:setMaxPlayerNum(10)
	G_RoomCfg:setSeatCount(G_RoomCfg:getMaxPlayerNum()-1)

    --要牌等待时长
	self.m_ThirdCardTime = 6
	--下注等待时长
	self.m_UserAnteTime = 8

	--设置按钮文本
	self:getControl(self.s_controls.text_yao):setText(Room_string.str_operate_yao)
	self:getControl(self.s_controls.text_buyao):setText(Room_string.str_operate_buyao)
	self:getControl(self.s_controls.text_startGame):setText(Room_string.str_operate_startGame)
	self:getControl(self.s_controls.text_invite):setText(Room_string.str_operate_invite)

    --下注弹窗
	self.m_viewChipIn = new(ViewChipIn,{callback = function(value)
			self:requestBet(value)
		end})
		:addTo(self)
		:align(kAlignBottom)

	--发牌器
	local cardDealer = new(ViewCardDealer)
		:addTo(self:findChildByName("view_table"))
	cardDealer:setPos_1()

	--玩家头像及数据初始化
	for i=1,G_RoomCfg:getMaxPlayerNum() do
		local playerData = Player(self,self:getControl(self.s_controls.view_players),i)
		self.mPlayer[#self.mPlayer+1] = playerData

		playerData:setCardDealerUi(cardDealer)

		local handCard = new(HandCard)
			:addTo(playerData:getUi())
		playerData:setHandCardUi(handCard)

		local viewBet = new(ViewBet)
			:addTo(playerData:getUi())
			:hide()
		playerData:setBetUi(viewBet)

		local viewCardType = new(ViewCardType)
			:addTo(playerData:getUi())
			-- :hide()
		playerData:setCardTypeUi(viewCardType)

		playerData:setSeatId(i)
		playerData:setLocalSeatId(i)
		playerData:setId(0)
	end

	--下注闹钟
	self.m_betClock = new(RoundClock, "games/common/img_counter.png")
			:addTo(self:findChildByName("view_table"))
			:align(kAlignCenter)
			:hide()
			:scale(1.2)
	self.m_betClock:setBg("games/common/img_clockBg.png",{w=136,h=136})

	--本轮游戏状态
	UIEx.bind(self, G_RoomCfg, "playStatus", function(value)	
	end)

	--底注
	UIEx.bind(self, G_RoomCfg, "baseAnte", function(value)
		local text_baseAnte = self:findChildByName("text_baseAnte")
		text_baseAnte:setText(string.format("%s：%s",Room_string.str_baseAnte,value))
		G_RoomCfg:setLatestBet(value)
		-- self.m_viewChipIn:setBaseAnte(value)--先屏蔽
	end)

	--上一次下注的筹码
	UIEx.bind(self, G_RoomCfg, "latestBet", function(value)
		self.m_viewChipIn:setLastChip(value)
	end)

	--荷官ID
	UIEx.bind(self, G_RoomCfg, "bankerId", function(value)
		JLog.d("G_RoomCfg set bankerId",value);
		local img_table = self:findChildByName("view_table"):findChildByName("img_table")
		if value==1 then --系统庄家
			self:findChildByName("view_dealer"):show()
			img_table:roate(0)
					:pos(0,0)
			cardDealer:setPos_1()

			self:findChildByName("view_banker"):findChildByName("btn_up_banker"):show();
			self:findChildByName("view_banker"):findChildByName("btn_down_banker"):hide();		
		else --玩家当庄家
			self:findChildByName("view_banker"):findChildByName("btn_up_banker"):hide();
			self:findChildByName("view_banker"):findChildByName("btn_down_banker"):hide();

			self:findChildByName("view_dealer"):hide()
			if value==MyUserData:getId() then
				img_table:roate(180)
						:pos(0,-40)
				self:findChildByName("view_banker"):findChildByName("btn_down_banker"):show();
				cardDealer:setPos_2()
			else
				cardDealer:setPos_1()
			end
		end
	end)

	--隐藏要牌界面	
	self:show3thCardOperateView(false)
	--隐藏开始游戏按钮
	self:showBankerOperateView(false)
	--隐藏要牌指示灯
	self:runIndicator(false)
	--隐藏荷官
	self:findChildByName("view_dealer"):hide()
    --隐藏游戏桌面提示
	self:showTableTip(false)	
end

function RoomScene:onBack()
	print("BaseRoomScene onBack()")
	if WindowManager and not WindowManager:onKeyBack() then
		if not self.roomMenuCallBack then
			self.roomMenuCallBack = {
				backFunc = function()
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
				end,
				standUpFunc = function()
					GameSocketMgr:sendMsg(Command.STANDUP_REQ, {}) --请求站起
				end,
				ruleFunc = function()
					WindowManager:showWindow(WindowTag.BrandDescPopu, {})
				end
			}
		end
		WindowManager:showWindow(WindowTag.RoomMenuPopu, self.roomMenuCallBack, WindowStyle.TRANSLATE_DOWN)
	end
end

--自己从庄家为下来，会导致位置错了，需要重置(将9号位和10号位换位置)
function RoomScene:resetSeatAfterBanker()
	local bankerSeatId = G_RoomCfg:getBankerLocalSeat()

	local player9 = self.mPlayer[bankerSeatId-1]
	local fromX,fromY = player9:getUi():getAbsolutePos()
	player9:setLocalSeatId(1)
	local toX,toY = player9:getUi():getAbsolutePos()
	player9:getUi():moveBy(Point(fromX-toX,fromY-toY),Point(0,0),0.2)

	local player10 = self.mPlayer[bankerSeatId]
	player10:setId(1);
	player10:setLocalSeatId(10)
end

function RoomScene:getBetPosByLocalSeat(localSeat)
	if localSeat==1 then
		return kAlignTop,{x=0,y=-100}
	elseif localSeat==10 then
		return kAlignBottom,{x=0,y=-110}
	elseif localSeat<=5 then
		return kAlignBottomRight,{x=-150,y=-40}
	elseif localSeat<=9 then
		return kAlignBottomLeft,{x=-150,y=-40}
	end
end

function RoomScene:getCardPosByLocalSeat(localSeat)
	if localSeat==1 then
		return kAlignBottom,{x=0,y=self:getMySeatId() and 120 or 60}
	elseif localSeat==10 then
		return kAlignBottom,{x=0,y=50}
	elseif localSeat<=5 then
		return kAlignBottomRight,{x=0,y=-50}
	elseif localSeat<=9 then
		return kAlignBottomLeft,{x=0,y=-50}
	end
end

function RoomScene:getPlayerPosByLocalSeat(localSeat)
	local view_players = self:getControl(self.s_controls.view_players)
	local w,h = view_players:getSize()
	if localSeat==1 then
		return kAlignBottom,{x=0,y=150}
	elseif localSeat==10 then
		return kAlignTop,{x=0,y=30}
	elseif localSeat<=5 then
		return kAlignTopLeft,{x=60,y=180+(5-localSeat)*h/5.5}
	elseif localSeat<=9 then
		return kAlignTopRight,{x=60,y=180+(localSeat-6)*h/5.5}
	end
end

function RoomScene:resume(bundleData)
	JLog.d("roomScene resume",bundleData);
	self.super.resume(self,bundleData)
	kMusicPlayer:play(AUDIO.BGM, true)
	local roomConfig = bundleData.config;
	if roomConfig and roomConfig:getChipList() then
		self.m_viewChipIn:initQuickChip(roomConfig:getChipList())
	else
		self.m_viewChipIn:setBaseAnte(G_RoomCfg:getBaseAnte())
	end
	--self:checkToSit()

	GameSocketMgr:sendMsg(Command.CLIENT_CMD_LOGINROMM, {tableId = self.tableId, reason = self.enterType})	
end

function RoomScene:pause()
	JLog.d("roomScene pause");
	RoomScene.super.pause(self)
end

function RoomScene:onHelpClick()
	-- WindowManager:showWindow(WindowTag.FeedbackPopu, {}, WindowStyle.POPUP)
end

function RoomScene:onFeedBackClick()
	WindowManager:showWindow(WindowTag.FeedbackPopu, {}, WindowStyle.POPUP)
end

function RoomScene:onShopClick()
	print("onAddChipBtnClick")
	WindowManager:showWindow(WindowTag.ShopPopu, {}, WindowStyle.TRANSLATE_RIGHT)
end

function RoomScene:onBuYaoClick()
	self:requestGet3card(0)
end

function RoomScene:onYaoClick()
	self:requestGet3card(1)

end

function RoomScene:onInviteClick()

end

function RoomScene:onStartClick()
	self:requestStartGame()
end

function RoomScene:onFaceClick()
	WindowManager:showWindow(WindowTag.RoomChatAndSpeakerPopu, {chatwords = Room_string.SysChatArray, noSpeaker = false , to = "face"}, WindowStyle.NORMAL)
end

function RoomScene:onChatClick()
	WindowManager:showWindow(WindowTag.RoomChatAndSpeakerPopu, {chatwords = Room_string.SysChatArray, noSpeaker = false , to = "chat" }, WindowStyle.NORMAL)
end

function RoomScene:onDetailClick()
	WindowManager:showWindow(WindowTag.RoomDetailPopu, {self.detailListTb, self.m_gameId}, WindowStyle.POPUP)
end

function RoomScene:onUpBankerClick()
	JLog.d("RoomScene:onUpBankerClick");
	self:requestUpBanker();
end

function RoomScene:onDownBankerClick()
	JLog.d("RoomScene:onDownBankerClick");
	JLog.d("onDownBankerClick m_gameId",self.m_gameId,"GAME_ID.Casinohall",GAME_ID.Casinohall)
	if self.m_gameId == tonumber(GAME_ID.Casinohall) then --筹码场
		GameSocketMgr:sendMsg(Command.STANDUP_REQ, {}) --请求站起
	elseif self.m_gameId == tonumber(GAME_ID.PokdengCash) then --现金币场
		GameSocketMgr:sendMsg(Command.EXIT_ROOM_REQ, {}) --请求退出房间
	end
end

--[[
	是否展示庄家操作视图
--]]
function RoomScene:showBankerOperateView(isShow)
	local view_operate = self:findChildByName("view_operate"):findChildByName("bankerStart")
	view_operate:setVisible(isShow)
end

--[[
	是否展示要牌操作视图
--]]
function RoomScene:show3thCardOperateView(isShow)
	local view_operate = self:findChildByName("view_operate"):findChildByName("thirdCard"):findChildByName("view_inner")
	if isShow then
		view_operate:show()
		local w,h = view_operate:getSize()
		local time = 0.2
		view_operate:runAction({{"opacity",0,1,time},{"y",h,0,time}},{loopType=kAnimNormal,order="spawn"})
	else
		local w,h = view_operate:getSize()
		local time = 0.2
		view_operate:runAction({{"opacity",1,0,time},{"y",0,h,time}},{loopType=kAnimNormal,order="spawn",onComplete=function()
				view_operate:hide()
			end})
	end
end

function RoomScene:onLoginServer(data)	
	if data.isInTable == 1 then
		local data = data.roomInfo
		local userInfo = {appid = 0, nick = MyUserData:getNick(), sex = MyUserData:getSex(), micon = MyUserData:getHeadUrl(), giftId = MyUserData:getGiftId()}
		cmd = 0x0117
		GameSocketMgr:sendMsg(cmd,{gameid=tonumber(data.gameID),level = data.serverLvl,userInfo=json.encode(userInfo), is_reconnect = 1})
	else
		self:requestExit()
	end
end

function RoomScene:_initMaps()
	RoomScene.super._initMaps(self)

	local s_controls = {
		btn_shop = getIndex(),
		btn_buyao = getIndex(),
		text_buyao = getIndex(),
		btn_yao = getIndex(),
		text_yao = getIndex(),

		btn_invite = getIndex(),
		text_invite = getIndex(),
		btn_startGame = getIndex(),
		text_startGame = getIndex(),
		btn_up_banker  = getIndex(),
		btn_down_banker = getIndex(),
	}
	table.merge(self.s_controls, s_controls)

	local s_controlConfig = {
		[self.s_controls.btn_shop] 	= {"img_room_bg", "btn_shop"},

		[self.s_controls.btn_buyao] 	= {"view_operate","thirdCard","view_inner","btn_buyao"},
		[self.s_controls.text_buyao] 	= {"view_operate","thirdCard","view_inner","btn_buyao","text_buyao"},
		[self.s_controls.btn_yao] 	= {"view_operate","thirdCard","view_inner","btn_yao"},
		[self.s_controls.text_yao] 	= {"view_operate","thirdCard","view_inner","btn_yao","text_yao"},
		
		[self.s_controls.btn_invite] 	= {"view_operate","bankerStart","btn_invite"},
		[self.s_controls.text_invite] 	= {"view_operate","bankerStart","btn_invite","text_invite"},
		[self.s_controls.btn_startGame] 	= {"view_operate","bankerStart","btn_startGame"},
		[self.s_controls.text_startGame] 	= {"view_operate","bankerStart","btn_startGame","text_startGame"},
		[self.s_controls.btn_up_banker] = {"view_table","view_banker","btn_up_banker"},
		[self.s_controls.btn_down_banker] = {"view_table","view_banker","btn_down_banker"},
	}
	table.merge(self.s_controlConfig, s_controlConfig)

	local s_controlFuncMap = {
		[self.s_controls.btn_shop] = self.onShopClick;

		[self.s_controls.btn_buyao] = self.onBuYaoClick;
		[self.s_controls.btn_yao] = self.onYaoClick;

		[self.s_controls.btn_invite] = self.onInviteClick;
		[self.s_controls.btn_startGame] = self.onStartClick;
		[self.s_controls.btn_up_banker] = self.onUpBankerClick;
		[self.s_controls.btn_down_banker] = self.onDownBankerClick;
		[self.s_controls.btn_face] = self.onFaceClick;
		[self.s_controls.btn_chat] = self.onChatClick;
		[self.s_controls.btn_detail] = self.onDetailClick;
	}
	table.merge(self.s_controlFuncMap, s_controlFuncMap)

	local messageFunMap = {
		["loginserver"] = self.onLoginServer,
	}
	table.merge(self.messageFunMap, messageFunMap)

	local s_severCmdEventFuncMap = {
	
	}
	table.merge(self.s_severCmdEventFuncMap, s_severCmdEventFuncMap)
end

function RoomScene:runIndicator(playerX,playerY)
	local view_inct = self:findChildByName("view_table"):findChildByName("view_inct"):show()
	if not playerX then
		view_inct:hide()
		return
	end

	local centerX, centerY = view_inct:getAbsolutePos()
	local targetPt = {x=playerX,y=playerY}
	local angle=0

	if targetPt.x>centerX and targetPt.y<centerY then --1,2,3
		angle = math.atan((targetPt.x-centerX)/(-targetPt.y+centerY))/3.141592653*180
	elseif targetPt.x>centerX and targetPt.y>centerY then --4
		angle = math.atan((targetPt.y-centerY)/(targetPt.x-centerX))/3.141592653*180+90
	elseif targetPt.x<centerX and targetPt.y>centerY then --6
		angle = 270 - math.atan((targetPt.y-centerY)/(centerX-targetPt.x))/3.141592653*180
	else --7,8,9
		angle = 270 + math.atan((-targetPt.y+centerY)/(centerX-targetPt.x))/3.141592653*180
	end
	self.lastAngle = self.lastAngle or 0
	if self.lastAngle-angle>180 then
		if self.lastAngle>0 then
			self.lastAngle = self.lastAngle - 360
		else
			self.lastAngle = self.lastAngle + 360
		end
	elseif angle-self.lastAngle>180 then
		if angle>0 then
			angle = angle - 360
		else
			angle = angle + 360
		end
	end
	angle = math.ceil(angle)

	local time = 0.1
	view_inct:runAction({"rotation",self.lastAngle,angle,time})
	
	self.lastAngle = angle
	if self.lastAngle<0 then
		self.lastAngle = self.lastAngle+360
	end
end


--======================================网络消息=================================
--请求下注
function RoomScene:requestBet(betNum)
	GameSocketMgr:sendMsg(Command.BET_REQ, {ante=betNum})
end

--[[
	0x1010:请求要第三张牌
	_type:是否需要第三张牌
	0:不需要
	1:需要
--]]
function RoomScene:requestGet3card(_type)
	GameSocketMgr:sendMsg(Command.GET_THIRD_CARD_REQ, {type=_type})
end

--庄家请求开始游戏
function RoomScene:requestStartGame()
	GameSocketMgr:sendMsg(Command.BANKER_START_REQ, {})
end

--请求上庄
function RoomScene:requestUpBanker()
	GameSocketMgr:sendMsg(Command.UP_BANKER_REQ, {})
end

function RoomScene:onLoginGame(data)
	-- JLog.d("RoomScene:onLoginGame :=================", data)

	--每次登陆成功，先清空用户数据
	for i=1,G_RoomCfg:getMaxPlayerNum() do		
		self.mPlayer[i]:clear()
	end

	local tableStatus = data.tableStatus 	--桌子当前状态 0牌局已结束 1下注中 2等待用户获取第3张牌 3等待结算
	if tableStatus ~= 2 then
		self:show3thCardOperateView(false)
	end

	G_RoomCfg:setBaseAnte(data.baseAnte)
	G_RoomCfg:setTotalRound(data.totalRound)
	G_RoomCfg:setRoundIndex(data.curRound)
	G_RoomCfg:setBankerId(data.banker_id)
	self.m_ThirdCardTime = data.ExtraCardTime
	self.m_UserAnteTime = data.UserAnteTime
	
	self.detailListTb = {}
	self.detailListTb[MyUserData:getId()] = {
		nick = MyUserData:getNick(),
		sex = MyUserData:getSex(),
		iconurl = MyUserData:getHeadUrl(),
		curMoney = MyUserData:getMoney(),
		isOnline = true,
		playNum = 0,
		curWin = 0
	}

	for i=1,data.playCount do
		local user = data.players[i]
		local player 		= self.mPlayer[user.SeatId]
		if player==nil then
			GameSocketMgr:closeSocketSync()
			return
		end
		player:setId(user.UserId)
		player:setSeatId(user.SeatId)
		player:setStatus(user.isPlay)
		
		player:setBet(user.nCurAnte)
		player:setChip(user.nMoney)
		if tableStatus ~= 2 then
			player:setTimeAnim(false)
		else
			--player:setTimeLeft({self.m_ThirdCardTime, 2})
		end

		local userInfo = json.decode(user.UserInfo)  or {}

		player:setSex(userInfo.sex or 0)
		player:setNick(userInfo.nick or "")
		player:setHeadUrl(userInfo.micon or "")
        player:setGiftId(userInfo.giftId)

        local handCard = player:getHandCardUi()
        if user.isOutCard ~= 1 then --还没亮牌	
        	for i=1,user.cardsCount do
        		handCard:getDealCard()
        	end
        else
        	player:setCards(user.cards or {})
        	player:setShowCard(true);
        end

        if player:getStatus() == 1 or player:getStatus() == 2 then
        	player:setShaderVisible(0)
        end

        self.detailListTb[player:getId()] = {
			nick = player:getNick(),
			sex = player:getSex(),
			iconurl = player:getHeadUrl(),
			curMoney = player:getChip(),
			isOnline = true,
			playNum = 0,
			curWin = 0
		}
	end
	self:reLocateSeat()

	if self:getMySeatId() then
		JLog.d("onLoginGame:already sitDown")
	else
		JLog.d("onLoginGame:request to sitDown")
		self:checkToSit()
	end
end

function RoomScene:checkToSit()
	if G_RoomCfg:getEnterType()==1 then --创建房间进来的,不请求坐下，而是请求上庄
		self:requestUpBanker()
	else --其他情况，请求坐下
		self:requestSitdown()
	end
end

--[[
	游戏桌面提示
	false：关掉
	1:正在等待闲家下注
	2：正在等待庄家续费
--]]
function RoomScene:showTableTip(_type)
	local view_tableTip = self:findChildByName("view_tableTip")
	view_tableTip:setVisible(_type~=false)
	local tipStr = ""
	if _type==1 then
		tipStr = Room_string.str_table_tip_1
	elseif _type==2 then
		tipStr = Room_string.str_table_tip_2
	end
	view_tableTip:findChildByName("text_tableTip"):setText(tipStr)
end

function RoomScene:onGameStart(data)
	self.super.onGameStart(self,data)
	if data.serverFee and data.serverFee ~= 0 then
		AlarmTip.play(string.format(Room_string.str_room_fee_deduct, data.serverFee))	
	end
	G_RoomCfg:setRoundIndex(data.curRound or 0) --现金场才有回合
	for i=1,#data.playerList do
		local user = data.playerList[i]
		self.mPlayer[user.seatid]:setStatus(1)
		self.mPlayer[user.seatid]:setShaderVisible(0)
	end

	if G_RoomCfg:getBankerId()~=MyUserData:getId() then  --我是闲家才需要下注
		if self:getMySeatId() then --已经坐下的人才能看到
			self.m_viewChipIn:showUp()
			self.m_betClock:play(self.m_UserAnteTime,self.m_UserAnteTime)
		end
	
	else --等待闲家下注
		self:showTableTip(1)
	end
end

--[[
	0x6007：广播游戏结束
--]]
function RoomScene:onGameEnd(data)
	-- dump(data, "RoomScene:onGameEnd.data :==================")

	self.super.onGameEnd(self,data)
	self:runIndicator(false)
	if self.m_betClock then
		self.m_betClock:stop()
	end
	for i=1,#data.playerList do
		local user = data.playerList[i]
		local playerData = self.mPlayer[user.seatid]
		playerData:setStatus(2)

		playerData:setCards(user.cards)
		playerData:setOpenAnim({})
		playerData:setChip(user.money)
		playerData:setTurnMoney(user.turnMoney)
		if self.detailListTb[playerData:getId()] then
			self.detailListTb[playerData:getId()].curMoney = user.money
			self.detailListTb[playerData:getId()].curWin = self.detailListTb[playerData:getId()].curWin + user.turnMoney
			self.detailListTb[playerData:getId()].playNum = self.detailListTb[playerData:getId()].playNum + 1
		end

		if playerData:getId() == MyUserData:getId() then

			if GAME_ID.Casinohall == tostring(self.m_gameId) then --筹码场
				MyUserData:setMoney(user.money)
			else --现金币
				MyUserData:setCashPoint(user.money)
			end

			MyUserData:setExp(user.exp)
			self:showExpPopu(user.exp)
			if user.turnMoney > 0 then
				kEffectPlayer:play(AUDIO.AudioWin)
			else
				kEffectPlayer:play(AUDIO.AudioLose)
			end
		end
	end
end

function RoomScene:onBroadcastSitDown(data)
	JLog.d("RoomScene:onBroadcastSitDown",data);
	self.super.onBroadcastSitDown(self,data);
	local player = self.mPlayer[data.seatId];
	self.detailListTb[player:getId()] = {
		nick = player:getNick(),
		sex = player:getSex(),
		iconurl = player:getHeadUrl(),
		curMoney = player:getChip(),
		isOnline = true,
		playNum = 0,
		curWin = 0
	}
end

function RoomScene:onBroadcastStandup(data)
	JLog.d("RoomScene:onBroadcastStandup",data);
	self.detailListTb[self.mPlayer[data.seatId]:getId()].isOnline = false;
	self.super.onBroadcastStandup(self,data);

	if data.seatId == G_RoomCfg:getBankerLocalSeat() then
		if data.uid == 1 then 	--上庄

		else
			--下庄
			--现金币场庄家退出，闲家也需退出游戏
			if GAME_ID.PokdengCash == tostring(self.m_gameId) then
				self:requestExit()
			end
		end
	end
end

function RoomScene:onBankerOffline(data)	
	AlarmTip.play(Room_string.str_banker_is_reconnect)
end

function RoomScene:onStandUp(data)
	JLog.d("RoomScene:onStandUp",data);
	if data.code == 0 then
		--玩家站起
		local player = self.mPlayer[data.seatId]
        if self:getMySeatId() == data.seatId then
        	if self.m_viewChipIn:getVisible() then-- 自己站起 隐藏下注
	        	self.m_viewChipIn:hideDown()
				self.m_betClock:stop()
			end
        end
		if player then 
            player:clear();
        end
		if data.seatId == G_RoomCfg:getBankerLocalSeat() then
			G_RoomCfg:setBankerId(1)--设置回默认庄家
			self:resetSeatAfterBanker();
			self:showTableTip(false)--屏蔽显示庄家提示
			self:showBankerOperateView(false)--屏蔽庄家开始按钮
		end

		if GAME_ID.Casinohall == tostring(self.m_gameId) then
			MyUserData:setMoney(data.nMoney)
		else
			MyUserData:setCashPoint(data.nMoney)
		end

		if data.reason == 2 then
			if MyUserData:getMoney() < gBankrupt then
				--破产弹框
				WindowManager:showWindow(WindowTag.BankruptPopu, {state = 1, gameId = self.m_gameId, level = nil}, WindowStyle.POPUP)
			else
				self:showStandUpPopu();
			end
		end
	end
end

--[[
	0x6009：轮到谁要不要第三张牌
--]]
function RoomScene:onBroadcastThirdCardAvailable(data)
	if data.seatid==self:getMySeatId() then
		local btnNo = self:getControl(self.s_controls.btn_buyao)
		if self.mPlayer[data.seatid]:getHandCardUi():needPoker() then
			btnNo:setEnable(false)
			btnNo:setIsGray(1, true)
		else
			btnNo:setEnable(true)
			btnNo:setIsGray(nil, true)
		end
		self:show3thCardOperateView(true)
	end

	local playerData = self.mPlayer[data.seatid]
	if playerData==nil then
		return
	end
	--打开头像倒计时动画
	playerData:setTimeAnim(self.m_ThirdCardTime)
	--聚光灯指向玩家头像
	self:runIndicator(playerData:getUi():getAbsolutePos())
end

--[[
	0x2005：请求第三张牌返回
--]]
function RoomScene:onGetThirdCard(data)
	local mySeat = self:getMySeatId()
	if mySeat == nil then
		return
	end

	self.mPlayer[mySeat]:add3thCard(data.card)
	local callback = function()
		self.mPlayer[mySeat]:setOpenAnim({}) --开牌显示牌型
	end
	self.mPlayer[mySeat]:setDealAnim({delay=0,callback=callback})
end

--[[
	0x6010：服务器广播用户操作第三张牌
--]]
function RoomScene:onBroadcastGetThirdCard(data)
	--关闭头像倒计时
	self.mPlayer[data.seatid]:setTimeAnim(false)

	--如果是我获取第三张牌，要隐藏要牌等按钮
	if data.seatid==self:getMySeatId() then
		self:show3thCardOperateView(false)
	end

	--其余玩家要牌，则直接展示发牌动画
	if data.type==1 and data.seatid~=self:getMySeatId() then
		self.mPlayer[data.seatid]:setDealAnim({delay=0})
	end
end

--[[
	0x2006：服务器返回用户下注
--]]
function RoomScene:onBet(data)
	if data.retCode~=0 then
		if data.retCode==ERROR_CODE.UPBANKER_BET_TOTAL_TOO_MUCH then --不能超过庄家的1/3
			AlarmTip.play(Room_string.TOOMUCHTOBET)
		elseif data.retCode==ERROR_CODE.UPBANKER_BET_NOT_BET_STATE then
			self.m_viewChipIn:hideDown()
			self.m_betClock:stop()
		end
	else
		--隐藏下注弹窗以及倒计时
		self.m_viewChipIn:hideDown()
		self.m_betClock:stop()
	end
end

--[[
	0x6008：服务器广播玩家下注
--]]
function RoomScene:onBroadcastBet(data)
	local playerData = self.mPlayer[data.seatid];
	if playerData then
		playerData:setBet(data.ante)
		if playerData:getId()==MyUserData:getId() then
			self.m_viewChipIn:hideDown()
			self.m_betClock:stop()
			G_RoomCfg:setLatestBet(data.ante)
			self.super.onGameBegin(self,data)
		end
	end
end

--[[
	0x6012：服务器广播前两张牌
--]]
function RoomScene:onDeal2Cards(data)
	self.m_betClock:stop()
	self:showTableTip(false)

	--所有玩家发第一张牌
	local acc = 0
	for i=1,#self.mPlayer do
		local playerData = self.mPlayer[i]
		if playerData:getId()~=0 and playerData:getStatus()==1 then
			playerData:setDealAnim({delay =0.15*acc})
			acc = acc+1
		end
	end

	local tab = {}
	for i = 1, #data.pokdengCards do
		local user = data.pokdengCards[i]
		tab[user.seatId] = user.cards
	end

	--开牌
	local dealCallback = function (seatId)
		if seatId==self:getMySeatId() then--我发完了两张牌，要亮牌
			self.mPlayer[seatId]:setCards(data.myCards)
			self.mPlayer[seatId]:setOpenAnim({}) 
		elseif tab[seatId] then--其余玩家发到博定牌，发完牌之后要亮牌
			self.mPlayer[seatId]:setCards(tab[seatId])
			self.mPlayer[seatId]:setOpenAnim({}) 
		end
	end

    --所有玩家发第二张牌	
    for i=1,#self.mPlayer do		
    	local playerData = self.mPlayer[i]
		if playerData:getId()~=0 and playerData:getStatus()==1 then
			playerData:setDealAnim({index=2,delay=0.25*acc,callback = dealCallback})
			acc = acc+1
		end
	end
end

--请求上庄返回
function RoomScene:onUpBanker(data)
	JLog.d("onUpBanker",data);
	if data.error_code==0 then
		-- G_RoomCfg:setBankerId(MyUserData:getId())
		AlarmTip.play(Room_string.BE_REQUEST_DEALER_SUCCESS)
	--301不满足上庄最低钱 302已经请求上庄了 303钱数低于当前庄家携带的1.5倍 304上庄请求队列已满
	elseif data.error_code == 301 then
		AlarmTip.play(Room_string.BE_REQUEST_DEALER_LESS_THAN_LIMIT)
	elseif data.error_code == 302 then
		AlarmTip.play(Room_string.BE_REQUEST_DEALER_IN_QUEUE)
	elseif data.error_code == 303 then
		AlarmTip.play(Room_string.BE_REQUEST_DEALER_LESS_THAN_1_5)
	elseif data.error_code == 304 then
		AlarmTip.play(Room_string.BE_REQUEST_DEALER_FULL)
	end
end

--通知庄家可以选择开始游戏
function RoomScene:onBroadcastBankerCanStart(data)
	self:showBankerOperateView(true)
	AlarmTip.play(Room_string.TO_BEGIN_GAME)
end

--庄家选择开始游戏的返回
function RoomScene:onBankerStartRsp(data)
	JLog.d("RoomScene:onBankerStartRsp",data);

	if data.error_code==0 then
		self:showBankerOperateView(false)
	elseif data.error_code==400 then
		AlarmTip.play(Room_string.str_operate_err_1)	--玩家人数不够
	else
		AlarmTip.play("onBankerStartRsp error code = "..data.error_code)
	end
end

--[[
	游戏结束的结算排行榜
--]]
function RoomScene:onBigSettle(data)
	JLog.d("onBigSettle",data);
	-- data = {
	--     _11_time = "Thu Jun 29 16:06:08 2017",
	--     users = { {
	--             rank = 1,
	--             turnMoney = 87000,
	--             uid = 10002101,
	--             userInfo = '{"appid":0,"sex":0,"micon":"","nick":"4.1.1"}'
	--         }, {
	--             rank = 2,
	--             turnMoney = -87000,
	--             uid = 1,
	--             userInfo = '{"micon":"","appid":0,"nick":"dealer","sex":0}'
	--         } },
	--     waitTime = 5
	-- }	
	WindowManager:showWindow(WindowTag.Room_BigSettlePopu, {waitTime=data.waitTime,rankData=data.users,callback=function()
	    end,timeOut=function(self)
			self:dismiss(true)
	    end}, WindowStyle.POPUP)
end

return RoomScene