
local gameItem = import(".gameItem")
local LobbyScene = class(BaseScene)
local Command = require("app.lobby.command")
local friHeadLayout = requireview("app.view.view.friHeadLayout")

local cIndex = 0
local function getIndex()
	cIndex = cIndex + 1
	return cIndex
	
end

LobbyScene.s_controls = 
{
	--topView
	btn_head = getIndex(),
	nickTxt = getIndex(),
	expSlider = getIndex(),
	levelTxt = getIndex(),
	iconVip = getIndex(),
	addCashBtn = getIndex(),
	cashNumTxt = getIndex(),
	chipTxt = getIndex(),
	addChipBtn = getIndex(),

	--middleView

	--bottomView
	inviteBtn = getIndex(),
	friendsBtn = getIndex(),
	feedbackBtn = getIndex(),
	messageBtn = getIndex(),
	storeBtn = getIndex(),
	moreBtn = getIndex(),
	welfareCenterBtn = getIndex(),
	hallNewMsgTip = getIndex(),
	friendNewTip = getIndex(),

	moreView = getIndex(),
	btnSetting = getIndex(),
	btnBoradcast = getIndex(),
}

LobbyScene.s_controlConfig = 
{
	[LobbyScene.s_controls.nickTxt] = {"topView","infoView","nickTxt"},
	[LobbyScene.s_controls.expSlider] = {"topView","infoView","expSlider"},
	[LobbyScene.s_controls.levelTxt] = {"topView","infoView","levelTxt"},
	[LobbyScene.s_controls.iconVip] = {"topView","infoView","iconVip"},
	[LobbyScene.s_controls.addCashBtn] = {"topView","topCashView","addCashBtn2"},
	[LobbyScene.s_controls.cashNumTxt] = {"topView","topCashView","cashNumTxt"},
	[LobbyScene.s_controls.chipTxt] = {"topView","topChipView","chipTxt"},
	[LobbyScene.s_controls.addChipBtn] = {"topView","topChipView","addChipBtn2"},

	[LobbyScene.s_controls.inviteBtn] = {"bottomView","inviteBtn"},
	[LobbyScene.s_controls.friendsBtn] = {"bottomView","friendsBtn"},
	[LobbyScene.s_controls.feedbackBtn] = {"bottomView","feedbackBtn"},
	[LobbyScene.s_controls.messageBtn] = {"bottomView","messageBtn"},
	[LobbyScene.s_controls.hallNewMsgTip] = {"bottomView","messageBtn", "img_newTip"},
	[LobbyScene.s_controls.friendNewTip] = {"bottomView","friendsBtn", "img_newTip"},

	[LobbyScene.s_controls.storeBtn] = {"bottomView","storeBtn"},
	[LobbyScene.s_controls.moreBtn] = {"bottomView","moreBtn"},
	[LobbyScene.s_controls.welfareCenterBtn] = {"bottomView","welfareCenterBtn"},
	
	[LobbyScene.s_controls.btn_head] = {"topView","infoView","btn_head"},

	[LobbyScene.s_controls.moreView] = {"moreView"},
	[LobbyScene.s_controls.btnSetting] = {"moreView","btn_setting"},
	[LobbyScene.s_controls.btnBoradcast] = {"broadcastView","btn_boradcast"},

}


function LobbyScene:ctor(viewConfig,controller,param)
	print("LobbyScene:ctor")
	EventDispatcher.getInstance():register(HttpModule.s_event, self, self.onHttpRequestsCallBack);
    EventDispatcher.getInstance():register(Event.Call, self, self.onNativeCallBack)

    --初始化UI
    --兼容下马哈
    MyApkUpdateInfo = MyApkUpdateInfo or setProxy(new(require("data.apkUpdateInfo")))    
	
	GameSetting:setLevel(1)
	GameSetting:save()
	self:initProtocol()
	self:initView()

	-- JLog.d("LobbyScene ctor",param)
	-- local delayAnim = self.m_root:addPropTranslate(1001, kAnimNormal, 1, 0, 0, 0, 0, 0)
 --    delayAnim:setEvent(nil, function()
 --        -- delete(textNode)
 --        self:dealLoginSuccess(param)
 --    end)
	-- self:dealLoginSuccess(param)
end

function LobbyScene:initProtocol()
	self.m_reader		= new(require('app.lobby.command_reader'))
	self.m_writer		= new(require('app.lobby.command_writer'))
	self.m_processer 	= new(require('app.lobby.command_processer'),self)

	GameSocketMgr:addCommonSocketReader(self.m_reader);
	GameSocketMgr:addCommonSocketWriter(self.m_writer);
	GameSocketMgr:addCommonSocketProcesser(self.m_processer);
end

