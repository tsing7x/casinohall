local LobbyGame = class()

addProperty(LobbyGame, "id", 0) 			--游戏ID
addProperty(LobbyGame, "name", "")          --游戏本地名称
addProperty(LobbyGame, "status", 0) 		--游戏安装状态 0 图标未下载 1 游戏未下载 2 游戏已安装
addProperty(LobbyGame, "choose", false) 	--游戏安装状态 0 图标未下载 1 游戏未下载 2 游戏已安装
addProperty(LobbyGame, "progress", 0) 		--当前下载进度百分比
addProperty(LobbyGame, "unzipDiskFile", 1)  --为0表示正在解压文件，按钮无响应。
addProperty(LobbyGame, "totalSize", 0)      --总体下载大小
addProperty(LobbyGame, "speed", 0)          --下载速度
addProperty(LobbyGame, "updateState", 1)    --1表示还没检查过,2表示检查update并正常更新完毕，3表示解压出错，
addProperty(LobbyGame, "autoDownload", false)   --1表示该游戏如果不存在,wifi环境下就自动下载，不然不自动下载
addProperty(LobbyGame, "latestVer", 0)		--记录一下最新版本，用来判断是否有新版本需要显示下载按钮

function LobbyGame:init(data)
	-- body
	self:setId(data.id)
	self:setStatus(data.status)
	self:setChoose(data.choose)
	self:setProgress(data.progress)
    
end

function LobbyGame:setUnZipProgress(progress)
    self:setProgress(progress)
    if progress >= 100 then
        self:setStatus(2)
        self:setUnzipDiskFile(1)
    elseif progress <= 0 then
        self:setUnzipDiskFile(0)
        self:setStatus(1)
    else 
        self:setUnzipDiskFile(0)
    end
end

return LobbyGame