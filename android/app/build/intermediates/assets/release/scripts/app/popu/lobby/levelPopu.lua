local GameWindow = require("app.popu.gameWindow")
local levelPopu = class(GameWindow)

local cIndex = 0
local function getIndex()
	cIndex = cIndex + 1
	return cIndex
end

levelPopu.s_controls =
{
	btn_close = getIndex(),

	text_line1 = getIndex(),

	view_line2 = getIndex(),
	text_line2_1 = getIndex(),
	text_line2_2 = getIndex(),
	text_line2_3 = getIndex(),
	text_line2_4 = getIndex(),

	text_line3 	 = getIndex(),

	text_line4_1 = getIndex(),

	text_line5 	 = getIndex(),

	levelTitle	= getIndex(),
	expTitle	= getIndex(),
	levelListView = getIndex(),
}

levelPopu.s_controlConfig = 
{
	[levelPopu.s_controls.btn_close] 	= {"img_popuBg","btn_close"},
	[levelPopu.s_controls.text_line1] 	= {"img_popuBg","text_line1"},
	[levelPopu.s_controls.view_line2] 	= {"img_popuBg","view_line2"},
	[levelPopu.s_controls.text_line2_1] 	= {"img_popuBg","view_line2", "text_1"},
	[levelPopu.s_controls.text_line2_2] 	= {"img_popuBg","view_line2", "text_2"},
	[levelPopu.s_controls.text_line2_3] 	= {"img_popuBg","view_line2", "text_3"},
	[levelPopu.s_controls.text_line2_4] 	= {"img_popuBg","view_line2", "text_4"},

	[levelPopu.s_controls.text_line3] 	= {"img_popuBg","text_line3"},

	[levelPopu.s_controls.text_line4_1] 	= {"img_popuBg","view_line4", "text_1"},

	[levelPopu.s_controls.text_line5] 	= {"img_popuBg","text_line5"},

	[levelPopu.s_controls.levelTitle] 	= {"img_popuBg","view_level","level_title"},
	[levelPopu.s_controls.expTitle] 	= {"img_popuBg","view_level","exp_title"},
	[levelPopu.s_controls.levelListView] 	= {"img_popuBg","view_level","levelListView"},
}

local levelItem = class(GameLayer,false)

function levelItem:ctor(data)
	super(self, require(ViewPath.."popu.lobby.levelPopuItem"))
	self:setSize(self.m_root:getSize())
	local textTitle = self.m_root:findChildByName("text_title")
	local textExp = self.m_root:findChildByName("text_exp")
	textTitle:setText("LV "..data)
	if data == 1 then
		textExp:setText("--")
	else
		textExp:setText("EXP "..(userLevelExp[data].x1))
	end
end

function levelPopu:initView(data)
	self:getControl(self.s_controls.text_line1):setText("如何获得经验值：")

	self:getControl(self.s_controls.text_line2_1):setText("玩牌赢一局，")
	self:getControl(self.s_controls.text_line2_2):setText("EXP+2")
	self:getControl(self.s_controls.text_line2_3):setText("，玩牌输/平一局，")
	self:getControl(self.s_controls.text_line2_4):setText("EXP+1")
	self:resetLineLeft(self:getControl(self.s_controls.view_line2), 0)

	self:getControl(self.s_controls.text_line3):setText("(玩牌每日最多获得300点)")

	self:getControl(self.s_controls.text_line4_1):setText("vip登录、礼包打开也可获得对应的经验点数。")

	self:getControl(self.s_controls.text_line5):setText("等级设定：")

	self:getControl(self.s_controls.levelTitle):setText("等级")
	self:getControl(self.s_controls.expTitle):setText("升级要求")
	local levelData = {}
	for i = 1, #userLevelExp do
		table.insert(levelData, i)
	end
	self:getControl(self.s_controls.levelListView):setAdapter(new(CacheAdapter, levelItem, levelData))
end

function levelPopu:resetLineLeft(view, offset)
	local children = view:getChildren()
	for i=2,#children do
		local child_last = children[i-1]
		local child_now = children[i]

		local w,h = child_last:getSize()
		local x,y = child_last:getPos()
		child_now:pos(x+w+offset,0)
	end
end

function levelPopu:onCloseBtnClick()
	self:dismiss()
end

----------------------------  config  --------------------------------------------------------
levelPopu.s_controlFuncMap = 
{
	[levelPopu.s_controls.btn_close] = levelPopu.onCloseBtnClick;
}

return levelPopu