function LobbyScene:initView()
	UIEx.bind(self, MyUserData, "money", function(value)
		local chipTxt = self:getControl(LobbyScene.s_controls.chipTxt)
		chipTxt:setText(ToolKit.formatMoney(value))
	end)
	UIEx.bind(self, MyUserData, "cashPoint", function(value)
		local cashNumTxt = self:getControl(LobbyScene.s_controls.cashNumTxt)
		cashNumTxt:setText(value)
	end)
	UIEx.bind(self, MyUserData, "nick", function(value)
		local nickTxt= self:getControl(LobbyScene.s_controls.nickTxt)
        ToolKit.formatTextLength(value, nickTxt, 120)
	end)
    UIEx.bind(self, MyUserData, "level", function(value)
    	local levelTxt = self:getControl(LobbyScene.s_controls.levelTxt)
        levelTxt:setText("Lv." .. value)
    end)
    -- UIEx.bind(self, MyUserData, "exp", function(value)

    -- end)
	UIEx.bind(self, MyUserData, "exp", function(fileName)
		self:initLevel()
	end)

    -- 为头像绑定数据源
	UIEx.bind(self, MyUserData, "headName", function(fileName)
		if self.m_headImage then
			self.m_headImage:removeSelf()
			self.m_headImage = nil;
		end
	    local headView = self.m_root:findChildByName("topView"):findChildByName("infoView"):findChildByName("img_headBg"):findChildByName("headBtn")
	    headView:setScaleOffset(0.99)
	    local width, height = headView:getSize()
	    self.m_headImage = new(ImageMask, fileName, "lobby/hall_avator_bg.png");
	    self.m_headImage:setSize(width, height)
	    self.m_headImage:setName("headImage")
	    --self.m_headImage:setAlign(kAlignCenter)
	    self.m_headImage:addTo(headView)
		MyUserData:checkHeadAndDownload()
	end)

	UIEx.bind(self, MyUserData, "hasUnckeckMsg", function(val)
		local unReadMsgPointTip = self:getControl(LobbyScene.s_controls.hallNewMsgTip)
		if val then
			--todo
			unReadMsgPointTip:show()
		else
			unReadMsgPointTip:hide()
		end
	end)

	local friendNewTip = self:getControl(LobbyScene.s_controls.friendNewTip)
	UIEx.bind(self, MyUserData, "unreadApply", function(value)
		local friendNewTip = self:getControl(LobbyScene.s_controls.friendNewTip)

		if MyUserData:getUnreadApply() > 0 then
			friendNewTip:setVisible(true)
		else
			friendNewTip:setVisible(false)
		end
	end)

	self:getControl(LobbyScene.s_controls.iconVip):hide()

	self:findChildByName("img_speakerLight"):addPropRotate(4, kAnimRepeat, 5000, 0, 0, 360, kCenterDrawing)

	self:initLevel()

	self:addMiddlePart()
end

function LobbyScene:addMiddlePart()
	--创建主游戏按钮
	local gameIds = app:getGameIds()
	local gameId = gameIds[1]
	if gameId then
		local mainGame = new(require("app.lobby.ui.lobbyGameButton"), gameId, "big")
		mainGame:setAlign(kAlignCenter)
		mainGame:setName("btn_mainGame")
		self:initButtonClick(mainGame)
		self:findChildByName("mainGameView"):addChild(mainGame)
	end

	--推荐游戏
	gameId = gameIds[2]
	if gameId then
		local mainGame = new(require("app.lobby.ui.lobbyGameButton"), gameId, "mid1")
		mainGame:setAlign(kAlignCenter)
		mainGame:setName("btn_mid1")
		self:initButtonClick(mainGame)
		self:findChildByName("hotGameView"):addChild(mainGame)
	end

	--获取最近常玩的游戏id
	local gameRecord = GameSetting:playRecord()
	gameId = tonumber(GAME_ID.PokdengCash)
	for i = 1, #gameRecord do
		if gameRecord[i] ~= gameIds[1] and gameRecord[i] ~= gameIds[2] then 
			gameId = gameRecord[i]
			break
		end		
	end

	--创建最近常玩按钮
	if gameId then
		local mainGame = new(require("app.lobby.ui.lobbyGameButton"), gameId, "mid2")
		mainGame:setAlign(kAlignCenter)
		mainGame:setName("btn_mid2")
		self:initButtonClick(mainGame)
		self:findChildByName("recentGameView"):addChild(mainGame)
	end
	
	--创建敬请期待按钮
	gameId = 0
	if gameId then
		local mainGame = new(require("app.lobby.ui.lobbyGameButton"), gameId, "mid3")
		mainGame:setAlign(kAlignCenter)
		mainGame:setName("btn_mid3")
		--self:initButtonClick(mainGame)
		self:findChildByName("moreGameView"):addChild(mainGame)
	end
end

