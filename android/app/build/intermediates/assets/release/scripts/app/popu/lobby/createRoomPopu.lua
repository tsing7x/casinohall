local GameWindow = require("app.popu.gameWindow")
local createRoomPopu = class(GameWindow)

-- local Hall_string = require("app.res.config")
local resPath = "popu/createRoom/"

local cIndex = 0
local function getIndex()
	cIndex = cIndex + 1
	return cIndex
end



function createRoomPopu:initView(data)
	JLog.d("createRoomPopu:initView",data);
	if not data then return end
	self.m_callback = data.callback
	self.m_gameId = data.gameId

	self.closeBtn = self:findChildByName("btn_close");
	self.closeBtn:setOnClick(nil,function ()
		self:dismiss()
	end)

	self.m_creatType = 0;

	if data.createType == "cashType" then --现金币场
		self.m_creatType = 1;
		self:initCashView();	
	else--默认为筹码场
		self.m_creatType = 0;
		self:initChipView();	
	end
end

--初始化筹码场建房UI
function createRoomPopu:initChipView(data)
	self:findChildByName("view_chip"):findChildByName("text_chose_ante"):setText(Hall_string.STR_SELECT_ANTE)
	self:findChildByName("view_chip"):findChildByName("text_dealer_min_limit"):setText(Hall_string.str_createRoom_zhuang_limit)
	self:findChildByName("view_chip"):findChildByName("text_xian_limit"):setText(Hall_string.str_createRoom_xian_limit)
	self:findChildByName("view_chip"):findChildByName("text_createRoom"):setText(Hall_string.str_createRoom_create)
	self:findChildByName("view_chip"):show();
	self:findChildByName("view_cash"):hide();

	local game 			= app:getGame(self.m_gameId)
	local createConfig 	= game:getRoomList();
	self.m_baseAnteView = self:findChildByName("view_chip"):findChildByName("view_baseAnte");
	self:initBaseAnte(self.m_baseAnteView,createConfig)
	self:onSelectBaseAnte(1)

	local confirmBtn = self:findChildByName("view_chip"):findChildByName("btn_confirm");
	confirmBtn:setOnClick(nil,function ()
		self:onChipConfirmBtnClick()
	end);
end

function createRoomPopu:initCashView(data)
	self:findChildByName("view_cash"):findChildByName("text_chose_ante"):setText(Hall_string.STR_SELECT_ANTE)
	self:findChildByName("view_cash"):findChildByName("text_chose_num"):setText(Hall_string.STR_SELECT_ROUND)
	self:findChildByName("view_cash"):findChildByName("text_creat_tips"):setText(Hall_string.STR_CREATE_CASH_ROOM_TIPS)	
	self:findChildByName("view_cash"):findChildByName("text_dealer_min_limit"):setText(Hall_string.str_createRoom_zhuang_limit)
	self:findChildByName("view_cash"):findChildByName("text_xian_limit"):setText(Hall_string.str_createRoom_xian_limit)
	self:findChildByName("view_cash"):findChildByName("text_ispublic"):setText(Hall_string.str_createRoom_public)
	self:findChildByName("view_cash"):findChildByName("text_room_fee"):setText(Hall_string.STR_ROOM_FEE)
	self:findChildByName("view_cash"):findChildByName("text_createRoom"):setText(Hall_string.str_createRoom_create)
	
	self:findChildByName("view_chip"):hide();
	self:findChildByName("view_cash"):show();
	local game 			= app:getGame(self.m_gameId)
	local createConfig 	= game:getRoomList();
	self.m_baseAnteView = self:findChildByName("view_cash"):findChildByName("view_baseAnte");

	self:initRoundCount(createConfig);
	self:onSelectRoundCount(1)

	self:initBaseAnte(self.m_baseAnteView,createConfig);
	self:onSelectBaseAnte(1)

	

	--确定按钮
	local confirmBtn = self:findChildByName("view_cash"):findChildByName("btn_confirm");
	confirmBtn:setOnClick(nil,function ()
		self:onCashConfirmBtnClick()
	end);

	--是否公开房间
	local switchBtn = self:findChildByName("view_cash"):findChildByName("switch_public");
	switchBtn:setOnChange(self,self.onSwitchPublicChange);
	self:onSwitchPublicChange(true)--默认打开

end

--初始化底注选择界面
function createRoomPopu:initBaseAnte(baseAnteView,roomListData)
	if not baseAnteView then
		return;
	end

	for i=1,roomListData:count() do
		local ante = baseAnteView:findChildByName("ante_"..i)
		if not ante then
			break
		end
		ante:findChildByName("text_anteNum"):setText(ToolKit.formatAnteWithoutFloor(roomListData:get(i):getAnte()))
		ante:findChildByName("text_tag"):setText(Hall_string.str_baseAnte)
		if ante then
			ante:setOnClick(self,function()
				self:onSelectBaseAnte(i)
			end)
		end
	end
end


--初始化现金币场选择界面
function createRoomPopu:initRoundCount(roomListData)
	local roundNumView = self:findChildByName("view_cash"):findChildByName("view_chose_num");
	if not roundNumView then
		return;
	end

	local roundList = roomListData:get(1):getRoundList();--所有场次的局数数据是一样的，所以只需拿第一个就行了
	self.m_selectRound = roundList[1];--默认选中第一个
	for i=1,#roundList do
		local roundNum = roundNumView:findChildByName("num_"..i)
		if not roundNum then
			break
		end
		roundNum:findChildByName("text_anteNum"):setText(ToolKit.formatAnteWithoutFloor(roundList[i]))
		roundNum:findChildByName("text_tag"):setText(Hall_string.STR_ROUND)
		if roundNum then
			roundNum:setOnClick(self,function()
				self.m_selectRound = roundList[i];
				self:onSelectRoundCount(i)
			end)
		end
	end
