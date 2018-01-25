local GameWindow = require("app.popu.gameWindow")
local popu = class(GameWindow)
local Room_string = require("app.games.pokdeng.res.config")

local cIndex = 0
local function getIndex()
	cIndex = cIndex + 1
	return cIndex
end

popu.s_controls =
{
	btn_back = getIndex(),
	btn_stand_up = getIndex(),
	btn_rule = getIndex(),
};

popu.s_controlConfig = 
{
	[popu.s_controls.btn_back] 	= {"img_popuBg","btn_back"},
	[popu.s_controls.btn_stand_up] 	= {"img_popuBg","btn_stand_up"},
	[popu.s_controls.btn_rule] 	= {"img_popuBg","btn_rule"},
};

function popu:initView(data)
	self:getControl(self.s_controls.btn_back):findChildByName("text"):setText(Room_string.STR_RETURN);
	self:getControl(self.s_controls.btn_stand_up):findChildByName("text"):setText(Room_string.STR_STAND_UP);
	self:getControl(self.s_controls.btn_rule):findChildByName("text"):setText(Room_string.STR_RULE);
	self.data = data
end

function popu:onBackBtnClick()
	self:dismiss()
	if self.data.backFunc then
		self.data.backFunc()
	end
end

function popu:onStandUpBtnClick()
	self:dismiss()
	if self.data.standUpFunc then
		self.data.standUpFunc()
	end
end

function popu:onRuleBtnClick()
	self:dismiss()
	if self.data.ruleFunc then
		self.data.ruleFunc()
	end
end

----------------------------  config  --------------------------------------------------------
popu.s_controlFuncMap = 
{
	[popu.s_controls.btn_back] = popu.onBackBtnClick;
	[popu.s_controls.btn_stand_up] = popu.onStandUpBtnClick;
	[popu.s_controls.btn_rule] = popu.onRuleBtnClick;
};

return popu
