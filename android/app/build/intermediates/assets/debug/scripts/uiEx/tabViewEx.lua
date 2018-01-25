-- TabViewEx.lua
-- Author: Vicent.Gong
-- Date: 2013-08-01
-- Last modification : 2013-08-05
-- Description: Implemented TabViewEx

-- require("core/constants");
-- require("core/object");
-- require("core/global");
-- require("ui/node");
-- require("ui/scrollableNode");

local TabViewEx = class(ScrollableNode);

TabViewEx.ctor = function(self, x, y, w, h)
	super(self,kVertical,0);

	TabViewEx.setPos(self,x,y);

	self.m_mainNode = new(Node);
	ScrollableNode.addChild(self,self.m_mainNode);
	
	TabViewEx.setPos(self,x,y);
	TabViewEx.setSize(self,w,h);

	TabViewEx.setEventDrag(self,self,self.onEventDrag);
	TabViewEx.setEventTouch(self,self,self.onEventTouch);

	self.m_tabs = {};
	self.m_curIndex = 1;
	self.m_tabChangedCallback = {};
    self.m_arriveStartCallback = {};
    self.m_arriveEndCallback = {};
    --记录上次diff为0是的滚动的偏移量，用来判断第一页和最后一个滚动时是否翻页
    self.m_lastReboundDif = nil;
end

TabViewEx.dtor = function(self)
	self.m_tabs = nil;
	self.m_mainNode = nil;
	self.m_tabChangedCallback = nil;
    self.m_arriveStartCallback = nil;
    self.m_arriveEndCallback = nil;
    self.m_lastScrollDif = nil;
end

TabViewEx.addTab = function(self, node)
	TabViewEx.addChild(self,node);
end

TabViewEx.removeTab = function(self, node)
	TabViewEx.removeChild(self,node);
end

TabViewEx.removeTabByName = function(self, name)
	local node = TabViewEx.getTabByName(self,name);
	if not node then
		return;
	end
	TabViewEx.removeTab(node);
end

TabViewEx.getTabByName = function(self, name)
	return TabViewEx.getChildByName(self,name);
end

TabViewEx.getTab = function(self, index)
	return self.m_tabs[index];
end

TabViewEx.setTabChangedCallback = function(self, obj, func)
	self.m_tabChangedCallback.func = func;
	self.m_tabChangedCallback.obj = obj;
end

TabViewEx.setArriveStartCallback = function(self, obj, func)
    self.m_arriveStartCallback.func = func;
    self.m_arriveStartCallback.obj = obj;
end

TabViewEx.setArriveEndCallback = function(self, obj, func)
    self.m_arriveEndCallback.func = func;
    self.m_arriveEndCallback.obj = obj;
end

TabViewEx.getCurIndex = function(self)
	return self.m_curIndex;
end

TabViewEx.scrollToTabIndex = function(self, index)
    if index and index >= 1 and self.m_tabs[index] then
        local len = self:getFrameLength() * (1 - index)
        if self.m_direction == kVertical then
		    self.m_mainNode:setPos(0, len);
	    else
		    self.m_mainNode:setPos(len,0);
	    end
        if self.m_scroller then
            self.m_scroller:setOffset(len)
        end
    end
end

--overwrite functions  
TabViewEx.setDirection = function(self, direction)
	if self.m_direction == direction then
		return;
	end

	local frameLength = self:getFrameLength();
	if direction == kVertical then
		for i,v in ipairs(self.m_tabs) do
			v:setPos(0,(i-1)*frameLength);
		end
	else
		for i,v in ipairs(self.m_tabs) do
			v:setPos((i-1)*frameLength,0);
		end
	end

	ScrollableNode.setDirection(self,direction);
end

TabViewEx.addChild = function(self, child)
	if not child then
		return;
	end

	if self.m_direction == kVertical then
		child:setPos(0,self:getViewLength());
	else
		child:setPos(self:getViewLength(),0);
	end

	self.m_mainNode:addChild(child);
	local nTabs = #self.m_tabs;
	self.m_tabs[nTabs+1] = child;
	
	ScrollableNode.update(self);
	return nTabs + 1;
