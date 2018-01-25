local AnimationBase = require("app.animation.animationBase")
local AnimAddMoney = class(AnimationBase)

function AnimAddMoney:load(params)
	local pos = params.pos
	if pos then
		self:pos(pos.x, pos.y)
	end

	self.m_imgNode = new(Node)
		:addTo(self)
		:align(kAlignCenter)
	local prefix = params.money >= 0 and "win" or "lose"
	local sign = params.money >= 0 and "+" or "-"
	local path = params.money >= 0 and "room/moneyNum/" or "room/moneyNum/" 
	local moneyStr = tostring(math.abs(params.money))
	local imagesTb = {prefix .. sign .. kPngSuffix}
	for i=1, #moneyStr do
		table.insert(imagesTb, string.format("%s%s.png", prefix, string.sub(moneyStr, i, i)))
	end
	local x = 0
	for i=1, #imagesTb do
		local img = UIFactory.createImage(path .. imagesTb[i])
			:addTo(self.m_imgNode)
			:align(kAlignLeft)
		local width, height = img:getSize()
		img:pos(x, 0)
		x = x + width
	end
	self.m_imgNode:setSize(x, 0)
end

function AnimAddMoney:play(params)
	self:stop()
	self:load(params)

	self.mAnim = self.m_imgNode:addPropTranslate(121, kAnimNormal, 300, 700, 0, 0, 35, -35)
	if self.mAnim then
		self.mAnim:setEvent(nil, function()
			self.mAnim = self.m_imgNode:addPropTransparency(122, kAnimNormal, 300, 700, 1.0, 0)
			if self.mAnim then
				self.mAnim:setEvent(self, self.release)
			else
				self:release()
			end
		end)
	else
		self:release()
	end
end

function AnimAddMoney:stop()
	printInfo("停止动画")
	if self.mAnim then
		delete(self.mAnim)
		self.mAnim = nil
	end
end

return AnimAddMoney