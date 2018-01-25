--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local GameVersionManager = class()
--本地更新
MyUpdate    = MyUpdate  or  new(require("app.update.update"));
MyUnzip     = MyUnzip or new(require("app.update.zip"))

--local print_string = DEBUG_MODE and printInfo or print_string
local kUpdateNone = 1
local kUpdatePatch = 2
local kUpdateFull = 3
--内网：http://pkgserver.oa.com/Api/Client/testUpdateInfo
--外网测试：http://pkgserver.boyaagame.com/Api/Client/onlineUpdateInfoForTest
--外网：http://pkgserver.boyaagame.com/Api/Client/onlineUpdateInfo
local kUpdateVerUrlPrefix = LOCAL_NET and "http://pkgserver.boyaa.com/Api/Client/testUpdateInfo" or "https://pkgserver.boyaagame.com/Api/Client/onlineUpdateInfo"

-------------用来请求热更新链接的参数，在更新后台是唯一的区分标志，后面带上gameId就用于各个游戏的热更新
local kUpdatePrefix = "julang_casinohall_"
local kHallPrefix = "0_tpe"

function GameVersionManager:ctor()
	self.mGameUpdateInfo = {}
	--请求更新的http请求和游戏中所用到的不一样，不在同一个后台，单独处理
	self.m_httpCommandMap = {};
	self.m_commandTimeoutAnimMap = {};
	--游戏更新路径，以gameId为索引
	self.updatePath = {}
	--是否更新过本地磁盘文件
	self.isLoadGameOnDisk = false
	--记录本地文件中保存的zip包的MD5值，用来加载时校验
	self.mFileMD5 = self:getZipFileMD5()
	--维护一个全量更新的下载队列，保证同时只有一个游戏在下载,避免抢占带宽
	self.downloadQueue = {}
	--当前是否有全量下载任务
	self.isDownloading = false
end

function GameVersionManager:dtor()

end

--对外提供的5个接口
--从本地update目录下加载游戏
function GameVersionManager:loadGameOnDisk()
	JLog.d("************Ouyang GameVersionManager:loadGameOnDisk");
	print_string("zyh start GameVersionManager "..os.clock())
	if not self.isLoadGameOnDisk then
		self.isLoadGameOnDisk = true
		self:scanDisk()
		--返回false表示备份本地文件失败，防止意外不进行更新
		if self:loadGames() then
			--loadgame的时候本地文件扫描路径计算完毕，此时可以开始检查更新,在这之前由于版本会因为更新而变动
			self:downLoadGameVerCfg()
		end
	else
		--已经扫描过本地文件了，检查更新，保证每次登陆后都会检查游戏的更新
		self:downLoadGameVerCfg()
	end
end

--从更新后台下载游戏,返回true表示可以进入游戏，其他表示还不可以进入游戏
function GameVersionManager:updateGameFromNet(gameId)
	print_string("zyh GameVersionManager:updateGameFromNet ")
	local gameStatus = app:getGameStatus(gameId)
	if gameStatus:getStatus() == 0 then
		AlarmTip.play(STR_GAME_CLOSED);
		return
	end
	--正在解压中
	if gameStatus:getUnzipDiskFile() == 0 then
		AlarmTip.play(STR_LOAING)
		return false
	end

	return self:checkVersionAndDownload(gameId)

end

function GameVersionManager:checkAndUpdateAPK()
	self:checkAndUpdateHall()
	--检查apk包的更新
	--    local url = self:initUpdateUrl(kUpdatePrefix.."apk_tpe", PhpManager:getVersionCode(), 0, 0)
	--    printInfo("zyh checkAndUpdateAPK "..url)
	-- local url = "http://192.168.203.224/gamehall/game/hall/firstapi.php?demo=1&sid="..PhpManager:getGame()
	-- local url = "http://mvlpvnhall.boyaagame.com/androidvn/game/hall/firstapi.php?&sid="..PhpManager:getGame()

	-- local url = "http://pcvdhl01.boyaagame.com/androidvn/game/hall/firstapi.php?&sid="..PhpManager:getGame()
	-- print_string("checkAndUpdateAPK url is "..url)
	-- self:executeURL(url, "apk_vtn")
end

--更新后台获取大厅的版本更新信息
function GameVersionManager:checkAndUpdateHall()
	--apkVersion用来控制大厅的可以升级的最低版本，用我们自己大厅的版本做控制比apkVersion更为灵活。
	--假如当前的apkVersion比当前最高版本需要的apkVersion低，那么无法升级到最高版本，但是可以升到非最高版本的差量路径。
	local updateUrl = self:initUpdateUrl(kUpdatePrefix..kHallPrefix, require('version'), require('version'), 0)
	print_string("zyh checkAndUpdateHall "..updateUrl)
	self:executeURL(updateUrl, kHallPrefix)
end

--用于游戏退出时检查更新状态是否正常，不正常的时候恢复到更新前
function GameVersionManager:checkUpdateFinish()
	print_string("zyh GameVersionManager:checkUpdateFinish")
	local gameIds = app:getGameIds()
	for i = 1, #gameIds do
		if gameIds[i] > 0 then
			local gameStatus = app:getGameStatus(gameIds[i])
			--都检查完了，但是存在解压错误，恢复
			if gameStatus:getUpdateState() == 3 then
				print_string("zyh gameId[i] checkupdate is 3 存在解压错误 "..gameIds[i])
				NativeEvent.getInstance():updateGameFinish({result = 0})
				return
			end
		end
	end
	NativeEvent.getInstance():updateGameFinish({result = 1})
