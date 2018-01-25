local AnimationBase = import(".animationBase");
local AnimShake = class(AnimationBase);

function AnimShake:load(target)
	self.target = target
	self.originX,self.originY = target:getPos()
end

function AnimShake:play(target)
	if not target then return end
	if not target:getParent() then return end--场景根节点填充屏幕貌似无法改变位置
	self:stop();
	self:load(target);
	self:startShake();
end

function AnimShake:stop()
	self:stopShake();
end

function AnimShake:release()
	self:stop()
	self:removeSelf()
end

function AnimShake:startShake()
	self.animShakeCount = 1;
	self.animShake = AnimFactory.createAnimInt(kAnimRepeat, 0, 0, 50, -1);
	self.animShake:setEvent(self, self.onFinishShake);
	self.animShake:setDebugName("AnimInt|AnimShake.animShake");
end

function AnimShake:stopShake()
	if self.animShake then
		delete(self.animShake);
		self.animShake = nil;
	end
	if self.target then
		self.target:setPos(self.originX,self.originY);
		self.target = nil;
	end
end

function AnimShake:onFinishShake(anim_type, anim_id, repeat_or_loop_num)
	local sX, sY = self.originX + math.random(4) - 2, self.originY + math.random(4) - 2;
	self.target:setPos(sX, sY);
	if self.animShakeCount <= 20 then
		self.animShakeCount = self.animShakeCount+1;
	else
		self:release();
	end
end

return AnimShake