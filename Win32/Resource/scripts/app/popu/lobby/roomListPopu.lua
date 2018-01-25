local GameWindow = require("app.popu.gameWindow")
local RoomListPopu = class(GameWindow)
local roomListItemLayout = requireview("app.view.games.pokdeng.roomListItemLayout")

-- local Hall_string = require("app.res.config")

local cIndex = 0
local function getIndex()
	cIndex = cIndex + 1
	return cIndex
end


RoomListPopu.s_controls =
{
	btn_close = getIndex(),
};

RoomListPopu.s_controlConfig = 
{
	[RoomListPopu.s_controls.btn_close] 	= {"img_popuBg","btn_close"},
};


function RoomListPopu:onErrorRoomCode()
	
end

function RoomListPopu:initView(data)
	if not data then return end
	self.m_gameId = data.gameId;
	self.m_callback = data.callback;
	
end

function RoomListPopu:onShowEnd()
	self.super.onShowEnd(self)
	self:initRoomList();
end

function RoomListPopu:initRoomList()
	local WINTERVAL = 8;--行间隔
	local posY = WINTERVAL;
	local scrollView = self:findChildByName("view_room_list"):findChildByName("sv_room_list");

	local game 	= app:getGame(self.m_gameId)
	if game then
		local roomDataList 	= game:getRoomList();
		for i = 1, roomDataList and roomDataList:count() or 0 do 
			local item 	= SceneLoader.load(roomListItemLayout);
			local w,h = item:getSize();
			local roomData = roomDataList:get(i)

			item:findChildByName("txt_ante"):setText(Hall_string.str_baseAnte..ToolKit.formatAnteWithoutFloor(roomData:getAnte()));
			item:findChildByName("txt_min_limit"):setText(Hall_string.STR_MIN_LIMIT..ToolKit.formatAnteWithoutFloor(roomData:getMinChip()));
		 	item:align(kAlignTopLeft)
			item:setPos(5,posY)
			posY = posY+h+WINTERVAL;
			scrollView:addChild(item);

			local btnBg = item:findChildByName("btn_bg"); 
			btnBg:setOnClick(self, function ( self )
				local myMoney = MyUserData:getMoney()
				if myMoney < gBankrupt then
				WindowManager:showWindow(WindowTag.BankruptPopu, {state = 1, gameId = self.m_gameId, level = nil}, WindowStyle.POPUP)
				end
				local content = nil
				if myMoney < roomData:getMinChip() then
					-- AlarmTip.play("你的筹码不足"..roomData:getMinChip())
					AlarmTip.play(string.format(Hall_string.STR_MONEY_LESS_THAN_ANTE, roomData:getMinChip()));	
				else
					if self.m_callback then 
						local level = roomData:getLevel();
						self.m_callback(level);
					end
					return ;
				end
			end);
		end
	else
		JLog.d("获取不到"..self.m_gameId.." 的房间列表");
	end
	
end


function RoomListPopu:onCloseBtnClick()
	self:dismiss()
end



----------------------------  config  --------------------------------------------------------

RoomListPopu.s_controlFuncMap = 
{
	[RoomListPopu.s_controls.btn_close] = RoomListPopu.onCloseBtnClick;
};

return RoomListPopu