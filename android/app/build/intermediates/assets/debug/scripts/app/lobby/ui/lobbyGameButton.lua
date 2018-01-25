local lobbyGameLayout = requireview("app.view.view.lobbyGameLayout")
local lobbyGameLayout2 = requireview("app.view.view.lobbyGameLayout2")
local LobbyGameButton = class(Button, false);

function LobbyGameButton:ctor(gameId, btnType)
	super(self, 'ui/blank.png');

	local layout = nil
	if btnType == "big" then 
		layout = SceneLoader.load(lobbyGameLayout)
	elseif btnType == "small" then 		
	else
		layout = SceneLoader.load(lobbyGameLayout2)
	end
	self:addChild(layout);
	self:setSize(layout:getSize());
	self.mLobbyGame = app:getGameStatus(gameId)

	local iconMap = nil
	local iconMap_b = {'lobby/' .. string.format('%s_icon_b.png', gameId), 'lobby/' .. string.format('%s_name_b.png', gameId)}
	local iconMap_m = {'lobby/' .. string.format('%s_icon_s.png', gameId), 'lobby/' .. string.format('%s_name_s.png', gameId)}
	if btnType == "big" then 
		iconMap = iconMap_b
	elseif btnType == "small" then 
	else
		iconMap = iconMap_m
		local itemBtn = self:findChildByName("itemBtn")
		if btnType == "mid1" then
			itemBtn:setFile("lobby/hall_game_item_bg1.png")
		elseif btnType == "mid2" then 
			itemBtn:setFile("lobby/hall_game_item_bg2.png")
		else
			itemBtn:setFile("lobby/hall_game_item_bg3.png")
		end
	end

	--绑定UI ID
	UIEx.bind(self, self.mLobbyGame, "id", function(gameId)
		if gameId == 0 then
			self.mLobbyGame:setStatus(0)
			return
		end
		--下载图片暂时屏蔽，后续补充
		-- local path = 'lobby/'
		-- local name = string.format('%s_%s.png', gameId, isBig and "b" or "s")
		-- --如果游戏ICON不存在
		-- if NativeEvent.getInstance():isFileExist(name, path) ~= 1 then
		-- 	--设置游戏未开放
		-- 	self.mLobbyGame:setStatus(0)
		-- 	-- 开始下载图片
		-- 	MyUpdate:downloadImage(app:getGameIconUrl(gameId), path, name, function(status, folder, name)
		-- 		--下载成功
		-- 		if status == 1 and NativeEvent.getInstance():isFileExist(name, path) == 1 then
		-- 			if app:isGameInstalled(gameId) then
		-- 				self.mLobbyGame:setStatus(2)
		-- 			else
		-- 				self.mLobbyGame:setStatus(1)
		-- 			end
		-- 		end
		-- 	end)
		-- else
			if app:isGameInstalled(gameId) then --游戏已安装				
				self.mLobbyGame:setStatus(2)
			else --游戏未下载
				self.mLobbyGame:setStatus(1)
			end
		--end
	end)

	local imgHasDownload = self:findChildByName("img_hasDownload")
	local gameBg = self:findChildByName("icon")
	gameBg:setFile(iconMap[1] or "")
	local imgGameName = self:findChildByName("name")
	imgGameName:setFile(iconMap[2] or "")

	UIEx.bind(self, self.mLobbyGame, "status", function(status)
		--游戏安装状态 0 图标未下载 1 游戏未下载 2 游戏已安装
		local gameId = self.mLobbyGame:getId()
		if status == 0 then
			-- gameBg:setFile(lobby_map['lobby.0.png']); --默认图标
			-- self.mLobbyGame:setChoose(false)
			-- imgHasDownload:setVisible(false)
			-- gameBg:setPos(20, 10)
		elseif status == 1 then
			gameBg:setFile(iconMap[1])
			imgHasDownload:setVisible(true)
			self.mLobbyGame:setChoose(false)
		elseif status == 2 then
			gameBg:setFile(iconMap[1])
			self.mLobbyGame:setChoose(true)
			imgHasDownload:setVisible(false)
		end
	end)

	local btnChoose = self:findChildByName("btn_chooseroom")
	UIEx.bind(
		self,
		self.mLobbyGame,
		"choose",
		function(choose)
			--博定现金币场不显示
			if gameId > 1499 or gameId == tonumber(GAME_ID.PokdengCash)  or gameId == tonumber(GAME_ID.PokdengBanker) then
				btnChoose:setVisible(false)
			else
				btnChoose:setVisible(choose)
			end
		end
	)
	self.mLobbyGame:setChoose(self.mLobbyGame:getChoose())
	local imgBoyaa = self:findChildByName("img_boyaa")
	if gameId > 1499 and imgBoyaa then
		imgBoyaa:setVisible(true)
	end

	local circleProgress = new(require("uiEx.circleProgress"), "ui/download_progress.png")
	circleProgress:setAlign(kAlignCenter)
	local viewProgress = self:findChildByName("view_progress")
	circleProgress:setSize(viewProgress:getSize())
	viewProgress:addChild(circleProgress)
	local textProgress = viewProgress:findChildByName("text_progress")
	-- local textGameName = self:findChildByName("text_gameName")

	UIEx.bind(self, self.mLobbyGame, "progress", function(progress)
		--progress变更表示在解压或者下载中，此时需要显示提示文字，如果是自动下载的就不提示
		if progress < 100 then
			if progress <= 0 then
				imgHasDownload:setVisible(true)
				viewProgress:setVisible(false)
			else
				imgHasDownload:setVisible(false)
				viewProgress:setVisible(true)
			end
			circleProgress:setProgressPecent(progress / 100)
			textProgress:setText(progress.."%")
			self.mLobbyGame:setChoose(false)
			--下载结束，提示消失
		else
			viewProgress:setVisible(false)
			imgHasDownload:setVisible(false)
			self.mLobbyGame:setChoose(true)
		end
	end)

	
	self.mLobbyGame:setId(gameId)
	self:findChildByName("btn_chooseroom"):setOnClick(self, function ( self )
		if MyGameVerManager:updateGameFromNet(gameId) then
			if self.mOnChooseFunc then
				self.mOnChooseFunc(self.mOnChooseObj)
			end
		end
	end)

	self:findChildByName("itemBtn"):setOnClick(self, function (self)
		if MyGameVerManager:updateGameFromNet(gameId) then
			if self.mOnClickFunc then
				self.mOnClickFunc(self.mOnClickObj)
			end
		end
	end)

	-- local gameList = MyUserData:getGameList() or {}
	-- local gameType = gameList[tostring(gameId)] or {}
	-- if not isBig and gameType.new == 1 then
	-- 	self:findChildByName("img_new"):setVisible(true)
	-- end

end

function LobbyGameButton:setOnClickButton(obj, func)
	-- body
	self.mOnClickObj = obj;
	self.mOnClickFunc= func;
end

function LobbyGameButton:setOnChooseRoom(obj, func)
	-- body
	self.mOnChooseObj = obj;
	self.mOnChooseFunc= func;
end

function LobbyGameButton:dtor()
	local shiningImg = self:findChildByName("img_buttonShining");
	if shiningImg then checkAndRemoveOneProp(shiningImg,1) end;
end

function LobbyGameButton:getGameId()
	return self.mLobbyGame:getId()
end


return LobbyGameButton
