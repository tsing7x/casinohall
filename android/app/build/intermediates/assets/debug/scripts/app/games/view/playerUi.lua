local view_player = require(ViewPath .. "games.view.view_player")
local RoundClock = require("app.games.view.roundClock")
local PlayerData = require("app.games.data.playerData")
local AUDIO = require("app.games.pokdeng.res.audio_config")

local PlayerUi = class(Node)

--[[
	创建结算文本
--]]
function PlayerUi:createTurnMoneyText(turnMoney)
	local numPath = "games/number/score_-/"
	if turnMoney>=0 then
		turnMoney = "+"..turnMoney
		numPath = "games/number/score_+/"
	end
	local numText = new(ImageNumber,{
		['0'] = numPath.."0.png",
		['1'] = numPath.."1.png",
		['2'] = numPath.."2.png",
		['3'] = numPath.."3.png",
		['4'] = numPath.."4.png",
		['5'] = numPath.."5.png",
		['6'] = numPath.."6.png",
		['7'] = numPath.."7.png",
		['8'] = numPath.."8.png",
		['9'] = numPath.."9.png",
		['+'] = numPath.."+.png",
		['-'] = numPath.."-.png",
		})
		:addTo(self)
		:align(kAlignCenter)
		:pos(0,0)

	numText:setNumber(turnMoney)
	numText:addPropScaleSolid(22, 1.5, 1.5, kCenterDrawing);--放大
	return numText
end

