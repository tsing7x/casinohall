local ctor = ScrollableNode.ctor;
ScrollableNode.ctor = function(self, direction, scrollBarWidth)
    ctor(self, direction, scrollBarWidth);
	self.scrolllerAlways = false;
end

ScrollableNode.setScrollAlways = function (self, always )
	-- body
	self.scrolllerAlways = always;
end

ScrollableNode.updateScroller = function(self)

	if not self.scrolllerAlways and not (self:needScroller() 
		and ScrollableNode.isAllLengthVaild(self) 
		and ScrollableNode.isViewBiggerThanFrame(self)) then

		ScrollableNode.releaseScroller(self);
		return;
	end

	if ScrollableNode.hasScroller(self) then
		local frameLength = self:getFrameLength();
		local viewLength = self:getViewLength();
		local unitLength = self:getUnitLength();
		self.m_scroller:setFrameLength(frameLength);
		self.m_scroller:setViewLength(viewLength);
		self.m_scroller:setUnitLength(unitLength);
		self.m_scroller:stopMarginRebounding();
	else
		ScrollableNode.createScroller(self);
	end
end