end

--更新后台获取当前版本的更新信息
function GameVersionManager:downLoadGameVerCfg()
	print_string("zyh GameVersionManager:downLoadGameVerCfg")
	local gameIds = app:getGameIds()
	JLog.d("*****************Ouyang GameVersionManager:downLoadGameVerCfg",gameIds);
	for i = 1, #gameIds do
		local gameId = gameIds[i]
		--没有本地更新路径，先进行热更新检查，有本地更新路径的，在解压结束后再进行检查
		if gameId > 0 and not self.updatePath[gameId] then
			self:checkGameVerCfg(gameId)
		end
	end
end

function GameVersionManager:setUpdateUrl(url)
	kUpdateVerUrlPrefix = url
end
------------private------------
--记录某个游戏的更新包信息
function GameVersionManager:setGameUpdateInfo(gameKey, info)
	self.mGameUpdateInfo[gameKey] = info
end

--获取某个游戏的更新包信息
function GameVersionManager:getGameUpdateInfo(gameKey)
	return self.mGameUpdateInfo[gameKey]
end

--获取本地压缩包及其MD5值
function GameVersionManager:getZipFileMD5()
	local dict = new(Dict, "zipMD5")
	dict:load()
	local str = dict:getString("data")
	local md5Table = {}
	for fileName, md5 in string.gmatch(str, "(update_%d+_%d+_%d+_%d+.zip)#(%x+)") do
		md5Table[fileName] = md5
	end
	return md5Table
end
--保存本地压缩包的MD5值
function GameVersionManager:saveZipFileMD5()
	local dict = new(Dict, "zipMD5")
	dict:load()
	local str = ""
	for k, v in pairs(self.mFileMD5) do
		str = str..tostring(k).."#"..tostring(v)..","
	end
	dict:setString("data", str)
	print_string("zyh saveZipFileMD5 "..str)
	dict:save()
end

function GameVersionManager:scanDisk()
	--解压本地保存的压缩包作为新游戏
	--扫描磁盘本地文件依次升级上去
	local strFiles = NativeEvent.getInstance():getAllUpdateFile() or ""
	--    local strFiles = "update_1007_100_150_150.zip,update_1004_100_104_180.zip,update_1004_100_104_100.zip,update_1004_150_152_125.zip,update_1004_152_155_125.zip,update_1005_130_131_110.zip,update_1004_152_155_150.zip,update_1005_130_132_125.zip,update_1005_131_133_125.zip,update_1005_132_134_125.zip,update_1005_133_138_125.zip,update_1005_136_137_135.zip,update_1007_130_131_115.zip,update_1006_100_150_150.zip,update_1002_100_150_150.zip,update_1003_100_150_150.zip,update_1004_100_152_130.zip,"
	local files = {}
	local gameIds = {}
	local hallVersion = require('version')      --获取当前大厅的版本，本地磁盘的更新包依赖版本必须比这个低的才能解压
	for fileName, gameId, beginVer, endVer, minVersion in string.gmatch(strFiles, "(update_(%d+)_(%d+)_(%d+)_(%d+).zip),") do
		local iBeginVer = tonumber(beginVer)
		local iEndVer = tonumber(endVer)
		local iGameId = tonumber(gameId)
		local iMinVersion = tonumber(minVersion)

		--在游戏配置列表里不存在的游戏不需要处理
		local isExistInList = false
		local allGames = HallConfig:getLobbyGames()
		for k, v in pairs(allGames) do
			if tonumber(v.gameid) == iGameId then
				isExistInList = true
				break
			end
		end
		if isExistInList and iGameId > 0 and iMinVersion <= hallVersion then
			if files[iGameId] then
				if not files[iGameId][iBeginVer] then
					files[iGameId][iBeginVer] = {}
				end
				table.insert(files[iGameId][iBeginVer], {iEndVer, fileName})
				--给结束节点也建一个空表，以后可能会用，也可能一直是空表
				if not files[iGameId][iEndVer] then
					files[iGameId][iEndVer] = {}
				end
			else
				--按游戏分类，将update文件夹下的update按版本记录在邻接表中。
				--因为可能会存在1-2,1-3,2-4,3-5这种升级包，根据当前版本为起点，选择升级路径最长的升级包进行升级。
				files[iGameId] = {}
				files[iGameId][iBeginVer] = {}
				files[iGameId][iEndVer] = {}
				table.insert(files[iGameId][iBeginVer], {iEndVer, fileName})
				table.insert(gameIds, iGameId)
			end
		end
	end
	self.allUpdateFiles = files
	--当前存在可升级路径的gameId列表
	self.allGameIds = gameIds
end

