local view_cardType = require(ViewPath .. "games.view.view_cardType")

local resPath = "games/pokdeng/cardType/"

local M = class(Node);

function M:ctor()
	local node = new(Node)
		:addTo(self)
		:align(kAlignCenter)

	local layout = SceneLoader.load(view_cardType)	
		:addTo(node)
	
	node:setSize(layout:findChildByName("view_type"):getSize())
	self.m_node = node
	self:hide()
end

local TYPE_PATH = 
{
	[1] = 
	{
		[0] = resPath.."0.png",
		[1] = resPath.."1.png",
		[2] = resPath.."2.png",
		[3] = resPath.."3.png",
		[4] = resPath.."4.png",
		[5] = resPath.."5.png",
		[6] = resPath.."6.png",
		[7] = resPath.."7.png",
		[8] = resPath.."8.png",
		[9] = resPath.."9.png",
	},
	[2] = resPath.."tag_straight.png",
	[3] = resPath.."tag_straightFlush.png",
	[4] = resPath.."tag_threeYellow.png",
	[5] = resPath.."tag_threeKind.png",
	[6] = {
		[8] = resPath.."pokdeng_8.png",
		[9] = resPath.."pokdeng_9.png",
	},
}

--设置牌型
function M:setCardType(_type,_point)
	self:show()
	local img_bg_1 = self:findChildByName("img_bg_1"):hide()
	local img_bg_2 = self:findChildByName("img_bg_2"):hide()
	local img_bg_3 = self:findChildByName("img_bg_3"):hide()

	if _type==1 then
		local tag_value = img_bg_1:show():findChildByName("tag_value")
		local typePath = TYPE_PATH[_type][_point]
		print("typePath",typePath)
		tag_value:setFile(typePath)
	elseif _type<=5 then
		local tag_type = img_bg_3:show():findChildByName("tag_type")
		local typePath = TYPE_PATH[_type]
		tag_type:setFile(typePath)
	elseif _type==6 then
		local tag_type = img_bg_2:show():findChildByName("tag_type")
		typePath = TYPE_PATH[_type][_point]
		tag_type:setFile(typePath)
	end
end

--设置翻倍
function M:setTimes(_times)
	local tag_times = self:findChildByName("tag_times")
	if _times<=1 then
		tag_times:hide()
		return
	elseif (_times~=2 and _times~=3 and _times~=5) then
		tag_times:hide()
		return
	else
		tag_times:show()
	end

	local path_x = string.format(resPath.."x%s.png",_times)
	tag_times:setFile(path_x)
end

function M:freshByLocalSeat(localSeat)
	local tag_times = self:findChildByName("tag_times")
	local w,h = tag_times:getSize()
	if localSeat>=6 and localSeat<=9 then
		tag_times:align(kAlignLeft)
	else
		tag_times:align(kAlignRight)
	end
	tag_times:pos(-w,0)
end


return M