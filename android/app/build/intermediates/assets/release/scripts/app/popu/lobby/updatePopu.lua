local GameWindow = require("app.popu.gameWindow")
local updatePopu = class(GameWindow)

local Hall_String = require("app.res.config")

local cIndex = 0
local function getIndex()
	cIndex = cIndex + 1
	return cIndex
end

updatePopu.s_controls =
{
	cancel_btn = getIndex(),
	confirm_btn = getIndex(),
	cancel_text = getIndex(),
	confirm_text = getIndex(),
	text_title = getIndex(),
	view_updateInfo = getIndex(),
	text_version = getIndex(),
	text_size_tip = getIndex(),
	text_size = getIndex(),
};

updatePopu.s_controlConfig = 
{
	[updatePopu.s_controls.cancel_btn] 	= {"img_popuBg", "btn_cancel"},
	[updatePopu.s_controls.confirm_btn] 	= {"img_popuBg","btn_confirm"},
	[updatePopu.s_controls.cancel_text] 	= {"img_popuBg","btn_cancel","text_cancel"},
	[updatePopu.s_controls.confirm_text] 	= {"img_popuBg","btn_confirm","text_confirm"},
	[updatePopu.s_controls.text_title] 	= {"img_popuBg","img_title", "text_title"},
	[updatePopu.s_controls.view_updateInfo] 	= {"img_popuBg","view_content", "view_updateInfo"},
	[updatePopu.s_controls.text_version] 	= {"img_popuBg","view_content","text_version"},
	[updatePopu.s_controls.text_size_tip] 	= {"img_popuBg","view_content","text_size_tip"},
	[updatePopu.s_controls.text_size] 	= {"img_popuBg","view_content","text_size_tip","text_size"},
};

-- local BtnDiffX = 120

function updatePopu:initView(data)
	self:findChildByName("img_popuBg"):setEventTouch(self, function()
		-- body
	end)

	if not data then return end
	self.cancelFunc = data.cancelFunc
	self.confirmFunc = data.confirmFunc
	self:getControl(self.s_controls.text_size_tip):setText(Hall_String.str_update_size)
	self:getControl(self.s_controls.text_title):setText(Hall_String.str_update_title)
	self:getControl(self.s_controls.cancel_text):setText(Hall_String.str_update_cancel)
	self:getControl(self.s_controls.confirm_text):setText(Hall_String.str_update_confirm)

	local text_version = self:getControl(self.s_controls.text_version)
	local text_size = self:getControl(self.s_controls.text_size)
	local view_updateInfo = self:getControl(self.s_controls.view_updateInfo)
	if data.size then
		text_size:setText(string.format("%sM",data.size))
	end
	if data.version then
		text_version:setText(string.format(Hall_String.str_update_version,data.version))
	end
	if data.updateInfo then
		local h = 0
		for i=1, #data.updateInfo do
			local info = data.updateInfo[i]
			local text = new(Text,info, 0, 0, kAlignTopLeft,"", 24, 0xf2, 0xc9, 0x17)
					:pos(0,h)
					:addTo(view_updateInfo)
			local _,_h = text:getSize()
			h = h+_h
		end
	end
end

function updatePopu:onLeftBtnClick()
	if self.cancelFunc then
		self.cancelFunc()
	end
	self:dismiss()
end

function updatePopu:onRightBtnClick()
	if self.confirmFunc then
		self.confirmFunc()
	end
	self:dismiss()
end

----------------------------  config  --------------------------------------------------------

updatePopu.s_controlFuncMap = 
{
	[updatePopu.s_controls.cancel_btn] = updatePopu.onLeftBtnClick;
	[updatePopu.s_controls.confirm_btn] = updatePopu.onRightBtnClick;
};

return updatePopu