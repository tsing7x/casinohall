local GameWindow = require("app.popu.gameWindow")
local debugPopu = class(GameWindow)

debugPopu.s_controls =
{
	btn_close = 1,
	btn_execute = 2,
	edit_text = 3,
};

g_editStr = [[AlarmTip.play("正在运行调试代码")]]

--data: {{text="发牌",callback = function},}
function debugPopu:initView(data)
	if not data then return end
	local img_popuBg = self:findChildByName("img_popuBg")
	local w,h = img_popuBg:getSize()
	local x ,y = 8,60
	for i=1,#data do
		local info = data[i]
		local btn = new(Button,"popu/btn_green.png")
				:addTo(img_popuBg)
				:size(80,40)
				:pos(x,y)
				:align(kAlignTopRight)
		btn:setOnClick(self,function()
			if type(info.callback) == "function" then
				info.callback()
			end
		end)

		y = y + 50
		if y>h-40 then
			y = 140
			x = x + 100
		end
		local text = new(Text, info.text, 0, 0, kAlignCenter,"", 28, 255, 0, 0)
			:addTo(btn)
			:align(kAlignCenter)
	end

	self:getControl(debugPopu.s_controls.edit_text):setText(g_editStr)
end


function debugPopu:onCloseBtnClick()
	if self.closeFunc then
		self.closeFunc()
	end
	self:dismiss(true)
end

function debugPopu:onExeCuteBtnClick()
	local str = self:getControl(debugPopu.s_controls.edit_text):getText()
	local xxx = loadstring(str)
	local ok, ret = pcall(xxx)
	g_editStr = str
end

function debugPopu:onExpendBtnClick()
	print("xxxxx")
	local img_inputBg = self:findChildByName("img_inputBg")
	img_inputBg:setVisible(not img_inputBg:getVisible())
end

debugPopu.s_controlConfig = 
{
	[debugPopu.s_controls.btn_close] 	= {"img_popuBg", "btn_close"},
	[debugPopu.s_controls.btn_execute] 	= {"img_popuBg", "btn_execute"},
	[debugPopu.s_controls.edit_text] 	= {"img_popuBg","img_inputBg" ,"edit_text"},
	
};

debugPopu.s_controlFuncMap = 
{
	[debugPopu.s_controls.btn_close] = debugPopu.onCloseBtnClick;
	[debugPopu.s_controls.btn_execute] = debugPopu.onExeCuteBtnClick;
};

return debugPopu