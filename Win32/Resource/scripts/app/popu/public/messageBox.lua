local GameWindow = require("app.popu.gameWindow")
local MessageBox = class(GameWindow)

MessageBox.s_controls =
{
	close_btn = 1,
	left_btn = 2,
	right_btn = 3,
	content_text = 4,
	left_text = 5,
	right_text = 6,
	title_text = 7,
};

-- local BtnDiffX = 120

function MessageBox:initView(data)
	if not data then return end
	if data.singleBtn then
		self:showSingleBtn()
	end
	self:findChildByName("btn_close"):setVisible(data.close and true or false);
	if data.leftFunc then
		self.leftFunc = data.leftFunc
	end
	if data.leftText then
		self:getControl(self.s_controls.left_text):setText(data.leftText)
	else
		self:getControl(self.s_controls.left_text):setText(Hall_string.str_cancel)
	end
	if data.rightFunc then
		self.rightFunc = data.rightFunc
	end
	if data.closeFunc then
		self.closeFunc = data.closeFunc
	end
	if data.rightText then
		self:getControl(self.s_controls.right_text):setText(data.rightText)
	else
		self:getControl(self.s_controls.right_text):setText(Hall_string.str_confirm)
	end
	if data.text then
		self:getControl(self.s_controls.content_text):setText(data.text)
	end
	
	self:getControl(self.s_controls.title_text):setText(data.titleText or "")
end

function MessageBox:showSingleBtn()
	self:getControl(self.s_controls.left_btn):pos(0, nil)
	self:getControl(self.s_controls.right_btn):hide()
end

function MessageBox:onCloseBtnClick()
	if self.closeFunc then
		self.closeFunc()
	end
	self:dismiss(true)
end

function MessageBox:onLeftBtnClick()
	if self.leftFunc then
		self.leftFunc()
	end
	self:dismiss(true, true)
end

function MessageBox:onRightBtnClick()
	if self.rightFunc then
		self.rightFunc()
	end
	self:dismiss(true, true)
end

----------------------------  config  --------------------------------------------------------
MessageBox.s_controlConfig = 
{
	[MessageBox.s_controls.close_btn] 	= {"img_popuBg", "btn_close"},
	[MessageBox.s_controls.left_btn] 	= {"img_popuBg", "btn_left"},
	[MessageBox.s_controls.left_text] 	= {"img_popuBg","btn_left","text_left"},
	[MessageBox.s_controls.right_btn] 	= {"img_popuBg","btn_right"},
	[MessageBox.s_controls.right_text] 	= {"img_popuBg","btn_right","text_right"},
	[MessageBox.s_controls.content_text] = {"img_popuBg","text_content"},
	[MessageBox.s_controls.title_text] 	= {"img_popuBg", "text_title"},
};

MessageBox.s_controlFuncMap = 
{
	[MessageBox.s_controls.close_btn] = MessageBox.onCloseBtnClick;
	[MessageBox.s_controls.left_btn] = MessageBox.onLeftBtnClick;
	[MessageBox.s_controls.right_btn] = MessageBox.onRightBtnClick;
};

return MessageBox