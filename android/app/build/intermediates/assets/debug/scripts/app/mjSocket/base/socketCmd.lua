module("Command")
--SOCKET EVENT
SOCKET_EVENT_CONNECTED 		= 0x30000; --socket连接成功
SOCKET_EVENT_CONNECT_FAILD	= 0x30001; --socket连接失败
SOCKET_EVENT_CLOSE 			= 0x30002; --sokcet关闭
SOCKET_EVENT_TIMEOUT		= 0x30003; --sokcet超时
SOCKET_EVENT_SEND_ERROR		= 0x30004; --sokcet超时

-----------------大厅 交互命令---------------------
HeatBeatReq = 0x2008		--发送心跳包
HeatBeatRsp	= 0x600D		--心跳包返回

--SERVER协议
LOGIN_SERVER_REQ 			= 0x116;
LOGIN_SERVER_RSP 			= 0x202;

--定向广播
BROADCAST_RSP 				= 0x7052;
--全网广播
ENTIRE_BROADCAST_RSP        = 0x7852;

-----------------游戏 公用命令---------------------
SERVER_RETIRE				= 0x9001;--服务器退休协议

