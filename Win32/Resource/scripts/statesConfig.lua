-- Data:2013-9-4
-- Description:各个状态的配置
-- Note:
--		程序使用StateMachine这个类，该类负责场景状态的切换，而切换的时候
-- 程序会查看系统维护的状态的集合，如果当前的状态不存在，那么以状态为索引
-- 到table----StatesMap中去获得状态，从而创建。所以，程序需要创建table,配置
-- state
States = 
{
	Load 				= "lobby_load",		        --加载场景
	Login 				= "lobby_login", 	        --登录场景
	Lobby 				= "lobby_lobby",  	        --大厅场景
	Game_Pokdeng 		= "subgame_pokdeng",  	    --博定房间

};

StateFileMap = {
	[States.Load] 					= "app/load/loadState",
	[States.Login] 					= "app/login/loginState",
	[States.Lobby] 					= "app/lobby/lobbyState",
	[States.Game_Pokdeng] 			= "app/games/pokdeng/room/roomState",
}

StatesMap = {
}

function autoRequire(state)
	if not StatesMap[state] then
		StatesMap[state] = require(StateFileMap[state])
	end
end