end


function createRoomPopu:freshCost(cost)
	self.img_cost:setNumber("x"..cost)
end

function createRoomPopu:onSelectRoundCount(index)
	local roundNumView = self:findChildByName("view_cash"):findChildByName("view_chose_num");
	local children = roundNumView:getChildren()
	for k,v in pairs(children) do
		v:findChildByName("img_normal"):show()
		v:findChildByName("img_select"):hide()
		v:findChildByName("text_anteNum"):setColor(67,91,157)
		v:findChildByName("text_tag"):setColor(67,91,157)
	end

	local roundNum =roundNumView:findChildByName("num_"..index)
	if roundNum then
		roundNum:findChildByName("img_normal"):hide()
		roundNum:findChildByName("img_select"):show()
		roundNum:findChildByName("text_anteNum"):setColor(38,55,154)
		roundNum:findChildByName("text_tag"):setColor(38,55,154)
	end

	if self.m_selectConfig then
		local tableFee = self.m_selectRound * self.m_selectConfig:getAnte();
		self:findChildByName("view_cash"):findChildByName("text_room_fee"):findChildByName("text_num"):setText(ToolKit.formatAnteWithoutFloor(tableFee));	
	end
	
end

function createRoomPopu:onSelectBaseAnte(index)
	-- local createConfig = CreateRoomConfigData:getConfigByGameId(self.m_gameId)
	local game 			= app:getGame(self.m_gameId)
	local createConfig 	= game:getRoomList();
	local config = createConfig:get(index)
	self.m_selectConfig = config

	local children = self.m_baseAnteView:getChildren()
	for k,v in pairs(children) do
		v:findChildByName("img_normal"):show()
		v:findChildByName("img_select"):hide()
		v:findChildByName("text_anteNum"):setColor(67,91,157)
		v:findChildByName("text_tag"):setColor(67,91,157)
	end
	local ante = self.m_baseAnteView:findChildByName("ante_"..index)
	if ante then
		ante:findChildByName("img_normal"):hide()
		ante:findChildByName("img_select"):show()
		ante:findChildByName("text_anteNum"):setColor(38,55,154)
		ante:findChildByName("text_tag"):setColor(38,55,154)
	end

	if self.m_creatType == 0 then --筹码场
		self:findChildByName("view_chip"):findChildByName("text_dealer_min_limit"):findChildByName("text_num"):setText(ToolKit.formatAnteWithoutFloor(config:getDealerMinChip()));
		self:findChildByName("view_chip"):findChildByName("text_xian_limit"):findChildByName("text_num"):setText(ToolKit.formatAnteWithoutFloor(config:getMinChip()));
	elseif self.m_creatType == 1 then --现金币场
		self:findChildByName("view_cash"):findChildByName("text_dealer_min_limit"):findChildByName("text_num"):setText(ToolKit.formatAnteWithoutFloor(config:getDealerMinChip()));
		self:findChildByName("view_cash"):findChildByName("text_xian_limit"):findChildByName("text_num"):setText(ToolKit.formatAnteWithoutFloor(config:getMinChip()));
		local tableFee = self.m_selectRound * config:getAnte();
		self:findChildByName("view_cash"):findChildByName("text_room_fee"):findChildByName("text_num"):setText(ToolKit.formatAnteWithoutFloor(tableFee));	
	end
end

function createRoomPopu:defaultSet()
	self:onSwitchPublicChange(true)
	self:onSelectBaseAnte(1)
end

function createRoomPopu:onCloseBtnClick()
	self:dismiss()
end

--筹码场确定按钮
function createRoomPopu:onChipConfirmBtnClick()
	local config = self.m_selectConfig
	local myMoney = MyUserData:getMoney()
	if myMoney < config:getDealerMinChip() then
		-- AlarmTip.play("你的筹码不足"..config:getDealerMinChip())
		JLog.d("createRoomPopu:onChipConfirmBtnClick",Hall_string.STR_MONEY_LESS_THAN_CREATE);
		AlarmTip.play(string.format(Hall_string.STR_MONEY_LESS_THAN_CREATE, config:getDealerMinChip()));
	else
		if type(self.m_callback)=="function" then
			local param = {
				gameId = self.m_gameId,
				level = config:getLevel(),
				money = myMoney,
				isCash = 0
				-- allow_quick_enter = self.m_isSwitchOpen and 1 or 0
			}
			self.m_callback(param)
		end
	end
end

--现金币场确定按钮
function createRoomPopu:onCashConfirmBtnClick(...)
	JLog.d("createRoomPopu:onCashConfirmBtnClick")
	local config = self.m_selectConfig
	local myCash = MyUserData:getCashPoint();
	if myCash < config:getDealerMinChip() then
		-- AlarmTip.play("你的现金币不足"..config:getDealerMinChip())
		AlarmTip.play(string.format(Hall_string.STR_CASH_LESS_THAN_CREATE, config:getDealerMinChip()));
	else
		if type(self.m_callback)=="function" then
			local param = {
				gameId = self.m_gameId,
				level = config:getLevel(),
				money = myCash,
				isCash = 1,
				isPublic = self.m_isSwitchOpen and 1 or 0,
				roundCount = self.m_selectRound
			}
			self.m_callback(param)
		end
	end
end

function createRoomPopu:onSwitchPublicChange(isOpen)
	print("isOpen",isOpen)
	self.m_isSwitchOpen = isOpen
end

return createRoomPopu