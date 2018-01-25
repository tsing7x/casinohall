local GameWindow = require("app.popu.gameWindow")
local friendsPopu = class(GameWindow)

local cIndex = 0
local function getIndex()
	cIndex = cIndex + 1
	return cIndex
end

friendsPopu.s_controls =
{
	btn_close = getIndex(),
	btn_invite_more = getIndex(),
}

friendsPopu.s_controlConfig = 
{
	[friendsPopu.s_controls.btn_close] 	= {"img_popuBg","btn_close"},
	[friendsPopu.s_controls.btn_invite_more] 	= {"img_popuBg","btn_invite_more"},
}

function friendsPopu:initView(data)
	self.m_tabs = {
		{self:findChildByName("img_popuBg"):findChildByName("view_btnTab"):findChildByName("btn_friendList"), self:findChildByName("img_popuBg"):findChildByName("view_sub"):findChildByName("view_friend_list")},
		{self:findChildByName("img_popuBg"):findChildByName("view_btnTab"):findChildByName("btn_addFriend"), self:findChildByName("img_popuBg"):findChildByName("view_sub"):findChildByName("view_friend_add")},
	}
	self.m_tabs_ctrl = {
		require("app.friends.friendListCtrlView"),
		require("app.friends.friendAddCtrlView"),
	}
	for i=1,#self.m_tabs do
		self.m_tabs[i][1]:setOnClick(self,function()
			self:selectTab(i)
		end)
		local ctrlView = new(self.m_tabs_ctrl[i])
		self.m_tabs[i][2]:addChild(ctrlView)
		self.m_tabs[i][3] = ctrlView
	end
	self:selectTab(1)
end

function friendsPopu:onShowEnd()
	self.super.onShowEnd(self)
	for i=1,#self.m_tabs do
		self.m_tabs[i][3]:onShowEnd()
	end
end

function friendsPopu:onCloseBtnClick()
	self:dismiss()
end

function friendsPopu:onInviteMore()
	self:dismiss()
	WindowManager:showWindow(WindowTag.FbInvitePopu, {}, WindowStyle.POPUP)
end

function friendsPopu:selectTab(index)
	for i=1,#self.m_tabs do
		local btn = self.m_tabs[i][1]
		btn:findChildByName("img_normal"):show()
		btn:findChildByName("img_select"):hide()

		self.m_tabs[i][2]:hide()
	end
	self.m_tabs[index][1]:findChildByName("img_normal"):hide()
	self.m_tabs[index][1]:findChildByName("img_select"):show()

	self.m_tabs[index][2]:show()

	local img_tabSelect = self:findChildByName("view_btnTab"):findChildByName("img_tabSelect")
	img_tabSelect:pos(self.m_tabs[index][1]:getPos())
end

----------------------------  config  --------------------------------------------------------
friendsPopu.s_controlFuncMap = 
{
	[friendsPopu.s_controls.btn_close] = friendsPopu.onCloseBtnClick;
	[friendsPopu.s_controls.btn_invite_more] = friendsPopu.onInviteMore;
}

return friendsPopu