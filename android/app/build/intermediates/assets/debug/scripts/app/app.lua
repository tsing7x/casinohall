
require("app.manager.windowManager")

local App = class()

function App:run()
	app = self
	StateMachine.getInstance():changeState(States.Load)
end

function App:ctor()
	-- body
	NativeEvent.getInstance():boyaaAd({type = kADStart or 1, value = 'start'})
	self.mGames = {}
	self.mGameStatus = {}
	self.mGameLatestVersion = {}
	self.reLoginServerData = nil;
end

function App:dtor()
	-- body
	self.mGames = nil
	self.reLoginServerData = nil;
end


function App:setReLoginingGame(roomData)
	self.reLoginServerData = roomData;
	if not roomData then return end
	local game = self:getGame(roomData.gameID);
	if game then
		local gameList = game:getRoomList();
        if gameList and gameList:count() >0 then --如果已经有列表直接重连
    		if roomData.serverLvl == 100 and game.enterPrivateRoom then
                game:enterPrivateRoom(States.Lobby, kFalse, 0)
            else
                game:enterRoom()
            end
            self.reLoginServerData = nil;
        end
	end	
end

function App:onGetedRoomList(gameId)
	local roomData = self.reLoginServerData;
	if roomData then
		if gameId == roomData.gameID then
			self:setReLoginingGame(roomData);
			self.reLoginServerData = nil;
		end
	end
end


function App:isInRoom()
	return (kCurrentState~= States.Lobby and kCurrentState~= States.Load and kCurrentState~= States.Login)
end

function App:isInGame()
	return G_RoomCfg:getPlayStatus()==1
end

function App:checkResponseOk(isSuccess, data, avoidErrorTip)
	if isSuccess and data and data.code == 1 and data.data then
		return true
	end
end

-- 大厅连接成功
function App:onSocketConnected()
	-- LoginMethod:autoRequestLogin()
	--登录SERVER
	printInfo('Command.LOGIN_SERVER_REQ')
	GameSocketMgr:sendMsg(Command.LOGIN_SERVER_REQ, {});
	GameSocketMgr:startHeartBeat();
	self:hideLoadingTip();
	if self:isInRoom() then
		AlarmTip.play(STR_NET_RECONNECT_SUCCESS);--"连接成功，大象请您继续游戏!"
	end
end

function App:onSocketClosed()
	if self:isInRoom() then
		self:showLoadingTip(STR_NET_TRY_RECONNECT);
	end
end

function App:onSocketConnectError(code)
	self:hideLoadingTip();
	if code == 1 then
		AlarmTip.play(STR_NET_PLEASE_RELOGIN)--你的网络状况较差，请重新登录试试！建议在WIFI环境下游玩。
	elseif code == 0 then
		AlarmTip.play(STR_NET_NOT_AVAILABLE)--你的网络有问题，请检查网络是否正常
	end
end

function App:onSocketTimeOut()
	printInfo("App:onSocketTimeOut");
end

function App:onSocketSendError()
	printInfo("App:onSocketSendError");
end

function App:showLoadingTip(loadingStr,isShowBg)
	JLog.d("======Ouyang",'App:showLoadingTip');
	-- body
	if not self.toastShade then
		self.toastShade = new(ToastShade, true, loadingStr, false)
	end
	self.toastShade:setIsShowBg(isShowBg)
	if loadingStr then
		self.toastShade:setLoadingText(loadingStr);
	end
	self.toastShade:addToRoot();
    self.toastShade:play()
end

function App:hideLoadingTip()
	JLog.d("======Ouyang",'App:hideLoadingTip()');
	if self.toastShade then
		self.toastShade:stop()
	end
end



--是否加载房间列表
function App:checkAndDownloadRoomList(gameId, curVersion, showLoading)
	JLog.d("##########App:checkAndDownloadRoomList");
	-- if 1 then --新项目不需要房间列表
	-- 	return
	-- end
	printInfo('gameId ---------------------------------------------------------------- ' .. gameId)
	HttpModule.s_config[HttpModule.s_cmds.GET_ROOM_LIST][HttpConfigContants.URL] = tostring(gameId)
	printInfo("3::::")
	HttpModule.getInstance():execute(HttpModule.s_cmds.GET_ROOM_LIST, {}, showLoading, true);
	return false
end

function App:getRoomFromLevel(gameId, level)
	repeat
		local roomList = MyRoomConfig:get(gameId)
		if not roomList then break end
		for i = 1, roomList:count() do
			local room = roomList:get(i);
			if level == room:getLevel() then
				return room;
			end
		end
	until true
end

--上报
function App:postFrontStaticstics(event)
	-- body
	HttpModule.getInstance():execute(HttpModule.s_cmds.FRONTSTATISTICS, {reportData =  {{id= event}}}, false, true)
end

--获取游戏安装路径
function App:getGameInstallPath( gameId )
	-- body
	local games = HallConfig:getLobbyGames()
	for k, v in pairs(games) do
		if tonumber(v.gameid) == tonumber(gameId) then
			return v.path
		end
	end
    return ""
end
--获取游戏icon地址
function App:getGameIconUrl(gameId)
	-- body
	local games = HallConfig:getLobbyGames()
	for k, v in pairs(games) do
		if tonumber(v.gameid) == tonumber(gameId) then
			return v.icon
		end
	end
	return ''
