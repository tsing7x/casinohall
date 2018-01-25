--jaywillou
--2017-1-21
--子类必须实现的方法：
--1.reLocateSeat() :根据自己的位置重新调整房间内所有玩家的位置
--2.getLocalSeatId(seatId) :根据玩家的seatId 返回本地的 localSeatId
--3.getChatPosition(seatId, x, y, w, h, mx, my):获取聊天显示位置
--4.playChatSound(chatInfo):播放音效
--5.isPlaying()--判断玩家是否在玩，能否直接离开
BaseRoomController = class(BaseController) 

addProperty(BaseRoomController, "stateFrom", nil)--来自于哪个状态机
addProperty(BaseRoomController, "followId", nil)--跟随目标玩家id

local AnimFace 		= require("animation.animFace")
local NewFaceConfig = require("room.chat.newExpressionCfg")
local FaceConfig 	= require("room.chat.faceConfig")
local AnimChat = require("animation/animChat")

function BaseRoomController:ctor(viewConfig,state,bundleData,...)
	self.delayId = 0;
	self.mPlayer = {};
	--HTTP
	EventDispatcher.getInstance():register(HttpModule.s_event, self, self.onHttpRequestsCallBack);
	EventDispatcher.getInstance():register(Event.onEventResume,self,self.onEventResume);
	EventDispatcher.getInstance():register(Event.onEventPause,self,self.onEventPause);
end


function BaseRoomController:dtor()
	delete(self.delayNode);
	self.delayNode = nil;
	EventDispatcher.getInstance():unregister(HttpModule.s_event, self, self.onHttpRequestsCallBack);
	EventDispatcher.getInstance():unregister(Event.onEventResume,self,self.onEventResume);
	EventDispatcher.getInstance():unregister(Event.onEventPause,self,self.onEventPause);

end


--必须初始化的数据
function BaseRoomController:initRoomController(mTableId,mPlayers)
	self.mTableId = mTableId;
	self.mPlayer = mPlayers;
end



--part1
--以下为：子类必须实现的方法----------start
--virtual
--根据自己的位置重新调整房间内所有玩家的位置
function BaseRoomController:reLocateSeat()
	error("Derived class must implement this function")
end

--virtual
--根据玩家的seatId 返回本地的 localSeatId
function BaseRoomController:getLocalSeatId(seatId)
	error("Derived class must implement this function")
end

--virtual
--获取指定seatId聊天显示位置
function BaseRoomController:getChatPosition(seatId, x, y, w, h, mx, my)
	error("Derived class must implement this function")
end

--virtual
--播放音效对应
function BaseRoomController:playChatSound(chatInfo)
	error("Derived class must implement this function")
end

--virtual
function BaseRoomController:getChatBg(seatId)
	error("Derived class must implement this function")
end

--virtual
function BaseRoomController:isPlaying()
	error("Derived class must implement this function")
end

--virtual
--发送协议，获取房间TableId
function BaseRoomController:getTableId()
	error("Derived class must implement this function")
end

--以上为：子类必须实现的方法----------end


--part2
--以下为：公用方法部分----------start
function BaseRoomController:delayFun(delayTime,func)
	if not self.delayNode then
		self.delayNode = new(Node);
		self.m_root:addChild(self.delayNode);	
	end
	self.delayId = self.delayId + 1;
	local delayId = self.delayId;
	checkAndRemoveOneProp(self.delayNode,delayId);
	local anim = self.delayNode:addPropTransparency(delayId, kAnimNormal, delayTime, 0, 1.0, 1.0) --延时
	if anim then
		anim:setEvent(nil,function ()
			if func then
				func();
			end
			checkAndRemoveOneProp(self.delayNode,delayId);
		end);
	end
end

--使用方法：开始计时用：local caculate = self:caculateTime();
--打印结果时用：caculate();
--计算代码执行时间
function BaseRoomController:caculateTime()
	local startTime = sys_get_int("tick_time",0);
	local function countDown()
	    local result = sys_get_int("tick_time",0) - startTime;
	    JLog.d("---------------run time",result.."ms");
	    return result;
  	end
  	return countDown;
end

--取得用户 
function BaseRoomController:getUserByUid(uid,players)
	local playerList = players or self.mPlayer;
    for k, v in pairs(playerList) do
		if v:getId() == uid then
			return v
		end
	end
    return nil;
end

