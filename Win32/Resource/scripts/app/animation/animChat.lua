local AnimationBase = require("app.animation.animationBase")
local AnimChat = class(AnimationBase)

local readyChatBg = {
	"word_bg_left.png",
	"word_bg_left.png",
	"word_bg_left.png",
	"word_bg_left.png",
}
local gameChatBg = {
	"word_bg_left.png",
	"word_bg_left.png",
	"word_bg_left.png",
	"word_bg_left.png",
	"word_bg_left.png",
	"word_bg_left.png",
	"word_bg_right.png",
	"word_bg_right.png",
	"word_bg_right.png",
	"word_bg_right.png",
}
function AnimChat:load(params)
	local pos = params.pos
	if pos then
		self:pos(pos.x, pos.y)
	end
	local chatInfo = params.chatInfo
	local seat = params.seat
	local isGame = params.isGame
	local chatBgFile = isGame and gameChatBg[seat] or readyChatBg[seat]
	self.m_bg = UIFactory.createImage("animation/roomAnim/" .. chatBgFile)
		:addTo(self)
	local width, height = self.m_bg:getSize()
	local node = new(Node)
		:addTo(self.m_bg)
	local diffX, diffY = 15, 5
	if seat == 10 then
		diffX = 30
	end
	self.m_regionSize = ccs(width - diffX * 2, height - diffY - 35)
	-- node:setClip(diffX, diffY, self.m_regionSize.width, self.m_regionSize.height)
	self.m_text = UIFactory.createTextView({
			text = chatInfo,
			size = 26,
			color = c3b(85, 85, 85),
			width = self.m_regionSize.width,
		})
		:addTo(node)
		:pos(diffX, diffY)
end

function AnimChat:play(params)
	self:stop()
	self:load(params)

	local width, height = self.m_text:getSize()
	local anim
	local releaseDelay = 1500
	if height > self.m_regionSize.height then
		local moveDiffY = height - self.m_regionSize.height
		releaseDelay = releaseDelay + height * 20 + 1500
		self.m_text:addPropTranslate(0, kAnimNormal, height * 20, 1500, 0, 0, 0, -moveDiffY)
	end
	local anim = AnimFactory.createAnimInt(kAnimNormal, 0, 1, 0, releaseDelay)
	anim:setEvent(self, self.release)
	self.mAnim = anim
end

function AnimChat:stop()
	printInfo("停止动画")
	if self.mAnim then
		delete(self.mAnim)
		self.mAnim = nil
	end
end

return AnimChat