function LobbyScene:initButtonClick(gameBtn)
	gameBtn:setOnClickButton(
		self,
		function(self)
			--破产了，不让进房间，弹出破产提示框
			local gameId = gameBtn:getGameId()
			if MyUserData:getMoney() < gBankrupt then
				WindowManager:showWindow(WindowTag.BankruptPopu, {state = 1, gameId = gameId, level = nil}, WindowStyle.POPUP)
				return
			end			
			if gameId > 0 then
				local game = app:getGame(gameId)
				if game then
					--判断是否低于最低底注，低的话不让进房间
					local roomList = game:getRoomList()
					if roomList then
						local room = roomList:get(1);
						--钱少于最低筹码要求，都进不去
						if room then
							if (gameId ~= 1004 and room.minchip and room.minchip > MyUserData:getMoney())
							or (gameId == 1004 and room:getAnte() > MyUserData:getMoney()) then
								WindowManager:showWindow(
									WindowTag.LobbyExitPopu,
									{
										content = STR_MONEY_LESS_THAN_MIN,
										confirm = STR_EXIT_GAME_CONFIRM,
									},
									WindowStyle.POPUP
								)
								return
							end
						end

					end
					--未获取房间列表，刷新
					if not game:enterRoom() then
						app:checkAndDownloadRoomList(gameId, 1, false)
						AlarmTip.play(STR_NETWORK_TERRIBLE_AND_RETRY)
					end
				end
				app:postFrontStaticstics(string.format('click%sQuickStart', gameId))
			else
				--AlarmTip.play(STR_GAME_CLOSED);
			end
		end
	)
	--选房
	gameBtn:setOnChooseRoom(
		self,
		function(self)
			--破产了，不让进房间，弹出破产提示框
			local gameId = gameBtn:getGameId()
			if MyUserData:getMoney() < gBankrupt then
				WindowManager:showWindow(WindowTag.BankruptPopu, {state = 1, gameId = gameId, level = nil}, WindowStyle.POPUP)
				return
			end		
			if gameId > 0 then
				local game = app:getGame(gameId)
				if game then
					game:enterLobby()
				end
				app:postFrontStaticstics(string.format('click%sChooseGame', gameId))
			else
				AlarmTip.play(STR_GAME_CLOSED);
			end
	end)
end

function LobbyScene:initLevel()
    local lv = tonumber(MyUserData:getLevel())
    local exp = tonumber(MyUserData:getExp()) 
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
    local progress = self:findChildByName("topView"):findChildByName("infoView"):findChildByName("img_exp_progressBg"):findChildByName("img_exp_progressFg")
    --经验的底图和背景一起，写死长度
    local maxLen = 87
    local minLen, h = progress:getSize()
    minLen = 0;
    progress:setSize(minLen + (maxLen - minLen) * percent / 100, h)
end

function LobbyScene:onAddCashBtnClick()
	print("onAddCashBtnClick")
	WindowManager:showWindow(WindowTag.ShopPopu, {tab = 2}, WindowStyle.TRANSLATE_RIGHT)
end

function LobbyScene:onAddChipBtnClick()
	print("onAddChipBtnClick")
	WindowManager:showWindow(WindowTag.ShopPopu, {}, WindowStyle.TRANSLATE_RIGHT)

end

function LobbyScene:onFriendsBtnClick()
	print("onFriendsBtnClick")
	WindowManager:showWindow(WindowTag.FriendsPopu, {}, WindowStyle.POPUP)
end

function LobbyScene:onInviteBtnClick()
	print("onInviteBtnClick")
	WindowManager:showWindow(WindowTag.FbInvitePopu, {}, WindowStyle.POPUP)	
end

function LobbyScene:onMessageBtnClick()
	print("onMessageBtnClick")
	WindowManager:showWindow(WindowTag.MessagePopu, {}, WindowStyle.POPUP)
end

function LobbyScene:onStoreBtnClick()
	print("onStoreBtnClick")
	WindowManager:showWindow(WindowTag.ShopPopu, {}, WindowStyle.TRANSLATE_RIGHT)
	
end

function LobbyScene:onMoreBtnClick()
	-- print("onMoreBtnClick")
	-- local data = {gameId = tonumber(GAME_ID.Casinohall),level = 201}
	-- local createConfig = CreateRoomConfigData:getConfigByGameId(data.gameId)
	-- local config = createConfig:getConfigByLevel(data.level)
	-- -- dump(config,"config level:"..(data.level or ""))
	-- StateChange.changeState(States.Game_Pokdeng,{gameId = data.gameId,config=config,roomCode = 222222},StateStyle.TRANSLATE_TO)
	local moreView = self:getControl(LobbyScene.s_controls.moreView)
	moreView:setVisible(not moreView:getVisible())
end

--福利中心按钮
function LobbyScene:onWelfareCenterClick()
end

function LobbyScene:onTaskBtnClick(  )
	WindowManager:showWindow(WindowTag.DailyTaskPopu, {}, WindowStyle.POPUP)	
end

function LobbyScene:onBtnBoradcast()
	WindowManager:showWindow(WindowTag.SpeakerPopu, {}, WindowStyle.POPUP)
end

--已加入福利中心
function LobbyScene:onWheelClick()
	if self.turntableData then
		WindowManager:showWindow(WindowTag.WheelPopu, self.turntableData.data, WindowStyle.POPUP)
	else
		self.isShowTurntable = true
		HttpModule.getInstance():execute(HttpModule.s_cmds.Turntable_GET_TABLE_CFG, {["mid"] = MyUserData:getId()}, false, false)
	end