end
--获取游戏更新码
--function App:getGameUpdateVerUrl(gameId)
--	-- body
--	local games = HallConfig:getLobbyGames()
--	for k, v in pairs(games) do
--		if tonumber(v.gameid) == tonumber(gameId) then
--			return v.updateVerUrl
--		end
--	end
--	return ''
--end
function App:getGameUpdateZipUrl(gameId)
	-- body
	local games = HallConfig:getLobbyGames()
	for k, v in pairs(games) do
		if tonumber(v.gameid) == tonumber(gameId) then
			return v.updateZipUrl
		end
	end
	return ''
end
--获取游戏列表
function App:getGameIds()
	-- body
	local gameids = {}
	local games = HallConfig:getLobbyGames()
	for i = 1, #games do
		table.insert(gameids, tonumber(games[i].gameid))
	end
	return gameids
end


--判断游戏是否已安装
function App:isGameInstalled(gameId)
	-- body
	repeat
		local path = App:getGameInstallPath(gameId)
		JLog.d("##########测试isGameInstalled path",path);
		if not path then break end
        local curPlatform = System.getPlatform()
		if curPlatform == kPlatformAndroid then
			JLog.d("##########测试isGameInstalled PhpManager:getFiles_path()",PhpManager:getFiles_path());
			local absPath = string.format('%s/scripts/app/games/%s/%s', PhpManager:getFiles_path(), path, 'version.lua')
			JLog.d("##########测试isGameInstalled absPath",absPath);
			if loadfile(absPath) then
				return true
			end
			local absPath = string.format('%s/update/scripts/app/games/%s/%s', PhpManager:getFiles_path(), path, 'version.lua')
			return nil ~= loadfile(absPath)
        elseif curPlatform == kPlatformIOS then
            local absPath = string.format('%s/scripts/app/games/%s/%s', PhpManager:getRes_path(), path, 'version.lua')
			if loadfile(absPath) then
				return true
			end
			local absPath = string.format('%s/update/scripts/app/games/%s/%s', PhpManager:getFiles_path(), path, 'version.lua')
			return nil ~= loadfile(absPath)
		end
        return true
	until true
	return false
end
--获取某个游戏
function App:getGame(gameId)
	local game = nil
	repeat
		game = self.mGames[tonumber(gameId)]
		if game then 
			local roomList = game:getRoomList()
			if roomList and not roomList:getInit() then
				game:initRoom(MyRoomConfig:get(gameId))
			end 
			break 
		end
		if app:isGameInstalled(gameId) then
			local path = app:getGameInstallPath(gameId)
			if not path or path == '' then break end
			-- if tonumber(gameId) == 1018 then path = "pokdeng.cashGame" end --测试代码
			JLog.d("##########测试App:getGame gameId",gameId,"path",path);
			JLog.d("##########测试App:game path",string.format('app.games.%s.%s', path, 'game'));
			game = new(require(string.format('app.games.%s.%s', path, 'game')), MyRoomConfig:get(gameId))
			-- game = new(require(string.format('%s.%s', path, 'game')), MyRoomConfig:get(gameId))
			self.mGames[tonumber(gameId)] = game
		end
	until true
	return game
end
--重新加载某个游戏
function App:reloadGame(gameId)
    if app:isGameInstalled(gameId) then
		local path = app:getGameInstallPath(gameId)
		if not path or string.len(path) <= 0 then 
            return 
        end
        local gamePath = string.format("app.games.%s.%s", path, "game")
        package.loaded[gamePath] = nil
		local game = new(require(string.format("app.games.%s.%s", path, "game")), MyRoomConfig:get(gameId))
		self.mGames[tonumber(gameId)] = game
	end
end
--获取某个游戏的状态
function App:getGameStatus(gameId)
	if not self.mGameStatus[gameId] then
		self.mGameStatus[gameId] = setProxy(new(require('app.data.lobbyGame')))
	end
	return self.mGameStatus[gameId]
end
--获取某个游戏的当前版本信息
function App:getGameCurVersion(gameId)
	--更新时的路径
	local path = string.format('%s/update/scripts/app/games/%s/version.lua', PhpManager:getFiles_path(), app:getGameInstallPath(gameId))
	JLog.d("**********Ouyang App:getGameCurVersion",path);
 	local chuck = loadfile(path)
 	if chuck then
 		return chuck() or 100
 	end
 	--安装APK时的路径
 	local path = string.format('%s/scripts/app/games/%s/version.lua', PhpManager:getFiles_path(), app:getGameInstallPath(gameId))
 	local chuck = loadfile(path)
 	if chuck then
 		return chuck() or 100
 	end

 	--IOS app .bundle 的资源路径
 	local path = string.format('%s/scripts/app/games/%s/version.lua', PhpManager:getRes_path(), app:getGameInstallPath(gameId))
 	local chuck = loadfile(path)
 	if chuck then
 		return chuck() or 100
 	end

 	return 100
end

--获取某个游戏的最低进入金币要求
function App:getGameMinChip(gameId)
	if gameId > 0 then
		local game = self:getGame(gameId)
		if game then 
	        local roomList = game:getRoomList()
	        if roomList then
	            local room = roomList:get(1);--找到最低级房间
	            if room then
	            	if gameId ~= 1004 then
	            		return room.minchip;
	            	elseif gameId == 1004 then
	            		return room:getAnte();
	            	end
	            end
	        end   
	    end
	end
    return nil;
end

--统计
function App:staticstics( eventStr )
	-- body
	HttpModule.getInstance():execute(HttpModule.s_cmds.UPDATE_GAME_EVENT, {eventName = eventStr}, false, false)
end

return App