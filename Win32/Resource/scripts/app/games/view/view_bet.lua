local view_bet = require(ViewPath .. "games.view.view_bet")

local img_chip_path = "games/common/img_tableChip.png"

local M = class(Node);

-- card_type:  花色
-- card_value： 大小
function M:ctor(data)
	self.m_data = data
	
	local node = new(Node)
		:addTo(self)
		:align(kAlignCenter)

	local layout = SceneLoader.load(view_bet)	
		:addTo(node)
	layout:setFillParent(true,true)

	node:setSize(layout:findChildByName("img_chipBg"):getSize())
	self.m_node = node
	
	self.m_chipView = self:findChildByName("chipView")
	self.m_betText = self:findChildByName("text_bet")
	self.m_betNum = 0
	self:setBet(0)
	self:hide()
end

function M:setBet(num)
	self:show()
	self.m_betNum = num
	self.m_betText:setText(self.m_betNum)
end

function M:addBet(num)
	self.m_betNum = self.m_betNum+num
	self.m_betText:setText(self.m_betNum)
end

function M:showAddBetAnim(num,delay)
	local playerUi = self:getParent()
	local fromX,fromY = playerUi:getAbsolutePos()
	local toX,toY = self:findChildByName("chipView"):getAbsolutePos()
	local img = new(Image,"games/common/img_tableChip.png")
		:addTo(self.m_chipView)
		:align(kAlignLeft)
		:hide()

	local fromPoint = Point(fromX-toX,fromY-toY)
	fromPoint:mul(System.getLayoutScale())

	img:runAction({"x",0,0,delay},{is_relative=true,onComplete=function()
		local time = 0.3
		img:show()
		img:runAction({{"pos",fromPoint,Point(0,0),time},{"opacity",0,1,time}},{order="spawn",is_relative=true,onComplete=function()
				self:addBet(num)
				img:removeSelf()
			end})	
	end})
		
end

function M:clear()
	self.m_betNum = 0
	self.m_betText:setText(self.m_betNum)
	self:hide()
end

return M