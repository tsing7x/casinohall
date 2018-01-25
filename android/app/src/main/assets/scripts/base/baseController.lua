
require("core.object")
require("base.baseLayer")

-- 去除gameScene 的版本
BaseController = class(BaseLayer)
function BaseController:ctor(viewConfig, state, ...)
	BaseLayer.addToRoot(self)
	BaseLayer.setFillParent(self,true,true)
	self.m_state = state
	self.m_ctrl = self.s_controls;
	EventDispatcher.getInstance():register(Event.Message, self, self.onMessageCallDone)
	EventDispatcher.getInstance():register(Event.Socket, self, self.onSocketReceive)
	EventDispatcher.getInstance():register(HttpModule.s_event, self, self.onHttpCommonRequestsCallBack);


	self.s_severCommonEventFuncMap = {
		[HttpModule.s_cmds.GET_DailyTASKReward]			= BaseController.onGetTaskAward,
		[HttpModule.s_cmds.GET_COUNTER_BOX_REWARD]= BaseController.onGetCounteBoxReward,
	}
end

-- 切换界面完成后 处理业务
function BaseController:dealBundleData(bundleData)
end


function BaseController:resume(bundleData)
	self.m_root:setPickable(true)
	if WindowManager then
		WindowManager:dealWithStateChange()
	end
end

function BaseController:pause()

	self.m_root:setPickable(false);
	EventDispatcher.getInstance():unregister(Event.Message, self, self.onMessageCallDone)
	EventDispatcher.getInstance():unregister(Event.Socket, self, self.onSocketReceive)
	EventDispatcher.getInstance():unregister(HttpModule.s_event, self, self.onHttpCommonRequestsCallBack);

end

function BaseController:dtor()
	printInfo("BaseController:dtor")
	EventDispatcher.getInstance():unregister(Event.Message, self, self.onMessageCallDone);
	EventDispatcher.getInstance():unregister(Event.Socket, self, self.onSocketReceive);
	EventDispatcher.getInstance():unregister(HttpModule.s_event, self, self.onHttpCommonRequestsCallBack);
end

function BaseController:pushStateStack(obj, func)
	self.m_state:pushStateStack(obj,func);
end

function BaseController:popStateStack()
	self.m_state:popStateStack();
end

function BaseController:stop()
	self.m_root:setVisible(false);
end

function BaseController:run()
	self.m_root:setVisible(true);
	self.m_root:setPickable(false);
end

function BaseController:onBack()

end

function BaseController:requestSendWord(chatInfo)
	if not chatInfo then return end
	GameSocketMgr:sendMsg(POKDENG_SEND_CHAT, {
		iChatInfo = chatInfo,
	})
end

function BaseController:requestSendFace(faceType)
	if not faceType then return end
	GameSocketMgr:sendMsg(POKDENG_SEND_FACE, {
		iFaceType = faceType,
		isVipFace = 0,
	})
end


BaseController.messageFunMap = {
	["sendChatWord"]			= BaseController.requestSendWord,
	["sendChatFace"]			= BaseController.requestSendFace,
}

BaseController.commandFunMap = {
}

function BaseController:onMessageCallDone(param, ...)
	if self.messageFunMap[param] then
		self.messageFunMap[param](self,...)
	end
end

function BaseController:onSocketReceive(param, ...)
	if self.commandFunMap[param] then
		self.commandFunMap[param](self,...)
	end
end
function BaseController:onHttpCommonRequestsCallBack(command, ...)
	if self.s_severCommonEventFuncMap[command] then
		self.s_severCommonEventFuncMap[command](self,...)
	end
end
function BaseController:onGetTaskAward(isSuccess, data)
	if app:checkResponseOk(isSuccess, data) then
		if data.data.gameId then
			MyUserData:setTaskAward(MyUserData:getTaskAward() - 1)
			MyUserData:setMoney(data.data.money)
			self:playRewardAnim(data.data.reward)
		end
	end
end
function BaseController:onGetCounteBoxReward(isSuccess, data)
	--writeTabToLog({data=data},"计时宝箱领奖返回","1ddd.lua")
	if app:checkResponseOk(isSuccess, data) then
		if data.code==1 then
			local data = data.data
			MyUserData:setBoxAward(false)
			MyUserData:setMoney(data.money)
			self:playRewardAnim(data.addMoney)
			HttpModule.getInstance():execute(HttpModule.s_cmds.GET_TASK_IS_UNREWARD, {mid = MyUserData:getId()}, false, false)
			if G_isInSit~=nil then
				G_isInSit:setTime(data.nextTime)
			end
		end
	end
