-- 赢牌动画(传入需要震动界面的根节点即可)
local AnimationBase = require("app.animation.animationBase")

local AnimationWinGame = class(AnimationBase);


function AnimationWinGame:ctor(obj_ctrl_node)
	self.m_roomNode = obj_ctrl_node;
	self.isPlaying = false;
	self.baseSequence = 100;

	self.screen_w = System.getScreenScaleWidth();
	self.screen_h = System.getScreenScaleHeight();
	self:setSize(self.screen_w, self.screen_h);
	self:setLevel(50);
end

function AnimationWinGame:play(params)
	params = params or {}
	self.m_showAnim = self:addPropScale(1,kAnimNormal, 250, 0, 1, 1.0, 1, 1.0,kCenterDrawing);
	self.m_showAnim:setDebugName("AnimationWinGame || self.m_showAnim");
	self.m_showAnim:setEvent(self, self.onTime)

	self:showScaleAndShake()
end


function AnimationWinGame:onTime()
	self:removeProp(1)
	-- self.m_delay_anim = AnimFactory.createAnimInt(kAnimNormal, 0, 1, 1000, 0);
	-- self.m_delay_anim:setDebugName("AnimationWinGame || self.m_delay_anim");
	-- self.m_delay_anim:setEvent(self, AnimationWinGame.stop);
end

function AnimationWinGame:showScaleAndShake( )
    local anim = self.m_roomNode:addPropScaleWithEasing(self.baseSequence, kAnimNormal, 250, 0, 'easeOutBounce', 'easeOutBounce', 1.0, 0.3, kCenterXY, display.cx * System.getLayoutScale(), (display.bottom - 100) * System.getLayoutScale())
	if anim then
		anim:setEvent(self, AnimationWinGame.startShake)
	end
end

--[[ 开始震动 ]]
function AnimationWinGame:startShake()
	self.animShake = AnimFactory.createAnimDouble(kAnimLoop,0,3, 50, 0);
	self.animShake:setDebugName("AnimDouble|AnimationWinGame.animShake");
	self.shakeCount = 0;
	self.propShake = new(PropTranslate, self.animShake, self.animShake);
	self.m_roomNode:addProp(self.propShake, self.baseSequence+5);
	self.animShake:setEvent(self, self.onShakeFinish);
end

function AnimationWinGame:stopShake()
	if self.animShake then
		self.m_roomNode:removeProp(self.baseSequence+5);
		delete(self.propShake);
		self.propShake=nil;
		delete(self.animShake);
		self.animShake = nil;
	end
	-- 避免异常退出
	if not self.m_roomNode.m_props then
		self:release()
		return
	end
	if not self.m_roomNode:checkAddProp(self.baseSequence) then
		self.m_roomNode:removeProp(self.baseSequence)
	end
	local anim = self.m_roomNode:addPropScaleWithEasing(self.baseSequence + 10, kAnimNormal, 250, 0, 'easeInBack', 'easeInBack', 1.3, -0.3, kCenterXY, display.cx * System.getLayoutScale(), (display.bottom - 100) * System.getLayoutScale())
	if anim then
		anim:setEvent(self, self.release)
	else
		self:release()
	end
end

function AnimationWinGame:onShakeFinish()
	self.shakeCount = self.shakeCount+1;
	if self.shakeCount>= 21 then
		self:stopShake();
	end
end


function AnimationWinGame:stop()
	self.isPlaying = false;

	if self.m_roomNode.m_props then
		if not self.m_roomNode:checkAddProp(self.baseSequence) then
			self.m_roomNode:removeProp(self.baseSequence)
		end
		if not self.m_roomNode:checkAddProp(self.baseSequence+10) then
			self.m_roomNode:removeProp(self.baseSequence+10)
		end
	end
end

function AnimationWinGame:release()
	self:stop();
end

function AnimationWinGame:dtor()
	self:stop();
end

return AnimationWinGame