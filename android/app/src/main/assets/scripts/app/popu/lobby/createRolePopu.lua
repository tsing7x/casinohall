local GameWindow = require("app.popu.gameWindow")
local createRolePopu = class(GameWindow)

local Hall_String = require("app.res.config")
local resPath = "popu/registerAward/"

local cIndex = 0
local function getIndex()
	cIndex = cIndex + 1
	return cIndex
end

createRolePopu.s_controls =
{
	btn_confirm = getIndex(),
	edit_code = getIndex(),
	btn_man = getIndex(),
	btn_woman = getIndex(),
	text_male = getIndex(),
	text_female = getIndex(),
	text_tip = getIndex(),
	btn_random = getIndex(),
	text_confirm = getIndex(),
};

createRolePopu.s_controlConfig = 
{
	[createRolePopu.s_controls.btn_confirm] 	= {"img_popuBg","btn_confirm"},
	[createRolePopu.s_controls.edit_code] 	= {"img_popuBg","view_nick","edit_code"},
	[createRolePopu.s_controls.btn_man] 	= {"img_popuBg","btn_man"},
	[createRolePopu.s_controls.btn_woman] 	= {"img_popuBg","btn_woman"},
	[createRolePopu.s_controls.text_male] 	= {"img_popuBg","text_male"},
	[createRolePopu.s_controls.text_female] 	= {"img_popuBg","text_female"},
	[createRolePopu.s_controls.text_tip] 	= {"img_popuBg","view_nick","text_tip"},
	[createRolePopu.s_controls.btn_random] 	= {"img_popuBg","view_nick","btn_random"},
	[createRolePopu.s_controls.text_confirm]={"img_popuBg","btn_confirm","text_confirm"},


};

-- local BtnDiffX = 120

function createRolePopu:initView(data)
	if not data then return end
	self.m_callback = data.callback

	self:getControl(createRolePopu.s_controls.edit_code):setText(Hall_String.str_createRole_inputinck)
	self:getControl(createRolePopu.s_controls.text_male):setText(Hall_String.str_male)
	self:getControl(createRolePopu.s_controls.text_female):setText(Hall_String.str_female)
	self:getControl(createRolePopu.s_controls.text_confirm):setText(Hall_String.str_get_reward)

	self:onManBtnClick()
end


function createRolePopu:dtor()
	
	self.super.dtor(self)
end


function createRolePopu:onConfirmBtnClick()
	local edit_code = self:getControl(createRolePopu.s_controls.edit_code)
	local str = edit_code:getText()

	if self.m_callback and type(self.m_callback)=="function" then
		self.m_callback({sex=self.m_sex,name=str})
	end
end

function createRolePopu:onManBtnClick()
	self.m_sex = "male"
	self:getControl(createRolePopu.s_controls.btn_man):findChildByName("img_normal"):hide()
	self:getControl(createRolePopu.s_controls.btn_man):findChildByName("img_select"):show()

	self:getControl(createRolePopu.s_controls.btn_woman):findChildByName("img_normal"):show()
	self:getControl(createRolePopu.s_controls.btn_woman):findChildByName("img_select"):hide()
end

function createRolePopu:onWomanBtnClick()
	self.m_sex="female"
	self:getControl(createRolePopu.s_controls.btn_woman):findChildByName("img_normal"):hide()
	self:getControl(createRolePopu.s_controls.btn_woman):findChildByName("img_select"):show()

	self:getControl(createRolePopu.s_controls.btn_man):findChildByName("img_normal"):show()
	self:getControl(createRolePopu.s_controls.btn_man):findChildByName("img_select"):hide()
end

function createRolePopu:onRondomBtnClick()
	local edit_code = self:getControl(createRolePopu.s_controls.edit_code)
	edit_code:setText(PhpManager:getModelName())
end
----------------------------  config  --------------------------------------------------------

createRolePopu.s_controlFuncMap = 
{
	[createRolePopu.s_controls.btn_confirm] = createRolePopu.onConfirmBtnClick;
	[createRolePopu.s_controls.btn_man] = createRolePopu.onManBtnClick;
	[createRolePopu.s_controls.btn_woman] = createRolePopu.onWomanBtnClick;
	[createRolePopu.s_controls.btn_random] = createRolePopu.onRondomBtnClick;
};

return createRolePopu