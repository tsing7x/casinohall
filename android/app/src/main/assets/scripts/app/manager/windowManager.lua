WindowStyle = {
    NORMAL          = 1,
    TRANSLATE_DOWN  = 2,
    TRANSLATE_UP    = 3,
    TRANSLATE_LEFT  = 4,
    TRANSLATE_RIGHT = 5,
    POPUP           = 6,
}

local cIndex = 0
local function getIndex()
	cIndex = cIndex + 1
	return cIndex
end

WindowTag = {
	MessageBox = getIndex(),
	ErrorTipBox = getIndex(),
	DebugPopu = getIndex(),
	UpdatePopu = getIndex(),
	WheelPopu = getIndex(),
	RegisterAwardPopu = getIndex(),
	CreateRoomPopu = getIndex(),
	EnterRoomPopu = getIndex(),
	RoomListPopu 		= getIndex(),
	CreateRolePopu = getIndex(),	
	Room_BigSettlePopu = getIndex(),
	UserInfoPopu = getIndex(),
	ChangeNickPopu = getIndex(),
	ChangeHeadPopu = getIndex(),
	FbInvitePopu = getIndex(),
	ShopPopu = getIndex(),
	SignPopu = getIndex(),

	SettingPopu	= getIndex(),
	FeedbackPopu = getIndex(),
	GameDescPopu = getIndex(),
	DailyTaskPopu = getIndex(),
	MessagePopu = getIndex(),
	MsgContPopu = getIndex(),

	RoomPlayerInfoPopu	= getIndex(),
	BankruptPopu	=getIndex(),
	StandUpPopu		=getIndex(),
	ChatPopu    = getIndex(),	
	LevelPopu		= getIndex(),
	FriendsPopu		= getIndex(),
	SpeakerPopu = getIndex(),
	RoomChatAndSpeakerPopu =getIndex(),
	AnnouncePopu=getIndex(),
	FriendInfoPopu=getIndex(),

	UpgradePopu = getIndex()
}
-- 弹窗配置表
-- 参数1 弹窗配置表{ 1 为弹窗类， 2为弹窗布局文件 }
-- 参数2 zorder
-- 参数3 关闭后是否销毁
WindowConfigMap = {
	-- config  														zOrder bgTouchHide backHide autoRemove stateRemove
	[WindowTag.MessageBox] 		= 	{ "app.popu.public.messageBox", "popu.public.messageBox", 220, true, true, true, true},
	[WindowTag.ErrorTipBox] 		= 	{ "app.popu.public.errorTipBox", "popu.public.errorTipBox", 220, true, true, true, true},	
	[WindowTag.DebugPopu] 		= 	{ "app.popu.public.debugPopu", "popu.public.debugPopu", 220, true, true, true, true},

	[WindowTag.UpdatePopu] 		= 	{ "app.popu.lobby.updatePopu", "popu.lobby.updatePopu", 225, true, false, true, true},
	[WindowTag.WheelPopu]			=		{ "app.popu.lobby.wheelPopu", "popu.lobby.wheelPopu", 220, true, true, true, true},
	[WindowTag.RegisterAwardPopu] 		= 	{ "app.popu.lobby.registerAwardPopu", "popu.lobby.registerAward", 220, false, false, true, true},
	[WindowTag.CreateRoomPopu] 		= 	{ "app.popu.lobby.createRoomPopu", "popu.lobby.createRoomPopu", 220, true, true, true, true},
	[WindowTag.EnterRoomPopu] 		= 	{"app.popu.lobby.enterRoomPopu", "popu.lobby.enterRoomPopu", 220, true, true, true, true},
	[WindowTag.RoomListPopu]		=		{ "app.popu.lobby.roomListPopu", "popu.lobby.roomListPopu", 220, true, true, true, true},
	[WindowTag.CreateRolePopu] 		= 	{ "app.popu.lobby.createRolePopu", "popu.lobby.createRolePopu", 220, true, true, true, true},
	[WindowTag.UserInfoPopu] 		= 	{ "app.popu.lobby.UsrInfoPopu", "popu.lobby.userInfoPopu", 220, true, true, true, true},
	[WindowTag.ChangeNickPopu] 		= 	{ "app.popu.lobby.NickSexChangePopu", "popu.lobby.changeNickPopu", 225, true, false, true, true},
	[WindowTag.ChangeHeadPopu] 		= 	{ "app.popu.lobby.HeadChangePopu", "popu.lobby.changeHeadPopu", 225, true, false, true, true},
	
	[WindowTag.SettingPopu] = {"app.popu.lobby.SettingPopu", "popu.lobby.settingPopu", 220, true, false, true, true},
	[WindowTag.GameDescPopu] = {"app.popu.lobby.GameDescPopu", "popu.lobby.gameDescPopu", 221, true, false, true, true},
	[WindowTag.FeedbackPopu] = {"app.popu.lobby.FeedBackPopu", "popu.lobby.feedBackPopu", 220, false, true, true, true},
	[WindowTag.DailyTaskPopu] = {"app.popu.lobby.DailyTaskPopu", "popu.lobby.dailyTaskPopu", 220, true, true, true, true},
	[WindowTag.MessagePopu] = {"app.popu.lobby.messagePopu", "popu.lobby.message.messagePopu", 221, true, true, true, true},
	[WindowTag.MsgContPopu] = {"app.popu.lobby.MessageContPopu", "popu.lobby.msgContPopu", 228, true, true, true, true},

	[WindowTag.Room_BigSettlePopu] 		= 	{ "app.popu.room.bigSettlePopu", "popu.room.bigSettlePopu", 221, true, true, true, true},
    [WindowTag.SignPopu] 		= 	{ "app.popu.lobby.signPopu", "popu.lobby.signPopu", 220, false, false, true, true},
	[WindowTag.FbInvitePopu] = {"app.popu.lobby.fbInvitePopu", "popu.lobby.invite.fbInvitePopu", 221, true, true, true, true},
	[WindowTag.ShopPopu] = {"app.popu.lobby.shopPopu", "popu.lobby.shop.shopPopu", 221, true, true, true, true},
	[WindowTag.RoomPlayerInfoPopu] = {"app.popu.room.roomPlayerInfoPopu", "popu.room.roomPlayerInfoPopu", 220, true, true, true, true},
	[WindowTag.BankruptPopu] = {"app.popu.room.bankruptPopu", "popu.public.bankruptPopu", 220, true, true, true, true},
	[WindowTag.StandUpPopu] = {"app.popu.room.standUpPopu", "popu.public.standUpPopu", 221, true, true, true, true},
	[WindowTag.LevelPopu] = {"app.popu.lobby.levelPopu", "popu.lobby.levelPopu", 221, true, true, true, true},
	[WindowTag.ChatPopu] = {"app.popu.room.chatPopu", "popu.room.chat.chatPopu", 221, true, true, true, true},
	[WindowTag.SpeakerPopu] = {"app.popu.room.speakerPopu", "popu.room.speaker.speakerPopu", 221, true, true, true,true},
	[WindowTag.FriendsPopu] = {"app.popu.lobby.friendsPopu", "popu.lobby.friendsPopu", 221, true, true, true, true},
	[WindowTag.RoomChatAndSpeakerPopu] = {"app.popu.room.roomChatAndSpeakerPopu", "popu.room.chat.roomChatAndSpeakerPopu", 221, true, true, true,true},
	[WindowTag.AnnouncePopu] = {"app.popu.lobby.announcePopu", "popu.lobby.announcePopu", 221, false, false, true , true},
	[WindowTag.FriendInfoPopu] = {"app.popu.room.friendInfoPopu", "popu.public.friendInfoPopu", 224, true, true, true, true},
	[WindowTag.UpgradePopu] = {"app.popu.lobby.UpgradePopu", "popu.lobby.upgradePopu", 225, true, true, true, true},

}

