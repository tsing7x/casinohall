local GameWindow = require("app.popu.gameWindow")
local ErrorTipBox = class(GameWindow)

ErrorTipBox.s_controls =
{
	content_view = 1,
	content_text = 2,
	confirm_btn = 3,
};

-- local BtnDiffX = 120

function ErrorTipBox:initView(data)
	local View = self:getControl(self.s_controls.content_view);
	View:roateTo(90, 0.1);

	local textView = self:getControl(self.s_controls.content_text);	
	textView:setText(data);
end

function ErrorTipBox:onConfirmBtnClick()
	self:dismiss(true)
end

----------------------------  config  --------------------------------------------------------
ErrorTipBox.s_controlConfig = 
{
	[ErrorTipBox.s_controls.content_view] 	= {"View"},
	[ErrorTipBox.s_controls.content_text] 	= {"View", "TextView"},
	[ErrorTipBox.s_controls.confirm_btn] 	= {"View", "Button"},
};

ErrorTipBox.s_controlFuncMap = 
{
	[ErrorTipBox.s_controls.confirm_btn] = ErrorTipBox.onConfirmBtnClick;
};

return ErrorTipBox