--计算解压路径并开始备份
function GameVersionManager:loadGames()
	local files = self.allUpdateFiles or {}
	local gameIds = self.allGameIds
	self.backScript = false

	for i = 1, #gameIds do
		local gameId = gameIds[i]
		print_string("zyh GameVersionManager:loadGames gameIds "..gameId)
		--游戏在update目录下可以找到当前版本开始的更新包，那么从当前版本开始更新
		--如果没有该游戏，curVer会是100，此时就会从update_100_**开始升级，如果没有100_开头的，就表示没法升级上去。
		local curVer = app:getGameCurVersion(gameId)
		--        local curVer = 101
		if gameId > 0 and files[gameId] and files[gameId][curVer] then
			--需要解压，设置当前进度为0，先处理所有要升级的游戏,防止误点击进入游戏
			local gameStatus = app:getGameStatus(gameId)
			gameStatus:setUnZipProgress(0)
			local adjacency = files[gameId]
			print_string("zyh calcuUpdatePath "..gameId)
			local updatePath = self:calcUpdatePath(adjacency, curVer)
			self.updatePath[gameId] = updatePath
			--有更新路径，脚本先备份，避免出错
			self.backScript = false
			if #updatePath > 1 and not self.backScript then
				self.backScript = true
				print_string("zyh start back scripts "..os.time())
				--备份失败
				if NativeEvent.getInstance():backupScripts() == 0 then
					print_string("zyh loadGames stop backup fail")
					gameStatus:setUnZipProgress(100)
					return false
				end
			end
		end
	end

	self:startLoadGame(1)
	return true
end

function GameVersionManager:startLoadGame(startIndex)
	for i = startIndex, #self.allGameIds do
		local gameId = self.allGameIds[i]
		print_string("zyh GameVersionManager:startLoadGame gameIds "..gameId)
		--游戏在update目录下可以找到当前版本开始的更新包，那么从当前版本开始更新
		--如果没有该游戏，curVer会是100，此时就会从update_100_**开始升级，如果没有100_开头的，就表示没法升级上去。
		local curVer = app:getGameCurVersion(gameId)
		--        local curVer = 101
		if gameId > 0 and self.updatePath[gameId] then
			--找到第一个需要更新的gameId，开始解压后就跳出循环，保证同一时间只有一个文件在解压，
			--不然会出现多个线程同时解压的问题，回调函数入口又是同一个，lua无法区分到底是哪个文件解压完毕了,
			--会导致所有unzip的回调函数被调用，认为所有zip都解压完毕，实际上只解压完了其中一个
			self:unZipGameFile(self.updatePath[gameId], gameId, i)
			return
		end
	end
end


--当前游戏下的邻接表adjacency，当前游戏的版本curVer
--返回计算结束后的版本升级路径
function GameVersionManager:calcUpdatePath(adjacency, curVer)
	adjacency[curVer].weight = 0
	adjacency[curVer].isVisited = true
	local startList = {curVer}
	local nextStartList = {}
	--遍历该邻接表的所有邻居节点, dijkstra算法
	--由于lua在遍历table的时候不应该对table里的数据进行删除增加等操作，不能用类似vector的方法，采用额外的startList记录需要遍历的节点。
	repeat
		for i = 1, #startList do
			local startVer = startList[i]
			local startAdj = adjacency[startVer]
			startAdj.isVisited = true

			--遍历startAdj的所有邻接节点
			for index = 1, #startAdj do
				--以版本号为索引建立的邻接表，每个节点都是一个table，1是下一个版本号，2是两个版本之间升级的文件名
				local endVer = startAdj[index][1]
				local newWeight = startAdj.weight + 1
				--更新升级到endVer需要解压的包的数量，
				if not adjacency[endVer].weight or adjacency[endVer].weight > newWeight then
					adjacency[endVer].weight = newWeight
					adjacency[endVer].front = startVer
					adjacency[endVer].fileName = startAdj[index][2]
				end
				--如果endVer节点的邻接节点还没有被遍历过，将他放入下一个遍历列表里。
				if not adjacency[endVer].isVisited then
					table.insert(nextStartList, endVer)
					adjacency[endVer].isVisited = true
				end
			end

		end
		startList = nextStartList
		nextStartList = {}
		--已经没有未遍历过周边节点的节点了，结束循环
		if #startList == 0 then
			break
		end
	until false;
	--已经遍历完这款游戏下的所有更新包，找到最高版本
	local finishVer = curVer
	for k, v in pairs(adjacency) do
		--存在weight表示可以被更新到，选择k最大的，就是最新的版本
		if v.weight and k > finishVer then
			finishVer = k
		end
	end
	--确定更新路径,没有front节点表示路径结束
	local filePath = {}
	repeat
		if adjacency[finishVer].front then
			table.insert(filePath, adjacency[finishVer].fileName)
			finishVer = adjacency[finishVer].front
		else
			break;
		end
	until false;

	return filePath
end