end

function LobbyScene:requestCreateRoom(param)
	self:showLoadingAnim(true)
	local userInfo = {appid = 0, nick = MyUserData:getNick(), sex = MyUserData:getSex(), micon = MyUserData:getHeadUrl(), giftId = MyUserData:getGiftId()}
	param.userInfo = json.encode(userInfo)
	JLog.d("LobbyScene:requestCreateRoom",param);
	GameSocketMgr:sendMsg(Command.CREATE_PRIVATEROOM_REQ,param)
end

function LobbyScene:requestRoomByLevel(gameId,level)
	self:showLoadingAnim(true)
	JLog.d("LobbyScene:requestRoomByLevel gameId",gameId,"level",level);
	if not level then return end
	local userInfo = {appid = 0, nick = MyUserData:getNick(), sex = MyUserData:getSex(), micon = MyUserData:getHeadUrl(), giftId = MyUserData:getGiftId()}
	GameSocketMgr:sendMsg(Command.RANDOM_ENTER_PRIVATEROOM_ERQ,{gameid=tonumber(gameId),level = level,userInfo=json.encode(userInfo), is_reconnect = 0})
end

--创建筹码场
function LobbyScene:onCreateRoomClick()
	local gameId = tonumber(GAME_ID.Casinohall)
	if not MyRoomConfig:get(gameId) then
		if DEBUG_MODE then
			AlarmTip.play("PHP没有返回建房参数")
		end
		return
	end
	
	local callback = function(param)
		JLog.d("create Chip Room callback",param)
		self:requestCreateRoom(param)
		WindowManager:closeWindowByTag(WindowTag.CreateRoomPopu)
		self:showLoadingAnim(true)
	end
	WindowManager:showWindow(WindowTag.CreateRoomPopu, {gameId = tonumber(GAME_ID.Casinohall),createType ="chipType",callback = callback}, WindowStyle.POPUP)
end

--筹码场快速开始
function LobbyScene:onQuickEnterClick()
	local gameId = tonumber(GAME_ID.Casinohall);	
	local pokdengGame = app:getGame(gameId);
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
		-- pokdengGame:enterRoom();
	else
		JLog.d("not exist this game!",gameId);
	end
	
end

function LobbyScene:onBtnHeadClick()
	WindowManager:showWindow(WindowTag.UserInfoPopu, {}, WindowStyle.POPUP)
end

function LobbyScene:onBtnNewsBulletin()
	WindowManager:showWindow(WindowTag.MessagePopu, {}, WindowStyle.POPUP)
	self:getControl(LobbyScene.s_controls.moreView):setVisible(false)
end

function LobbyScene:onBtnSettingCallBack(evt)
	-- body
	WindowManager:showWindow(WindowTag.SettingPopu, {}, WindowStyle.POPUP)
	self:getControl(LobbyScene.s_controls.moreView):setVisible(false)
end

function LobbyScene:onBtnFeedBackCallBack(evt)
	-- body
	WindowManager:showWindow(WindowTag.FeedbackPopu, {}, WindowStyle.POPUP)
	self:getControl(LobbyScene.s_controls.moreView):setVisible(false)
end

--每日任务，已添加至福利中心
function LobbyScene:onActivityBtnClick(evt)
	WindowManager:showWindow(WindowTag.DailyTaskPopu, {}, WindowStyle.POPUP)
end


function LobbyScene:loadGameList()
end

function LobbyScene:resume(bundleData)
	LobbyScene.super.resume(self)
	JLog.d("LobbyScene resume", bundleData);
	if bundleData and next(bundleData) ~=nil then
		self:dealLoginSuccess(bundleData)
	else
		self:updateUserInfo()

		--更新好友列表
		if self.friListData then
			self:onGetFriendsList(true, self.friListData)	
		end
		HttpModule.getInstance():execute(HttpModule.s_cmds.GET_FRIENDS_LIST, {gameid = PhpManager:getGame()}, true)
	end	

	if MyUserData:getId() ~= 0 then
		kMusicPlayer:play(Music.AudioHallBack, true)
		kMusicPlayer:setVolume(GameSetting:getMusicVolume())
	end

    if GameSetting.showPrivateRoomPopu then
        WindowManager:showWindow(WindowTag.PrivateRoomPopu, {}, WindowStyle.NORMAL)
        GameSetting.showPrivateRoomPopu = false
    end

	-- 签到
	-- HttpModule.getInstance():execute(HttpModule.s_cmds.SIGN_IN_LOAD, {}, false, false)
	-- 登陆抽奖
	self:showExpPopu(MyUserData:getExp());
	-- HttpModule.getInstance():execute(HttpModule.s_cmds.GET_UPGRADE_REWARD, {level = 2}, false, true)	

	-- 

	--选场次弹窗
	-- local callback = function(level)
	-- 	local gameId = GAME_ID.Casinohall;
	-- 	self:requestRoomByLevel(gameId,level);
	-- 	JLog.d("LobbyScene:onEnterChipRoomClick callback",level);
	-- 	WindowManager:closeWindowByTag(WindowTag.RoomListPopu);
	-- end
	-- WindowManager:showWindow(WindowTag.ChooseRoomPopup, {lobbyScn = self, gameId = tonumber(GAME_ID.Casinohall),callback = callback}, WindowStyle.POPUP)	
