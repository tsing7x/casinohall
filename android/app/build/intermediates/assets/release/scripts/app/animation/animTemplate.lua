local AnimationBase = require("app.animation.animationBase")
local AnimTemplate = class(AnimationBase)

function AnimTemplate:load(params)
	printInfo("创建动画")
	local image = UIFactory.createImage("ui/image.png")
	self:addChild(image)
end

function AnimTemplate:play(params)
	printInfo("播放动画")
	self:stop()
	self:load(params)
	self.mAnim = AnimFactory.createAnimInt(kAnimNormal, 0, 1, 1000, 0)
	self.mAnim:setEvent(nil, function()
		self:release()
	end)
end

function AnimTemplate:stop()
	printInfo("停止动画")
	if self.mAnim then
		delete(self.mAnim)
		self.mAnim = nil
	end
end

function AnimTemplate:release()
	printInfo("销毁动画")
	self:stop()
	self:removeSelf()
end

return AnimTemplate