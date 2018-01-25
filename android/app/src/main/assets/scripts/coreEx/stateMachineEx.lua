require("statesConfig");
require("app.common.stateChange")

StateStyle = 
{	
	NORMAL = 1,
	POPUP = 2,
	FADE  = 3,
	TRANSLATE_TO = 4,
	TRANSLATE_BACK = 5,
};

local superPushState = StateMachine.pushState;
StateMachine.pushState = function(self, state, style, isPopupState, ...)
	if(kCurrentState == state) then
		return;
	end
    superPushState(self, state, style, isPopupState, ...);
end

local superCtor = StateMachine.ctor;
StateMachine.ctor = function(self)
	superCtor(self);
	StateMachine.registerStyle(self, StateStyle.TRANSLATE_TO, StateMachine.translateToStyle);
	StateMachine.registerStyle(self, StateStyle.TRANSLATE_BACK, StateMachine.translateBackStyle);
end

StateMachine.translateToStyle = function(newStateObj, lastStateObj, self, onSwitchEnd)
	if self.m_translateAnim then
		return;
	end
	local screenW = System.getScreenScaleWidth();
	local screenH = System.getScreenScaleHeight();

	local newView = newStateObj:getController().m_view.m_root;
	local lastView = lastStateObj:getController().m_view.m_root;
	-- newView:setVisible(false)
	-- local duration = 500;
	-- self.m_translateAnim = new(EaseMotion, kEaseOut, 30, duration, 0, {2.0});
	-- self.m_translateAnim:setEvent(nil, function()
	-- 	local process = self.m_translateAnim and self.m_translateAnim.m_process or 1;
	-- 	local time = self.m_translateAnim and self.m_translateAnim.m_timer or duration;
	-- 	newView:removeProp(0);
	-- 	lastView:removeProp(0);
	-- 	if time <= duration then
	-- 		newView:addPropTranslateSolid(0, screenW * (1- process), 0)
	-- 		lastView:addPropTranslateSolid(0, -screenW * process, 0)
	-- 	else
	-- 		onSwitchEnd(self);
	-- 		delete(self.m_translateAnim);
	-- 		self.m_translateAnim = nil;
	-- 	end
	-- 	newView:setVisible(true);
	-- end)
	-- 由于translateTo 是需要创建界面 所以需要预留多一些时间 加了100ms延迟
	self.m_translateAnim = newView:addPropTranslate(0, kAnimNormal, 200, 100, screenW, 0, 0, 0);
	lastView:addPropTranslate(0, kAnimNormal, 200, 100, 0, -screenW, 0, 0);
	self.m_translateAnim:setEvent(nil,function()
		newView:removeProp(0);
		lastView:removeProp(0);
		onSwitchEnd(self);
		self.m_translateAnim = nil;
	end);
end

StateMachine.translateBackStyle = function(newStateObj, lastStateObj, self, onSwitchEnd)
	if self.m_translateAnim then
		return;
	end

	local screenW = System.getScreenScaleWidth();
	local screenH = System.getScreenScaleHeight();
	local newView = newStateObj:getController().m_view.m_root;
	local lastView = lastStateObj:getController().m_view.m_root;

	self.m_translateAnim = newView:addPropTranslate(0, kAnimNormal, 200, 0, -screenW, 0, 0, 0);
	lastView:addPropTranslate(0, kAnimNormal, 200, 0, 0, screenW, 0, 0);
	self.m_translateAnim:setEvent(nil,function()
		newView:removeProp(0);
		lastView:removeProp(0);
		onSwitchEnd(self);
		self.m_translateAnim = nil;
	end);
end

--[[
local superGetNewState = StateMachine.getNewState;
StateMachine.getNewState = function(self, state, ...)
	autoRequire(state);
	superGetNewState(self, state, ...);
end--]]
StateMachine.getNewState = function(self, state, ...)
	local nextStateIndex;
	for i,v in ipairs(self.m_states) do 
		if v.state == state then
			nextStateIndex = i;
			break;
		end
	end
	autoRequire(state)
	local nextState;
	if nextStateIndex then
		nextState = table.remove(self.m_states,nextStateIndex);
	else
		nextState = {};
		nextState.state = state;
		nextState.stateObj = new(StatesMap[state],...);
	end
	return nextState,(not nextStateIndex);
end

StateMachine.onSwitchEnd = function(self)
	if self.m_lastState then
		if self.m_releaseLastState then
			StateMachine.cleanState(self,self.m_lastState);
		elseif self.m_isNewStatePopup then
		
		else
			self.m_lastState.stateObj:stop();
		end
	end

	self.m_lastState = nil;
	self.m_releaseLastState = false;

	local newState = self.m_states[#self.m_states].stateObj;
	local state = self.m_states[#self.m_states].state;
	StateChange.stateChangeEnd(state, newState);
	newState:resume(self.m_bundleData);  -- ADD
	self.m_bundleData = nil; -- 生效一次
end

StateMachine.setBundleData = function(self, bundleData)
	self.m_bundleData = bundleData;
end