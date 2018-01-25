local GameWindow = class(BaseLayer)

function GameWindow:ctor(viewConfig, data)
    self.loadingNode = {}
	self:setVisible(false)
	self:setFillParent(true, true)
	self.m_root:setFillParent(true, true)
	local bg = self.m_root:findChildByName("img_bg")
	if bg then
		bg:setEventTouch(self, function(self)
            self:dismiss()
        end)
		bg:setEventDrag(nil, function() end)
	end

    local popuBg = self.m_root:findChildByName("img_popuBg")
    if popuBg then
        popuBg:setEventTouch(nil, function(self) end)
    end

	EventDispatcher.getInstance():register(HttpModule.s_event, self, self.onPHPRequestsCallBack);
end

function GameWindow:dtor(viewConfig, data)
	EventDispatcher.getInstance():unregister(HttpModule.s_event, self, self.onPHPRequestsCallBack);
end

function GameWindow:isBgTouchHide()
	return self.bgTouchHide
end

function GameWindow:isAutoRemove()
	return self.autoRemove
end

function GameWindow:isStateRemove()
	return self.stateRemove
end

function GameWindow:isPlayAnim()
	return self.animFlag
end

-- back键
function GameWindow:isBackHide()
	return self.backHide
end

function GameWindow:setConfigFlag(bgTouchHide, backHide, autoRemove, stateRemove)
	self.bgTouchHide = bgTouchHide
	self.backHide 	 = backHide
	self.autoRemove  = autoRemove
	self.stateRemove = stateRemove
end

function GameWindow:initView(data)
    
end

function GameWindow:updateView(data)
end

--@isOtherDismiss 是否非关闭按钮
function GameWindow:onHidenEnd(isOtherDismiss)
	self.animFlag = nil
	self:setVisible(false)
	self:getParent():onHidenEnd(self:getName(), self:isAutoRemove())
end

function GameWindow:onShowEnd()
	printInfo("onShowEnd")
	self.animFlag = nil
	self:getParent():onShowEnd(self:getName())
end

function GameWindow:show(style)
    
	self.m_style = style or WindowStyle.POPUP
	if self.animFlag or self:getVisible() then
		return false
	end

	self:setVisible(true)
	self.animFlag = true
	if self.m_style == WindowStyle.NORMAL then
		self:onShowEnd()
	elseif self.m_style == WindowStyle.TRANSLATE_DOWN then
		local anim = self:addPropTranslate(1001, kAnimNormal, 300, -1,0, 0, -display.cy * 2, 0)
		if anim then
			anim:setEvent(nil, function()
				self:removeProp(1001)
				self:onShowEnd()
			end)
		end
	elseif self.m_style == WindowStyle.POPUP then
		
    	local anim = self:addPropScaleWithEasing(1001, kAnimNormal, 300, -1, 'easeOutBack', 'easeOutBack', 0.0, 1.0)
		if anim then
			anim:setEvent(nil, function()
				self:removeProp(1001)
				self:onShowEnd()
			end)
		end

	elseif self.m_style == WindowStyle.TRANSLATE_LEFT then
		local anim = self:addPropTranslate(1001, kAnimNormal,300, -1, -display.cx * 2,0, 0, 0)
		if anim then
			anim:setEvent(nil, function()
				self:removeProp(1001)
				self:onShowEnd()
			end)
		end

	elseif self.m_style == WindowStyle.TRANSLATE_RIGHT then
		local anim = self:addPropTranslate(1001, kAnimNormal,300, -1, display.cx * 2,0, 0, 0)
		if anim then
			anim:setEvent(nil, function()
				self:removeProp(1001)
				self:onShowEnd()
			end)
		end

	end
	return true
end

function GameWindow:dismiss(directFlag, isOtherDismiss, dismissStyle)
	if self.animFlag or not self:getVisible() then
		return false
	end
	self.m_style = dismissStyle or self.m_style;
	JLog.d("消失类型",self.m_style);
	self.animFlag = true
	if directFlag or self.m_style == WindowStyle.NORMAL or not self.m_style then
		self:onHidenEnd(isOtherDismiss)
	elseif self.m_style == WindowStyle.TRANSLATE_DOWN then
		local anim = self:addPropTranslate(1001, kAnimNormal,300, -1, 0, 0, 0, -display.cy * 2)
		if anim then
			anim:setEvent(nil, function()
				self:removeProp(1001)
				self:onHidenEnd(isOtherDismiss)
			end)
		end
	elseif self.m_style == WindowStyle.POPUP then
		local anim = self:addPropScaleWithEasing(1001, kAnimNormal, 300, -1, 'easeInBack', 'easeInBack', 1.0, -0.5)
		if anim then
			anim:setEvent(nil, function()
				self:removeProp(1001)
				self:onHidenEnd(isOtherDismiss)
			end)
		end
	elseif self.m_style == WindowStyle.TRANSLATE_LEFT then
		local anim = self:addPropTranslate(1001, kAnimNormal,300, -1, 0, -display.cx * 2, 0, 0)
		if anim then
			anim:setEvent(nil, function()
				self:removeProp(1001)
				self:onHidenEnd(isOtherDismiss)
			end)
		end
	elseif self.m_style == WindowStyle.TRANSLATE_RIGHT then
		local anim = self:addPropTranslate(1001, kAnimNormal,300, -1, 0, display.cx * 2, 0, 0)
		if anim then
			anim:setEvent(nil, function()
				self:removeProp(1001)
				self:onHidenEnd(isOtherDismiss)
			end)
		end
	
	end

	return true
end

function GameWindow:execHttpCmd(command, data, continueLast, isShowLoading, parentNode)
    for k, v in pairs(self.loadingNode) do
        v.node:stop()
    end
    HttpModule.getInstance():execute(command, data, true, continueLast)
    
    if isShowLoading or (isShowLoading == nil) then
        local loadingParent = parentNode or self.m_root
        --loading has exist
        if self.loadingNode[loadingParent] then
            self.loadingNode[loadingParent].command = command
            self.loadingNode[loadingParent].node:play()
        else
            local toastShadeBg = new(ToastShade,false)
            toastShadeBg:findChildByName("view_loading"):addPropScaleSolid(1, 0.8, 0.8, kCenterDrawing)
            self.loadingNode[loadingParent] = {}
            self.loadingNode[loadingParent].command = command
            self.loadingNode[loadingParent].node = toastShadeBg
            loadingParent:addChild(toastShadeBg)
            toastShadeBg:play()
        end
        
    end
end

function GameWindow:onPHPRequestsCallBack(command, ...)
    for k, v in pairs(self.loadingNode) do
        if v.command == command then
            (v.node):stop()
        end
    end
	if self.s_severCmdEventFuncMap[command] then
     	self.s_severCmdEventFuncMap[command](self,...)
	end 
end 

--[[
	通用的（大厅）协议
]]
GameWindow.s_severCmdEventFuncMap = {
    
}

return GameWindow
