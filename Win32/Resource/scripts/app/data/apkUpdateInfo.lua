local ApkUpdateInfo = class(require("app.data.imgData"))

addProperty(ApkUpdateInfo, "isForceUpdate", 0)
addProperty(ApkUpdateInfo, "updateContent", "")
addProperty(ApkUpdateInfo, "updateTitle", "")
addProperty(ApkUpdateInfo, "updateReward", 0)
addProperty(ApkUpdateInfo, "updateRewardType", 0)
addProperty(ApkUpdateInfo, "updateSize", 0)
addProperty(ApkUpdateInfo, "autoUpdate", 0)
addProperty(ApkUpdateInfo, "updateVer", "")
addProperty(ApkUpdateInfo, "updateUrl", "")
addProperty(ApkUpdateInfo, "isDownloading", false)
addProperty(ApkUpdateInfo, "updateProgress", 0)             --记录apk当前的更新进度
addProperty(ApkUpdateInfo, "updateType", 0) --更新类型，0：非强制更新，1：强制更新，2：引导更新
addProperty(ApkUpdateInfo, "fileName", "") --待安装文件
addProperty(ApkUpdateInfo, "isToBeInstalled", false) --是否等待安装
addProperty(ApkUpdateInfo, "hasInit", 0) --数据是否已初始化

--url统一用一个，apkSize大小是KB？, 强制更新和静默更新不要用是和否

function ApkUpdateInfo:init(data)
    local curVer = PhpManager:getVersionCode()
    local str = data.version or ""
    -- print_string("ygd curVer:"..curVer)
    -- print_string("ygd data.version:"..data.version)
    --根据version判断当前客户端是否需要更新
    local versionCode = 0
    for num in string.gmatch(str, "(%d+)") do
        versionCode = versionCode * 10 + num
    end
    if curVer >= versionCode then
        print_string("zyh curVer "..curVer.." updateApkversion is "..versionCode.." no need to update apk")
        --当前不需要更新
        return
    end
    --开了强制更新，判断当前版本是否需要强制更新
    print_string("ygd data.is_force:"..tonumber(data.is_force))
    if tonumber(data.is_force) == 1 then
        local forceVersion = 0
        local str = data.updateVersion or ""
        for num in string.gmatch(str, "(%d+)") do
            forceVersion = forceVersion * 10 + num
        end
        
        if curVer > forceVersion then
            self:setIsForceUpdate(0)
            self:setUpdateType(0)
        else
            self:setIsForceUpdate(1)
            self:setUpdateType(1)
        end
    else
        self:setUpdateType(data.is_force or 0)
    end
    -- print_string("zyh self:getIsForceUpdate "..tostring(self:getIsForceUpdate()))
    self:setUpdateContent(data.content or "")
    self:setUpdateTitle(data.title or "")
    self:setUpdateReward(tonumber(data.rewardNum) or 0)
    self:setUpdateRewardType(tonumber(data.rewardType) or 0)
    self:setUpdateSize(string.format("%0.2fM", (tonumber(data.apkSize) or 0) / 1000))
    self:setAutoUpdate(tonumber(data.is_slient) or 0)
    print_string("zyh data.is_slient is "..tostring(tonumber(data.is_slient) or 0))
    print_string("zyh self:getAutoUpdate "..tostring(self:getAutoUpdate()))
    local apkUrl = data.apkUrl or ""
    self:setUpdateUrl(apkUrl)
    self:setUpdateVer(data.version or "")
    if data.iconUrl and data.iconUrl ~= "" then
        self:setImgUrl(data.iconUrl)
    end
    print_string("zyh updateinfo data.iconUrl "..tostring(data.iconUrl).." imgUrl is "..self:getImgUrl())

    self:setHasInit(1)
end

return ApkUpdateInfo