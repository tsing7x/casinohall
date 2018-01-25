return {
	CREATE_PRIVATEROOM_REQ 				= 0x127, --用户请求创建私人房
	ENTER_PRIVATEROOM_ERQ 					= 0x0115,--用户请求进入私人房(输口令加入)
	RANDOM_ENTER_PRIVATEROOM_ERQ 			= 0x0117,--用户请求进入私人房(随机加入)

	ENTER_PRIVATEROOM_RSP = 0x0212,	--返回用户进入私人房间(创建房间返回也是这个)
	COMMAND_LOGIN_ERR_RSP = 0x1005, 	--进房登陆错误
}