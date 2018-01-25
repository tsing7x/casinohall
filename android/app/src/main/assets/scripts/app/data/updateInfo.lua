--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local UpdateInfo = class()

addProperty(UpdateInfo, "branchID", 0)              --后端定义，用来区分更新后台上的唯一的游戏分支
addProperty(UpdateInfo, "branchSign", "")           --后端定义，用来区分更新后台上的唯一的游戏分支,跟上面的branchID用一个就好，现在用branchSign
addProperty(UpdateInfo, "fullSize", 0)              --完整更新包大小，非差分
addProperty(UpdateInfo, "fullURL", "")              --完整更新包链接
addProperty(UpdateInfo, "fullMD5", "")              --更新包的MD5值
addProperty(UpdateInfo, "patchDepend", "")           --游戏依赖的大厅版本
addProperty(UpdateInfo, "patchSize", 0)             --差分包大小
addProperty(UpdateInfo, "patchURL", "")             --差分包下载链接
addProperty(UpdateInfo, "patchMD5", "")              --更新包的MD5值
addProperty(UpdateInfo, "updateCondition", "")      --更新条件，暂时不用
addProperty(UpdateInfo, "updateDescription", "")    --更新说明，暂时不用
addProperty(UpdateInfo, "updateMode", 1)            --更新模式，后台发布更新包时可选参数，1:增量更新 2:第三方更新 3:完整更新
addProperty(UpdateInfo, "updateType", 1)            --更新方式，后台发布更新包时可选参数，1:可选更新 2:强制更新 3:静默更新
addProperty(UpdateInfo, "latestVersion", 100)       --当前最新版本
addProperty(UpdateInfo, "dependVersion", 0)        --依赖的版本，对于游戏而言，依赖的是大厅的版本，对于大厅而言，依赖的是apk的版本,高于此版本的才能跟新
addProperty(UpdateInfo, "checkUpdate", 1)           --检查判定的更新方法，1不更新，2差量更新，3全量更新
--暂时只用updateType，

function UpdateInfo:init(param)
    self:setBranchID(tonumber(param.branchID) or 0)
    self:setBranchSign(param.branchSign or "")
    self:setFullSize(tonumber(param.fullSize) or 0)
    self:setFullURL(param.fullURL or "")
    self:setFullMD5(param.fullMD5 or "")
    self:setPatchDepend(param.patchDepend or "")
    self:setPatchSize(tonumber(param.patchSize) or 0)
    self:setPatchMD5(param.patchMD5 or "")
    self:setPatchURL(param.patchURL or "")
    self:setUpdateMode(tonumber(param.updateMode) or 1)
    self:setUpdateType(tonumber(param.updateType) or 1)
    self:setLatestVersion(tonumber(param.targetVersion) or 100)
    self:setDependVersion(tonumber(param.patchDepend) or 0)
end

return UpdateInfo

--endregion
