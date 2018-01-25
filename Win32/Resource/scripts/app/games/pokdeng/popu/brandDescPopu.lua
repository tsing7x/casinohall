local GameWindow = require("app.popu.gameWindow")
local popu = class(GameWindow)

local cIndex = 0
local function getIndex()
	cIndex = cIndex + 1
	return cIndex
end

popu.s_controls =
{
	btn_close = getIndex(),
};

popu.s_controlConfig = 
{
	[popu.s_controls.btn_close] 	= {"img_popuBg","btn_close"},
};

function popu:initView(data)
end

function popu:onBackBtnClick()
	self:dismiss()
end
----------------------------  config  --------------------------------------------------------
popu.s_controlFuncMap = 
{
	[popu.s_controls.btn_close] = popu.onBackBtnClick;
};

return popu
