local view_card = require(ViewPath .. "games.view.view_card")

local function getCardPath(path)
	return "games/card/"..path
end

local M = class(Node);

-- card_type:  花色
-- card_value： 大小
function M:ctor(data)
	self.m_data = data
	
	local node = new(Node)
		:addTo(self)
		:align(kAlignCenter)

	local layout = SceneLoader.load(view_card)	
		:addTo(node)

	node:setSize(layout:findChildByName("img_bg"):getSize())
	self.m_node = node

	if type(data)~="number" then
		return
	end
	
	local card_type, card_value = math.ceil(data/16),data%16
	if not (card_type>=1 and card_type<=4 and card_value>=1 and card_value<=13) and not (card_type==5 and (card_value==14 or card_value==15)) then
		if DEBUG_MODE then
			-- error("创建牌的数据有问题%s",data)
		end
		return
	end

	self:setTypeAndValue(data)
	self.m_scale = 1
end

function M:getCardSize()
	local w,h = self.m_node:getSize()
	return {w=w,h=h}
end

function M:scale(_scale)
	self.m_node:scale(_scale)
			:anchor(0.5,0.5)
			:_scale_at_anchor_point(true)

	self.m_scale = _scale
	return self
end

function M:showBack(isShow)
	local img_back = self:findChildByName("img_back")
	img_back:setVisible(isShow)
end

function M:setTypeAndValue(data)
	if type(data)~="number" then
		return
	end
	self.m_data = data
	local card_type, card_value = math.floor(data/16),data%16
	if card_type>=0 and card_type<=3 then
		smallTypeName = "s_"..card_type;	
		bigTypeName   = "b_"..card_type;
		if card_value > 10 then
			bigTypeName = string.format('bg_%d_%d',(card_type == 0 or card_type == 3) and 1 or 2, card_value) --1黑2红
		end
		self:findChildByName('img_stype'):setFile(getCardPath(smallTypeName..".png"));
		self:findChildByName('img_btype'):setFile(getCardPath(bigTypeName..".png"));
		
	else
		-- printInfo("Card: invail card type!");
	end

	if card_value >= 1 and card_value <= 13 then
		numName = string.format('%d_%d',(card_type == 0 or card_type == 3) and 1 or 2, card_value)
		self:findChildByName('img_value'):setFile(getCardPath(numName..".png"));
	else
		-- printInfo("Card: invail card card_value! %s",card_value);
	end
end

function M:getData()
	return self.m_data
end

return M