local AnimationBase = class(Node)

function AnimationBase:load(...)
end

function AnimationBase:play(...)
	self:stop()
	self:load(...)
end

function AnimationBase:stop()
end

function AnimationBase:release()
	self:stop()
	self:removeSelf()
end

function AnimationBase:dtor()
	self:stop()
end

return AnimationBase