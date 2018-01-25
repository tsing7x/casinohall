-- BaseLayer.lua
-- Author: Vicent Gong
-- Date: 2013-01-17
-- Last modification : 2013-06-27
-- Description: A base class of layer in multi-layer scene 

require("core/object");
-- require("core/sceneLoader");
require("ui/node");

BaseLayer = class(Node);

BaseLayer.s_controls = 
{

};

BaseLayer.s_controlConfig = 
{
	--[BaseLayer.s_controls.***] = {"***","***","***"};
};

BaseLayer.s_controlFuncMap = 
{
	--[BaseLayer.s_controls.***] = function;
};

BaseLayer.s_cmds = 
{

};

BaseLayer.s_cmdConfig = 
{
	--[BaseLayer.s_cmds.***] = ***;
};

BaseLayer.s_ctrlCallbackMap = 
{
	{CheckBoxGroup      , "setOnChange"};
	{RadioButtonGroup 	, "setOnChange"};
	{Button 			, "setOnClick"};
	{EditText			, "setOnTextChange"};
	{EditTextView		, "setOnTextChange"};
	{Images	    		, "setEventTouch"};
	{Image				, "setEventTouch"};
	{Slider 			, "setOnChange"};
	{Switch				, "setOnChange"};
	{DrawingBase		, "setEventTouch"};
};

BaseLayer.ctor = function(self, viewConfig)
	if not viewConfig then
		return;
	end
	self.m_root = SceneLoader.load(viewConfig);
	if self.m_root then 
	    BaseLayer.addChild(self, self.m_root);
	end
	self.m_ctrl = self.s_controls;
	self.m_controlsMap = {};
	BaseLayer.addEventListeners(self);
end

--virtual function
BaseLayer.getControl = function(self, control)
	if self.m_controlsMap[control] ~= nil then
		return self.m_controlsMap[control] or nil;
	end

	local config = self.s_controlConfig[control];

	if (not config) or (#config < 1) then
		self.m_controlsMap[control] = false;
		return nil;
	end

	local itorNestValues = function(t)
		local index = {1};

		return function()
			local getValue = function(t,idx)
				local c = t;
				for i=1,#idx-1 do
					c = c[ idx[i] ]; 
				end
				c = c[ idx[#idx] ];
				return c
			end

			local value = getValue(t,index);
			while not value do
				table.remove(index,#index);
				if #index < 1 then
					return nil;
				end
				index[#index] = index[#index] + 1;
				value = getValue(t,index);
			end

			while type(value) == "table" do
				index[#index+1] = 1;
				value = getValue(t,index);
			end

			index[#index] = index[#index] + 1;
			return value;
		end
	end
    
    local ctrl = self.m_root;
	for v in itorNestValues(config) do
		ctrl = ctrl:getChildByName(v);
		self.m_controlsMap[control] = ctrl;
		if not ctrl then
			self.m_controlsMap[control] = false;
			break;
		end
	end
	
	return self.m_controlsMap[control] or nil;
end

BaseLayer.testCmd = function(self, cmd)
	return self.s_cmdConfig[cmd] and true or false;
end

BaseLayer.handleCmd = function(self, cmd, ...)
	if not self.s_cmdConfig[cmd] then
		FwLog("Scene, no such cmd" .. cmd);
		return;
	end

	return self.s_cmdConfig[cmd](self,...)
end

BaseLayer.dtor = function(self)
	self.m_root = nil;
	self.m_controlsMap = nil;
end

---------------------------------private functions-----------------------------------------

BaseLayer.addEventListeners = function(self)
    for k,v in pairs(self.s_controlFuncMap) do
		local ctrl = self:getControl(k);
		if ctrl then
			for _,vv in ipairs(BaseLayer.s_ctrlCallbackMap) do 
				if typeof(ctrl,vv[1]) then
					ctrl[ vv[2] ](ctrl,self,v);
					break;
				end
			end
		end
	end
end
