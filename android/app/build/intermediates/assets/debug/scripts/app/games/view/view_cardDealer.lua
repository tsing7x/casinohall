local view_cardDealer = require(ViewPath .. "games.view.view_cardDealer")

local Card = require("app.games.view.view_card")

local M = class(Node);

-- card_type:  花色
-- card_value： 大小
function M:ctor()
	local node = new(Node)
		:addTo(self)
		:align(kAlignCenter)

	local layout = SceneLoader.load(view_cardDealer)	
		:addTo(node)
	
	node:setSize(layout:findChildByName("view_dealer"):getSize())
	self.m_node = node
	
	self.card_view = self:findChildByName("card_view")

	self.m_roate = 0
end

function M:roate(value)
	self.m_roate = value
	self.m_node:roate(value)
	return self
end

function M:runDeal(delay,callback)
	local cardRoate = -6
	local cardScale = 0.24

	local card = new(Card)
		:addTo(self.card_view)
		:align(kAlignCenter)
		:scale(cardScale)
		:roate(cardRoate)
		:pos(0,2)
	card:showBack(true)

	local length = 40
	local x,y = -length*math.cos(math.rad(self.m_roate)),-length*math.sin(math.rad(self.m_roate))
	local absx,absy = card:getAbsolutePos()

	local toPoint = Point(-length,0)
	toPoint:mul(System.getLayoutScale())
	card:runAction({"x",0,0,delay},{is_relative=true,onComplete=function()
		local time = 0.1
		card:setLevel(1)
		card:runAction({"pos",Point(0,0),toPoint,time},{is_relative=true,onComplete=function()			
			card:removeSelf()
			if type(callback)=="function" then
				callback({x=x+absx,y=y+absy},cardScale,self.m_roate+cardRoate)
			end
		end})	
	end})	

end

--正常位置，靠近10号位
function M:setPos_1()
	self:align(kAlignTopRight)
		:pos(200,100)
		:roate(-50)
end

--我坐庄时位置，靠近1号位
function M:setPos_2()
	self:align(kAlignBottomRight)
		:pos(180,200)
		:roate(50)
end

return M