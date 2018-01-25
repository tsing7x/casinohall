local ViewAddChip = require("app.games.view.viewAddChip")

local view_chipIn = require(ViewPath .. "games.view.view_chipIn")
local Room_String = require('app.games.pokdeng.res.config')

local viewChipIn = class(Node)

local BetConfig = class()
addProperty(BetConfig, "quickChip_1", 0) 	--快捷下注1金额
addProperty(BetConfig, "quickChip_2", 0)	--快捷下注1金额
addProperty(BetConfig, "quickChip_3", 0)	--快捷下注1金额
addProperty(BetConfig, "maxChip", 0)		--最大下注金额
addProperty(BetConfig, "minChip", 0)		--最小下注金额

addProperty(BetConfig, "lastChip", 0)		--上一局下注金额

local TIMES_1,TIMES_2,TIMES_3 = 1,2,3
local TIME_MIN,TIME_MAX = 1,10

function viewChipIn:ctor(data)
	self.m_layout = new(BaseLayer, view_chipIn)
			:addTo(self)
			:align(kAlignTopLeft)
	self:setSize(self.m_layout:findChildByName("view_bg"):getSize())
	self:hide()

	self:findChildByName("view_bg"):setEventTouch(nil,function()end)
	self:findChildByName("text_repeat"):setText(Room_String.str_chip_in_repeat)
	self:findChildByName("text_addChip"):setText(Room_String.str_chip_in_addChip)
	self:findChildByName("text_in_min"):setText(string.format(Room_String.str_chip_in_min,"100"))
	self:findChildByName("text_in_max"):setText(string.format(Room_String.str_chip_in_max,"100"))

	for i=1,3 do
		local btn_chip = self:findChildByName("btn_chip_"..i)
		btn_chip:setOnClick(self,function()
			local ante = self.m_betConfig["quickChip_"..i]
			print("ante",ante)
			if data.callback and type(data.callback) then
				data.callback(ante)
			end
		end)
	end

	self.btn_repeat = self:findChildByName("btn_repeat")
	self.btn_repeat:setOnClick(self,function()
		local ante = self.m_lastChipNum
		if not ante then
			return
		end
		print("ante",ante)
		if data and data.callback and type(data.callback) then
			data.callback(ante)
		end
	end)

	self.m_viewAddChip = new(ViewAddChip,{callback = data.callback})
			:addTo(self)
			:align(kAlignBottomRight)
			:hide()
	self.btn_addChip = self:findChildByName("btn_addChip")
	self.btn_addChip:setOnClick(self,function()
		self.m_viewAddChip:showUp()
	end)

	self.m_betConfig = setProxy(new(BetConfig))

	UIEx.bind(self, self.m_betConfig, "quickChip_1", function(value)
		self:findChildByName("text_chip_1"):setText(ToolKit.formatAnteWithoutFloor(value))
	end)
	UIEx.bind(self, self.m_betConfig, "quickChip_2", function(value)
		self:findChildByName("text_chip_2"):setText(ToolKit.formatAnteWithoutFloor(value))
	end)
	UIEx.bind(self, self.m_betConfig, "quickChip_3", function(value)
		local str = ToolKit.formatAnteWithoutFloor(value)
		self:findChildByName("text_chip_3"):setText(str)
	end)
	UIEx.bind(self, self.m_betConfig, "maxChip", function(value)
		self:findChildByName("text_in_max"):setText(string.format("MAX: %s",value))
	end)
	UIEx.bind(self, self.m_betConfig, "minChip", function(value)
		self:findChildByName("text_in_min"):setText(string.format("MIN: %s",value))
	end)

	UIEx.bind(self, MyUserData, "money", function(value)
		self:freshBtns()
	end)
	UIEx.bind(self, self.m_betConfig, "lastChip", function(value)
		self.m_viewAddChip:setLastChip(value)
		self:freshBtns()
	end)
	MyUserData:setMoney(MyUserData:getMoney())
end

--根据底注换算快捷下注数值--暂时不用
function viewChipIn:setBaseAnte(baseAnte)	
	JLog.d("测试setBaseAnte",baseAnte);
	self.m_betConfig:setQuickChip_1(baseAnte*TIMES_1)
	self.m_betConfig:setQuickChip_2(baseAnte*TIMES_2)
	self.m_betConfig:setQuickChip_3(baseAnte*TIMES_3)
	self.m_betConfig:setMaxChip(baseAnte*TIME_MAX)
	self.m_betConfig:setMinChip(baseAnte*TIME_MIN)

	print(baseAnte*1,baseAnte*10,"-------------------")
	self.m_viewAddChip:setMinMaxChip(baseAnte*TIME_MIN,baseAnte*TIME_MAX)
end

--根据PHP返回房间列表 初始化快捷下注数值
function viewChipIn:initQuickChip(chipList)
	JLog.d("viewChipIn:initQuickChip",chipList);
	self.m_betConfig:setQuickChip_1(chipList[1])
	self.m_betConfig:setQuickChip_2(chipList[2])
	self.m_betConfig:setQuickChip_3(chipList[3])
	self.m_betConfig:setMaxChip(chipList[4])
	self.m_betConfig:setMinChip(chipList[1]*TIME_MIN)
	self.m_viewAddChip:setMinMaxChip(chipList[1]*TIME_MIN,chipList[4])
end

function viewChipIn:setLastChip(value)
	self.m_betConfig:setLastChip(value)
end

function viewChipIn:freshBtns()
	local myMoney = 0
	if G_CUR_GAME_ID == tonumber(GAME_ID.Casinohall) then --筹码场
		myMoney = MyUserData:getMoney()
	elseif G_CUR_GAME_ID == tonumber(GAME_ID.PokdengCash) then --现金币场
		myMoney = MyUserData:getCashPoint()		
	end

	for i=1,3 do
		local btn_chip = self:findChildByName("btn_chip_"..i)
		if self.m_betConfig["quickChip_"..i]>myMoney then
			btn_chip:setEnable(false)
			btn_chip:setGray(true)
		else
			btn_chip:setEnable(true)
			btn_chip:setGray(false)
		end
	end
	if myMoney<=self.m_betConfig:getLastChip() then --我的钱<=上次的下注<=最大下注  ,显示全下,重复下注为 我的剩余钱
		self:findChildByName("text_repeat"):setText(Room_String.str_chip_in_allIn)
		self.m_lastChipNum = myMoney
	else
		if self.m_betConfig:getMaxChip()==self.m_betConfig:getLastChip() then --上次的下注==最大下注 ，显示全下 ，重复下注为最大下注
			self:findChildByName("text_repeat"):setText(Room_String.str_chip_in_allIn)
		else --上次的下注<最大下注
			self:findChildByName("text_repeat"):setText(Room_String.str_chip_in_repeat)
		end
		self.m_lastChipNum = self.m_betConfig:getLastChip()
	end	
end

function viewChipIn:showUp()
	self:show()
	local w,h = self:getSize()
	local time = 0.2
	self.m_layout:runAction({{"opacity",0,1,time},{"y",h,0,time}},{loopType=kAnimNormal,order="spawn"})
end

function viewChipIn:hideDown()
	local w,h = self:getSize()
	local time = 0.4
	self.m_layout:runAction({{"opacity",1,0,time},{"y",0,h,time}},{loopType=kAnimNormal,order="spawn",onComplete=function()
			self:hide()
		end})
	self.m_viewAddChip:hideDown()
end

return viewChipIn