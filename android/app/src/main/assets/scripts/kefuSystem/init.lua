require('kefuSystem/EngineCore/config')
local Global = require("kefuSystem/common/kefuGlobal")
local platform = require("kefuSystem/platform/platform")
local kefuCommon = require('kefuSystem/kefuCommon')
local lbl_config = require("kefuSystem/lbl_config")
local UserData = require('kefuSystem/conversation/sessionData')
local URL = require("kefuSystem/mqttModule/mqttConstants")
local LoadingView = require('kefuSystem/view/loadingView')
local GKefuOnlyOneConstant = require('kefuSystem/common/kefuConstant')
local GKefuNetWorkControl = require('kefuSystem/conversation/netWorkControl')
local GKefuSessionControl = require('kefuSystem/conversation/sessionControl')
local GKefuViewManager = require("kefuSystem/viewManager")

local receviceCallback = require("kefuSystem/conversation/protocalFunc")

local M = {}


function M.receiveProtocal(_, proName, ...)
    if proName == "end" then
        proName = "xend"
    end

    if receviceCallback[proName] then
        receviceCallback[proName](...)
    end
end

function System.onInit()
    collectgarbage("setpause", 100);
    collectgarbage("setstepmul", 5000);
    System.startTextureAutoCleanup();
    Label.config(System.getLayoutScale(), 48, true)
    lbl_config()
    Window.instance().root.fbo.need_stencil = true
end

--callBack 是退出时的回调函数
--data 是需要传递的参数
--URLType 地址类型：1 测试服， 2 正式服，  3 预发布
M.initSystem = function(callBack)

    KefuRootPath = "kefuSystem/"

    if not M.logoutCallback then
        M.logoutCallback = function()
            EventDispatcher.getInstance():unregister(GKefuOnlyOneConstant.mqttReceive, M, M.receiveProtocal)
            if callBack then
                callBack()
            end
        end

        kefuCommon.initFaceEmoji()
    end

    Label.set_emoji_baseline(0.9)
    Label.set_emoji_scale(0.9)

    local data = UserData.getStatusData() or {}
    data.isOut = false

    data.connectCallbackStatus = false
    UserData.setStatusData(data)
    UserData.initLeaveDict()
    UserData.initHackDict()
    UserData.initAppealDict()
end


M.initKefuData = function(data, URLType)

    mqtt_client_config.gameId = data.gameId or mqtt_client_config.gameId
    mqtt_client_config.siteId = data.siteId or mqtt_client_config.siteId
    mqtt_client_config.role = data.role or mqtt_client_config.role
    mqtt_client_config.stationId = data.stationId or mqtt_client_config.stationId
    mqtt_client_config.avatarUri = data.avatarUri or mqtt_client_config.avatarUri
    mqtt_client_config.userName = data.nickName or mqtt_client_config.userName

    mqtt_client_info.nickName = data.nickName or mqtt_client_info.nickName
    mqtt_client_info.avatarUri = data.avatarUri or mqtt_client_config.avatarUri
    mqtt_client_info.vipLevel = data.vipLevel or mqtt_client_info.vipLevel
    mqtt_client_info.gameName = data.gameName or mqtt_client_info.gameName
    mqtt_client_info.accountType = data.accountType or mqtt_client_info.accountType
    mqtt_client_info.client = data.client or mqtt_client_info.client
    mqtt_client_info.userID = data.stationId or mqtt_client_config.stationId
    mqtt_client_info.deviceType = data.deviceType or mqtt_client_info.deviceType

    mqtt_client_info.connectivity = data.connectivity or platform.getInstance():getConnectivity()
    mqtt_client_info.deviceDetail = platform.getInstance():getDeviceDetail()
    mqtt_client_info.mac = data.mac or platform.getInstance():getMacAddress()
    mqtt_client_info.ip = platform.getInstance():getIP()
    mqtt_client_info.OSVersion = data.OSVersion or platform.getInstance():getOSVersion()

    mqtt_client_info.gameVersion = data.gameVersion or mqtt_client_info.gameVersion
    mqtt_client_info.operator = data.operator or mqtt_client_info.operator
    mqtt_client_info.jailbreak = data.jailbreak or mqtt_client_info.jailbreak

    mqtt_client_info.extend = data.extend or ""

    if data.hotline and type(data.hotline) == "string" and #data.hotline > 0 then
        mqtt_client_info.hotline = data.hotline
    end
    print_string('555555555555555555555555 gameid = ', mqtt_client_config.gameId, '  mqtt_client_config.siteId = ', mqtt_client_config.siteId
    ,'  mqtt_client_config.stationId = ',mqtt_client_config.stationId)



    local data = UserData.getStatusData() or {}
    data.isOut = false
    if mqtt_client_info.vipLevel == "0" then
        data.isVip = false
    else
        mqtt_client_info.vipLevel = "1"
        data.isVip = true
    end

    data.connectCallbackStatus = false
    UserData.setStatusData(data)
    UserData.initLeaveDict()
    UserData.initHackDict()
    UserData.initAppealDict()


    URL.setURLPrefix(URLType or 2)
    mqtt_client_config.host = URL.CurrentHost
    mqtt_client_config.port = URL.CurrentPort
end

M.showKefuSystem = function()
    local start = Clock.now()
    EventDispatcher.getInstance():register(GKefuOnlyOneConstant.mqttReceive, M, M.receiveProtocal)
    EventDispatcher.getInstance():register(Event.Back, GKefuViewManager, GKefuViewManager.onBackEvent)
    GKefuOnlyOneConstant.KefuSetDesign()

    local layoutScale = System.getOldLayoutScale()
    --保证下划线高度>=1
    if layoutScale < 1 then
        Label.set_default_line_scale(1 / layoutScale)
    end

    local data = UserData.getStatusData() or {}

    local loadingView = LoadingView()
    loadingView:start()
    local view = nil
    if data.isVip then
        view = GKefuViewManager.showVipChatView(GKefuOnlyOneConstant.No)
    else
        view = GKefuViewManager.showNormalChatView(GKefuOnlyOneConstant.No)
    end

    if view then
        view.on_load_succ = function(...)
            loadingView:stop(true)
            view.on_load_succ = nil
            view:showExceptionTips(GKefuOnlyOneConstant.DELAY_CONNECT_DEADLINE)
            view:resetBottom()
            view:contentPreUpdate()
            --显示界面后再connect
            GKefuNetWorkControl.init()
        end
    end
end

M.event_resize = function(width, height)
    if not KefuRootPath then return end
    mqtt_client_info.screen = width .. "*" .. height
    M.showKefuSystem()
end

function M.hideKefuSystem()
    GKefuSessionControl.logout()
end


function M.hasNewMessage(cb)
    GKefuNetWorkControl.hasNewMessage(cb)
end

return M