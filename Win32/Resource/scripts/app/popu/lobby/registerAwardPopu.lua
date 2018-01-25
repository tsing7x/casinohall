local GameWindow = require("app.popu.gameWindow")
local registerAwardPopu = class(GameWindow)

local Hall_String = require("app.res.config")
local resPath = "popu/registerAward/"

local cIndex = 0
local function getIndex()
	cIndex = cIndex + 1
	return cIndex
end

registerAwardPopu.s_controls =
{
	-- img_title_2 = getIndex(),

	btn_confirm = getIndex(),
	btn_close = getIndex(),
};

registerAwardPopu.s_controlConfig = 
{
	-- [registerAwardPopu.s_controls.img_title_2] 	= {"img_popuBg","img_title_2"},

	[registerAwardPopu.s_controls.btn_confirm] 	= {"img_popuBg","btn_confirm"},
	[registerAwardPopu.s_controls.btn_close] 	= {"img_popuBg","btn_close"},
	


};

-- local BtnDiffX = 120

function registerAwardPopu:initView(data)
	if not data then return end
	self.m_data = data

	-- local title_2 = self:getControl(registerAwardPopu.s_controls.img_title_2)
	local btn_confirm = self:getControl(registerAwardPopu.s_controls.btn_confirm)
	btn_confirm:findChildByName("text_confirm"):setText(Hall_string.str_get_reward)
	-- if data.day==1 then --首日登录奖励
	-- 	view_day_1:show()
	-- 	title_2:setFile(resPath.."tag_day_1.png")
	-- 	btn_confirm:setGray(false)
	-- elseif data.day==2 then --次日登录奖励
	-- 	view_day_2:show()
	-- 	title_2:setFile(resPath.."tag_day_2.png")
	-- 	if data.waitTime>0 then --还没到第二天领奖的时候
	-- 		btn_confirm:setGray(true)
	-- 		self:playCounter(data.waitTime)
	-- 		btn_confirm:setEnable(false)
	-- 	else
	-- 		btn_confirm:setGray(false)
	-- 	end
	-- end
	
	-- if data.waitTime>0 then --还没到第二天领奖的时候
	-- 	btn_confirm:setGray(true)
	-- 	self:playCounter(data.waitTime)
	-- 	btn_confirm:setEnable(false)
	-- else
	btn_confirm:setGray(false)
	-- end
end

-- function registerAwardPopu:playCounter(waitTime)
-- 	local showTime = function(miao)
-- 		local h = math.floor(miao/3600)
-- 		local min = math.floor((miao - h*3600)/60)
-- 		local secend = miao - h*3600 - min*60
-- 		print(h,min,secend)
-- 		local str = string.format("%02d%02d%02d",h,min,secend)

-- 		local view_day_2 = self:getControl(registerAwardPopu.s_controls.view_day_2)
-- 		for i=1,6 do
-- 			local num = view_day_2:findChildByName("numBg_"..i):findChildByName("img_num")
-- 			num:setFile(string.format(resPath.."num_time/%d.png",string.sub(str,i,i)))
-- 		end
-- 	end
-- 	showTime(waitTime)
-- 	local callback = function()
-- 		if waitTime<=0 then
-- 			self.m_handler:cancel()
-- 			self.m_handler = nil
-- 			return
-- 		end
-- 		waitTime = waitTime - 1
-- 		showTime(waitTime)
-- 	end
-- 	self.m_handler = Clock.instance():schedule(callback,1)
-- end



function registerAwardPopu:dtor()
	-- if self.m_handler then
	-- 	self.m_handler:cancel()
	-- 	self.m_handler = nil
	-- end
	self.super.dtor(self)
end

function registerAwardPopu:dismiss()
	GameWindow.dismiss(self)
	HttpModule.getInstance():execute(HttpModule.s_cmds.SIGN_IN_LOAD, {}, false, false)
end


function registerAwardPopu:onCloseBtnClick()
	self:dismiss()
end

function registerAwardPopu:onConfirmBtnClick()
	-- if self.m_data.day==1 then
	-- 	local edit_code = self:getControl(registerAwardPopu.s_controls.edit_code)
	-- 	local str = edit_code:getText()
	-- 	if false then
	-- 		--输入的不知数字格式
	-- 	end
	-- 	HttpModule.getInstance():execute(HttpModule.s_cmds.GET_REGISTER_REWARD, {inviterId=str}, false, true)
	-- elseif self.m_data.day>1 then
	-- 	HttpModule.getInstance():execute(HttpModule.s_cmds.GET_REGISTER_REWARD, {}, false, true)
	-- end

	-- AnimationParticles.play(AnimationParticles.DropCoin)
	-- 			kEffectPlayer:play('audio_get_gold')
	HttpModule.getInstance():execute(HttpModule.s_cmds.GET_REGISTER_REWARD, {}, false, true)
end

function registerAwardPopu:onGetRegisterReward( isSuccess, data )
	if isSuccess and data then
		if 1 == data.code then
			if data.data then
				local addmoney = data.data.addmoney
				if addmoney then
					EventDispatcher.getInstance():dispatch(Event.Message, "showAddMoneyAnim", addmoney)
				end
				local money 		= data.data.money;
				if money then
					MyUserData:setMoney(money);
				end
                
				--金币雨动画
				AnimationParticles.play(AnimationParticles.DropCoin)
				kEffectPlayer:play('audio_get_gold')
			end
		else
			AlarmTip.play(data.codemsg or "");
		end
	end
    if WindowManager:containsWindowByTag(WindowTag.RegisterAwardPopu) then 
		WindowManager:closeWindowByTag(WindowTag.RegisterAwardPopu)
	end
end


----------------------------  config  --------------------------------------------------------

registerAwardPopu.s_controlFuncMap = 
{
	[registerAwardPopu.s_controls.btn_close] = registerAwardPopu.onCloseBtnClick;
	[registerAwardPopu.s_controls.btn_confirm] = registerAwardPopu.onConfirmBtnClick;
};

registerAwardPopu.s_severCmdEventFuncMap = {
    [HttpModule.s_cmds.GET_REGISTER_REWARD] 	= registerAwardPopu.onGetRegisterReward,
}

return registerAwardPopu