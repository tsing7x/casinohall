
local pageItemView = require (ViewPath .. "gameItem")

local gameItem = class(GameLayer,false)

local cIndex = 0
local function getIndex()
	cIndex = cIndex + 1
	return cIndex
end

gameItem.s_controls = 
{
	--topView
	gameBtn = getIndex(),
	gameImg = getIndex(),
	onlineNum = getIndex(),
	
}

gameItem.s_controlConfig = 
{
	[gameItem.s_controls.gameBtn] = {"bgBtn"},
	[gameItem.s_controls.gameImg] = {"bgBtn","img"},
	[gameItem.s_controls.onlineNum] = {"bgBtn","countTxt"},
}

function gameItem:ctor(data)
	super(self,pageItemView)
	self.m_data = data
	local dw,dh = self.m_root:getSize();
	GameLayer.setSize(self, dw, dh);

	local t = new(Text,math.random() .. " test")
	self:addChild(t)
end

function gameItem:onGameBtnClick()
	dump(self.m_data)
end

gameItem.s_controlFuncMap = 
{
	[gameItem.s_controls.gameBtn] = gameItem.onGameBtnClick,
	
}

return gameItem