end

function LobbyScene:showExpPopu(exp)
	local level = MyUserData:getLevel()
	--用户经验信息
	if type(exp) == "number" then
		for i = 1,#userLevelExp do
			local x1 = userLevelExp[i].x1 
			local x2 = userLevelExp[i].x2 
			if exp >= x1 and exp < x2 then
				printInfo('levely1 = ' .. i)
				if level == i then --已领取等级奖励
					--AlarmTip.play('已领取等级奖励')
				else --未领取等级奖励
					--请求领取礼包
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

function LobbyScene:dealLoginSuccess(bundleData)
	-- JLog.d("dealLoginSuccess判断是否为空",next(bundleData))
	if bundleData then
		--播放大厅背景音乐
        kMusicPlayer:play(Music.AudioHallBack, true)
        kMusicPlayer:setVolume(GameSetting:getMusicVolume())
        --支付的登陆回调
        MyPay:logincb()
        --获取支付码
        if not MyPayMode then
            HttpModule.getInstance():execute(HttpModule.s_cmds.GET_PAY_MODE, {}, true, true);
        end

        if bundleData.aUser and bundleData.aUser.haveMessage then
            HallConfig:setHasUnckeckMsg(tonumber(bundleData.aUser.haveMessage or 0) > 0)
        end

        --是否有好友未读消息
        HttpModule.getInstance():execute(HttpModule.s_cmds.FRIEND_UNREAD, {}, false, false);
        --是否有任务奖励
        HttpModule.getInstance():execute(HttpModule.s_cmds.HAS_TASK_AWARD, {mid = MyUserData:getId()}, false, false);
		HttpModule.getInstance():execute(HttpModule.s_cmds.GET_PAY_MODE, {}, false, false)
        HttpModule.getInstance():execute(HttpModule.s_cmds.GET_FRIENDS_LIST, {gameid = PhpManager:getGame()}, true)
        -- dump(bundleData.registerAward,"bundleData.registerAward")
   --      if bundleData.registerAward then
	  --       local money = bundleData.registerAward.addmoney or 0;
	  --       local mtype = bundleData.registerAward.type or 0
	  --       local days = bundleData.registerAward.days or 0
			-- --mtype:1 登录成功 0：登录失败
	  --       if mtype == 1 then
	  --       	WindowManager:showWindow(WindowTag.RegisterAwardPopu, {day=days}, WindowStyle.POPUP)
	  --       else
			-- 	HttpModule.getInstance():execute(HttpModule.s_cmds.Turntable_GET_TABLE_CFG, {["mid"] = MyUserData:getId()}, false, false)
	  --       end
	  --   end
	 	 MyGameVerManager:loadGameOnDisk()
	end

	if bundleData.isCreate then
		WindowManager:showWindow(WindowTag.RegisterAwardPopu, {day=1,waitTime=3824}, WindowStyle.POPUP)
	else
		HttpModule.getInstance():execute(HttpModule.s_cmds.SIGN_IN_LOAD, {}, false, false)
	end

	HttpModule.getInstance():execute(HttpModule.s_cmds.Turntable_GET_TABLE_CFG, {["mid"] = MyUserData:getId()}, false, false)
	HttpModule.getInstance():execute(HttpModule.s_cmds.VERSION_UPDATE_MSG, {}, false, false)

	self:updateUserInfo()
end

function LobbyScene:updateUserInfo()
	-- if MyUserData:getIsLogin() then
		MyUserData:setNick(MyUserData:getNick())
		MyUserData:setMoney(MyUserData:getMoney())
		MyUserData:setRoomCardNum(MyUserData:getRoomCardNum())
		MyUserData:setLevel(MyUserData:getLevel())
		MyUserData:setHeadName(MyUserData:getHeadName())
		MyUserData:setCashPoint(MyUserData:getCashPoint())
	-- end
end

function LobbyScene:pause()
	LobbyScene.super.pause(self)
end

function LobbyScene:dtor()
	EventDispatcher.getInstance():unregister(HttpModule.s_event, self, self.onHttpRequestsCallBack);
	EventDispatcher.getInstance():unregister(Event.Call, self, self.onNativeCallBack);
	kMusicPlayer:stop(true)
end

function LobbyScene:showAddMoneyAnim(...)
	local AddMoneyAnim = require("app.animation.animAddMoney")
	new(AddMoneyAnim)
		:addTo(self)
		:play( {
			money = ...,
			pos = {x = 220, y = 100},
		})
end

