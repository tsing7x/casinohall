local GameWindow = require("app.popu.gameWindow")
local enterRoomPopu = class(GameWindow)

-- local Hall_string = require("app.res.config")
local resPath = "popu/enterRoom/"

local cIndex = 0
local function getIndex()
	cIndex = cIndex + 1
	return cIndex
end

enterRoomPopu.s_controls =
{
	btn_close = getIndex(),
	btn_confirm = getIndex(),
	text_enterRoom = getIndex(),
	text_inputTip = getIndex(),
	view_input = getIndex(),
	view_screen = getIndex(),
};

enterRoomPopu.s_controlConfig = 
{
	[enterRoomPopu.s_controls.btn_close] 	= {"img_popuBg", "btn_close"},
	[enterRoomPopu.s_controls.btn_confirm] 	= {"img_popuBg", "btn_confirm"},
	[enterRoomPopu.s_controls.text_enterRoom] 	= {"img_popuBg", "btn_confirm", "text_enterRoom"},
	[enterRoomPopu.s_controls.text_inputTip] 	= {"img_popuBg", "btn_bg","tip"},
	[enterRoomPopu.s_controls.view_input] 	= {"img_popuBg", "btn_bg","viewBtn"},
	[enterRoomPopu.s_controls.view_screen] 	= {"img_popuBg", "btn_bg","inputBg", "viewNum"},
};

-- local BtnDiffX = 120

function enterRoomPopu:onErrorRoomCode()
	
end

function enterRoomPopu:initView(data)
	if not data then return end
	self.m_gameId = data.gameId
	self.m_callback = data.callback
	self:initInputView(data)
end

function enterRoomPopu:initInputView(data)
	local text_inputTip = self:getControl(enterRoomPopu.s_controls.text_inputTip)
	text_inputTip:setText(Hall_string.STR_INPUT_CODE_TIPS)

	local text_enterRoom = self:getControl(enterRoomPopu.s_controls.text_enterRoom)
	text_enterRoom:setText(Hall_string.str_confirm)

	local view_input = self:getControl(enterRoomPopu.s_controls.view_input)
	local btns = view_input:getChildren()
	for i=1,#btns do
		btns[i]:setScaleOffset(0.98)
	end

	self.m_Str = "";

	for i=0,9 do
		local btn = view_input:findChildByName("btnNum"..i)
		btn:setOnClick(self,function()
			print(i)
			if #self.m_Str < 6 then
				self.m_Str = self.m_Str .. i
				self:freshScreen()
			else
				self:onErrorRoomCode()
			end
		end)
	end

	local btn = view_input:findChildByName("btnNumC")
	btn:setOnClick(self,function()
		self.m_Str = "";
		self:freshScreen()
	end)
	btn = view_input:findChildByName("btnNumD")
	btn:setOnClick(self,function()
		self.m_Str = string.sub(self.m_Str, 1, #self.m_Str - 1)
		self:freshScreen()
	end)

	self:freshScreen()
end

function enterRoomPopu:freshScreen()
	local numStr = self.m_Str
	for i=6, 1, -1 do
		local numText = self:findChildByName("inputBg"):findChildByName(string.format('num%d', i))
		local ss = string.sub(numStr, i, i)
		if ss and tonumber(ss) then
			numText:setFile(string.format("popu/enterRoom/inputNum/%s.png", ss))
			numText:show()
		else
			numText:hide()
		end
	end
end


function enterRoomPopu:onCloseBtnClick()
	self:dismiss()
end

function enterRoomPopu:onConfirmBtnClick()
	if type(self.m_callback)=="function" then
		local prama = {
			enterType = "roomCode",
			gameid = self.m_gameId,
			password = self.m_Str,
		}
		self.m_callback(prama)
	end
end

----------------------------  config  --------------------------------------------------------

enterRoomPopu.s_controlFuncMap = 
{
	[enterRoomPopu.s_controls.btn_close] = enterRoomPopu.onCloseBtnClick;
	[enterRoomPopu.s_controls.btn_confirm] = enterRoomPopu.onConfirmBtnClick;
};

return enterRoomPopu