local WindowManager = class(Node)
local BgAlpha = 180
local BgFadeTime = 200

function WindowManager:ctor()
	self:addToRoot()
	self:setLevel(50)
	self.m_windows = {}
	self:setFillParent(true, true)
end

function WindowManager:showWindow(name, data, style,shadeHide)
	if not name or not WindowConfigMap[name] then
		data = {text = "",titleText = "代替弹窗"}
		name = WindowTag.MessageBox
	end
	self:createBgShade(shadeHide)

	local window = self:getChildByName(name)
	local winCfg = WindowConfigMap[name]
	local reCreate
	if not window and winCfg then
		local path, viewCfg, zOrder, bgTouchHide, backHide, autoRemove, stateRemove, lpath = unpack(winCfg)
		local cls = require(path)
		local layout = requireview((lpath or ViewPath) .. viewCfg)


		window = new(cls, layout, data) -- _G[viewCfg]
		window:initView(data)
		window:setLevel(zOrder)
		self.m_shadeBg:setLevel(zOrder)
		window:setName(name)
		printInfo("创建弹窗 %s", name)
		window:setConfigFlag(bgTouchHide, backHide, autoRemove, stateRemove)
		window:setAlign(kAlignCenter)
		self:addChild(window)
		table.insert(self.m_windows, window)
		reCreate = true
	elseif window then
		window:updateView(data)
	end
	self:sortWindow()
	window:show(style)
	checkAndRemoveOneProp(self.m_shadeBg, 1002)
	if window and not self.m_shadeBg:getVisible() then
		self.m_shadeBg:setVisible(true)
		local anim = self.m_shadeBg:addPropTransparency(1001, kAnimNormal, BgFadeTime, 0, 0.0, 1.0)
		if anim then
			anim:setEvent(
				nil,
				function()
				self.m_shadeBg:removeProp(1001)
		end)
	end
	end

	self:resortLevel()
