--ScrollView
ScrollView.update = function(self)
	if self.m_direction == kVertical then
		if self.m_nodeH <= self:getFrameLength() then
			self.m_mainNode:setPos(0, 0)
		end
	end
	ScrollableNode.update(self)
end

ScrollView.removeChild = function(self, child, doCleanup, anim, deltaH)

	if not anim then
		return self.m_mainNode:removeChild(child,doCleanup);
	end

	local x, y = child:getPos();
	local w, h = child:getSize();

	local nodeAnimIndex = {};
	local needAnim = false;

	for index, child in pairs(self:getChildren()) do
		local _x, _y = child:getPos();
		if _y > y then
			nodeAnimIndex[index] = index;
			needAnim = true;
		end
	end

	self.m_mainNode:removeChild(child,doCleanup);

	if not needAnim then
		self.m_nodeH = self.m_nodeH - deltaH;
		ScrollView.update(self);
		return;
	end

	local step  = 15;
	local animH = 0;

	self.mAnimId = self.mAnimId or 0;
	self.mAnimId = self.mAnimId + 1;

	local animId = tonumber(self.mAnimId);
    
    local closeAnim = self:addPropTransparency(animId, kAnimRepeat, 50, 0, 1, 1);
    closeAnim:setDebugName("ScrollView || anim");
    closeAnim:setEvent(self, function ( self )
        -- body
        animH = animH + step;

        if animH >= deltaH then
            self:removeProp(animId);
            
            for index, child in pairs(self:getChildren()) do
            	if nodeAnimIndex[index] then
					local _x, _y = child:getPos();
					child:setPos(_x, _y - (deltaH - (animH - step)));
				end
			end
			self.m_nodeH = self.m_nodeH - deltaH;

			ScrollView.update(self);
            return;
        end

		for index, child in pairs(self:getChildren()) do
			if nodeAnimIndex[index] then
				local _x, _y = child:getPos();
				child:setPos(_x, _y - step);
			end
		end
    end);
    self.closeAnim = closeAnim;
end

--add by zyh
ScrollView.reposition = function(self)
	local children = self.m_mainNode:getChildren()
	self.m_nodeH = 0
	self.m_nodeW = 0
	for i = 1, #children do
		if children[i] and children[i]:getVisible() then
			local w, h = children[i]:getSize()
			children[i]:setPos(self.m_nodeW, self.m_nodeH)
			if self.m_direction == kVertical then
				self.m_nodeH = self.m_nodeH + h
			else
				self.m_nodeW = self.m_nodeW + w
			end
		end
	end
	ScrollView.update(self)
end

ScrollView.scrollWithDistance = function(self, length)
	if self.m_scroller then
		self.m_scroller:setOffset(length)
	end
end

ScrollView.scrollItemToView = function(self, item)
    local svX, svY = ScrollView.getAbsolutePos(self)
    local svW, svH = ScrollView.getSize(self)
    local itemX, itemY = item:getAbsolutePos()
    local itemW, itemH = item:getSize()
    if self.m_direction == kVertical then
        local itemBottom = itemY + itemH
        local viewBottom = svY + svH
        if itemBottom > viewBottom then
            self.m_mainNode:removeProp(1001)
            local len = viewBottom - itemBottom
            local topDis = svY - itemY
            len = len > topDis and len or topDis
            local scrollAnim = self.m_mainNode:addPropTranslate(1001, kAnimNormal, 100, 0, 0, 0, 0, len)
            scrollAnim:setEvent(nil, function()
                local x, y = self.m_mainNode:getPos()
                if self.m_scroller then
                    self.m_scroller:setOffset(y + len)
                end
                self.m_mainNode:removeProp(1001)
                self.m_mainNode:setPos(x, y + len)
            end)
        end
    else
        local itemBottom = itemX + itemW
        local viewBottom = svX + svW
        if itemBottom > viewBottom then
            self.m_mainNode:removeProp(1001)
            local len = viewBottom - itemBottom
            local topDis = svX - itemX
            len = len > topDis and len or topDis
            local scrollAnim = self.m_mainNode:addPropTranslate(1001, kAnimNormal, 100, 0, 0, len, 0, 0)
            scrollAnim:setEvent(nil, function()
                local x, y = self.m_mainNode:getPos()
                if self.m_scroller then
                    self.m_scroller:setOffset(x + len)
                end
                self.m_mainNode:removeProp(1001)
                self.m_mainNode:setPos(x + len, y)
            end)
        end
    end
end

ScrollView.resetPosition = function(self)
    if self.m_scroller then
        self.m_scroller:setOffset(0 - self.m_scroller.m_offset)
    end
    self.m_mainNode:setPos(0, 0)
end

ScrollView.setAutoPosition = function(self, auto)
   self.m_autoPositionChildren = auto
end

--virtual
ScrollView.setParent = function(self, parent)
	ScrollableNode.setParent(self,parent);
	local x,y = ScrollView.getUnalignPos(self);
    local w,h = ScrollView.getSize(self);
	ScrollView.setClip(self,x,y,w,h);
end


--ScrollViewEx

ScrollViewEx = class(ScrollView, false);

ScrollViewEx.ctor = function(self, x, y, w, h, autoPositionChildren)
	super(self, x, y, w, h, autoPositionChildren);

	self.mReachBottomCallback 	= nil;
	self.mReachBottomObj 		= nil;
	self.mIsReachBottom 		= false;
end

ScrollViewEx.setOnReachBottom = function(self, obj, callback)
	self.mReachBottomCallback 	= callback;
	self.mReachBottomObj 		= obj;
end

ScrollViewEx.setOffset = function(self, offset)
end

ScrollViewEx.dtor = function(self)
    if self.closeAnim then
        delete(self.closeAnim)
        self.closeAnim = nil;
    end
end

ScrollViewEx.onScroll = function(self, scroll_status, diffY, totalOffset)
	self.super.onScroll(self, scroll_status, diffY, totalOffset);

	if self:getFrameLength() - self:getViewLength() > totalOffset then
		
		if not self.mIsReachBottom and self.mReachBottomCallback then
			self.mReachBottomCallback(self.mReachBottomObj);
		end
		self.mIsReachBottom = true;
	else
		self.mIsReachBottom = false;
	end

end