end
function BaseController:moneyIncreaseShare(money)
	if MyUserData:getUserType() == UserType.Visitor then
		if GameSetting:getShareTimesGuest() >= 3 then
			return
		end
	else
		if GameSetting:getShareTimesFb() >= 3 then
			return
		end
	end
	if money >= 10000000 then
		if MyUserData:getUserType() == UserType.Visitor then
			if GameSetting:getMultimillionaireGuest() == 0 then
				WindowManager:showWindow(WindowTag.SharePopu, {content = STR_SHARE_MULTIMILLIONAIRE, strParam = {PhpManager:getGameName()}}, WindowStyle.POPUP)
			end
		else
			if GameSetting:getMultimillionaireFb() == 0 then
				WindowManager:showWindow(WindowTag.SharePopu, {content = STR_SHARE_MULTIMILLIONAIRE, strParam = {PhpManager:getGameName()}}, WindowStyle.POPUP)
			end
		end
	elseif money >= 1000000 and money < 10000000 then
		if MyUserData:getUserType() == UserType.Visitor then
			if GameSetting:getMillionaireGuest() == 0 then
				WindowManager:showWindow(WindowTag.SharePopu, {content = STR_SHARE_MILLIONAIRE, strParam = {PhpManager:getGameName()}}, WindowStyle.POPUP)
			end
		else
			if GameSetting:getMillionaireFb() == 0 then
				WindowManager:showWindow(WindowTag.SharePopu, {content = STR_SHARE_MILLIONAIRE, strParam = {PhpManager:getGameName()}}, WindowStyle.POPUP)
			end
		end
	end

end
function BaseController:playRewardAnim(coinNum)
	if self.countDownCoinAnim~=nil then
		self.countDownCoinAnim:removeSelf()
		self.countDownCoinAnim = nil
	end
	local node = UIFactory.createImage("ui/shade2.png")
	node:addToRoot()
	node:pos(display.cx* System.getLayoutScale(),display.cy* System.getLayoutScale())
	self.countDownCoinAnim = node
	node:setLevel(5000)
	node:setFillParent(true, true)
	local showDelay = 1800
	local anim = node:addPropTransparency(10,kAnimNormal,400,showDelay,1,0)
	anim:setEvent(function()
			self.countDownCoinAnim:removeSelf()
			self.countDownCoinAnim = nil
	end)

	local guang = new(Image,task_map["task.anim_bg.png"])
		:addTo(node)
		:align(kAlignCenter)
	local pots = new(Image,task_map["task.anim_pots.png"])
		:addTo(node)
		:align(kAlignCenter)
	local coin = new(Image,task_map["task.anim_chip.png"])
		:addTo(node)
		:align(kAlignCenter)
	guang:addPropRotate(1, kAnimRepeat, 5000, 0, 0, 360, kCenterDrawing)
	pots:addPropTranslate(1,kAnimNormal,5000,0,0,0,-100,50)
	coin:addPropScale(1,kAnimNormal,100,0,0.2,1,0.2,1,kCenterDrawing)

	local imgNum = new(
		require("common.imageNumber"),
		{
			['1'] = "new_common/number_1/1.png",
			['2'] = "new_common/number_1/2.png",
			['3'] = "new_common/number_1/3.png",
			['4'] = "new_common/number_1/4.png",
			['5'] = "new_common/number_1/5.png",
			['6'] = "new_common/number_1/6.png",
			['7'] = "new_common/number_1/7.png",
			['8'] = "new_common/number_1/8.png",
			['9'] = "new_common/number_1/9.png",
			['0'] = "new_common/number_1/0.png",
			['+'] = "new_common/number_1/+.png",
	})
		:addTo(node)
		:align(kAlignCenter)
		:pos(-10,0)
	imgNum:setNumber("+"..(coinNum or "0"))
	imgNum:addPropTranslate(1,kAnimNormal,200,0,0,0,0,-140)
	imgNum:addPropTransparency(2, kAnimNormal, 200, 0, 0, 1)

end
