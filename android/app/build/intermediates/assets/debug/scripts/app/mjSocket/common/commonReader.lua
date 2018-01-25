--[[
	通用的（大厅）接收协议  2015-03-03
]]
local CommonReader = class(SocketReader)
local printInfo, printError = overridePrint("CommonReader")

function CommonReader:ctor()
	self.m_sockName = "通用"
end

function CommonReader:onLoginLobbyServerRsp(packetId)
	printInfo('CommonReader:onLoginLobbyServerRsp');
	local data = {};
	data.isInTable = self.m_socket:readByte(packetId, -1)
	printInfo("data.isInTable"..data.isInTable);
	if data.isInTable > 0 then
		local roomInfo = {}
		roomInfo.gameID 	= self.m_socket:readShort(packetId, -1);
		roomInfo.gameSerID	= self.m_socket:readInt(packetId, -1);
		roomInfo.tid		= self.m_socket:readInt(packetId, -1);
		roomInfo.serverLvl	= self.m_socket:readShort(packetId, -1);
		data.roomInfo = roomInfo;
	end
	data.isInMatch = self.m_socket:readByte(packetId, -1);
	printInfo("data.isInMatch"..data.isInMatch);
	if data.isInMatch > 0 then
		local matchInfo = {}
		matchInfo.gameID 		= self.m_socket:readShort(packetId, -1);
		matchInfo.matchID 		= self.m_socket:readShort(packetId, -1);
		matchInfo.matchSerID 	= self.m_socket:readShort(packetId, -1);

		data.matchInfo = matchInfo;
	end
	return data
end

function CommonReader:onBroadcastRsp(packetId)
	printInfo("onBroadcastRsp")
	local info = {};
	info.type = self.m_socket:readShort(packetId, -1)
	if info.type == 1 then  --刷新金币数量
		info.data = json.decode(self.m_socket:readString(packetId) or "") 
	elseif info.type == 2 or info.type == 3 then
		info.data = json.decode(base64.decode(self.m_socket:readString(packetId) or "")) 
    elseif info.type == 6 then  --通过好友请求
        info.data = self.m_socket:readString(packetId) or ""
    elseif info.type == 7 then	--活动加减金币
        info.data = json.decode(self.m_socket:readString(packetId) or "")
    elseif info.type == 8 then  --活动加减道具数量
        info.data = json.decode(self.m_socket:readString(packetId) or "")
    elseif info.type == 9 then      --邀请好友加入好友房
        info.data = json.decode(self.m_socket:readString(packetId) or "")
    elseif info.type == 10 then     --礼物赠送的推送通知
        info.data = json.decode(self.m_socket:readString(packetId) or "")
    elseif info.type == 15 then
        info.data = json.decode(self.m_socket:readString(packetId) or "")
    elseif info.type == 17 then
        info.data = json.decode(self.m_socket:readString(packetId) or "")
	end
	return info;
end

function CommonReader:onEntireBroadcastRsp(packetId)
    local info = {}
    info.data = json.decode(self.m_socket:readString(packetId) or "")
    return info;
end

function CommonReader:onServerRetire(packetId)
	local data = {};
	return data;
end

--[[
	通用的（大厅）接收协议
]]
CommonReader.s_severCmdFunMap = {
	-- 大厅业务命令字
	[Command.LOGIN_SERVER_RSP]		= CommonReader.onLoginLobbyServerRsp, --大厅登录返回
	[Command.BROADCAST_RSP] 		= CommonReader.onBroadcastRsp,
    [Command.ENTIRE_BROADCAST_RSP]  = CommonReader.onEntireBroadcastRsp,
	[Command.SERVER_RETIRE] 		= CommonReader.onServerRetire,--服务器退休协议
}
return CommonReader
