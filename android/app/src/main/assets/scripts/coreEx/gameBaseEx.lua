HttpManager.execute = function(self,command,data, continueLast)
	if not HttpManager.checkCommand(self,command) then
		return false;
	end
	if not continueLast then
		HttpManager.destroyHttpRequest(self,self.m_commandHttpMap[command]);
	end

	local config 	= self.m_configMap[command];
	local httpType 	= config[HttpConfigContants.TYPE] or kHttpPost;

	local url = self.m_urlOrganizer(config[HttpConfigContants.URL],
									config[HttpConfigContants.METHOD],
									httpType)

	local httpRequest = new(Http,httpType,kHttpReserved,url)
	httpRequest:setTimeout(self.m_timeout, self.m_timeout)
	httpRequest:setEvent(self, self.onResponse)

	if httpType == kHttpPost then 
		local postData = self.m_postDataOrganizer(config[HttpConfigContants.METHOD], data);
		httpRequest:setData(postData)
	end

    self.m_httpCommandMap[httpRequest] = command
    self.m_commandHttpMap[command] = httpRequest

    -- 如果是多次请求不覆盖 则只生成一个超时计时器就可以了 避免报错
    if not continueLast or not self.m_commandTimeoutAnimMap[command] then
		local timeoutAnim = HttpManager.createTimeoutAnim(self,command,config[HttpConfigContants.TIMEOUT] or self.m_timeout);
   		self.m_commandTimeoutAnimMap[command] = timeoutAnim
	end

	httpRequest:execute()
	return true
end

HttpManager.onResponse = function(self , httpRequest)
	local command = self.m_httpCommandMap[httpRequest]

	if not command then
		HttpManager.destroyHttpRequest(self,httpRequest)
		return;
	end

	HttpManager.destoryTimeoutAnim(self,command)
 
 	local errorCode = HttpErrorType.SUCCESSED
 	local data = nil
   	local resultStr
	repeat 
		-- 判断http请求的错误码,0--成功 ，非0--失败.
		-- 判断http请求的状态 , 200--成功 ，非200--失败.
		if 0 ~= httpRequest:getError() or 200 ~= httpRequest:getResponseCode() then
			errorCode = HttpErrorType.NETWORKERROR
			break
		end
	
		-- http 请求返回值
		resultStr =  httpRequest:getResponse()
		-- http 请求返回值的json 格式
		data = json.decode(resultStr); -- json.decode_node
	until true

    EventDispatcher.getInstance():dispatch(HttpManager.s_event,command,errorCode, data, resultStr)
	
	HttpManager.destroyHttpRequest(self,httpRequest)
end

-- 根据域名直接请求
HttpManager.executeDirect = function(self, command, domain, data)
	if not HttpManager.checkCommand(self,command) then
		return false;
	end

	HttpManager.destroyHttpRequest(self,self.m_commandHttpMap[command]);

	local config = self.m_configMap[command];
	local httpType = config[HttpConfigContants.TYPE] or kHttpPost;

	print_string("-------------------------------------------------------------------------------------------------")
	print_string("发起php请求: " .. domain);
	
	local httpRequest = new(Http,httpType,kHttpReserved,domain)
	httpRequest:setTimeout(self.m_timeout, self.m_timeout);
	httpRequest:setEvent(self, self.onResponse);

	if httpType == kHttpPost then 
		local postData =  self.m_postDataOrganizer(config[HttpConfigContants.METHOD],data);
		httpRequest:setData(postData);
	end

	local timeoutAnim = HttpManager.createTimeoutAnim(self,command,config[HttpConfigContants.TIMEOUT] or self.m_timeout);

    self.m_httpCommandMap[httpRequest] = command;
    self.m_commandHttpMap[command] = httpRequest;
    self.m_commandTimeoutAnimMap[command] = timeoutAnim;

	httpRequest:execute();
	print_string("-------------------------------------------------------------------------------------------------\n")
end

--GameSocket
GameSocket.onSocketConnected = function(self)
	self.m_isSocketOpen = true;
	-- 心跳包改为进入房间后才发送
	-- GameSocket.startHeartBeat(self);