function BaseRoomController:getPlayerCount(players)
	local playerList = players or self.mPlayer; 
	local count = 0
    for k, v in pairs(playerList) do
		if v:getId() ~= 0 then
			count = count + 1
		end
	end
    return count;
end


--获取自己的座位号
function BaseRoomController:getMySeatId(players)
	local playerList = players or self.mPlayer; 
	JLog.d("测试玩家个数",#playerList);
	for i = 1, #playerList do
		local player = playerList[i];
		if player:getId() == MyUserData:getId() then
			return player:getSeatId();
		end
	end
end

--获取自己对应的玩家
function BaseRoomController:getMyPlayer(players)
	local playerList = players or self.mPlayer; 
	local seatId = self:getMySeatId(players)
	if seatId then
		return playerList[seatId]
	end
end


function BaseRoomController:getUserInfo()
    return { appid = 0, nick = MyUserData:getNick(), sex = MyUserData:getSex(), micon = MyUserData:getHeadUrl(), giftId = MyUserData.giftId}
end

--以上为：公用方法部分----------end





--part3
--以下为：动画部分----------start

--显示loading 动画
function BaseRoomController:showLoadingAnim(loadingStr)	
	if not self.toastShade then
		self.toastShade = new(ToastShade, true, STR_LOAING, true)
		self:addChild(self.toastShade)
	end
	if loadingStr then
		self.toastShade:setLoadingText(loadingStr);
	end
    self.toastShade:play()
end

--隐藏loading 动画
function BaseRoomController:hideLoadingAnim()
	if self.toastShade then
		self.toastShade:stop()
	end
end


--AnimChat有问题,需要重写，需要添加：配置显示框功能
-- -- 聊天相关
function BaseRoomController:showChatWord(chatInfo, x, y, w, h, seatId)

	local srcx, srcy = x, y
	local srcw, srch = w, h
	local localSeatId 		= seatId
	local imgFace 			= new(Image, 'animation/roomAnim/word_bg_left.png')
	local imgChipW,imgChipH = imgFace.m_width, imgFace.m_height
	if not self.m_chatWord then
		self.m_chatWord = new(Node):addTo(self, 1000)
	end
	self.m_chatWord:removeAllChildren()
	local x, y = self:getChatPosition(localSeatId, srcx, srcy, srcw, srch, imgChipW, imgChipH)
	if not x or not y then return end

	-- local chatbg = nil;
	-- if self.getChatBg then
	-- 	chatbg= self:getChatBg(localSeatId);
	-- end
	local chatBg = self:getChatBg(localSeatId);
	JLog.d("测试所选聊天 localSeatId",localSeatId," chatBg",chatBg);

	local params = {
		seat = localSeatId,
		chatInfo = chatInfo,
		chatBg = chatBg,
		pos = ccp(x, y),
		isGame = true,
	}
	new(AnimChat):addTo(self.m_chatWord, 1000):play(params)
	self:playChatSound(chatInfo)
end


-- --展示表情
function BaseRoomController:showChatFace(faceIndex, mid)
	if not self.m_chatFace then
		self.m_chatFace = new(Node):addTo(self, 1001);
	end
	self.m_chatFace:removeAllChildren()	
	local player  = self:getUserByUid(mid);
	if not player then return end
	local srcx, srcy = player:getUi():getPos();
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
	local imgFace 		= new(Image, img)
	local imgChipW,imgChipH = imgFace.m_width, imgFace.m_height
	local x,y = srcx + (srcw - 110)/2, srcy + (srch - 110)/2
	local params = {
		num = imgCount,
		playCount = playCount,
		faceName = faceName,
		duration = playTime,
		pos = ccp(x, y),
	}
	new(AnimFace):addTo(self, 1001):play(params);
end

--单个玩家坐下动画(私有方法,请勿手动调用)
function BaseRoomController:singleSitdownAnim(player,func)
	if player then
		local viewHead 	= player:getUi():findChildByName("view_phead");
		local x, y  	= viewHead:getAbsolutePos();
		local w, h  	= viewHead:getSize();
		local sw, sh 	= 1280, 720;
		local dx, dy 	= (sw - w) / 2 - x, (sh - h) / 2 - y;
		checkAndRemoveOneProp(viewHead, 1);
		local sitdownAnim = viewHead:addPropTranslateWithEasing(1, kAnimNormal, 500, 0, "easeOutSine", "easeOutSine", 0, dx, 0, dy);
		sitdownAnim:setEvent(self, function()
				checkAndRemoveOneProp(viewHead, 1);
				--重新排位
				self:reLocateSeat();
				local x, y  	= viewHead:getAbsolutePos();
				local dx, dy 	= (sw - w) / 2 - x, (sh - h) / 2 - y;
				local sitdownAnim = viewHead:addPropTranslateWithEasing(1, kAnimNormal, 500, 0, "easeOutSine", "easeOutSine", dx, -dx, dy, -dy);
				sitdownAnim:setEvent(self, function()
					checkAndRemoveOneProp(viewHead, 1);					
				end);

				if func then
					func(player);
				end
		end);
	end
end

--所有玩家坐下动画
function BaseRoomController:playSitdownAnim(func)
	for i=1,#self.mPlayer do
		-- if i ==1 then
		-- 	self:singleSitdownAnim(self.mPlayer[i],func);
		-- else
		-- 	self:singleSitdownAnim(self.mPlayer[i]);
		-- end	
		self:singleSitdownAnim(self.mPlayer[i],func);
	end
end


function BaseRoomController:showExpPopu(exp)
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

--以上为：动画部分----------end



--part4
--以下为：协议部分----------
--服务器退休
function BaseRoomController:onServerRetire(data)
    StateChange.changeState(States.Lobby)
end


--接收server返回道具信息
function BaseRoomController:onSendProp(data)
 --此处处理广播消息,收到发送道具之后
 	local msgInfo 	 = json.decode(data.msg_info);
   	if data.mid ~= 0 and data.dest_mid == 0 then
   		local srcPlayer  = self:getUserByUid(data.mid)
   		if not srcPlayer then
	   		return 
	   	end

	   	local dealer = self:findChildByName('btn_dealer');
	    if data.type == 1 then
	   		if dealer then 	
		   		local srcx, srcy = srcPlayer:getUi():getPos()
			   	local dstx, dsty = dealer:getAbsolutePos();
			   	local dstw, dsth = dealer:getSize()
			   	self.mAnimFriend:play(msgInfo.id, {x = srcx , y = srcy}, {x = (dstx + 15), y = dsty + 20})
	            if(msgInfo.id ~= 2003 and msgInfo.id ~= 2004 and msgInfo.id ~= 2005) then
			   	    self:showChatWord(STR_DEALER_NEGATIVE[math.random(1, #STR_DEALER_NEGATIVE)], dstx + 30, dsty + 30, dstw, dsth, 10);
	            else
	                self:showChatWord(STR_DEALER_POSITIVE[math.random(1, #STR_DEALER_POSITIVE)], dstx + 30, dsty + 30, dstw, dsth, 10);
	            end
	        end
	    elseif data.type == 2 then --处理送筹码
	    	if dealer then
				local dstx, dsty = dealer:getAbsolutePos();
				local dstw, dsth = dealer:getSize();
				self:playSendChipAnim(srcPlayer, {dstx = dstx, dsty = dsty, dstw = dstw, dsth = dsth}, tonumber(msgInfo.addMoney or 0))
				local random = math.random(1, 6)
				if MyUserData:getSex() == 0 then
					self:showChatWord(DEALER_MAN[random], dstx - 10, dsty + 20, dstw, dsth, 10)
				else
					self:showChatWord(DEALER_WOMAN[random], dstx - 10, dsty + 20, dstw, dsth, 10)
				end
			end
	    end
   	else
   		local srcPlayer  = self:getUserByUid(data.mid)
   		local dstPlayer  = self:getUserByUid(data.dest_mid)
   		if not srcPlayer or not dstPlayer then
	   		return 
	   	end
	    if data.type == 1 then
	   		local srcx, srcy = srcPlayer:getUi():getPos()
		   	local dstx, dsty = dstPlayer:getUi():getPos()
		   	self.mAnimFriend:play(msgInfo.id, {x = srcx, y = srcy}, {x = dstx, y = dsty})
	    elseif data.type == 2 then --处理送筹码
	    	local dstx, dsty = dstPlayer:getUi():getPos()
			local dstw, dsth = dstPlayer:getUi():getSize()
	    	dstPlayer:addChip(tonumber(msgInfo.addMoney or 0))
			self:playSendChipAnim(srcPlayer, {dstx = dstx, dsty = dsty, dstw = dstw, dsth = dsth}, tonumber(msgInfo.addMoney or 0))
		elseif data.type == 4 then --添加好友
	   		local srcx, srcy = srcPlayer:getUi():getPos()
		   	local dstx, dsty = dstPlayer:getUi():getPos()
		   	self.mAnimFriend:play(3000, {x = srcx, y = srcy}, {x = dstx, y = dsty})
        elseif data.type == 6 then  --玩家发送付费表情
            local pnid = msgInfo.pnid
            local index = msgInfo.id
            if pnid and index then
	            local srcx, srcy = srcPlayer:getUi():getPos();
	            local srcw, srch = srcPlayer:getUi():getSize(); 
                local expression = NewFaceConfig[index]
                if not expression then
                    return
                end
                local expressionName = expression.imgName
                local packFile = expression.packFile
                local animExpression = new(require("animation.animFrame"), expression.imgName, 
                    require(expression.packFile), expression.deltaTime, expression.repeatTime)
                animExpression:setPos(srcx, srcy - 35)
                animExpression:play()
                self:findChildByName("view_players"):addChild(animExpression)            
            end
		end


   	end
end

function BaseRoomController:onSendFace(data)
	-- AlarmTip.play('showFace')
	if data.mid and data.type and data.isVipFace then
		self:showChatFace(data.type, data.mid);
	end
end




function BaseRoomController:onSendChat(data)
	if data.mid and data.msg then
		local player  = self:getUserByUid(data.mid);
		if not player then return end
		local srcx, srcy = player:getUi():getPos();
		local srcw, srch = player:getUi():getSize();
		local localSeatId = player:getLocalSeatId();
		self:showChatWord(data.msg, srcx, srcy, srcw, srch, localSeatId);
		local player  = self:getUserByUid(data.mid);
		if player then
			G_RoomCfg:addChatRecord(player:getNick(), data.msg)
		end
	end
end

function BaseRoomController:requestSendWord(chatInfo)
	if not chatInfo then return end
	GameSocketMgr:sendMsg(COMMON_SEND_CHAT, {
		iChatInfo = chatInfo,
	})
end

function BaseRoomController:requestSendFace(faceType)
	if not faceType then return end
	GameSocketMgr:sendMsg(COMMON_SEND_FACE, {
		iFaceType = faceType,
		isVipFace = 0,
	})
end

function BaseRoomController:onGiftSendBroadcast(data)
    local receiver = data.receiver
    local giftId = data.gift
    --找到送礼人的人
    local sendPlayer = nil
    for i = 1, #self.mPlayer do
        if self.mPlayer[i]:getId() == data.sender then
            sendPlayer = self.mPlayer[i]
            break;
        end
    end 
    --找到礼物对应的图片
    local imgName = ""
    local giftList = MyUserData.giftList or {}
    local gift = giftList[giftId[1]] and giftList[giftId[1]][giftId[2]]
    if gift then
        imgName = gift:getImgName()
    else
    --礼物不存在
        printInfo("gift not exists")
        return
    end
    
    --找到需要接收礼物的人
    for i = 1, #receiver do
        for j = 1, #self.mPlayer do
            printInfo("receiver[i] "..type(receiver[i]).." "..receiver[i] )
            if self.mPlayer[j]:getId() == receiver[i] then
                --如果送礼物的人和这个收礼物的人是同一个人，那么礼物本来就是从他的位置送出，不需要动画
                if self.mPlayer[j]:getId() ~= data.sender then
                    --找不到赠送人，从屏幕中送出
                    local startX, startY = CONFIG_SCREEN_WIDTH / 2, CONFIG_SCREEN_HEIGHT / 2
                    if sendPlayer then
                        startX, startY = sendPlayer:getUi():findChildByName("btn_gift"):getAbsolutePos()
                    elseif data.sender ~= MyUserData:getId() then
                        AlarmTip.play(string.format(STR_GIFT_GET_FROM_FRIEND, data.name, data.sender, gift:getName()))
                    end
                    --送礼物的动画
                    local endX, endY = self.mPlayer[j]:getUi():findChildByName("btn_gift"):getAbsolutePos()
                    local node = new(Node)
                    local imgGift = new(Image, imgName)
                    imgGift:setAlign(kAlignCenter)
                    node:setSize(imgGift:getSize())
                    node:addChild(imgGift)
                    node:setPos(startX, startY)
                    self:addChild(node)
                    local animGift = node:addPropTranslateWithEasing(1, kAnimNormal, 500, 0, "easeOutSine", "easeOutSine", 0, endX - startX, 0, endY - startY)
                    printInfo("animGift is "..tostring(animGift))
                    animGift:setEvent(self, function()
                        self.mPlayer[j]:setGiftId(giftId)
                        self:removeChild(node, true)
                    end)
                else
                    self.mPlayer[j]:setGiftId(giftId)
                end
                break
            end
        end
    end
    
end

--[[
	跟随 (只有跟随失败才回包)
]]
function BaseRoomController:onFollow(data)
	self:hideLoadingAnim();
	-- if data.code == 0 then
		WindowManager:showWindow(WindowTag.LobbyExitPopu, {
			title 	= STR_FRIEND_FOLLOW_TITLE,
			content = STR_FRIEND_FOLLOW_CONTENT,
			confirm = STR_EXIT_GAME_CONFIRM,
			confirmFunc = function ()
				self:setFollowId(nil);
				--获取tableId
				self:getTableId();
				-- GameSocketMgr:sendMsg(COMMON_GET_TABLEID_REQ, {u16_gameLevel = self.mRoomInfo:getLevel(), u32_gameId = self.mGameId});
			end
		}, WindowStyle.POPUP);
	-- end
end
function BaseRoomController:onFollowed(data)
	if data.code == 0 then
		AlarmTip.play(string.format(STR_FRIEND_FOLLOWED_TIPS, data.nick or ""))
	end
end

function BaseRoomController:onLoginGame(data)
	self:initUserInfo_(data);
end

function BaseRoomController:initUserInfo_(data)
	for i = 1, #data.user do
		local user 	 		= data.user[i];
		local player 		= self.mPlayer[user.seatId];
		local localSeatId 	= self:getLocalSeatId(user.seatId);
		player:setId(user.uid)
		player:setSeatId(user.seatId);
		local userInfo = json.decode(user.userInfo) or {};
		player:setSex(userInfo.sex or 0);
		player:setNick(userInfo.nick or "");
		player:setHeadUrl(userInfo.micon or "");
		player:setChip(user.chip);
        player:setGiftId(userInfo.giftId)
		player:setLocalSeatId(localSeatId);
	end
end

function BaseRoomController:onLoginServer( data )
	if data.isInTable > 0 then
	AlarmTip.play(STR_BACK_TO_GAME)
	local roomInfo = data.roomInfo;
	self.mTableId:init({tableId = roomInfo.tid, 
						isInTable = 1, 
						gameLevel = roomInfo.serverLvl, 
						gameId = roomInfo.gameID });
	end

	if data.isInTable == 0 and data.isInMatch == 0 then
		-- self:onExitRoom();
		--如果重连回来，服务器判断自己不在房间内，则清除数据并重新请求房间
		--清玩家
		for k, v in pairs(self.mPlayer) do
			v:clear()
		end
		-- self:clearGame();
		self:getTableId();
	end
end

function BaseRoomController:onExitRoom(data)
    MyUserData:setMoney(data.money)
    StateChange.changeState(self:getStateFrom() or States.GameLobby);
end

function BaseRoomController:onBack()
	WindowManager:showWindow(WindowTag.LobbyExitPopu, {
		title 	= STR_EXIT_ROOM_TITLE,
		content = STR_EXIT_ROOM_CONTENT,
		cancel 	= STR_EXIT_GAME_CANCEL,
		confirm = STR_EXIT_GAME_CONFIRM,
		confirmFunc = function ()
			GameSocketMgr:sendMsg(COMMON_EXIT_ROOM_REQ);
			StateChange.changeState(self:getStateFrom() or States.GameLobby);
		end
	}, WindowStyle.POPUP);
end



--相当于android的resume
function BaseRoomController:onEventResume()
	if not GameSocketMgr:isSocketOpening() or not GameSocketMgr:isSocketOpen() then
		GameSocketMgr:openSocket();
	end
end


--相当于android的pause
function BaseRoomController:onEventPause()
	GameSocketMgr:closeSocketSync(false);
end

--HTTP回调
function BaseRoomController:onHttpRequestsCallBack(command, ...)
	if self.s_severCmdEventFuncMap[command] then
     	self.s_severCmdEventFuncMap[command](self,...)
	end 
end