end

TabViewEx.removeChild = function(self, child)
	if not node then
		return;
	end

	local index = TabViewEx.getTabIndex(self,node);

	if not index then
		return;
	end

	self.m_mainNode:removeChild(node);
	table.remove(self.m_tabs,index);

	if self.m_direction == kVertical then
		for i=index,#self.m_tabs do
			self.m_tabs[i]:setPos(0,(i-1)*self:getFrameLength());
		end
	else
		for i=index,#self.m_tabs do
			self.m_tabs[i]:setPos((i-1)*self:getFrameLength(),0);
		end
	end

	ScrollableNode.update(self);
end

TabViewEx.getChildByName = function(self, child)
	return self.m_mainNode:getChildByName(child);
end

TabViewEx.removeAllChildren = function(self, doCleanup)
	self.m_tabs = {};
	return self.m_mainNode:removeAllChildren(doCleanup);
end

TabViewEx.getChildren = function(self)
	return self.m_mainNode:getChildren();
end

--override functions
TabViewEx.getFrameLength = function(self)
	if self.m_direction == kVertical then
		return self.m_height;
	else
		return self.m_width;
	end
end

TabViewEx.getViewLength = function(self)
    if self.m_tabs then
	    return #self.m_tabs * self:getFrameLength();
	else
	    return 0;
	end
end

TabViewEx.getUnitLength = function(self)
	return self:getFrameLength();
end

TabViewEx.getFrameOffset = function(self)
	return 0;
end

TabViewEx.needScroller = function(self)
	return true;
end

TabViewEx.needScrollBar = function(self)
	return false;
end

---------------------------------private functions-----------------------------------------

TabViewEx.getTabIndex = function(self, node)
	local index;
	for k,v in pairs(self.m_tabs) do
		if v == node then
			index = k;
			break;
		end
	end

	return index;
end

TabViewEx.getTabIndexByName = function(self, name)
	local node = TabViewEx.getChildByName(name);
	if not node then
		return nil;
	end

	return TabViewEx.getTabIndex(self,node);
end

TabViewEx.onEventTouch = function(self, finger_action, x, y, drawing_id_first, drawing_id_current)

    
end

TabViewEx.onEventDrag =  function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
	if TableView.hasScroller(self) then 
		self.m_scroller:onEventTouch(finger_action,x,y,drawing_id_first,drawing_id_current);
	end

    if finger_action == kFingerDown then
        self.m_lastReboundDif = nil;
    end
end

TabViewEx.onScroll = function(self, scroll_status, diff, totalOffset)
	ScrollableNode.onScroll(self, scroll_status, diff, totalOffset);
	if self.m_direction == kVertical then
		self.m_mainNode:setPos(0,totalOffset);
	else
		self.m_mainNode:setPos(totalOffset,0);
	end

	if scroll_status == kScrollerStatusStop then
		local lastIndex = self.m_curIndex;
		self.m_curIndex = math.floor(-totalOffset/self:getFrameLength()) + 1;
		if self.m_tabChangedCallback.func then
			self.m_tabChangedCallback.func(self.m_tabChangedCallback.obj,
										self.m_curIndex,lastIndex);
		end
    --未成功翻页
        if lastIndex == self.m_curIndex and self.m_lastReboundDif then
            if lastIndex >= #self.m_tabs and self.m_lastReboundDif - totalOffset < -100 and self.m_arriveEndCallback then
                self.m_arriveEndCallback.func(self.m_arriveEndCallback.obj);
            elseif lastIndex <= 1 and self.m_lastReboundDif - totalOffset > 100 and self.m_arriveStartCallback then
                self.m_arriveStartCallback.func(self.m_arriveStartCallback.obj)
            end
        end
	end

    if diff == 0 then
        self.m_lastReboundDif = totalOffset;
    end
end

return TabViewEx