function LobbyScene:showLoadingAnim(value)
	if value then
		JLog.d("显示loading！！！！！");

		local loadingStr = Hall_string.STR_LOGIN_LOADING
		app:showLoadingTip(loadingStr,true)
	else
		app:hideLoadingTip()
	end

	-- local loadingStr = "正在加载"
	-- if not self.toastShade then
	-- 	self.toastShade = new(ToastShade, true, loadingStr, false)
	-- 	self:addChild(self.toastShade)
	-- 	self.toastShade:setLevel(1000);
	-- end
	-- self.toastShade:setIsShowBg(isShowBg)
	-- if loadingStr then
	-- 	self.toastShade:setLoadingText(loadingStr);
	-- end
	-- self.toastShade:play()
end

function LobbyScene:onBack()
	-- JLog.d("LobbyScene:onBack",WindowManager:onKeyBack());
	if WindowManager and not WindowManager:onKeyBack() then
		JLog.d("WindowManager:onKeyBack()！！！");
	    WindowManager:showWindow(WindowTag.MessageBox, {text = Hall_string.STR_EXITGAME,rightFunc=function()
	    	self:exitGame()
	    end}, WindowStyle.POPUP)

	    self:showLoadingAnim(false)
	end
end

function LobbyScene:exitGame()
	-- --检查启动时游戏升级状态是否正常，不正常恢复到升级前版本
	MyGameVerManager:checkUpdateFinish()
	NativeEvent.getInstance():Exit()
	GameSocketMgr:closeSocketSync()
end

--HTTP回调
function LobbyScene:onHttpRequestsCallBack(command, ...)
	if self.s_severCmdEventFuncMap[command] then
     	self.s_severCmdEventFuncMap[command](self,...)
	end 
end

--native callback
function LobbyScene:onNativeCallBack(key, data, result)
	if key == kActivityGoFunction then
	    self:onActivityToFunction(data)
	elseif key == kActCenter then
		--todo
		JLog.d("LobbyScene:onNativeCallBack[key :" .. key .. ", result :" .. result .. "].data :=============", data)
	end
end

-- 处理活动界面事件
function LobbyScene:onActivityToFunction(data)
	local target = data.target:get_value(); -- 跳转常量
	if kMessage == target then
		WindowManager:showWindow(WindowTag.NoticePopu, {}, WindowStyle.POPUP)
	elseif kGame == target then
		local param = data.desc;   -- 参数
		if param and type(param) == 'table' then
			local gameId = param.gameid:get_value()
			if gameId then
				local game = app:getGame(gameId)
				if game then 
					game:enterRoom() 
				else
					AlarmTip.play(STR_GAME_CLOSED);
				end
			end
		end
	elseif kRoom == target then
		local param = data.desc;   -- 参数
		if param and type(param) == 'table' then
			local gameId = param.gameid:get_value()
			if gameId then
				local game = app:getGame(gameId)
				if game then 
					game:enterLobby() 
				else
					AlarmTip.play(STR_GAME_CLOSED);
				end
			end
		end
	elseif kInvite == target then
		WindowManager:showWindow(WindowTag.FbInvitePopu, {}, WindowStyle.POPUP)
	elseif kTask == target then
		WindowManager:showWindow(WindowTag.TaskPopu, {}, WindowStyle.POPUP)
	elseif kShare == target then
		local param = data.desc;   -- 参数
		if param and type(param) == 'table' then
			if param.type and param.type:get_value() == 'facebook' then
				NativeEvent.getInstance():share({
				name = param.name and param.name:get_value() or '',
				caption = param.caption and param.caption:get_value() or '',
				link = param.link and param.link:get_value() or '',
				picture = param.picture and param.picture:get_value() or '',
				message = param.message and param.message:get_value() or '',
                from = "activity",
				})
			end
		end
	elseif kShop == target then
        local param = data.desc;
        local pmode = param and param.pmode:get_value()
        local props = param and param.props:get_value()
		WindowManager:showWindow(WindowTag.ShopPopu, {pmode = pmode, to = props}, WindowStyle.TRANSLATE_RIGHT)
	end

end

function LobbyScene:onGetFriendUnread(isSuccess, data)
	JLog.d("LobbyScene:onGetFriendUnread", isSuccess, data)
	if app:checkResponseOk(isSuccess, data) then
		MyUserData:setUnreadApply(data.data.applyNum);
    	MyUserData:setUnreadGigt(data.data.giftNum);
	end
end

function LobbyScene:onGetVersionUpdateMsg(isSuccess, data)
	if app:checkResponseOk(isSuccess, data) then
		if data.data.state == 1	then
			WindowManager:showWindow(WindowTag.AnnouncePopu, data.data, WindowStyle.POPUP)
		end
	end
end

function LobbyScene:updateUserInfos(...)
	self:updateUserInfo()
end

--在大厅如果收到送礼物的广播，接收里的人有我，那么给个toast提示
function LobbyScene:onGiftSendBroadcast(data)
    printInfo("LobbyScene:onGiftSendBroadcast ")
