local GameWindow = require("app.popu.gameWindow")
local roomDetailPopu = class(GameWindow)
local detailListItemLayout = requireview("app.view.games.pokdeng.detailListItemLayout")

local Hall_String = require("app.res.config")
local resPath = "popu/enterRoom/"

local cIndex = 0
local function getIndex()
	cIndex = cIndex + 1
	return cIndex
end

roomDetailPopu.s_controls =
{
	btn_close = getIndex(),	
};

roomDetailPopu.s_controlConfig = 
{
	[roomDetailPopu.s_controls.btn_close] 	= {"img_popuBg","btn_close"},
};

function roomDetailPopu:initView(data)
	-- if not data then return end
	self:initTabView()
	-- self:initInputView(data)
	-- self:initRoomList();
	self:initDetailList(data);
end

function roomDetailPopu:initTabView()
	self.detailListView = self:findChildByName("view_detail_list");
	self.ruleView = self:findChildByName("view_rule");
	--tab 对应view
	self.m_tabs = {
		{self:findChildByName("view_btnTab"):findChildByName("btn_detail_list"),self.detailListView},
		{self:findChildByName("view_btnTab"):findChildByName("btn_rule"),self.ruleView},
	}
	for i=1,#self.m_tabs do
		self.m_tabs[i][1]:setOnClick(self,function()
			self:selectTab(i)
		end)
	end
	self:selectTab(1)
end

function roomDetailPopu:selectTab(index)
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

function roomDetailPopu:initDetailList(detailList)
	gameId = detailList[2]
	detailList = detailList[1]		

	local WINTERVAL = 8;--行间隔
	local posY = WINTERVAL;
	local scrollView = self:findChildByName("view_detail_list"):findChildByName("sv_detail_list");

	--设置你的玩牌局数和你的输赢
	local playNum = 0
	local curWin = 0
	if detailList[MyUserData:getId()] then
		playNum = detailList[MyUserData:getId()].playNum
		curWin = detailList[MyUserData:getId()].curWin
	end
	self:findChildByName("text_roud_count"):setText("คุณเล่นไพ่"..playNum.."รอบ")

	local types = type(GAME_ID.PokdengCash)
	if GAME_ID.PokdengCash == tostring(gameId) then
		self:findChildByName("img_money_icon"):setFile("lobby/hall_chip.png")
	else
		self:findChildByName("img_money_icon"):setFile("lobby/hall_cash.png")
	end
	self:findChildByName("text_add_money"):setText(curWin)

	--筛选出要显示的玩家
	local detailListForShow = {}	
	for _, detailListItem in pairs(detailList) do
		--荷官不显示
		if _ == 1 then
		elseif _ == MyUserData:getId() then
		else
			table.insert(detailListForShow, detailListItem)
		end
		--设置最多显示100人
		if #detailListForShow > 100 then
			break
		end
	end

	--根据玩家输赢进行排序
	table.sort(detailListForShow, function(a, b)
		return a.curWin > b.curWin
	end)

	--将自己的信息插入
	table.insert(detailListForShow, 1, detailList[MyUserData:getId()])

	--设置其他玩家的玩牌信息
	for _, detailListItem in ipairs(detailListForShow) do
		local item 	= SceneLoader.load(detailListItemLayout);
		local w,h = item:getSize();

		--自己的背景设为淡蓝色
		if _ == 1 then
			item:findChildByName("btn_bg"):setFile("games/pokdeng/detailPopu/item_me.png")
		end

		--离线设置背景为灰
		if not detailListItem.isOnline then
			item:findChildByName("btn_bg"):setIsGray(1, true)
		end
		--设置昵称
		item:findChildByName("txt_name"):setText(detailListItem.nick);

		--设置头像
		local headData = setProxy(require("app.data.headData"))
		local imgHeadBg = item:findChildByName("img_head_bg")
		UIEx.bind(self, headData, "headName", function(value)
				if value and value~= "" then
					imgHeadBg:setFile(value)					
				end
			end
		)
		headData:setSex(detailListItem.sex)
		headData:setHeadUrl(detailListItem.iconurl)
		headData:checkHeadAndDownload()

		if GAME_ID.PokdengCash == tostring(gameId) then
			item:findChildByName("img_chip_icon"):setFile("lobby/hall_chip.png")
		else
			item:findChildByName("img_chip_icon"):setFile("lobby/hall_cash.png")
		end		
		--设置筹码
		item:findChildByName("text_chip"):setText(detailListItem.curMoney);
		--设置输赢
		item:findChildByName("txt_win_money"):setText(detailListItem.curWin);		

	 	item:align(kAlignTopLeft)
		item:setPos(5,posY)
		posY = posY+h+WINTERVAL;
		scrollView:addChild(item);
	end
	
end


function roomDetailPopu:onCloseBtnClick()
	self:dismiss()
end

function roomDetailPopu:onConfirmBtnClick()
	if type(self.m_callback)=="function" then
		local prama = {
			gameid = self.m_gameId,
			password = self.m_Str,
		}
		self.m_callback(prama)
	end
end

----------------------------  config  --------------------------------------------------------

roomDetailPopu.s_controlFuncMap = 
{
	[roomDetailPopu.s_controls.btn_close] = roomDetailPopu.onCloseBtnClick;
};

return roomDetailPopu