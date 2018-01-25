local AnimationBase = require("app.animation.animationBase")
local AnimFace = class(AnimationBase)
local MJAnim_map = require("app.room.chat.expression")

function AnimFace:load(params)
	local pos = params.pos
	if pos then
		self:pos(pos.x, pos.y)
	end

	local playCount = params.playCount or 1
	printInfo("创建动画")
	dump(playCount)

	local faceName = params.faceName
	local res = {}
	for i=0, params.num - 1 do
		local strTmp = string.format(faceName, i + 1)
        strTmp = MJAnim_map[strTmp]
		res[i] = new(ResImage,strTmp)
	end
	local drawing = new(DrawingImage, res[0])
	drawing:setSize(100, 100)
	for i=1,#res do
		drawing:addImage(res[i],i)
	end
	self:addChild(drawing)

	self.mDrawing = drawing
	self.mRes = res
	self.mPlayCount = playCount
	self.mCallback = params.onComplete
end

function AnimFace:play(params)
	printInfo("播放动画 %d", params.playCount)
	self:stop()
	self:load(params)
	local totalNum = params.playCount * params.num
	local anim = new(AnimInt, kAnimRepeat, 0, totalNum, 120, -1)
    anim:setDebugName("AnimFace.anim")
    local index = 0
	anim:setEvent(self, function(self, anim_type, anim_id, repeat_or_loop_num)
		index = index + 1
		if repeat_or_loop_num >= totalNum + 3 then
			if self.mCallback then
				self.mCallback()
			end
			self:release()
		elseif repeat_or_loop_num < totalNum - 1 then
			self.mDrawing:setImageIndex(index % params.num)
		end
	end)
	self.mAnim = anim
end

function AnimFace:stop()
	printInfo("停止动画")
	if self.mAnim then
		delete(self.mAnim)
		self.mAnim = nil
	end
end

return AnimFace