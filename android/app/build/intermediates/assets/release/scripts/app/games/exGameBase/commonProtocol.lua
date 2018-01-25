return {
	-- --公共协议
	-- COMMON_GET_TABLEID_REQ           		= 0x118    -- 请求分配桌子ID
	-- COMMON_GET_TABLEID_RSP       			= 0x210    -- 
	-- COMMON_FOLLOW_REQ           			= 0x123    -- 跟踪玩家
	-- COMMON_FOLLOW_RSP           			= 0x214    -- 跟踪玩家
	-- COMMON_FOLLOWED_RSP 					= 0x215    -- 被跟踪玩家
	-- COMMON_SITDOWN_IN_GAME_REQ 				= 0x1031   -- 请求坐下
	-- COMMON_SITDOWN_IN_GAME_RSP 				= 0x1051   -- 坐下返回
	-- COMMON_BROADCAST_SITDOWN_RSP 			= 0x4002   -- 广播坐下

	-- COMMON_BET_REQ 							= 0x1032   -- 请求下注
	-- COMMON_STANDUP_REQ 						= 0x1033   -- 玩家站起
	-- COMMON_STANDUP_RSP 						= 0x1053
	-- COMMON_BROADCAST_STANDUP_RSP 			= 0x4006   -- 广播站起
	-- COMMON_SEND_PROP_RSP              		= 0x7854   -- 响应发送道具

	-- ---add
	-- ----------------- Client send to Server ---------------------------------------------------

	-- COMMON_LOGIN_GAME_REQ 					= 0x1001    -- 请求登录某个游戏
	-- COMMON_EXIT_ROOM_REQ 					= 0x1002 	-- 退出房间
	-- COMMON_SEND_FACE						= 0x1004	-- 发送表情

	-- ------------------ Client recv from Server ------------------------------------------------
	-- COMMON_BROADCAST_USER_READY				= 0x4001	-- 广播用户准备
	-- COMMON_LOGIN_GAME_ERROR_RSP 			= 0x1005    -- 登录失败返回
	-- COMMON_LOGIN_GAME_RSP					= 0x1007    -- 登录成功
	-- COMMON_RELOGIN_GAME_RSP					= 0x1009    -- 重连
	-- COMMON_EXIT_ROOM_RSP 					= 0x1008 	-- 退出房间
	-- COMMON_SEND_CHAT						= 0x1003	-- 发送聊天
	-- SERVER_BROADCAST_USER_LOGOUT    		= 0x100E	-- 广播用户退出

	GET_TABLEID_REQ           			= 0x118,    -- 请求分配桌子ID
	GET_TABLEID_RSP       				= 0x210,    -- 分配桌子返回
	FOLLOW_REQ           				= 0x123,    -- 跟踪玩家
	CLIENT_CMD_LOGINROMM                = 0x11a,    -- 客户端请求登录房间
	FOLLOW_RSP           				= 0x214,    -- 跟踪玩家
	FOLLOWED_RSP 						= 0x215,    -- 被跟踪玩家
	LOGIN_GAME_REQ 						= 0x1001,    -- 请求登录某个游戏
	LOGIN_GAME_RSP						= 0x2001,    -- 登录成功
	LOGIN_GAME_ERROR_RSP 				= 0x2011,    -- 登录失败返回
	EXIT_ROOM_REQ 						= 0x1002, 	-- 退出房间
	EXIT_ROOM_RSP 						= 0x1008, 	-- 退出房间返回
	BROADCAST_EXIT 						= 0x6002, 	-- 广播用户登出
	SITDOWN_IN_GAME_REQ 				= 0x1013,   -- 请求坐下
	SITDOWN_IN_GAME_RSP 				= 0x2003,   -- 坐下返回
	BROADCAST_SITDOWN   				= 0x6003,   -- 广播坐下
	STANDUP_REQ 						= 0x1004,   -- 请求站起
	STANDUP_RSP 						= 0x2004,   -- 站起返回
	BROADCAST_STANDUP   				= 0x6004,   -- 广播站起
	SEND_FACE							= 0x1014,	-- 发送表情
	SEND_CHAT							= 0x1003,	-- 发送聊天(收和发都是他)
	SEND_PROP_RSP              			= 0x7854,   -- 响应发送道具
	BROADCAST_BANKER_OFFLINE            = 0x1060,   -- server广播庄家处于离线状态
	ENTER_ROOM_REQ 						= 0x0117,    --用户请求进入房间
}
