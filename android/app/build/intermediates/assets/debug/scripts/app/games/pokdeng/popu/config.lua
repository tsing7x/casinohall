require("app.manager.windowManager")

function pokdengPopuInit()
	WindowTag.RoomDetailPopu 	 = 1000;
	-- WindowTag.RoomLoadingPopu 	 = 1002;
	-- WindowTag.GameRulePopu 	 	 = 1004;
	-- WindowTag.ResultDetailPopu	 = 1005;
	-- WindowTag.DummyRoomTipsPopu  = 1006;--场次提示
    
	--配置
	WindowConfigMap[WindowTag.RoomDetailPopu] 		= {"app.games.pokdeng.popu.roomDetailPopu", "roomDetailPopu", 220, true, true, true, true, "app.view.games.pokdeng."}
	-- WindowConfigMap[WindowTag.RoomLoadingPopu] 		= { "dummy.popu.roomLoadingPopu", "loadingLayout", 220, false, true, true, true, "view.dummy."}
	-- WindowConfigMap[WindowTag.GameRulePopu] 		= { "dummy.popu.gameRulePopu", "gameRuleLayout", 220, true, true, true, true, "view.dummy."}
	-- WindowConfigMap[WindowTag.ResultDetailPopu] 	= { "dummy.popu.resultDetailPopu", "resultDetailLayout", 220, false, true, true, true, "view.dummy."}
	-- WindowConfigMap[WindowTag.DummyRoomTipsPopu] 	= { "dummy.popu.dummyRoomTipsPopu", "dummyRoomTipsLayout", 220, false, true, true, true, "view.dummy."}
end