end

--SocketProcesser
SocketProcesser.onReceivePacket = function(self,cmd,packetInfo,gameid)
    if self.s_severCmdEventFuncMap[cmd] then
        local info = self.s_severCmdEventFuncMap[cmd](self, packetInfo or {}, gameid);
        EventDispatcher.getInstance():dispatch(Event.Socket, cmd, packetInfo)
        return info or {};
    end
    return nil;
end

--GameSound
GameSound.getPath = function(self, index)
	if not index then return end
	local path = self.m_prefix .. index .. self.m_extName;
	return path;
end


do --BaseScane
	local M = class(GameScene)
	function M:ctor(viewConfig, state, ...)
		GameScene.ctor(self)
		EventDispatcher.getInstance():register(Event.Message, self, self.onMessageCallDone)
		EventDispatcher.getInstance():register(Event.Socket, self, self.onSocketReceive)
		EventDispatcher.getInstance():register(Event.Back,self,self.onBack);
		
	end

	-- 切换界面完成后 处理业务
	function M:dealBundleData(bundleData)
	end

	function M:resume(bundleData)
		GameScene.resume(self)
		if WindowManager then
			printInfo("basescene resume")
			WindowManager:dealWithStateChange()
		end
	end

	function M:pause()
		GameScene.pause(self)
		-- EventDispatcher.getInstance():unregister(Event.Message, self, self.onMessageCallDone)
		-- EventDispatcher.getInstance():unregister(Event.Socket, self, self.onSocketReceive)
	end

	function M:dtor()
		GameScene.dtor(self)
		printInfo("M:dtor")
		EventDispatcher.getInstance():unregister(Event.Message, self, self.onMessageCallDone);
		EventDispatcher.getInstance():unregister(Event.Socket, self, self.onSocketReceive);
		EventDispatcher.getInstance():unregister(Event.Back,self,self.onBack);
	end

	function M:onBack()

	end

	M.messageFunMap = {
	}

	M.commandFunMap = {
	}

	function M:onMessageCallDone(param, ...)
		if self.messageFunMap[param] then
			self.messageFunMap[param](self,...)
		end
	end

	function M:onSocketReceive(param, ...)
		if self.commandFunMap[param] then
			self.commandFunMap[param](self,...)
		end
	end

	BaseState = GameState
	BaseLayer = GameLayer
	BaseController = GameController
	BaseScene = M

	package.preload[ "base.basegame" ] = function( ... )
	    local Game = class()
	    addProperty(Game, "roomList", nil)
		addProperty(Game, "update", false)
		addProperty(Game, "name", '')
		addProperty(Game, "iconFile", "")

		function Game:ctor(roomList)
			-- body
		end

		function Game:initRoom(roomList)
			-- body
		end

		function Game:getRoomFromLevel(level)
			-- body
			repeat
				local roomList = self:getRoomList()
				if not roomList then break end
				for i = 1, roomList:count() do
					local room = roomList:get(i);
					if level == room:getLevel() then
						return room;
					end
				end
			until true
		end

		function Game:getRoomFromMoney(money)
			-- body
			repeat
				local roomList = self:getRoomList()
				if not roomList then break end
				for i = 1, roomList:count() do
					local room = roomList:get(i);
					if money <= room:getLimit()then return room end
					--默认最后一条
					if i == roomList:count() then return room end
		 		end
			until true

		end
		--[[
			进入游戏房间
		]]
		function Game:enterRoom(from, room)
			-- body
			return false
		end
		--[[
			进入游戏大厅
		]]
		function Game:enterLobby()
			-- body
			return false
		end


		function Game:dtor()
			-- body
		end

		return Game
	end

end

GameState.resume = function(self,bundleData)
	State.resume(self,bundleData);
    EventDispatcher.getInstance():register(Event.Back,self,self.onBack);
    
	local controller = self:getController();
	if typeof(controller,GameController) then
		controller:resume(bundleData);
	end
end

GameController.resume = function(self,bundleData)
	if not self.m_view then
		return;
	end

	self.m_view:resume(bundleData);
end