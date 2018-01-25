require("app.mjSocket/base/socketTip")
require("gameBase/gameSocket")
require("app.mjSocket/base/socketConfig")

local CommonProcesser 		= require("app.mjSocket.common.commonProcesser")
local CommonPhpProcesser	= require("app.mjSocket.common.commonPhpProcesser")
local CommonReader 			= require("app.mjSocket.common.commonReader")
local CommonWriter 			= require("app.mjSocket.common.commonWriter")

--[[
	主要用来管理 套接字的状态
	分发命令字
]]
local SocketMgr = class(GameSocket);
local printInfo, printError = overridePrint("SocketMgr")

-------------------------------------------------------------------------------
-- private
-------------------------------------------------------------------------------
function SocketMgr:ctor(sockName, sockHeader, netEndian)
	self:initSocketTools();
	self:setHeartBeatCmd(Command.HeatBeatReq);
    self.m_maxReconnectTime = 5;--最大重连次数
    self.m_reconnTime 		= 0;--当前重连次数
    self.reconnDelay		= 3000;--尝试重连间隔
    self.autoConnectTimer 	= nil;--自动重连定时器
    --如果断线，点击会触发重连
    -- EventDispatcher.getInstance():register(Event.RawTouch, self, function (self,finger_action,x,y,drawing_id)
    -- 	self:tryReconnect() 
    -- end);
    EventDispatcher.getInstance():register(Event.RawTouch, self, self.onTouchEvent);

end

function SocketMgr:dtor()
	self:deleteReconnectTimer();
	EventDispatcher.getInstance():unregister(Event.RawTouch, self, self.onTouchEvent);
	self:removeCommonSocketReader(self.m_reader)
	self:removeCommonSocketWriter(self.m_writer)
	self:removeCommonSocketProcesser(self.m_processer)
	self:removeCommonSocketProcesser(self.m_phpProcesser)

	delete(self.m_reader);
    self.m_reader = nil;
	delete(self.m_writer);
    self.m_writer = nil;
	delete(self.m_processer);
    self.m_processer = nil;
    delete(self.m_phpProcesser);
    self.m_phpProcesser = nil;
end

function SocketMgr:initSocketTools()
	self.m_reader = new(CommonReader)
	self.m_writer = new(CommonWriter)
	self.m_processer = new(CommonProcesser)
	self.m_phpProcesser = new(CommonPhpProcesser)

	printInfo("添加通用socket工具")
    self:addCommonSocketReader(self.m_reader);
    self:addCommonSocketWriter(self.m_writer);
    self:addCommonSocketProcesser(self.m_processer);
    self:addCommonSocketProcesser(self.m_phpProcesser);
end

function SocketMgr:isSocketOpening()
	return self.m_isSocketOpening;
end

function SocketMgr:createSocket(sockName, sockHeader, netEndian)
	return new(Socket, sockName, sockHeader, netEndian)
end

function SocketMgr:getSocket()
	return self.m_socket;
end	

function SocketMgr:openSocket()
	--open socket
	local addrList = HallConfig:getAddrList();
	for i = 1, #addrList do
		local addr = addrList[i];
		if addr and addr.ip and addr.port then
			printInfo("ip = %s, port = %s", addr.ip, addr.port)
			if ToolKit.isValidString(addr.ip) and tonumber(addr.port) then
				self.m_isSocketOpening = true;
				GameSocket.openSocket(self, addr.ip, addr.port);
				break;
			end
		end
	end
end

function SocketMgr:isSocketClosed()
	return not self:isSocketOpen() and not self:isSocketOpening()
end
--关闭socket
function SocketMgr:closeSocketSync()
	GameSocket.closeSocketSync(self);
	self.m_isSocketOpening = false;
end

function SocketMgr:sendMsg(cmd, info, anim)
	--send

	if self:isSocketOpen() then
		local mode = 1
		if cmd==0x116 then
			mode = 2
		end
		writeTabToLog({info=info,cmd=string.format("0x%02x",cmd)}, "发送Scoket请求","debug_socket.lua",mode)
		GameSocket.sendMsg(self, cmd, info)
		return ;
	end
	app:onSocketSendError()	
end

function SocketMgr:writeBegin(socket, cmd)
	return socket:writeBegin3(cmd, kProtocalVersion, 
							kProtocalSubversion, kDeviceTypeANDROID);
	
end

function SocketMgr:writePacket(socket, packetId, cmd, info)
	-- php cmd
	return GameSocket.writePacket(self,socket, packetId, cmd, info);
end

function SocketMgr:onTimeout()
	printInfo("Socket Status onTimeout")
	GameSocket.onTimeout(self);
	app:onSocketTimeOut();
	EventDispatcher.getInstance():dispatch(Event.ConnectTimeout);
	--重连
	self:tryReconnect()