dump(data)
    local receiver = data.receiver
    local giftId = data.gift
    for i = 1, #receiver do
        if receiver[i] == MyUserData:getId() then
            local giftList = MyUserData:getGiftList() or {}
            local gift = giftList[giftId[1]] and giftList[giftId[1]][giftId[2]]
            if gift then
                AlarmTip.play(string.format(STR_GIFT_GET_FROM_FRIEND, data.name, data.sender, gift:getName()))
            end
        end
    end
end

function LobbyScene:onShowSpeakerMsg(textNode)
	JLog.d("LobbyScene:onShowSpeakerMsg")
    local viewSpeaker = self:findChildByName("view_speaker")
    local viewContent = viewSpeaker:findChildByName("view_content")
    local x, y = viewContent:getPos()
    local w, h = viewContent:getSize()
    viewContent:setClip(x, y, w, h)
    viewContent:addChild(textNode)
    textNode:setAlign(kAlignCenter)
    --文字从最右边到最左边滚动
    local showAnim = textNode:addPropTranslate(1, kAnimNormal, (viewContent:getSize()+textNode:getSize())*8, 0, viewContent:getSize(), 0 - textNode:getSize(), 0, 0)
    showAnim:setEvent(nil, function()
        delete(textNode)
    end)
end

function LobbyScene:onHallActivityFinish(isSuccess,data)
    JLog.d("LobbyScene ShopPopu:onHallActivityFinish",data)
    if app:checkResponseOk(isSuccess, data) then
        if MyUserData.actFirstPayThirdWayOffi_id and data.data.activityId and 
            tonumber(data.data.activityId) == tonumber(MyUserData.actFirstPayThirdWayOffi_id) 
            and data.data.info then
            if data.data.info.className == 'actFirstPayThirdWay20' or data.data.info.className == 'actFirstPayThirdWay49' or
                data.data.info.className == 'actFirstPayOfficial' or data.data.info.className == 'actFirstPayOfficialCompatible' then
                --ชิปในกิจกรรม 金币
                MyUserData:addMoney(data.data.info.addMoney, false)

                local content = string.format("คุณได้รับรางวัลแถมในกิจกรรม รวมมี %s ชิป พลายแก้ว*%s วัน ไอเทม*%s การ์ด*%s บ้านเดี่ยว*1",
                    data.data.info.addMoney,data.data.info.elephant,data.data.info.inter,data.data.info.roomCard)
                WindowManager:showWindow(WindowTag.LobbyExitPopu, {
                    title = "",
                    close = true,
                    content = content,
                    confirm = STR_EXIT_GAME_CONFIRM,
                    
                }, WindowStyle.POPUP)
                MyUserData.actFirstPayThirdWayOffi_money = nil
                MyUserData.actFirstPayThirdWayOffi_id = nil
                MyUserData.actFirstPayThirdWayOffi_classname = nil
                WindowManager:closeWindowByTag(WindowTag.BankruptPopu)
                WindowManager:closeWindowByTag(WindowTag.ShopPopu)
                WindowManager:closeWindowByTag(WindowTag.ActCenterPopu)
            end
        end
    end
end

function LobbyScene:onTurntableGetTableCfg(isSuccess,data)
	if not app:checkResponseOk(isSuccess, data) then
		AlarmTip.play(data and data.codemsg or "")
		return
	end
	if not data.data.list then
		return
	end
	self.turntableData = data
	if self.isShowTurntable then
		WindowManager:showWindow(WindowTag.WheelPopu, data.data, WindowStyle.POPUP)
		self.isShowTurntable = nil
	end
end

--大厅加载好友列表
function LobbyScene:onGetFriendsList(isSuccess, data)

	if not isSuccess then 
		self.friListData = nil
		return 
	end

	self.friListData = data
	local friScrollView = self.m_root:findChildByName("bottomView"):findChildByName("friendScrollView")
	local friBtn = self.m_root:findChildByName("bottomView"):findChildByName("friendsBtn")

	--初始值备份
	if not self.friScrollViewSize then
		self.friScrollViewSize = friScrollView:getSize()
		self.friScrollViewPos = friScrollView:getPos()
		self.friBtnPos = friBtn:getPos()
	else
		friScrollView:setSize(self.friScrollViewSize)
		friScrollView:setPos(self.friScrollViewPos)
		friBtn:setPos(self.friBtnPos)
	end

	--好友列表设置
	friScrollView:setDirection(1)
	friScrollView:setScrollBarWidth(0)
	friScrollView:setAutoPosition(true)
	friScrollView:removeAllChildren()

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

		local friList = data.data.friendsList
		for i = 1, #friList do

			--设置头像
			local item 	= SceneLoader.load(friHeadLayout);			
			item:addTo(friScrollView)
			local friHeadImg = item:findChildByName("friHeadImg")
			local hallOfflineImg = item:findChildByName("hallOfflineImg")			

			local headData = setProxy(require("app.data.headData"))
			UIEx.bind(self, headData, "headName", function(value)
					if value and value~= "" then
						friHeadImg:setFile(value)
					    local shader = require("libEffect/shaders/imageMask");
					    shader.applyToDrawing(friHeadImg, {file = "lobby/hall_avator_bg.png", position = {0,0}});
					end
				end
			)
			headData:setSex(friList[i].msex)
			headData:setHeadUrl(friList[i].micon)
			headData:checkHeadAndDownload()
			if friList[i].isOnline == 0 then
				hallOfflineImg:show()
			else
				hallOfflineImg:hide()
			end
			local itemW, itemH = item:getSize()

			--头像个数小于5个将进行位置偏移
			if i < 6 then
				local w, h = friScrollView:getSize()
				friScrollView:setSize(w + itemW, itemH)

				local x, y = friBtn:getPos()
				friBtn:pos(x + itemW, y)
			end
		end
	end
