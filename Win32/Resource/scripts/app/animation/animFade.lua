
require("app.common/uiFactory");
require("app.common/animFactory");
require("app.animation/animMap")
local AnimationBase = require("app.animation.animationBase")
local RoomCoord = require("app.room.coord.roomCoord")
--[[
	单张图 缩放 淡出效果动画
]]
local AnimFade = class(AnimationBase);

function AnimFade:ctor()
	self.baseSequence = 20;
end

--[[
	file : 可选 图片类型
	pos :可选 坐标
	node : 节点 如果没有指定file则从节点的m_res.m_file获取
]]
function AnimFade:load(params)
	-- 是否显示底图
	local showBg = params.showBg or false
	self.m_fadeTime = params.fadeTime or 600
	self.m_scaleTime = params.scaleTime or 250
	self.m_delayTime = params.delayTime or 0
	self.m_fadeSize = params.fadeSize or 1.3
	self.m_bgSize   = params.bgSize or 1.0
	self.m_onComplete = params.onComplete

	self.m_root = new(Node)
		:addTo(self)
	self.m_root:setLevel(RoomCoord.AnimLayer);
	local file = params.file
	local node = params.node
	if not file then
		file = node and node.m_res.m_file
	end
	if params.pos then
		self:setPos(params.pos.x, params.pos.y)
	else
		local width, height = node:getSize()
		local x, y = node:getAbsolutePos()
		self:setPos(x + width/2, y + height/2)
	end

	if showBg then
		self.m_animBg = new(Image, file)
			:align(kAlignCenter)
			:addTo(self.m_root)
	end
	self.m_animImage = new(Image, file)
		:align(kAlignCenter)
		:addTo(self.m_root)

	self.m_animImage:setVisible(false)
end

function AnimFade:play(params)
	AnimFade.super.play(self, params)
	self:playSate();
end

function AnimFade:playSate()
	self.m_animImage:setVisible(true)
	self.m_animImage:addPropTransparency(1, kAnimNormal, self.m_fadeTime, 0, 0.5, 0);
	local anim = self.m_animImage:addPropScaleEase(2, kAnimNormal, ResDoubleArraySinIn, self.m_scaleTime, 0, 1, self.m_fadeSize, 1, self.m_fadeSize, kCenterDrawing);
	if self.m_animBg and self.m_bgSize ~= 1.0 then
		self.m_animBg:addPropScaleEase(1, kAnimNormal, ResDoubleArraySinIn, 100, 0, self.m_bgSize, 1, self.m_bgSize, 1, kCenterDrawing);
	end
	if self.m_delayTime > 0 then
		anim = self:addPropTransparency(1, kAnimNormal, self.m_fadeTime + self.m_delayTime, 0, 1.0, 1.0)
	end
	if anim then
		anim:setEvent(nil, handler(self, self.release))
	else
		self:release()
	end
end

function AnimFade:release()
	if type(self.m_onComplete) == "function" then
		self.m_onComplete()
	end
	self:removeSelf()
end

return AnimFade