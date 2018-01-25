local Card = require("app.games.view.view_card")
local Logic = require("app.games.pokdeng.card.logic")
local M = class(Node)

--[[
	构造函数
--]]
function M:ctor()
	self.m_normalScale = 0.2
	self.m_isMe = false
	self.m_array = {}
	for i=1,3 do
		self.m_array[i] = new(Card)
			:addTo(self)
			:align(kAlignCenter)
			:hide()
	end
	self.m_logic = new(Logic)
	self.m_cardSize = self.m_array[1]:getCardSize()
	self.m_dealIndex = 0 --当前发第几张牌
	self.m_openIndex = 0 --当前第几次翻牌 
	self.m_data = {0,0,0}
	self._pos = {x=0,y=0}
end

--[[
	设置手牌位置
--]]
function M:pos(x,y)
	M.super.pos(self,x,y)
	self._pos.x = x
	self._pos.y = y
	return self
end

--[[
	更新手牌尺寸
--]]
function M:fresh(_scale)
	for i=1,3 do
		self.m_array[i]:scale(_scale or self.m_normalScale)
	end

	if self.m_dealIndex>0 then
		self:freshCard(self.m_dealIndex)
	end
end

--[[
	根据该牌是否是本玩家决定卡片尺寸
--]]
function M:setIsMe(_isMe)
	self.m_isMe = _isMe
	self.m_normalScale = _isMe and 0.6 or 0.2
	self:fresh()
end

--[[
	清除手牌
--]]
function M:clear()
	self.m_dealIndex = 0
	self.m_openIndex = 0
	for i=1,3 do
		self.m_array[i]:hide():showBack(true)
	end

	self:scale(1):pos(self._pos.x,self._pos.y)
end

--[[
	判断能否发牌
--]]
function M:getCanDeal() 
	return self.m_dealIndex < 3
end

--[[
	设置手牌的值
--]]
function M:setData(data)
	JLog.d("#####setData",data);
	for i=1,3 do
		self.m_data[i] = data[i] or 0
	end

	--将原始数据给logic进行处理
	self.m_logic:setCards(self.m_data)	
end

--[[
	获取牌型、倍数、点数
--]]
function M:getInfo()
	return self.m_logic:getType(),self.m_logic:getX(),self.m_logic:getPoint()
end

--[[
	添加第三张牌
	返回牌型、倍数、点数
--]]
function M:add3thCard(cardV)
	self.m_data[3] = cardV
	self.m_logic:add3thCard(cardV)
	return self.m_logic:getType(),self.m_logic:getX(),self.m_logic:getPoint()
end

--[[
	返回正要发的牌
--]]
function M:getDealCard()
	self.m_dealIndex = self.m_dealIndex +1
	if self.m_dealIndex > 3 then
		return
	end
	local card = self.m_array[self.m_dealIndex]:show()

	self:freshCard()
	card:showBack(true)

	return card
end

--[[
	显示每张牌（暂未发现有何作用）
--]]
function M:setDealedIndex(index)
	if index>3 then
		index = 3
	end
	self.m_dealIndex = index;
	for i=1,self.m_dealIndex do
		self.m_array[i]:show()
	end
end

--[[
	是否显示手牌背面
--]]
function M:showBack(isShow)
	for i=1,3 do
		local card = self.m_array[i]
		local cardV = self.m_data[i]
		if cardV>0 then
			card:showBack(isShow)
		else
			card:showBack(true)
		end
	end
end

local _roates = {
	[2] = {-12,12},
	[3] = {-15,2,16},
}
local _posxs = {
	[2] = {-0.1,0.3},
	[3] = {-0.15,0.2,0.5},
}
local _posys = {
	[2] = {0,0.05},
	[3] = {0.01,0,0.08},
}

--[[
	刷新牌的位置旋转以及牌值牌型等数据
--]]
function M:freshCard()
	local index = self.m_dealIndex
	local w,h = self.m_cardSize.w*self.m_normalScale, self.m_cardSize.h*self.m_normalScale

	local _time = 0.1
	if index==2 then
		self.m_array[1]:roateTo(_roates[2][1],_time)
				:moveTo(_posxs[2][1]*w,_posys[2][1]*h,_time)
				:pos(_posxs[2][1]*w,_posys[2][1]*h)
		self.m_array[2]:roateTo(_roates[2][2],_time)
			:moveTo(_posxs[2][2]*w,_posys[2][2]*h,_time)
			:pos(_posxs[2][2]*w,_posys[2][2]*h)
	elseif index==3 then
		self.m_array[1]:roateTo(_roates[3][1],_time)
			:moveTo(_posxs[3][1]*w,_posys[3][1]*h,_time)
			:pos(_posxs[3][1]*w,_posys[3][1]*h)
		self.m_array[2]:roateTo(_roates[3][2],_time)
			:moveTo(_posxs[3][2]*w,_posys[3][2]*h,_time)
			:pos(_posxs[3][2]*w,_posys[3][2]*h)
		self.m_array[3]:roateTo(_roates[3][3],_time)
			:moveTo(_posxs[3][3]*w,_posys[3][3]*h,_time)
			:pos(_posxs[3][3]*w,_posys[3][3]*h)
	else
		JLog.d("########freshCard",index);
		self.m_array[1]:roate(0)
				:pos(0,0)
	end

	for i=1,3 do
		local cardV = self.m_data[i]
		local card = self.m_array[i]
		card:setTypeAndValue(cardV)	
	end
end

--[[
	开牌动画
--]]
function M:showOpenAnim()
	self.m_openIndex = self.m_openIndex+1
		
	if self.m_isMe then
		local time = 0.2
		for i=1,3 do
			local card = self.m_array[i]
			local roation = card:getRoation()
			local x,y = card:getPos()
			local toPoint = Point(x,y)
			toPoint:mul(System.getLayoutScale())
			print("roation",roation)

			self:freshCard()
			self:showBack(false)
			-- card:runAction({{"rotation",0,roation,time},{"pos",Point(0,0),toPoint,time}},{order="spawn"})
		end
	else
		if self.m_openIndex > 1 then
			return
		end
		local x,y = self:getPos()
		local toPoint = Point(-6,-20)
		local fromPoint = Point(x,y)
		fromPoint:mul(System.getLayoutScale())
		local time = 0.4
		self:runAction({"pos",fromPoint,toPoint,time},{is_relative = false,onComplete=function()
			local targetScale = 2.25
			local time = 0.2
			self:runAction({"scale",Point(self.m_normalScale,self.m_normalScale),Point(targetScale,targetScale),time},{onComplete = function()

			end})
			for i=1,3 do
				local card = self.m_array[i]
				local roation = card:getRoation()
				local x,y = card:getPos()
				local toPoint = Point(x,y)
				toPoint:mul(System.getLayoutScale())
				
				self:freshCard()
				self:showBack(false)
				-- card:runAction({{"rotation",0,roation,time},{"pos",Point(0,0),toPoint,time}},{order="spawn"})
			end
		end})
		JLog.d("其他玩家亮牌");
	end
end

--[[
	是否需要第三张牌
--]]
function M:needPoker()
	return self.m_logic:needPoker()
end

return M