--[[
	玩家头像构造函数
--]]
function PlayerUi:ctor(roomScene)
	local playerData = setProxy(new(PlayerData))
	local node = new(Node)
		:addTo(self)
		:align(kAlignCenter)
	local layout = SceneLoader.load(view_player):addTo(node)		
	local w,h = layout:findChildByName("btn_player"):getSize()

	node:setSize(w,h)
	playerData:setUi(self)	
	self.m_roomScene = roomScene	
	self.m_playerData = playerData
	self.m_node = node

	--设置按钮尺寸
	self:findChildByName("btn_player"):setScaleOffset(0.985)

	--玩家头像的点击按钮
	self:findChildByName("btn_player"):setOnClick(self,function()
		if false then
			-- local handCard = playerData:getHandCardUi()
			-- handCard:clear()
			-- handCard:getDealCard(0)
			-- handCard:getDealCard(0)
			-- if 1 then
			-- 	handCard:getDealCard(0)
			-- end
			-- handCard:setData({41, 6, 55})--44, 12, 61       41, 6, 55
			-- handCard:show()
			-- playerData:setOpenAnim()
			self.m_roomScene:onBroadcastThirdCardAvailable({seatid = playerData:getSeatId()})
			return
		end
		if playerData:getId()==0 then --点击处没有玩家则坐下
			self.m_roomScene:requestSitdown(playerData:getSeatId())
		elseif playerData:getId()==1 then --点击荷官
		else --点击自己
			local windowParam = { player = playerData, seatId =playerData:getSeatId()}
			WindowManager:showWindow(WindowTag.RoomPlayerInfoPopu, windowParam, WindowStyle.POPUP);
			-- WindowManager:showWindow(WindowTag.MessageBox, {singleBtn=true,text="uid="..playerData:getId()}, WindowStyle.POPUP)
		end
	end)

	--根据本地座位号初始化位置
	UIEx.bind(self, playerData, "localSeatId", function(value)

		--初始化头像的位置
		local _align,pt = self.m_roomScene:getPlayerPosByLocalSeat(value)
		self:align(_align)
			:pos(pt.x,pt.y)

		local offset = {
			[kAlignCenter] 		= {x=0,y=0},
			[kAlignTop] 		= {x=0,y=-1},
			[kAlignTopRight] 	= {x=1,y=-1},
			[kAlignRight] 		= {x=1,y=0},
			[kAlignBottomRight] = {x=1,y=1},
			[kAlignBottom] 		= {x=0,y=1},
			[kAlignBottomLeft] 	= {x=-1,y=1},
			[kAlignLeft] 		= {x=-1,y=0},
			[kAlignTopLeft] 	= {x=-1,y=-1},
		}

		--初始化手牌的位置
		_align,pt = self.m_roomScene:getCardPosByLocalSeat(value)
		local handCard = playerData:getHandCardUi()
		if handCard then
			-- print("card seat",value,"align",_align,"pos",pt.x,pt.y)
			pt.x = offset[_align].x*w*0.5+pt.x
			pt.y = offset[_align].y*h*0.5+pt.y
			handCard:align(kAlignCenter)
					:pos(pt.x,pt.y)
		end

		--初始化筹码的位置
		_align,pt = self.m_roomScene:getBetPosByLocalSeat(value)
		local viewBet = playerData:getBetUi()
		if viewBet then
			viewBet:align(_align)
					:pos(pt.x,pt.y)
			-- print("bet seat",value,"align",_align,"pos",pt.x,pt.y)
		end

		--初始化筹码类型的位置
		local view_cardType = playerData:getCardTypeUi()
		if view_cardType then
			view_cardType:freshByLocalSeat(value)
			if playerData:getId()==MyUserData:getId() then
				view_cardType:pos(0,h+50)
			else
				view_cardType:pos(0,30)
			end
		end

		if value==1 then
			self:scale(1.2)
		else
			self:scale(1)
		end
	end)

	--玩家的游戏状态
	--1:游戏开始
	--2:游戏结束,等待下一局
	UIEx.bind(self, playerData, "status", function(value)

		local viewBet = playerData:getBetUi() --筹码
		local view_cardType = playerData:getCardTypeUi() --牌型
		local handCard = playerData:getHandCardUi() --手牌

		--游戏开始
		if value == 1 then

			--隐藏牌型
			if view_cardType then 
				view_cardType:hide() 
				checkAndRemoveOneProp(view_cardType, 23)
			end

			--清除手牌
			if handCard then
				handCard:clear() 
			end

		--游戏结束,等待下一局
		elseif value == 2 then 

			--清除下注的筹码
			if viewBet then 
				viewBet:clear() 
			end

			if playerData:getId() == MyUserData:getId() then

				--自己的手牌网上移动
				if handCard then					
					handCard:moveTo(0,-30,0.3)
				end

				if view_cardType then
					--因懒得重新设置位置，因此用老动画
					view_cardType:addPropTranslate(23,kAnimNormal,300,0,0,0,0,-150)
				end
			end
		end
	end)

	--玩家当前筹码
	UIEx.bind(self, playerData, "chip", function(value)
		self:findChildByName("img_chipbg"):findChildByName("text_chip"):setText(ToolKit.formatMoney(value))
	end)

	--当前玩家id
	UIEx.bind(self, playerData, "id", function(value)

		--玩家筹码与昵称的显示隐藏
		self:findChildByName("img_chipbg"):setVisible(value~=0)

		--暂时屏蔽礼物
		self:findChildByName("btn_gift"):setVisible(false)

		--为1表示是庄家，隐藏头像
		self:findChildByName("btn_player"):setVisible(value~=1)

		local handCard = playerData:getHandCardUi()
		if handCard then
			handCard:setVisible(value~=0)
			handCard:setIsMe(value == MyUserData:getId())
		end

		--该头像目前没有玩家坐下
		if value==0 then
			playerData:getBetUi():clear()
			playerData:getCardTypeUi():hide()
			self:findChildByName("view_phead"):removeAllChildren()
		end
	end)

	--当前玩家昵称
	UIEx.bind(self, playerData, "nick", function(value)
		self:findChildByName("img_chipbg"):findChildByName("text_name"):setText(value)
	end)

	--当前玩家下注的筹码
	UIEx.bind(self, playerData, "bet", function(value)
		local viewBet = playerData:getBetUi():show()
		if value==0 then
			viewBet:hide()
			return
		end

		local tmpTimes = math.floor(value/G_RoomCfg:getBaseAnte())
		if tmpTimes > 15 then
			tmpTimes = 15
		end

		--播放下注动画
		local times = math.random(1,tmpTimes)
		for i=1,times do
			local delay = i*0.06
			local addNum = math.floor(value/10)
			if i==times then
				addNum = value - (times-1)*addNum
			end
			viewBet:showAddBetAnim(addNum,delay)
		end
		kEffectPlayer:play(AUDIO.betChip)
	end)

	--头像设置
	local headView = self:findChildByName("view_phead");
	local imgData = setProxy(new(require("app.data.imgData")))
	UIEx.bind(self, imgData, "imgName", function(value)
		if imgData:checkImg() then
			imgStr = imgData:getImgName()
		else
			imgStr = playerData:getSex() == 0 and "common/male.png" or "common/female.png"
			JLog.d("TEST GHJ", playerData:getId(),playerData:getHeadUrl(), value)
		end
		headView:removeAllChildren();
		if playerData:getId() ~= 0 then
			-- headView:removeAllChildren();
			local width, height = headView:getSize()
			local imgHead = new(ImageMask, imgStr, "games/common/head_mask.png")
					:addTo(headView)
					:size(width-8, height-8)
					:pos(4,4)
			
			--灰色遮罩		
			self.imgHeadShader = new(Image, "games/common/img_clockBg.png")
						:addTo(headView)
						:size(width, height)
			if playerData:getShaderVisible() == 1 then
				self.imgHeadShader:show()
			else
				self.imgHeadShader:hide()
			end	
		end
    end)
	UIEx.bind(self, playerData, "headUrl", function(value)
		imgData:setImgUrl(value)
	end)
	imgData:setImgUrl(playerData:getHeadUrl())

	--头像遮罩，用于未开始游戏的玩家
	UIEx.bind(self, playerData, "shaderVisible", function(value)
		if playerData:getId() ~= 0 then
			if value == 1 then
				self.imgHeadShader:show()
			else
				self.imgHeadShader:hide()
			end			
		end
	end)

	--头像倒计时
	local roundClock = new(RoundClock, "games/common/img_counter.png")
		:addTo(self:findChildByName("view_progress"))
		:align(kAlignCenter)
		:hide()
		:scale(0.92)
		:hideText(true)
	UIEx.bind(self, playerData, "timeAnim", function(value)
		roundClock:stop()
		if value then
			roundClock:play(value,value,function (second)
				-- body
				if second <= 3 then
					kEffectPlayer:play(AUDIO.TIME_WARNING)
				end
			end)
		end
	end)

	UIEx.bind(self, playerData, "timeLeft", function(value)
		roundClock:stop()
		if value then
			roundClock:play(value[1], value[2],function (second)
				-- body
				if second <= 3 then
					kEffectPlayer:play(AUDIO.TIME_WARNING)
				end
			end)
		end
	end)

	--发牌动画
	UIEx.bind(self, playerData, "dealAnim", function(param)
		local dealer = playerData:getCardDealerUi()
		local handCard = playerData:getHandCardUi()
		
		if not handCard then return end
		if not dealer then return end
		if not handCard:getCanDeal() then return end

		local delay = param.delay or 0
		local callback = param.callback
		dealer:runDeal(param.delay, function(_pos,_scale,_roate)
			kEffectPlayer:play(AUDIO.deal)
			local card = handCard:getDealCard()
			local toX,toY = card:getAbsolutePos()
			local toRotation = card:getRoation()
			local toScale = card.m_scale

			local fromPoint = Point(_pos.x-toX,_pos.y-toY)
			fromPoint:mul(System.getLayoutScale())
			local fromRoation = _roate - toRotation
			local time = 0.6

			card:runAction({{"pos",fromPoint,Point(0,0),time},},{order="spawn",is_relative=true,onComplete=function()
				if type(callback)=="function" then
					callback(playerData:getSeatId())
				end
			end})
			card.m_node:runAction({"scale",Point(_scale,_scale),Point(toScale,toScale),time})
			card.m_node:runAction({"rotation",_roate,toScale,time})
		end)
	end)

	--设置手牌的值
	UIEx.bind(self, playerData, "cards", function(data)
		local handCard = playerData:getHandCardUi()
		if not handCard then return end	
		handCard:setData(data or {})
	end)

	--打开手牌动画
	UIEx.bind(self, playerData, "openAnim", function(value)
		local handCard = playerData:getHandCardUi()
		if not handCard then
			return
		end

		handCard:showOpenAnim()
		kEffectPlayer:play(AUDIO.opencard)

		--展示牌型与倍数
		local _type,_times,_point = handCard:getInfo()
		local view_cardType = playerData:getCardTypeUi()
		if not view_cardType then
			return
		end
		view_cardType:show()
		view_cardType:setCardType(_type,_point)
		view_cardType:setTimes(_times)
	end)

	--打开手牌
	UIEx.bind(self, playerData, "showCard", function(value)
		if value then
			local handCard = playerData:getHandCardUi()
			if not handCard then return end	
			local cardsData = playerData:getCards();
			local count =0;
			if cardsData then
				for i=1,#cardsData do
					if cardsData[i] > 0 then
						count =count +1;
					end
				end
				handCard:setDealedIndex(count)
				handCard:show()
				playerData:setOpenAnim(true);
			end
		end
	end)

	--本轮结算的金币
	UIEx.bind(self, playerData, "turnMoney", function(value)
		local turnText = self:createTurnMoneyText(value)
		local time = 0.8
		local callback = function()
			local time = 3
			turnText:runAction({"opacity",1,0,time},{onComplete=function()
					turnText:removeSelf()
				end})
		end
		turnText:runAction({"y",h/4,-h/2,time},{is_relative=true,onComplete=callback})
	end)
end

--[[
	缩放玩家头像
--]]
function PlayerUi:scale(_scale)
	self.m_node:scale(_scale)
		:anchor(0.5,0.5)
		:_scale_at_anchor_point(true)
end

--[[
	玩家头像移动
--]]
function PlayerUi:moveBy(fromPoint, toPoint, time, onComplete)
	fromPoint:mul(System.getLayoutScale())
	toPoint:mul(System.getLayoutScale())
	self:runAction({"pos",fromPoint,toPoint,time},{is_relative=true,onComplete=onComplete})
	-- self:addPropTranslate(1,kAnimNormal,time*1000,0,fromPoint.x,toPoint.x,fromPoint.y,toPoint.y)
end

--[[
	返回玩家数据
--]]
return function(roomScene, parent, i)
	local playerUi = new(PlayerUi,roomScene):addTo(parent)
	return playerUi.m_playerData
end

