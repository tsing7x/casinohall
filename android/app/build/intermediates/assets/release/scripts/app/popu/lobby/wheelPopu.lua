local GameWindow = require("app.popu.gameWindow")
local wheelPopu = class(GameWindow)

local Hall_String = require("app.res.config")
local resPath = "popu/wheel/"

local cIndex = 0
local function getIndex()
	cIndex = cIndex + 1
	return cIndex
end

wheelPopu.s_controls =
{
	img_guang = getIndex(),
	img_bg = getIndex(),
	img_wheel = getIndex(),
	view_reward = getIndex(),
	btn_confirm = getIndex(),
	img_btn = getIndex(),
	view_normal = getIndex(),
	view_vip = getIndex(),
	img_price = getIndex(),
	text_tip = getIndex(),
	img_title = getIndex(),
	btn_close = getIndex(),
	img_btn_disnable = getIndex(),

	btn_shadow = getIndex(),
	result_text = getIndex(),
	result_icon = getIndex(),
	-- view_tip_vip = getIndex(),
	-- text_vip_tip = getIndex(),
	-- text_vip_level = getIndex(),
	-- text_vip_add = getIndex(),
};

wheelPopu.s_controlConfig = 
{
	[wheelPopu.s_controls.img_guang] 	= {"img_guang"},
	[wheelPopu.s_controls.img_bg] 	= {"view_wheel","img_bg"},
	[wheelPopu.s_controls.img_wheel] 	= {"view_wheel","img_wheel"},
	[wheelPopu.s_controls.view_reward] 	= {"view_wheel","img_wheel","view_reward"},
	[wheelPopu.s_controls.btn_confirm] 	= {"view_wheel","btn_confirm"},
	[wheelPopu.s_controls.img_btn] 	= {"view_wheel","btn_confirm","img_btn"},
	[wheelPopu.s_controls.view_normal] 	= {"view_wheel","btn_confirm","view_normal"},
	[wheelPopu.s_controls.view_vip] 	= {"view_wheel","btn_confirm","view_vip"},
	[wheelPopu.s_controls.img_price] 	= {"view_wheel","btn_confirm","view_vip","img_price"},
	[wheelPopu.s_controls.text_tip] 	= {"view_wheel","btn_confirm","view_vip","text_tip"},
	[wheelPopu.s_controls.img_title] 	= {"view_wheel","img_title"},
	[wheelPopu.s_controls.btn_close] 	= {"view_wheel","btn_close"},
	[wheelPopu.s_controls.img_btn_disnable]= {"view_wheel","img_btn_disnable"},
	[wheelPopu.s_controls.btn_shadow]= {"btn_shadow"},
	[wheelPopu.s_controls.result_text]= {"btn_shadow","result_text"},
	[wheelPopu.s_controls.result_icon]= {"btn_shadow","icon"},
	-- [wheelPopu.s_controls.view_tip_vip] 	= {"view_tip_vip"},
	-- [wheelPopu.s_controls.text_vip_tip] 	= {"view_tip_vip","text_vip_tip"},
	-- [wheelPopu.s_controls.text_vip_level] 	= {"view_tip_vip","text_vip_tip","text_vip_level"},
	-- [wheelPopu.s_controls.text_vip_add] 	= {"view_tip_vip","text_vip_tip","text_vip_add"},

};

-- local BtnDiffX = 120

function wheelPopu:initView(data)
	if not data then return end
	self.data = data
	self:getControl(self.s_controls.img_bg):setEventTouch(self, function(self) end)
	-- self:getControl(self.s_controls.text_vip_tip):setText(string.format(Hall_String.str_wheel_reward))
	-- local view_tip_vip = self:getControl(self.s_controls.view_tip_vip):hide()
	-- local isVip = true
	-- if isVip then
	-- 	self:getControl(wheelPopu.s_controls.img_bg):setFile(resPath.."vip/img_bg.png")
	-- 	self:getControl(wheelPopu.s_controls.img_guang):setFile(resPath.."vip/img_guang.png")
	-- 	self:getControl(wheelPopu.s_controls.img_wheel):setFile(resPath.."vip/img_wheel.png")
	-- 	self:getControl(wheelPopu.s_controls.img_title):setFile(resPath.."vip/img_title.png")
	-- 	Clock.instance():schedule_once(function()
	-- 		view_tip_vip:show()
	-- 		view_tip_vip:runAction({"scale",Point(2,2),Point(1,1),0.2})
	-- 	end,0.8)
	-- end
	self:resetBtnBg()
	self:loadList(data.list)
end

function wheelPopu:resetBtnBg()
	if self.data.isCanAward ~= 0 then
		self:getControl(self.s_controls.btn_confirm):setVisible(true);
		self:getControl(self.s_controls.img_btn_disnable):setVisible(false);
	else
		self:getControl(self.s_controls.btn_confirm):setVisible(false);
		self:getControl(self.s_controls.img_btn_disnable):setVisible(true);
	end