function GameVersionManager:unZipGameFile(updatePath, gameId, gameIdIndex)
	print_string("zyh unZipGameFile "..gameId.." #updatePath  "..#updatePath)
	--生成解压包的名字，依次解压
	local unzipFunc
	unzipFunc = function(startIndex)
		local fileName = updatePath[startIndex]
		local gameStatus = app:getGameStatus(gameId)
		if not fileName then
			gameStatus:setUnZipProgress(100)
			--因为检查更新时如果有本地升级路径会先解压，防止重新登陆的时候不需要再解压了却无法检查到升级
			updatePath = nil
			--已经没有结束版本的升级包了，结束解压,重新加载game.lua，防止更新,线上有bug，先去掉
			app:reloadGame(gameId)
			--开始检查网络更新
			self:checkGameVerCfg(gameId)
			--开始解压下一个压缩包
			self:startLoadGame(gameIdIndex + 1)
			return
		end
		gameStatus:setUnZipProgress(math.floor((#updatePath - startIndex) / #updatePath) * 100)

		local saveFile = fileName
		print_string("zyh unzip file "..saveFile)
		local zipFile
		local unZipPath = ""
		if NativeEvent.s_platform == kPlatformIOS  then
			zipFile = "/update/" .. saveFile
			unZipPath = ""
		else
			zipFile = saveFile
		end
		--md5值不正确的不解压
		if not self:checkFileMD5(saveFile, self.mFileMD5[saveFile]) then
			print_string("zyh scans files and check md5 error "..tostring(saveFile))
			--设置解压完毕，防止进不去房间
			gameStatus:setUnZipProgress(100)
			gameStatus:setUpdateState(2)
			--开始解压下一个游戏,以免影响其他游戏
			self:startLoadGame(gameIdIndex + 1)
			return
		end

		MyUnzip:unzip(
			'update',
			zipFile,
			unZipPath,
			self,
			function (self, jsonData)
				local status		= tonumber(jsonData.status:get_value()) or 0
				if status == 1 then
					--安装完成
					print_string("zyh unzip finish zipFile "..zipFile.." "..gameId)
					--接着解压
					unzipFunc(startIndex - 1)
				else
					--当前版本已经解压失败了，不再继续解压
					app:reloadGame(gameId)
					print_string("zyh unzip file fail "..zipFile.." "..gameId)
					--设置解压完毕，防止进不去房间
					gameStatus:setUnZipProgress(100)
					--记录解压失败,游戏退出时会删掉update下已经解压的脚本
					gameStatus:setUpdateState(3)
					--开始解压下一个游戏,以免影响其他游戏
					self:startLoadGame(gameIdIndex + 1)
				end
			end
		)
	end
	unzipFunc(#updatePath)

end

function GameVersionManager:checkVersionAndDownload(gameId)
	print_string("zyh GameVersionManager:checkVersionAndDownload "..gameId)
	--0是未开放游戏，不可进入
	if gameId == 0 then
		return false
	end
	--win32平台没有热更新
	if System.getPlatform() == kPlatformWin32 then
		return true
	end

	local updateInfo = self:getGameUpdateInfo(kUpdatePrefix..gameId)
	if updateInfo then
		if updateInfo:getCheckUpdate() == kUpdateNone then
			return true
		else
			--需要更新
			self:checkNetAndDownloadUpdateZip(gameId)
		end
	else
		print_string("zyh no updateinfo to checkGameVerCfg "..gameId)
		self:checkGameVerCfg(gameId)
	end

	return false
end

function GameVersionManager:checkNetAndDownloadUpdateZip(gameId)
	print_string("zyh GameVersionManager:checkNetAndDownloadUpdateZip "..gameId)
	local curVer  = app:getGameCurVersion(gameId)
	local updateInfo = self:getGameUpdateInfo(kUpdatePrefix..gameId)
	--检查是否wifi，不是wifi要先提示是否更新
	if NativeEvent.getInstance():getNetworkType() ~= kNetWifi then
		--检查如果有差量更新路径，用差量更新，不然用全量更新
		local size = updateInfo:getCheckUpdate() == kUpdatePatch and updateInfo:getPatchSize() or updateInfo:getFullSize()
		local strSize = ""
		if size > 1000000 then
			strSize = string.format("%.2fMB", size / 1000000)
		elseif size > 1000 then
			strSize = string.format("%.2fKB", size / 1000)
		else
			strSize = string.format("%dB", size)
		end
		local gameList = HallConfig:getGameList() or {}
		local gameType = gameList[tostring(gameId)] or {}
		local gameName = gameType.localName or ""
		WindowManager:showWindow(
			WindowTag.LobbyConfirmPopu,
			{
				cancel		= STR_GAME_UPDATE_CANCEL,
				confirm = STR_GAME_UPDATE_CONFIRM,
				title = string.format(STR_GAME_UPDATE_TITLE, gameName),
				content = string.format(STR_GAME_UPDATE_CONTENT, strSize),
				confirmFunc = function ()
					self:downloadUpdateZip(gameId)
				end
			},
			WindowStyle.POPUP
		)
	else
		self:downloadUpdateZip(gameId)
	end
end

function GameVersionManager:downloadUpdateZip(gameId)
	print_string("zyh GameVersionManager:downloadUpdateZip "..gameId)

	local updateInfo = self:getGameUpdateInfo(kUpdatePrefix..gameId)
	print_string("zyh updateInfo:getPatchMD5() "..tostring(updateInfo:getPatchMD5()))
	if updateInfo:getCheckUpdate() == kUpdateNone then
		--不需要更新就直接返回
		return
	end
	local curVer  = app:getGameCurVersion(gameId)
	local updateVer = updateInfo:getLatestVersion()
	local dependVersion = updateInfo:getDependVersion()
	--开始更新
	local saveFile		= string.format('update_%s_%s_%s_%s.zip', gameId, curVer, updateVer, dependVersion)
	local zipUrl = updateInfo:getPatchURL()
	local zipMD5 = updateInfo:getPatchMD5()
	--全量更新的时候用全量的路径，增量更新的时候用增量的URL
	if updateInfo:getCheckUpdate() ~= kUpdatePatch then
		--全量更新，起始版本由最低的100开始，而不是当前版本，为了以后安装新的apk不带这个游戏时可以从磁盘解压
		saveFile = string.format('update_%s_%s_%s_%s.zip', gameId, 100, updateVer, dependVersion)
		zipUrl = updateInfo:getFullURL()
		zipMD5 = updateInfo:getFullMD5()
	end
	print_string("zyh downloadUpdateZip "..gameId.." zipUrl "..zipUrl.." updateInfo:getCheckUpdate() "..updateInfo:getCheckUpdate())
	--返回链接里URL为空，无法正行下载，设置最新版本为当前版本，避免进不去游戏
	if zipUrl == "" then
		updateInfo:setLatestVersion(curVer)
		updateInfo:setCheckUpdate(kUpdateNone)
		return
	end
	local zipBasePath
	local zipFolder
	local zipFile
	local unZipPath = ""
	if NativeEvent.s_platform == kPlatformIOS  then
		zipBasePath = "/update/"
		zipFolder = ""
		zipFile = "/update/" .. saveFile
		unZipPath = ""
	else
		zipFile = saveFile
	end
	if NativeEvent.getInstance():getPermission({permission = "storage"}) ~= "success" then
		return;
	end

	local gameStatus = app:getGameStatus(gameId)
	gameStatus:setUnZipProgress(1)
	--全量更新任务，如果当前有全量任务在下载，加入队列，等待调用
	if updateInfo:getCheckUpdate() == kUpdateFull then
		if self.isDownloading then
			table.insert(self.downloadQueue, gameId)
			--点击更新后给一个简单的进度条
			gameStatus:setUnZipProgress(1)
			print_string("zyh add download task "..gameId)
			return;
		else
			self.isDownloading = true
		end
	end
	--下载源码包
	print_string("zyh actually start download "..saveFile)
	MyUpdate:download(
		"updatezip",
		zipUrl,
		saveFile,
		self,
		function (self, jsonData)
			local status = tonumber(jsonData.status:get_value()) or 0
			if status == 1 then --下载完成
				--继续下载队列里的下一个游戏
				if updateInfo:getCheckUpdate() == kUpdateFull then
					self.isDownloading = false
					local nextGameId = self.downloadQueue[1]
					print_string("zyh finish download task "..gameId)
					--当前游戏下载完成，从队列里移除
					if nextGameId == gameId then
						table.remove(self.downloadQueue, 1)
						nextGameId = self.downloadQueue[1]
					end
					if nextGameId then
						print_string("zyh start download next game id "..nextGameId)
						self:downloadUpdateZip(nextGameId)
					end
				end
				--检查下载下来的文件MD5值
				if not self:checkFileMD5(saveFile, zipMD5, "downloadZipMD5Error") then
					print_string("zyh check downloadZip md5 error "..saveFile)
					self:downloadGameFail(gameId)
					return
				end
				--解压之前将进度条设置为99，省得解压时又从0开始显示进度条
				gameStatus:setUnZipProgress(99)
				print_string('zyh download zip suc '..saveFile)
				MyUnzip:unzip(
					'update',
					zipFile,
					unZipPath,
					self,
					function (self, jsonData)
						gameStatus:setUnZipProgress(100)
						local status		= tonumber(jsonData.status:get_value()) or 0
						--更新包解压失败，设置检查完毕，
						if status == 1 then
							--安装完成
							print_string("zyh 更新包解压成功 "..zipFile)
							--请求房间列表
							app:checkAndDownloadRoomList(gameId, 1, false);
							--重新加载原来的game.lua文件
							gameStatus:setUpdateState(2)
							app:reloadGame(gameId)
							--设置游戏不需要再更新
							updateInfo:setCheckUpdate(kUpdateNone)
						else
							print_string("zyh unzip fail "..zipFile)
							AlarmTip.play(STR_UNZIP_GAME_ERROR.." : "..tostring(gameStatus.name))
							--设置游戏不需要再更新
							updateInfo:setCheckUpdate(kUpdateNone)
							gameStatus:setUpdateState(3)
							--上报统计游戏解压失败的人数，用来分析
							HttpModule.getInstance():execute(HttpModule.s_cmds.REPORT_DEBUG_INFO, {log = "unzipGameFail#"..tostring(saveFile)}, false, false);
						end
					end
				)
			elseif status == 2 then --下载中
				gameStatus:setProgress(tonumber(jsonData.progress:get_value()) or 0)
			else --下载失败
				--继续下载队列里的下一个游戏
				if updateInfo:getCheckUpdate() == kUpdateFull then
					self.isDownloading = false
					local nextGameId = self.downloadQueue[1]
					print_string("zyh finish download task fail "..gameId)
					--当前游戏下载完成，从队列里移除
					if nextGameId == gameId then
						table.remove(self.downloadQueue, 1)
						nextGameId = self.downloadQueue[1]
					end
					if nextGameId then
						print_string("zyh start download next game id "..nextGameId)
						self:downloadUpdateZip(nextGameId)
					end
				end

				--上报统计游戏下载失败的人数
				HttpModule.getInstance():execute(HttpModule.s_cmds.REPORT_DEBUG_INFO, {log = "downloadGameFail"..tostring(gameId)}, false, false);
				--删除本地上出错的这份压缩包
				NativeEvent.getInstance():deleteFile({type = "updateZip", file = saveFile})
				self.mFileMD5[saveFile] = nil
				self:saveZipFileMD5()
				self:downloadGameFail(gameId)
			end
		end,
		zipBasePath,
		zipFolder
	)
end

function GameVersionManager:downloadGameFail(gameId)
	print_string("zyh 更新包下载失败，设置更新结束 "..gameId)
	local gameStatus = app:getGameStatus(gameId)
	local updateInfo = self:getGameUpdateInfo(kUpdatePrefix..gameId)
	local curVer  = app:getGameCurVersion(gameId)
	gameStatus:setUnZipProgress(100)

	--当前版本从100开始，也就是游戏并未安装，不可以进入游戏
	if curVer == 100 then
		AlarmTip.play(STR_DOWNLOAD_GAME_ERROR.." : "..tostring(gameStatus.name))
		gameStatus:setStatus(1)
		--弹窗提示游戏更新失败，请打开SDK读写权限并检查网络问题。
	else
		--强制更新类型，不更新无法进入游戏
		if updateInfo:getUpdateType() ~= 2 then
			--设置游戏不需要再更新
			AlarmTip.play(STR_DOWNLOAD_GAME_ERROR.." : "..tostring(gameStatus.name))
			updateInfo:setCheckUpdate(kUpdateNone)
		end
		--游戏有原先的版本，可以先进入
		gameStatus:setUpdateState(2)
	end
	print_string('download zip fail')
end

function GameVersionManager:checkGameVerCfg(gameId)
	local updateUrl = self:initUpdateUrl(kUpdatePrefix..gameId, 0, require('version'), app:getGameCurVersion(gameId))
	print_string("zyh checkGameVerCfg ".." gameId "..gameId.." "..updateUrl)
	self:executeURL(updateUrl, gameId)
end

function GameVersionManager:executeURL(url, gameId)
	print_string("GameVersionManager:executeURL "..url.." gameId "..gameId)
	local timeoutTime = 18000
	local httpRequest = new(Http,kHttpPost,kHttpReserved,url)
	httpRequest:setTimeout(timeoutTime, timeoutTime)
	httpRequest:setEvent(self, self.httpResponse)
	httpRequest:setData("")

	local timeoutAnim = new(AnimInt,kAnimRepeat,0,1,timeoutTime,-1)
	timeoutAnim:setDebugName("AnimInt | httpTimeoutAnim")
	timeoutAnim:setEvent(
		self,
		function()
			self:handleHttpResult(httpRequest, false)
			self:destroyHttpRequest(httpRequest)
		end
	)
	print_string("timeoutTime="..timeoutTime)

	self.m_httpCommandMap[httpRequest] = gameId
	self.m_commandTimeoutAnimMap[httpRequest] = timeoutAnim;
	httpRequest:execute()
	print_string("zyh httpRequest is "..tostring(httpRequest).." gameId "..gameId)
end

function GameVersionManager:httpResponse(httpRequest)
	local gameId = self.m_httpCommandMap[httpRequest];
	if not gameId then
		self:destroyHttpRequest(httpRequest);
		return;
	end

	--删除超时计时器
	local anim = self.m_commandTimeoutAnimMap[httpRequest];
	delete(anim);
	self.m_commandTimeoutAnimMap[httpRequest] = nil

		local errorCode = HttpErrorType.SUCCESSED;
		local data = nil;
	local resultStr;
	repeat
		-- 判断http请求的错误码,0--成功 ，非0--失败.
		-- 判断http请求的状态 , 200--成功 ，非200--失败.
		print_string("zyh httpRequest:getError() "..tostring(httpRequest:getError()).." httpRequest:getResponseCode() "..tostring(httpRequest:getResponseCode()))
		if 0 ~= httpRequest:getError() or 200 ~= httpRequest:getResponseCode() then
			errorCode = HttpErrorType.NETWORKERROR;
			break;
		end

		-- http 请求返回值
		resultStr =  httpRequest:getResponse();
		-- print_string("zyh resultStr is "..tostring(resultStr))
		-- http 请求返回值的json 格式
		local json_data = json.decode(resultStr); -- json.decode_node

		data = json_data;
	until true;

	self:handleHttpResult(httpRequest, errorCode == HttpErrorType.SUCCESSED, data)

	self:destroyHttpRequest(httpRequest);
end

function GameVersionManager:destroyHttpRequest(httpRequest)
	if not httpRequest then
		return;
	end

	local command = self.m_httpCommandMap[httpRequest];

	if not command then
		delete(httpRequest);
		return;
	end

	local anim = self.m_commandTimeoutAnimMap[httpRequest];
	delete(anim);
	self.m_commandTimeoutAnimMap[httpRequest] = nil
	self.m_httpCommandMap[httpRequest] = nil;
end

function GameVersionManager:handleHttpResult(httpRequest, isSuccess, data)
    JLog.d("GameVersionManager:handleHttpResult",data);
	local gameId = self.m_httpCommandMap[httpRequest];
	print_string("handleHttpResult gameId "..tostring(gameId))
	if not gameId then
		return
	end
	--检查的是apk包的更新
	if gameId == "apk_vtn" then
			if isSuccess and data then
			if MyApkUpdateInfo:getHasInit() == 0 then
				MyApkUpdateInfo:init(data)
				if MyApkUpdateInfo:getHasInit() ~= 0 then
					if MyApkUpdateInfo:getUpdateType() == 0 or MyApkUpdateInfo:getUpdateType() == 1 then
						WindowManager   = WindowManager     or new(require("app.manager.windowManager"))
						WindowManager:showWindow(WindowTag.UpdateApkPopu, {}, WindowStyle.POPUP)
						return
					end
				end
			end
		end
		--没有更新信息，或者检查更新失败，都开始检查大厅的更新
		self:checkAndUpdateHall()
		return
	end

	local updateInfo = new(require("app.data.updateInfo"))
	--成功返回并且带了数据
	if isSuccess and data then
		updateInfo:init(data)
		--成功匹配到更新路径，有差分包
		if data.errorCode == 0 then
			updateInfo:setCheckUpdate(kUpdatePatch)            --差量更新
			--大厅版本匹配，没有差量路径，采用全量更新
		elseif data.errorCode == 204 then
			updateInfo:setCheckUpdate(kUpdateFull)
			--当前已经是最新版本201--当前大厅版本过低，无法升级203--其他情况可能有分支错误、版本错误等可能，无法更新
		else
			updateInfo:setCheckUpdate(kUpdateNone)
		end
		dump(data,"GameVersionManager,http结果")
		print_string("zyh GameVersionManager:handleHttpResult "..gameId.." data.errorCode "..data.errorCode.. " updateInfo:setCheckUpdate "..updateInfo:getCheckUpdate().." getLatestVersion "..updateInfo:getLatestVersion())
	end
	--不论结果正常与否，都需要设置当前游戏的更新信息，保证可以进入游戏
	updateInfo:setBranchSign(kUpdatePrefix..gameId)
	self:setGameUpdateInfo(updateInfo:getBranchSign(), updateInfo)

	--大厅必须要更新的，自动更新
	if gameId == kHallPrefix then
		JLog.d("##########checkAndUpdateHallOnResponse")
		self:checkAndUpdateHallOnResponse()
	else
		local gameStatus = app:getGameStatus(gameId)
		--win32不升级
		if System.getPlatform() == kPlatformWin32 then
            JLog.d("win32不需要升级");
			app:checkAndDownloadRoomList(gameId, 1, false);
			updateInfo:setCheckUpdate(kUpdateNone)
			gameStatus:setUpdateState(2)
			gameStatus:setUnZipProgress(100)
			print_string("zyh updateInfo:getPatchMD5() "..tostring(updateInfo:getPatchMD5()))
			return
		end
		--该游戏不需要升级，设置为检查更新完毕
		if updateInfo:getCheckUpdate() == kUpdateNone then
			print_string("zyh 无需更新 "..gameId)
			--请求房间列表
			app:checkAndDownloadRoomList(gameId, 1, false);
			gameStatus:setUpdateState(2)
			gameStatus:setUnZipProgress(100)
			--差量更新的情况下自动更新
		elseif updateInfo:getCheckUpdate() == kUpdatePatch then
			print_string("zyh 差量更新 "..gameId)
			self:downloadUpdateZip(gameId)
			gameStatus:setLatestVer(updateInfo:getLatestVersion())
			--全量更新的情况下，wifi环境，只更新分类下的第一个或者已经安装过的
		elseif updateInfo:getCheckUpdate() == kUpdateFull and NativeEvent.getInstance():getNetworkType() == kNetWifi then
			print_string("zyh 全量更新 "..gameId)
			gameStatus:setProgress(0)
			gameStatus:setLatestVer(updateInfo:getLatestVersion())
			--jaywillou-20170815-此处要注意，全量更新不会自己下载，要等到点击按钮才会去下载
		end
	end
end

--大厅检查后的更新后下载压缩包
function GameVersionManager:checkAndUpdateHallOnResponse()
	print_string("zyh GameVersionManager:checkAndUpdateHallOnResponse ")
	local updateInfo = self:getGameUpdateInfo(kUpdatePrefix..kHallPrefix)
	print_string("zyh updateInfo:getCheckUpdate() "..tostring(updateInfo:getCheckUpdate()))
	if not updateInfo or updateInfo:getCheckUpdate() ~= kUpdatePatch or System.getPlatform() == kPlatformWin32 then
		--不要更新，进入大厅
		print_string("zyh no nedd to update hall and StartSceneInit ")
		PlatformManager:executeAdapter(PlatformManager.s_cmds.StartSceneInit)
		return
	end
	local curVer = require('version')
	local updateVer = updateInfo:getLatestVersion()
	--大厅需要增量更新
	local file			= string.format('update_%s_%s.zip', curVer, updateVer)
	local saveFile		= string.format('update_%s_%s.zip', curVer, updateVer)
	local url			= updateInfo:getPatchURL()
	local zipMD5    = updateInfo:getPatchMD5()
	local zipBasePath
	local zipFolder
	local zipFile
	local unZipPath = ""
	if NativeEvent.s_platform == kPlatformIOS  then
		zipBasePath = "/update/"
		zipFolder = ""
		zipFile = "/update/"  .. saveFile
		unZipPath = ""
	else
		zipFile = saveFile
	end

	local startDownload = function()
		local hallStatus = app:getGameStatus(0)
		local startTime = sys_get_int("tick_time", 0)

		MyUpdate:download(
			"updatezip",
			url,
			saveFile,
			self,
			function (self, jsonData)

				local status		= tonumber(jsonData.status:get_value()) or 0
				if status == 1 then
					--大厅文件校验MD5失败
					if not self:checkFileMD5(saveFile, zipMD5, "downloadHallMD5Error") then
						--进入大厅
						PlatformManager:executeAdapter(PlatformManager.s_cmds.StartSceneInit)
						return
					end
					MyUnzip:unzip(
						'update',
						zipFile,
						unZipPath,
						self,
						function (self, jsonData)
							local status		= tonumber(jsonData.status:get_value() or 0) or 0
							--成功,清除所有已经加载的脚本
							if status == 1 then
								self:clearLoadedScripts()
							else
								--删除本地上出错的这份压缩包
								NativeEvent.getInstance():deleteFile({type = "updateZip", file = saveFile})
							end
							--不管正确失败 进入大厅
							PlatformManager:executeAdapter(PlatformManager.s_cmds.StartSceneInit)
						end
					)
				elseif status == 2 then
					--正在下载更新包
					local downSize = tonumber(jsonData.downSize:get_value()) or 0
					local totalSize = tonumber(jsonData.totalSize:get_value()) or 0
					local progress = tonumber(jsonData.progress:get_value()) or 0
					local curTime = sys_get_int("tick_time", 0)
					local speed = curTime ~= startTime and math.floor(downSize / (curTime - startTime)) or 0
					hallStatus:setTotalSize(totalSize)
					hallStatus:setProgress(progress)
					hallStatus:setSpeed(speed)
				elseif status == 0 then
					--下载更新包失败
					--进入大厅
					--删除本地上出错的这份压缩包
					NativeEvent.getInstance():deleteFile({type = "updateZip", file = saveFile})
					PlatformManager:executeAdapter(PlatformManager.s_cmds.StartSceneInit)
				end
			end,
			zipBasePath,
			zipFolder
		)
	end

	startDownload()

end

function GameVersionManager:clearLoadedScripts()
	loadHall()

	--必须提前初始化
	PhpManager      = PhpManager			or new(require("app.mjSocket.base.phpManager"))
	PlatformManager = PlatformManager		or new(require("app.platform.platformManager"))
	--全局版本控制器
	MyGameVerManager    = MyGameVerManager or new(require("app.update.gameVersionManager"))
	MyApkUpdateInfo = MyApkUpdateInfo or setProxy(new(require("app.data.apkUpdateInfo")))
	app = new(require("app.app"))
end

function GameVersionManager:initUpdateUrl(branchSign, apkVersion, hallVersion, subGameVersion)
	--当
	local time = math.floor(os.time() / 600)
	local sign = "boyaa"..apkVersion..branchSign..hallVersion..subGameVersion..time.."boyaa"
	--md5参数校验
	local sign_md5 = md5_string(sign)
	print_string("zyh branchSign "..branchSign.." md5 "..sign_md5)
	return kUpdateVerUrlPrefix..string.format("?apkVersion=%s&branchSign=%s&hallVersion=%s&subGameVersion=%s&sign=%s&time=%s", apkVersion, branchSign,hallVersion,subGameVersion, sign_md5, time)
end

function GameVersionManager:checkFileMD5(saveFile, zipMD5, errorLog)
	--只有安卓平台，校验文件MD5值，一样表示文件正常下载完毕
	if NativeEvent.s_platform == kPlatformAndroid then
		--校验码都统一成32位的字符串
		local strMD5 = NativeEvent.getInstance():getFileMD5({type = "updateZip", file = saveFile}) or ""
		if string.format("%032s", strMD5) ~= tostring(zipMD5) then
			print_string("zyh download finish and check md5 fail "..tostring(zipMD5))
			--上报统计游戏下载失败的人数
			if errorLog then
				HttpModule.getInstance():execute(HttpModule.s_cmds.REPORT_DEBUG_INFO, {log = tostring(errorLog).."#"..tostring(saveFile)}, false, false);
			end
			--删除本地上出错的这份压缩包
			NativeEvent.getInstance():deleteFile({type = "updateZip", file = saveFile})
			self.mFileMD5[saveFile] = nil
			self:saveZipFileMD5()
			return false
			--文件下载成功，记录MD5值
		else
			print_string("zyh downlaod finish and check md5 suc "..saveFile)
			self.mFileMD5[saveFile] = zipMD5
			self:saveZipFileMD5()
		end
	end
	return true
end

return GameVersionManager
--endregion
