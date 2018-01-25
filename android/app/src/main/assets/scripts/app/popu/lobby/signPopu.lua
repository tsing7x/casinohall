local GameWindow = require("app.popu.gameWindow")
local getIndex = require("app.utils.index")()
local clazz = class(GameWindow)

clazz.s_controls =
{
	btn_close = getIndex(),
	items = getIndex(),

};

clazz.s_controlConfig = 
{
	[clazz.s_controls.btn_close] 	= {"img_popuBg","btn_close"},
	[clazz.s_controls.items] 	= {"img_popuBg", "items"},

};


function clazz:initView(data)
	if not data then return end
	self._signData = data
	local ctrl = self.m_root or self
	ctrl:getChildByName("img_popuBg"):getChildByName("sign_hint"):setText(Hall_string.str_sign_hint)
	for i=1,6 do
		self:initItem(data, i)
	end
	self:initItem7(data)
end

function clazz:dtor()

end

function clazz:initItem(data, i)
	local itemData = data.prizelist[i]
	local itemView = self:getControl(clazz.s_controls.items):getChildByName("item"..i)
	local moneyView = itemView:getChildByName("money")
	local selectedView = itemView:getChildByName("selected")
	local button = itemView:getChildByName("button")
	local mask = itemView:getChildByName("mask")
	moneyView:setText(itemData.chips)
	if data.signNum == i - 1 then
		mask:setVisible(false)
		selectedView:setVisible(false)
		button:setOnClick(self, self.signIn)
	elseif data.signNum > i - 1 then
		mask:setVisible(false)
		selectedView:setVisible(true)
	else
		mask:setVisible(true)
		selectedView:setVisible(false)
	end
end

function clazz:initItem7(data)
	local itemData = data.prizelist[7]
	local itemView = self:getControl(clazz.s_controls.items):getChildByName("item7")
	-- local moneyView = itemView:getChildByName("money")
	local button = itemView:getChildByName("button")
	local mask = itemView:getChildByName("mask")
	-- moneyView:setText(Hall_string.str_sing_7)
	local moneyView = itemView:getChildByName("img_money")
	moneyView:setFile(UserType.Facebook == MyUserData:getUserType() and "popu/sign/80000.png" or "popu/sign/60000.png")
	if data.signNum == 6 then
		mask:setVisible(false)
		button:setOnClick(self, self.signIn)
	-- elseif data.signNum > i - 1 then
	else
		mask:setVisible(true)
	end
end

function clazz:signIn()
	if self.isSigning then
		return
	end
	self.isSigning = true
	HttpModule.getInstance():execute(HttpModule.s_cmds.SIGN_IN, {}, false, false)
end

function clazz:onCloseBtnClick()
	self:dismiss()
end

function clazz:onSignIn(isSuccess,data)
	self.isSigning = false
	if not app:checkResponseOk(isSuccess,data) then
		AlarmTip.play(data.codemsg or "");
		return
	end
	self:dismiss()
end

----------------------------  config  --------------------------------------------------------

clazz.s_controlFuncMap = 
{
	[clazz.s_controls.btn_close] = clazz.onCloseBtnClick;
};

clazz.s_severCmdEventFuncMap = {
	[HttpModule.s_cmds.SIGN_IN]					= clazz.onSignIn,
    -- [HttpModule.s_cmds.GET_REGISTER_REWARD] 	= registerAwardPopu.onGetRegisterReward,
}

return clazz