end

LobbyScene.messageFunMap = {
	["SelectGameType"] 			= LobbyScene.onSelectGameType,
	["logout"] 					= LobbyScene.onLogout,
	["FaceBooklogin"]			= LobbyScene.onFaceBookLogin,
	["LobbyExitGame"] 			= LobbyScene.exitGame,
	["autoLogin"] 				= LobbyScene.onAutoLogin,
	["loginserver"] 			= LobbyScene.onLoginServer,
	["showAddMoneyAnim"] 		= LobbyScene.showAddMoneyAnim,
	['updateUserInfo']			= LobbyScene.updateUserInfos,
    ["giftSendBroadcast"]       = LobbyScene.onGiftSendBroadcast,
    ["acceptPrivateRoomInvite"] = LobbyScene.onAcceptPrivateRoomInvite,
    ["showBeginnerHelp"]        = LobbyScene.onShowBeginnerHelp,
    ["showSpeakerMsg"]          = LobbyScene.onShowSpeakerMsg,
}

LobbyScene.s_severCmdEventFuncMap = {	
	[HttpModule.s_cmds.FRIEND_UNREAD] 		= LobbyScene.onGetFriendUnread,
    [HttpModule.s_cmds.HALL_ACTIVITY_FINISH]        = LobbyScene.onHallActivityFinish,
    [HttpModule.s_cmds.VERSION_UPDATE_MSG]        = LobbyScene.onGetVersionUpdateMsg,
    [HttpModule.s_cmds.Turntable_GET_TABLE_CFG] = LobbyScene.onTurntableGetTableCfg,
    [HttpModule.s_cmds.GET_FRIENDS_LIST] 	= LobbyScene.onGetFriendsList,
}

LobbyScene.s_controlFuncMap = 
{
	[LobbyScene.s_controls.addCashBtn] = LobbyScene.onAddCashBtnClick,
	[LobbyScene.s_controls.addChipBtn] = LobbyScene.onAddChipBtnClick,
	[LobbyScene.s_controls.friendsBtn] = LobbyScene.onFriendsBtnClick,

	[LobbyScene.s_controls.inviteBtn] = LobbyScene.onInviteBtnClick,
	[LobbyScene.s_controls.messageBtn] = LobbyScene.onMessageBtnClick,
	[LobbyScene.s_controls.storeBtn] = LobbyScene.onStoreBtnClick,
	[LobbyScene.s_controls.moreBtn] = LobbyScene.onMoreBtnClick,
	[LobbyScene.s_controls.welfareCenterBtn] = LobbyScene.onWelfareCenterClick,
	
	[LobbyScene.s_controls.feedbackBtn] = LobbyScene.onBtnFeedBackCallBack,
	
	[LobbyScene.s_controls.btnSetting] = LobbyScene.onBtnSettingCallBack,

	[LobbyScene.s_controls.btn_head] = LobbyScene.onBtnHeadClick,
	[LobbyScene.s_controls.btnBoradcast] = LobbyScene.onBtnBoradcast,
}

function LobbyScene:onEnterRoom(data)
	self:showLoadingAnim(false)
	-- JLog.d("LobbyScene:onEnterRoom.data :===============", data)

	if data.reason==0 then --进房出错
	else
		if data.reason==1 then --创建房间进来的
			WindowManager:closeWindowByTag(WindowTag.CreateRoomPopu)
		elseif data.reason==2 then --输入房号进来的
			WindowManager:closeWindowByTag(WindowTag.EnterRoomPopu)
		end
		-- local targetState = nil
		-- if data.gameId==tonumber(GAME_ID.Casinohall) then
		-- 	targetState = States.Game_Pokdeng
		-- end
		-- if targetState==nil then
		-- 	AlarmTip.play("不支持该游戏"..data.gameId)
		-- 	return
		-- end

		-- local createConfig = CreateRoomConfigData:getConfigByGameId(data.gameId)
		-- local config = createConfig:getConfigByLevel(data.level)
		-- StateChange.changeState(targetState,{gameId = data.gameId,config=config,roomCode = data.roomCode,enterType=data.reason},StateStyle.TRANSLATE_TO,{jay ="hhhahaha"})
			
		-- if not self.pokdengGame then
		-- 	self.pokdengGame = new(require("app.games.pokdeng.chipGames.game"))
		-- end

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

return LobbyScene