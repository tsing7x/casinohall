local Game = class(require('base.basegame'))
--协议类
local Command = require("app.lobby.command")

--游戏属性
addProperty(Game, "name", '')
addProperty(Game, "iconFile", "")
addProperty(Game, "update", false)
addProperty(Game, "roomList", nil)

function Game:ctor(roomList)
	self:setName("博定上庄场")
    self:setIconFile("kaengWild/kaeng_icon.png")
end

function Game:showLoadingAnim(value)
	if value then
		JLog.d("显示loading！！！！！");

		local loadingStr = Hall_string.STR_LOGIN_LOADING
		app:showLoadingTip(loadingStr,true)
	else
		app:hideLoadingTip()
	end
end

--[[
	筹码场上庄
]]
function Game:requestCreateRoom(param)
	self:showLoadingAnim(true)
	local userInfo = {appid = 0, nick = MyUserData:getNick(), sex = MyUserData:getSex(), micon = MyUserData:getHeadUrl(), giftId = MyUserData:getGiftId()}
	param.userInfo = json.encode(userInfo)
	JLog.d("PokdengLobbyScene:requestCreateRoom",param);
	GameSocketMgr:sendMsg(Command.CREATE_PRIVATEROOM_REQ, param)
end

--[[
	进入游戏房间
]]
function Game:enterRoom()
	local gameId = tonumber(GAME_ID.Casinohall)
	if not MyRoomConfig:get(gameId) then
		if DEBUG_MODE then
			AlarmTip.play("PHP没有返回建房参数")
		end
		return
	end
	
	local callback = function(param)
		JLog.d("create Chip Room callback",param)
		self:requestCreateRoom(param)
		WindowManager:closeWindowByTag(WindowTag.CreateRoomPopu)
		self:showLoadingAnim(true)
	end
	WindowManager:showWindow(WindowTag.CreateRoomPopu, {gameId = tonumber(GAME_ID.Casinohall),createType ="chipType",callback = callback}, WindowStyle.POPUP)
end


function Game:dtor()
	-- body
end

return Game