end


function WindowManager:resortLevel(visibleTb)
	visibleTb = visibleTb or self:getVisibleTb()
	if #visibleTb > 0 then
		self:sortWindow(visibleTb)
		self.m_shadeBg:setLevel(visibleTb[#visibleTb]:getLevel() - 1)
	end
end

--[[
	排序
]]
function WindowManager:sortWindow(windowTb)
	windowTb = windowTb or self.m_windows
	table.sort(
		self.m_windows,
		function(node1, node2)
		return node1:getLevel() < node2:getLevel()
		end
	)
end

function WindowManager:createBgShade(shadeHide)
	self.oldIsHide = self.oldIsHide or nil
	if self.m_shadeBg then
		if self.oldIsHide~=shadeHide then
			self.m_shadeBg:removeSelf()
			self.oldIsHide=shadeHide
		else
			return
		end
	end
	if shadeHide then
		self.m_shadeBg = UIFactory.createImage("ui/blank.png")
	else
		self.m_shadeBg = UIFactory.createImage("ui/shade2.png")
	end
	self.m_shadeBg:setFillParent(true, true)
	self.m_shadeBg:setVisible(false)
	self.m_shadeBg:setLevel(1)
	self.m_shadeBg:setEventTouch(self, self.onShadeBgTouch);
	self:addChild(self.m_shadeBg)
end

function WindowManager:onShadeBgTouch(finger_action, x, y, drawing_id_first, drawing_id_current)
	if finger_action ~= kFingerDown then return end
	for i=#self.m_windows, 1, -1 do
		local window = self.m_windows[i]
		if window:isBgTouchHide() and window:getVisible() then
			local success = window:dismiss()
			if success then
				printInfo("success name = %s", window:getName())
				break
			else
				printInfo("false name = %s", window:getName())
				return
			end
		end
	end
end

function WindowManager:onKeyBack()
	JLog.d("WindowManager:onKeyBack()",#self.m_windows);
	for i=#self.m_windows, 1, -1 do
		local window = self.m_windows[i]
		if window:isBackHide() then
			local success = window:dismiss()
			if success then
				return true
			end
		end
	end
end

--[[
	当前有多少弹窗可见
]]
function WindowManager:getVisibleTb()
	local visibleTb = {}
	for k,v in pairs(self.m_windows) do
		if v:getVisible() then
			table.insert(visibleTb, v)
		end
	end
	return visibleTb
end

function WindowManager:onShowEnd(name)
	self.m_shadeBg:setVisible(true)
	checkAndRemoveOneProp(self.m_shadeBg, 1002)
end

function WindowManager:onHidenEnd(name, doClean)
	if doClean then
		for k,v in pairs(self.m_windows) do
			if v:getName() == name then
				table.remove(self.m_windows, k)
				self:removeChild(v, doClean)
				printInfo("销毁弹窗 ！！！！！ %s", name)
				break;
			end
		end
	end
	local visibleTb = self:getVisibleTb()
	self:createBgShade()
	printInfo("弹窗%s关闭成功, 剩余弹窗数量%d, 存在弹窗数量%d", name, #visibleTb, #self.m_windows)
	checkAndRemoveOneProp(self.m_shadeBg, 1001)
	if #visibleTb == 0 and self.m_shadeBg:getVisible() then
		local anim = self.m_shadeBg:addPropTransparency(1002, kAnimNormal, BgFadeTime, 0, 1.0, 0.0)
		if anim then
			anim:setEvent(
				nil,
				function()
				self.m_shadeBg:removeProp(1002)
				self.m_shadeBg:setVisible(false)
				end
			)
		else
			self.m_shadeBg:setVisible(false)
		end
	end
	self:resortLevel(visibleTb)
end

function WindowManager:closeWindowByTag(tag, noAnim)
	JLog.d("WindowManager:closeWindowByTag1",tag);
	for i,v in pairs(self.m_windows) do
		if v:getName() == tag then
			JLog.d("WindowManager:closeWindowByTag2",tag);
			v:dismiss(noAnim)
		end
	end
end

function WindowManager:containsWindowByTag(tag)
	printInfo("containsWindowByTag(tag) = %s", tag)
	for i,v in pairs(self.m_windows) do
		printInfo("name = %s", v:getName())
		if v:getName() == tag then
			return v
		end
	end
end

function WindowManager:dealWithStateChange()
	local indexTb = {}
	for k,v in pairs(self.m_windows) do
		if v:isStateRemove() then
			table.insert(indexTb, k)
		end
	end
	for i=#indexTb, 1, -1 do
		local wnd = self.m_windows[indexTb[i]]
		if wnd:alive() then
			self:onHidenEnd(wnd:getName(), true)
		end
	end
end

return WindowManager
