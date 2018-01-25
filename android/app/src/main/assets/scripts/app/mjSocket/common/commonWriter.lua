--[[
	通用的（大厅）发送协议  2015-03-03
]]
local CommonWriter = class(SocketWriter)
local printInfo, printError = overridePrint("CommonWriter")


function CommonWriter:onSendHeadBeat(packetId, data)
	printInfo("发送心跳包")
end

function CommonWriter:onSendPHPRequest(packetId, param)
	local cmd 	= param.cmd
	local data 	= PhpManager:getBasic(cmd)
	local compress = 1
	-- 如果是登录请求 则不压缩
	if cmd == Command.LOGIN_PHP_REQUEST then
		compress = 1
	end
	PhpManager:mergeApiParams(data.api, param)
	printInfo("========[[ 发送PHP命令 0x%04x 是否压缩 %d ]] ============================", cmd or 0, compress or 0)
	dump(data)
	printInfo("发送php请求 %s", json.encode(data))
	self.m_socket:writeInt(packetId, cmd)
	self.m_socket:writeBinary(packetId, json.encode(data), compress)
end

function CommonWriter:onRequestLoginLobby(packetId, param)
	param = param or {
		iUserId 		= MyUserData:getId(),
		iUserStatus 	= 0,
		iOriginAPI 		= PhpManager:getApi(),
		iVersionName 	= PhpManager:getVersionName(),
		iUserName		= MyUserData:getNick(),
	}
	self.m_socket:writeInt(packetId, param.iUserId);
    self.m_socket:writeShort(packetId, param.iUserStatus);
    self.m_socket:writeInt(packetId, param.iOriginAPI);
    self.m_socket:writeString(packetId, param.iVersionName);
    self.m_socket:writeString(packetId, param.iUserName);
end

function CommonWriter:onRequestLoginServerReq(packetId, param)
	printInfo("onRequestLoginTest"..MyUserData:getId());
	self.m_socket:writeInt(packetId, MyUserData:getId()); 			-- 用户ID
	self.m_socket:writeShort(packetId, tonumber(PhpManager:getGame()));  		-- 终端类型
	self.m_socket:writeInt(packetId, PhpManager:getVersionCode() or 0);	-- 版本
	self.m_socket:writeString(packetId, PhpManager:getDevice_id()); -- 设备唯一码
end


--登出大厅  0x102
function CommonWriter:onLogoutLobbyReq(packetId, param)

end

function CommonWriter:onJoinRoomReq(packetId, param)
	dump("进入房间请求")
	dump(param)
 	self.m_socket:writeInt(packetId,  param.iGameType);
	self.m_socket:writeInt(packetId,  param.iMoney);
  	self.m_socket:writeInt(packetId,  7);
  	-- 整合以前登录房间需要的信息  
  	self.m_socket:writeShort(packetId,  3);
  	self.m_socket:writeString(packetId,  param.iUserInfoJson);
  	self.m_socket:writeString(packetId,  param.iMtKey);
  	self.m_socket:writeInt(packetId,  param.iOriginAPI);
  	self.m_socket:writeInt(packetId,  param.iVersion);
  	self.m_socket:writeString(packetId,  param.iVersionName);
  	self.m_socket:writeShort(packetId, param.iChangeDesk);
  	self.m_socket:writeShort(packetId, param.iQuickStart or 0);
end

function CommonWriter:onChangeDeskReq(packetId, param)
	self.m_socket:writeInt(packetId, param.iChangeType or 0)
	self.m_socket:writeInt(packetId, param.iQuickStart or 1)
end

function CommonWriter:onLobbyOnlineReq(packetId, param)

end

-- 请求准备
function CommonWriter:onRequestReady(packetId)
	-- 空包
end

function CommonWriter:onSendChat(packetId, param)
	self.m_socket:writeString(packetId, param.iChatInfo)
end

function CommonWriter:onSendFace(packetId, param)
	self.m_socket:writeInt(packetId, param.iFaceType)
end

function CommonWriter:onSendProp(packetId, param)
	self.m_socket:writeInt(packetId, param.a_uid);
	self.m_socket:writeInt(packetId, param.p_id);
	self.m_socket:writeInt(packetId, 1);
	self.m_socket:writeInt(packetId, param.b_uid);
end

function CommonWriter:onLogoutRoomReq(packetId, param)
	-- 空包
end

function CommonWriter:onRequestOutCard(packetId, param)
	dump(param, "出牌=============")
	self.m_socket:writeByte(packetId, param.iCard)
	self.m_socket:writeShort(packetId, param.iIsTing)
end

function CommonWriter:onRequestOperate(packetId, param)
	self.m_socket:writeInt(packetId, param.iOpValue)
	self.m_socket:writeByte(packetId, param.iCard)
end

function CommonWriter:onRequestAi(packetId, param)
	self.m_socket:writeInt(packetId, param.iAiType)
end

function CommonWriter:onSwapCardReq(packetId, cards)
	self.m_socket:writeByte(packetId, #cards)
	for i=1, #cards do
		self.m_socket:writeByte(packetId, cards[i])
	end
end

function CommonWriter:onFreshMoneyReq(packetId, params)
	self.m_socket:writeInt(packetId, 1)
	self.m_socket:writeShort(packetId, 0x0001)
	self.m_socket:writeInt(packetId, params.iUserId)
end

function CommonWriter:onNoticeMoneyChangeReq(packetId, params)
	self.m_socket:writeInt(packetId, params.iUserId)
end

--[[
	通用的（大厅）发送协议
]]
CommonWriter.s_clientCmdFunMap = {
	[Command.HeatBeatReq]		= CommonWriter.onSendHeadBeat,
	-- [Command.PHP_CMD_REQUEST]	= CommonWriter.onSendPHPRequest,
	-- 大厅相关
	[Command.LOGIN_SERVER_REQ]	= CommonWriter.onRequestLoginServerReq,
	-- [Command.LoginLobbyReq]		= CommonWriter.onRequestLoginLobby,
	-- [Command.LogoutLobbyReq]	= CommonWriter.onLogoutLobbyReq,
	-- [Command.LobbyOnlineReq]	= CommonWriter.onLobbyOnlineReq,
	-- -- 新版 加入房间 0x119  返回 0x1007 和 0x1005
	-- [Command.JoinGameReq]   	= CommonWriter.onJoinRoomReq;
	-- [Command.ChangeDeskReq]   	= CommonWriter.onChangeDeskReq;
	-- -- 房间相关
	-- [Command.ReadyReq]   		= CommonWriter.onRequestReady;
	-- [Command.SendChat]          = CommonWriter.onSendChat,
	-- [Command.SendFace]          = CommonWriter.onSendFace,
	-- [Command.SendProp]          = CommonWriter.onSendProp,

	-- [Command.LogoutRoomReq]		= CommonWriter.onLogoutRoomReq,
	-- [Command.RequestOutCard]	= CommonWriter.onRequestOutCard,
	-- [Command.RequestOperate]	= CommonWriter.onRequestOperate,
	-- [Command.RequestAi]			= CommonWriter.onRequestAi,

	-- -- 换三张
	-- [Command.SwapCardReq]		= CommonWriter.onSwapCardReq,

	-- -- 请求更新金币
	-- [Command.FreshMoneyReq]		= CommonWriter.onFreshMoneyReq,

	-- -- 通知server金币变动
	-- [Command.NoticeMoneyChangeReq] = CommonWriter.onNoticeMoneyChangeReq,
}

return CommonWriter