end

function wheelPopu:loadList(list)
	local view_reward = self:findChildByName("view_reward")
	for i=1,#list do
		local item = list[i]
		local view_item = new(Node)
			:addTo(view_reward)
			:align(kAlignCenter)
			:size(120,560)
			:name("view_item_"..i)
			:roate(360/12*(i-1))
		local iconStrUrl = "common/blank.png"
		if item.type and item.type == "1" then
			if item.imgshow == 1 then
				iconStrUrl = resPath.."award/award_1.png"
			elseif item.imgshow == 2 then
				iconStrUrl = resPath.."award/award_2.png"
			elseif item.imgshow == 3 then
				iconStrUrl = resPath.."award/award_3.png"
			end
		end
		local icon = new(Image, iconStrUrl)
			:addTo(view_item)
			-- :align(kAlignTop)
			-- :pos(0,13)
			:align(kAlignCenter)
			:pos(0, -222)
		if item.icon and #item.icon > 0 then
			local imgData = setProxy(new(require("app.data.imgData")))
			UIEx.bind(view_item, imgData, "imgName", function(value)
				if imgData:checkImg() then
					icon:setFile(imgData:getImgName())
				else
					icon:setFile(iconStrUrl)
				end
				local iconW, iconH = icon.m_res.m_width, icon.m_res.m_height
				icon:setSize(iconW, iconH)
		    end)
			imgData:setImgUrl(item.icon)
		end
		local text_info = new(Text,item.name, 0, 0, kAlignTop,"", 24, 0xf2, 0xc9, 0x17)
			:addTo(view_item)
			:align(kAlignTop)
			:pos(0,115)
	end
end

function wheelPopu:onCloseBtnClick()
	self:dismiss()
end

function wheelPopu:onConfirmBtnClick()
	if self.data.isCanAward == 0 then
		return
	end
	self.data.isCanAward = 0
	HttpModule.getInstance():execute(HttpModule.s_cmds.Turntable_LOTTERY, {["mid"] = MyUserData:getId()}, false, false)
end

function wheelPopu:findIndex(id)
	for i=1,#self.data.list do
		if self.data.list[i].id == id then
			return i
		end
	end
	return nil
end

function wheelPopu:onLottery(isSuccess, data)
	JLog.d("wheelPopu:onLottery", isSuccess,data)
	if not app:checkResponseOk(isSuccess,data) then
		self.data.isCanAward = 1
		return
	end
	local i = self:findIndex(data.data.id)
	if i == nil then
		return
	end
	local img_wheel = self:getControl(wheelPopu.s_controls.img_wheel)
	img_wheel:roate(img_wheel:getRoation()%360)
	local rotationEndValue = 2160 - 360/12*(i - 1)
	img_wheel:runAction({"rotation", img_wheel:getRoation(), rotationEndValue, 10, require("animation").decelerate(1.4)}, {onComplete = function()
		local addMoney = tonumber(data.data.num) or 0
		if addMoney > 0 then
	        MyUserData:setMoney(addMoney + MyUserData:getMoney())
			AnimationParticles.play(AnimationParticles.DropCoin)
		end
		self:resetBtnBg()
		self:showResult(data)
	end})
end

function wheelPopu:showResult(resultData)
	self:getControl(self.s_controls.btn_shadow):setVisible(true)
	self:getControl(self.s_controls.result_text):setText(resultData.codemsg)
	local img = self:getControl(self.s_controls.result_icon)
	local iconStrUrl = "common/blank.png"
	if resultData.data.type and resultData.data.type == "1" then
		iconStrUrl = resPath.."award/award_max.png"
	end
	img:setFile(iconStrUrl)
	if resultData.data.icon and #resultData.data.icon > 0 then
		local imgData = setProxy(new(require("app.data.imgData")))
		UIEx.bind(self, imgData, "imgName", function(value)
			if imgData:checkImg() then
				img:setFile(imgData:getImgName())
			else
				img:setFile(iconStrUrl)
			end
	    end)
		imgData:setImgUrl(resultData.data.icon)
	end
end

function wheelPopu:onShadow()
	self:getControl(self.s_controls.btn_shadow):setVisible(false);
end
----------------------------  config  --------------------------------------------------------

wheelPopu.s_controlFuncMap = 
{
	[wheelPopu.s_controls.btn_close] = wheelPopu.onCloseBtnClick;
	[wheelPopu.s_controls.btn_confirm] = wheelPopu.onConfirmBtnClick;
	[wheelPopu.s_controls.btn_shadow] = wheelPopu.onShadow;
};

wheelPopu.s_severCmdEventFuncMap = {
    [HttpModule.s_cmds.Turntable_LOTTERY] 	= wheelPopu.onLottery,
}

return wheelPopu