end 

-------------------------------------------------------------------------------
-- private
-- Method: onSocketConnected
-- Action: 当程序打开Socket的时候，如果连接成功会触发该回调函数，此时请求登
-- 陆服务器
function SocketMgr:onSocketEvent(eventType, param)
	-- JLog.d("======Ouyang",'SocketMgr.onSocketEvent');
	GameSocket.onSocketEvent(self,eventType, param);
	if eventType == kSocketConnected or eventType == kSocketRecvPacket then
        self.m_reconnTime = 0;
        self:deleteReconnectTimer();
    elseif eventType == kSocketConnectFailed then
        self.m_reconnTime = self.m_reconnTime + 1;
        JLog.d("======Ouyang",'重连次数:'..self.m_reconnTime);
        if self.m_reconnTime <= self.m_maxReconnectTime then
        	self:autoTryReconnet();
        else--重连最大次数失败
        	self.m_reconnTime = 0;
        	self:deleteReconnectTimer();
        	local netAvaliable = NativeEvent.getInstance():GetNetAvaliable()
        	JLog.d("======Ouyang",'网络状态:'..netAvaliable);
   			if netAvaliable == 1 then --网络正常情况下,但连不上服务器      		
        		app:onSocketConnectError(1);
        	else --网络不正常
        		app:onSocketConnectError(0);
        	end
        end
    elseif eventType == kSocketUserClose then
    	self.m_reconnTime = 0;
    	self:autoTryReconnet();
	end
end

function SocketMgr:onSocketConnected()
	printInfo("Socket Status onSocketConnected")
	JLog.d("======Ouyang",'SocketMgr.onSocketConnected');
	GameSocket.onSocketConnected(self);
	self.m_isSocketOpening = false;
	app:onSocketConnected()
	self:deleteReconnectTimer();
end

function SocketMgr:onSocketReconnecting()
	printInfo("Socket Status onSocketReconnecting")
	JLog.d("======Ouyang",'SocketMgr.onSocketReconnecting');
	GameSocket.onSocketReconnecting(self);
	self.m_isSocketOpening = true;
end

function SocketMgr:onSocketConnectFailed()
	printInfo("Socket Status onSocketConnectFailed")
	JLog.d("======Ouyang",'SocketMgr.onSocketConnectFailed');
    GameSocket.onSocketConnectFailed(self)
    self.m_isSocketOpening = false;
    self:deleteReconnectTimer();
end

function SocketMgr:onSocketClosed()
	printInfo("Socket Status onSocketClosed %s", "大厅连接断开")
	JLog.d("======Ouyang",'SocketMgr.onSocketClosed');
    GameSocket.onSocketClosed(self)
    self.m_isSocketOpening = false;
    app:onSocketClosed();
    self:deleteReconnectTimer();
end

function SocketMgr:onTouchEvent(finger_action,x,y,drawing_id)
	if finger_action == kFingerDown then
		self:tryReconnect();
	end
end

function SocketMgr:tryReconnect()
	if System.getPlatform() ~= kPlatformAndroid and not self:isSocketOpen() and not self.reconnectTimer then
		printInfo("zyh create reconnect timer")
		--3秒执行一次，共35次重试，只要socket有任何响应就停止，
		self.repeatCount = 5
		self.reconnectTimer = new(AnimInt,kAnimRepeat,0,1, 3000,0);
		self.reconnectTimer:setEvent(nil, function()
			if self.repeatCount > 0 then
				printInfo("zyh close and reopen socket")
				self:closeSocketSync()
				self:openSocket()
				self.repeatCount = self.repeatCount - 1
				else
				self:deleteReconnectTimer()
			end
		end)
	end
	--打开socket	
	if self:isSocketClosed() then
		JLog.d("======Ouyang",'SocketMgr.tryReconnect');
		printInfo("tryReconnect true")
		self:closeSocketSync()
		self:openSocket()
		EventDispatcher.getInstance():dispatch(Event.Message, "onSocketReconnecting",nil)
	end
end

function SocketMgr:autoTryReconnet()
	-- AlarmTip.play(STR_NET_TRY_RECONNECT);--"您已掉线，现正在努力连接中，请稍候… "
	if self.autoConnectTimer then
		self:deleteReconnectTimer();
	end
	self.autoConnectTimer = new(AnimInt,kAnimRepeat,0,1,self.reconnDelay,0);
    self.autoConnectTimer:setEvent(self, self.tryReconnect);
end

function SocketMgr:deleteReconnectTimer()
	if self.autoConnectTimer then
        delete(self.autoConnectTimer)
        self.autoConnectTimer = nil
    end
    if self.reconnectTimer then
        self.repeatCount = 0
        delete(self.reconnectTimer)
        self.reconnectTimer = nil
    end
end

return SocketMgr