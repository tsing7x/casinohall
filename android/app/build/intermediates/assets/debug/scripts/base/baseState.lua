require("core/object")
require("core/state")
require("core/global")
require("core/eventDispatcher")

BaseState = class(State)

function BaseState:ctor()
	self.m_stateStack = {}
end

function BaseState:getController()
	return self.m_controller
end

function BaseState:gobackLastState()
	error("Sub class must define this function")
end

function BaseState:load()
	State.load(self)
	return true
end

function BaseState:run()
	State.run(self)

	local controller = self:getController()
	if typeof(controller, BaseController) then
		controller:run()
	end
end

function BaseState:resume(bundleData)
	State.resume(self)
    EventDispatcher.getInstance():register(Event.Back,self,self.onBack)
    
	local controller = self:getController()
	if typeof(controller, BaseController) then
		controller:resume(bundleData)
	end
end

function BaseState:pause()
	local controller = self:getController()
	if typeof(controller, BaseController) then
		controller:pause()
	end
	
	EventDispatcher.getInstance():unregister(Event.Back,self,self.onBack)

	State.pause(self)
end

function BaseState:stop()
	local controller = self:getController()
	if typeof(controller, BaseController) then
		controller:stop()
	end

	State.stop(self)
end

function BaseState:pushStateStack(obj, func)
	if not self.m_stateStack then
		return
	end
	
	local t = {}
	t["obj"] = obj
	t["func"] = func
	self.m_stateStack[#self.m_stateStack+1] = t
end

function BaseState:popStateStack()
	if not self.m_stateStack then
		return
	end
	
	if #self.m_stateStack > 0 then
		return table.remove(self.m_stateStack,#self.m_stateStack)
	else
		return nil
	end
end

function BaseState:changeState(state, bundleData, style, ...)
	StateChange.changeState(state, bundleData, style,...)
end

function BaseState:pushState(state, style, isPopupState, ...)
	StateMachine.getInstance():pushState(state,style,isPopupState,...)
end

function BaseState:popState(style, ...)
	local lastStateCallback = self:popStateStack()
	local lastStateCbFunc = lastStateCallback and lastStateCallback["func"]
	if lastStateCbFunc then
		lastStateCbFunc(lastStateCallback["obj"],...)
	else
		return self:gobackLastState(...)
	end
end

function BaseState:gobackLastState()
	if WindowManager and not WindowManager:onKeyBack() then  -- 如果没有可关闭的弹窗
		printInfo("onBack=========== 11111111")
		self.m_controller:onBack()
	end
end

function BaseState:dtor()
	self.m_stateStack = nil
end

---------------------------------private functions-----------------------------------------

function BaseState:onBack()
	self:popState()
end
