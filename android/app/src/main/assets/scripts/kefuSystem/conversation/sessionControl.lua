local UserData = require('kefuSystem/conversation/sessionData')
local HTTP2 = require("network.http2")
local kefuCommon = require('kefuSystem/kefuCommon')
local ConstString = require('kefuSystem/common/kefuStringRes')
local Record = require('kefuSystem/conversation/record')
local Log = require('kefuSystem/common/log')
local URL = require("kefuSystem/mqttModule/mqttConstants")
local GKefuOnlyOneConstant = require('kefuSystem/common/kefuConstant')
local GKefuNetWorkControl = require('kefuSystem/conversation/netWorkControl')
local GKefuViewManager = require('kefuSystem/viewManager')
local timeOutTask = nil
local endSessionTask = nil


sessionControl = {}

--设置会话超时Task
sessionControl.scheduleSessionTask = function(view)
    if timeOutTask then
        timeOutTask:cancel()
        timeOutTask = nil
    end

    if endSessionTask then
        endSessionTask:cancel()
        endSessionTask = nil
    end

    --如果不是人工服务，则不需要超时task
    if not sessionControl.isHumanService() then return end

    local data = UserData.getStatusData() or {}

    timeOutTask = Clock.instance():schedule_once(function()
        view:addLeftMsg(ConstString.hint_timeout)
    end, GKefuOnlyOneConstant.DELAY_TIMEOUT)

    endSessionTask = Clock.instance():schedule_once(function()
        view:addLeftMsg(ConstString.hint_end_session)

        if sessionControl.isShouldGrade() then
            sessionControl.logout(GKefuOnlyOneConstant.LOGOUT_TYPE_TIMEOUT, true)
            view:showEvalutePage(function()
                sessionControl.clearAllTask()
                view:hideEvalutePage()
                GKefuViewManager.deleteAllView()
                GKefuNetWorkControl.sendProtocol("disconnect")
                UserData.clearAllData()
                local M = require('kefuSystem/init')
                if M.logoutCallback then
                    KefuRootPath = nil
                    M.logoutCallback()
                    M.logoutCallback = nil
                else
                    GKefuViewManager.showStartView(GKefuOnlyOneConstant.No)
                end
            end)
        else
            sessionControl.logout(GKefuOnlyOneConstant.LOGOUT_TYPE_TIMEOUT)
        end
    end, GKefuOnlyOneConstant.DELAY_END_SESSION)
end


sessionControl.clearAllTask = function()
    if timeOutTask then
        timeOutTask:cancel()
        timeOutTask = nil
    end

    if endSessionTask then
        endSessionTask:cancel()
        endSessionTask = nil
    end
end

--是否是人工服务
sessionControl.isHumanService = function(serviceSiteId)

    if not serviceSiteId then
        local data = UserData.getStatusData() or {}
        serviceSiteId = data.serviceSiteId or "1"
    end

    if serviceSiteId == "0" then
        return true
    else
        return false
    end
end

--判读是否当前是由人工转到机器人
sessionControl.isShiftToRobot = function(oldSid, newSid)
    if sessionControl.isHumanService(oldSid) then
        return not sessionControl.isHumanService(newSid)
    else
        return false
    end
end

--获取客服端的fid
sessionControl.getCurrentServiceFid = function()
    local data = UserData.getStatusData()
    local fid = "null"
    if data and data.serviceGid and data.serviceSiteId and data.serviceStationId then
        fid = string.format("%s/%s/%s", data.serviceGid, data.serviceSiteId, data.serviceStationId)
    end

    return fid
end

--是否需要评分
sessionControl.isShouldGrade = function()
    local dd = UserData.getStatusData() or {}
    --只有登录情况下才需要评分
    if dd.loginCode ~= 1 then return false end


    local data = UserData.getChatViewData() or {}
    if data.couples and data.couples[1] and data.couples[2] then
        return true
    end
    return false
end

--记录下双方至少经过一次聊天
sessionControl.incChatRecord = function(isService)
    if not sessionControl.isHumanService then return end

    local data = UserData.getChatViewData() or {}
    data.couples = data.couples or {}

    if isService then
        data.couples[1] = true
    else
        data.couples[2] = true
    end

    UserData.setChatViewData(data)
end

--处理发送消息, 序列化在本地
sessionControl.dealwithSendMsg = function(message, fullPath)
    sessionControl.incChatRecord()
    --插入历史消息队列
    UserData.insertNewMessage(message)

    local data = UserData.getStatusData()

    local view = nil
    if data.isVip then
        view = GKefuViewManager.getVipChatView()
    else
        view = GKefuViewManager.getNormalChatView()
    end

    if not view then return end

    print_string('send msg type ==== ', message.types)
    if message.types == 1 then --文本消息
        sessionControl.showTimeTips(view)
        local txtWg = view:sendTxtMsg(message)
        local msg = message:unicode2Emoji()

        local callback = function()
            local r = GKefuNetWorkControl.sendProtocol("sendChatMsg", msg, GKefuOnlyOneConstant.MsgType.TXT)
            --表示发送出去了，但服务器是否收到还没确定
            if r == 0 then
                txtWg.failBtn.visible = false
                view:insertSendItem(txtWg)
            else
                --断网等原因发送失败
                txtWg.failBtn.visible = true
            end
        end

        callback()

        txtWg.failBtn.on_click = function()
            view:showSendAgainPage(callback)
        end

    elseif message.types == 2 then --图片
        --message.msg 表示图片路径,不是全路径
        sessionControl.showTimeTips(view)

        local wgImg = view:addImage(message.msg)
        wgImg.sendingIcon.show()

        local callback = function()
            --上传图片, fullPath为图片全路径，相当于本地url
            GKefuNetWorkControl.upLoadFile(fullPath, function(rsp)
                wgImg.sendingIcon.hide()
                --发送失败
                if rsp.errmsg or rsp.code ~= 200 then
                    Log.v("upLoadFile", "发送图片失败!", rsp.errmsg);
                    wgImg.failBtn.visible = true
                    return
                end

                local content = rsp.content
                local tb = cjson.decode(content)
                if tb.code == 0 then
                    wgImg.failBtn.visible = false
                    Log.v("upLoadFile", "发送图片成功!");
                    Log.v("upLoadFile:" .. tb.file)

                    local msgTb = {}
                    msgTb.localUri = fullPath
                    msgTb.remoteUrl = URL.FILE_UPLOAD_HOST .. tb.file
                    --TODO
                    --msgTb.remoteUrl = 'https://cs-test.boyaagame.com' .. tb.file
                    msgTb.voiceLength = 0
                    print_string("sendChatMsg == ", msgTb.remoteUrl)

                    local jsonMsg = cjson.encode(msgTb)
                    GKefuNetWorkControl.sendProtocol("sendChatMsg", jsonMsg, GKefuOnlyOneConstant.MsgType.IMG)
                else
                    wgImg.failBtn.visible = true
                    Log.v("upLoadFile", "发送图片失败!");
                end
            end, GKefuOnlyOneConstant.JPG)
        end

        wgImg.failBtn.on_click = function()
            view:showSendAgainPage(callback)
        end

        callback()

    elseif message.types == 3 then --声音
        sessionControl.showTimeTips(view)
        local voiceItem = view:sendVoice(message.time, message.msg)
        voiceItem.sendingIcon.show()
        --上传语音
        local callback = function()

            GKefuNetWorkControl.upLoadFile(fullPath, function(rsp)
                voiceItem.sendingIcon.hide()

                --发送失败
                if rsp.errmsg or rsp.code ~= 200 then
                    Log.v("upLoadFile", "发送语音失败!");
                    voiceItem.failBtn.visible = true
                    return
                end

                local content = rsp.content
                local tb = cjson.decode(content)
                if tb.code == 0 then
                    Log.v("upLoadFile", "发送语音成功!");
                    voiceItem.failBtn.visible = false
                    local msgTb = {}
                    msgTb.localUri = fullPath
                    msgTb.remoteUrl = URL.FILE_UPLOAD_HOST .. tb.file
                    msgTb.voiceLength = message.time

                    local jsonMsg = cjson.encode(msgTb)
                    GKefuNetWorkControl.sendProtocol("sendChatMsg", jsonMsg, GKefuOnlyOneConstant.MsgType.VOICE)
                else
                    Log.v("upLoadFile", "发送语音失败!");
                    voiceItem.failBtn.visible = true
                end
            end, GKefuOnlyOneConstant.MP3)
        end

        voiceItem.failBtn.on_click = function()
            view:showSendAgainPage(callback)
        end

        callback()
    end

    sessionControl.scheduleSessionTask(view)

    --序列化在本地
    message:saveToDict(true)
end

--根据接收消息刷新界面, 序列化在本地
sessionControl.dealwithChatMsg = function(message)

    UserData.insertNewMessage(message)
    local data = UserData.getStatusData()

    local view = nil
    if data.isVip then
        view = GKefuViewManager.getVipChatView()
    else
        view = GKefuViewManager.getNormalChatView()
    end

    if not view then return end

    if not data.connectCallbackStatus then
        view:hideExceptionTips()
        data.connectCallbackStatus = true
    end
    UserData.setStatusData(data)

    if message.types == 1 then --文本消息
        message:faceChar2UnicodeChar()
        sessionControl.incChatRecord(true)
        sessionControl.showTimeTips(view)
        view:addLeftMsg(message.msg)

    elseif message.types == 2 then --图片
        sessionControl.incChatRecord(true)
        --下载图片
        local fileName = string.format("%simg.png", seqId)
        local filePath = string.format("%s%s", System.getStorageImagePath(), fileName)
        local url = message.msg
        message.msg = fileName


        GKefuNetWorkControl.downLoadFile(url, filePath, function()
            message.msg = fileName
            if view and os.isexist(filePath) then
                sessionControl.showTimeTips(view)
                view:addImage(fileName, true)
            elseif view then
                Log.v("os.isexist", "图片资源不存在")
            end
        end)

    elseif message.types == 3 then --客服声音待定
        sessionControl.incChatRecord(true)

        local fileName = "audio_" .. tostring(Clock.now())
        local filePath = string.format("%s%s", System.getStorageUserPath(), fileName)

        GKefuNetWorkControl.downLoadFile(message.msg, filePath, function()
            message.msg = filePath

            -- if view then
            -- 	sessionControl.showTimeTips(view)
            --     view:addVoice(filePath, true)
            -- end
        end)
    elseif message.types == 4 then --机器人文本消息，带超链接形式
        local status, ret = pcall(cjson.decode, message.msg)
        if status then
            local msgTb = ret
            sessionControl.showTimeTips(view)
            local headStr = msgTb.head or msgTb.foot
            --[[if headStr == "zh:mb.answer"then
                        headStr = msgTb.foot
                    end]]
            if msgTb.foot and string.len(msgTb.foot) > 0 then
                headStr = msgTb.foot
            end
            view:addRobotMsg(headStr, msgTb.links)
        else
            sessionControl.showTimeTips(view)
            view:addLeftMsg(message.msg)
        end
    end

    sessionControl.scheduleSessionTask(view)

    message:saveToDict(true)
end

--显示时间tips
sessionControl.showTimeTips = function(view)
    local tips = UserData.getNewMsgTimeTips()
    if tips then
        view:addTimeTips(tips)
    end
end

--是否有新盗号回复
sessionControl.hasNewAppealReport = function(callback)
    local appealData = UserData.getPlayerReportViewData() or {}
    local dictData = appealData.dictData or {}
    appealData.hasNewReport = 0

    GKefuNetWorkControl.obtainUserTabHistroy(0, 50, URL.HTTP_SUBMIT_APPEAL_HISTORY_URI, function(content)
        local tb
        if type(content) == "string" then
            tb = cjson.decode(content)
        else
            tb = content
        end

        if tb.code == 0 then
            if not tb.data then return end
            local replyData = {}
            for i, v in ipairs(tb.data) do
                --说明是新提交的消息
                if not dictData[v.id] then
                    dictData[v.id] = {}
                    dictData[v.id].reportContent = string.format(ConstString.replay_default, mqtt_client_info.hotline)
                    dictData[v.id].hasNewReport = GKefuOnlyOneConstant.HasNewReport.no
                    dictData[v.id].id = v.id
                    UserData.insertAppealMsg(dictData[v.id])
                end

                --说明是新回复
                if v.reply ~= "" and dictData[v.id].reportContent ~= v.reply then

                    dictData[v.id].reportContent = v.reply
                    dictData[v.id].hasNewReport = GKefuOnlyOneConstant.HasNewReport.yes
                    UserData.updateAppealMsg(dictData[v.id])
                end

                if dictData[v.id].hasNewReport == GKefuOnlyOneConstant.HasNewReport.yes then
                    appealData.hasNewReport = appealData.hasNewReport + 1
                end

                local data = {}
                data.id = v.id
                data.reply = dictData[v.id].reportContent
                data.hasNewReport = dictData[v.id].hasNewReport
                data.time = v.clock
                data.errInfo = v.err_info --新增了错误信息
                data.mid = v.lost_mid
                data.lostTimeStr = v.lost_time
                data.lostChip = v.lost_chip
                data.ip = v.ip
                data.lastChip = v.last_chip
                data.firstLoginTime = v.first_login_time
                data.lastLoginTime = v.last_login_time
                data.bank = v.bank


                table.insert(replyData, data)
            end
            UserData.saveAppealMsg()
            appealData.historyData = replyData
        else
            Log.w("hasNewAppealReport", "盗号内容获取失败")
        end

        appealData.dictData = dictData
        UserData.setPlayerReportViewData(appealData)
        if callback then
            callback(appealData.hasNewReport)
        end
    end)
    UserData.setPlayerReportViewData(appealData)
end

--是否有新的留言回复
sessionControl.hasNewLeaveReport = function(callback)
    local leaveData = UserData.getLeaveMessageViewData() or {}
    local dictData = leaveData.dictData or {}
    leaveData.hasNewReport = 0

    GKefuNetWorkControl.obtainUserTabHistroy(0, 50, URL.HTTP_SUBMIT_ADVISE_HISTORY_URI, function(content)
        local tb
        if type(content) == "string" then
            tb = cjson.decode(content)
        else
            tb = content
        end

        if tb.code == 0 then
            if not tb.data then return end
            table.sort(tb.data, function(v1, v2)
                if v1.id > v2.id then
                    return true
                end
                return false
            end)


            local replyData = {}
            for i, v in ipairs(tb.data) do
                --说明是新提交的消息
                if not dictData[v.id] then
                    dictData[v.id] = {}
                    dictData[v.id].reportContent = string.format(ConstString.replay_default, mqtt_client_info.hotline)
                    dictData[v.id].hasNewReport = GKefuOnlyOneConstant.HasNewReport.no
                    dictData[v.id].id = v.id
                    UserData.insertLeaveMsg(dictData[v.id])
                end

                if v.replies then
                    local replyNum = #v.replies
                    --需要找到最晚客服回复的那条消息与本地消息进行对比，不同则认为有新消息
                    if v.replies[replyNum].from_client == 0 and dictData[v.id].reportContent ~= v.replies[replyNum].reply then

                        dictData[v.id].hasNewReport = GKefuOnlyOneConstant.HasNewReport.yes
                        dictData[v.id].reportContent = v.replies[replyNum].reply
                        UserData.updateLeaveMsg(dictData[v.id])
                    end
                end

                if dictData[v.id].hasNewReport == GKefuOnlyOneConstant.HasNewReport.yes then
                    leaveData.hasNewReport = leaveData.hasNewReport + 1
                end

                local data = {}
                data.title = v.content
                data.time = v.clock
                data.id = v.id
                data.mail = v.mail
                data.phone = v.phone
                data.hasNewReport = dictData[v.id].hasNewReport
                data.isResolved = nil
                --查看是否解决了
                if v.replies then
                    local replyNum = #v.replies
                    data.reply = v.replies[replyNum].reply
                    data.replies = v.replies
                    for _, k in ipairs(v.replies) do
                        if k.is_resolved == 1 then
                            data.isResolved = true
                            break
                        end
                    end
                else
                    data.reply = string.format(ConstString.replay_default, mqtt_client_info.hotline)
                end

                table.insert(replyData, data)
            end

            UserData.saveLeaveMsg()
            leaveData.historyData = replyData
        else
            Log.w("hasNewLeaveReport", "留言内容获取失败")
        end

        leaveData.dictData = dictData
        UserData.setLeaveMessageViewData(leaveData)
        if callback then
            callback(leaveData.hasNewReport)
        end
    end)
end

--是否有新的举报回复
sessionControl.hasNewHackReport = function(callback)
    local hackData = UserData.getHackAppealViewData() or {}
    local dictData = hackData.dictData or {}
    hackData.hasNewReport = 0

    GKefuNetWorkControl.obtainUserTabHistroy(0, 50, URL.HTTP_SUBMIT_REPORT_HISTORY_URI, function(content)
        local tb
        if type(content) == "string" then
            tb = cjson.decode(content)
        else
            tb = content
        end

        if tb.code == 0 then
            if not tb.data then return end
            table.sort(tb.data, function(v1, v2)
                if v1.id > v2.id then
                    return true
                end
                return false
            end)

            local replyData = {}
            for i, v in ipairs(tb.data) do
                --说明是新提交的消息
                v.id = tonumber(v.id)
                if not dictData[v.id] then
                    dictData[v.id] = {}
                    dictData[v.id].reportContent = string.format(ConstString.replay_default, mqtt_client_info.hotline)
                    dictData[v.id].hasNewReport = GKefuOnlyOneConstant.HasNewReport.no
                    dictData[v.id].id = v.id
                    UserData.insertHackMsg(dictData[v.id])
                end

                --说明是新回复
                if v.reply ~= "" and dictData[v.id].reportContent ~= v.reply then

                    dictData[v.id].reportContent = v.reply
                    dictData[v.id].hasNewReport = GKefuOnlyOneConstant.HasNewReport.yes
                    UserData.updateHackMsg(dictData[v.id])
                end

                if dictData[v.id].hasNewReport == GKefuOnlyOneConstant.HasNewReport.yes then
                    hackData.hasNewReport = hackData.hasNewReport + 1
                end

                local data = {}
                data.id = v.id
                data.title = v.report_content
                data.time = v.clock
                data.reply = dictData[v.id].reportContent
                data.typeStr = GKefuOnlyOneConstant.HackNum2MsgType[v.report_type]
                data.mid = v.report_mid
                data.hasNewReport = dictData[v.id].hasNewReport

                table.insert(replyData, data)
            end

            UserData.saveHackMsg()
            hackData.historyData = replyData


        else
            Log.w("hasNewHackReport", "举报内容获取失败")
        end

        hackData.dictData = dictData
        UserData.setHackAppealViewData(hackData)
        if callback then
            callback(hackData.hasNewReport)
        end
    end)
end

--处理统计相关信息
sessionControl.submitStatisticsInfo = function(retries)
    local conn_log = {}
    local tbArray = {}
    local tb = {}
    tb.clock = os.time()
    tb.gid = mqtt_client_config.gameId
    tb.sid = mqtt_client_config.siteId
    tb.mid = mqtt_client_config.stationId
    tb.connectivity = mqtt_client_info.connectivity
    tb.ip = mqtt_client_info.ip
    tb.deviceType = mqtt_client_info.deviceType
    tb.deviceDetail = mqtt_client_info.deviceDetail
    tb.osVersion = mqtt_client_info.OSVersion
    tb.sdkVersion = mqtt_client_info.sdkVersion
    tb.success = 1
    tb.retries = retries
    tbArray[1] = tb
    conn_log.conn_log = tbArray

    local content = cjson.encode(conn_log)

    GKefuNetWorkControl.postString(URL.HTTP_SUBMIT_STATISTICAL_MESSAGE_URI, content, function(rsp)
        if rsp.errmsg then
            Log.s("submitStatisticsInfo", "Fail errmsg:", rsp.errmsg);
        elseif rsp.code ~= 200 then
            Log.s("submitStatisticsInfo", "Fail code:", rsp.code);
        else
            Log.v("submitStatisticsInfo", "sucess", rsp.content)
        end
    end)
end



--登出后的数据状态重置
--stayView为true表示继续呆在客服系统界面，这时应该只是登出，网络连接不断开
sessionControl.logout = function(logoutType, stayView)
    sessionControl.clearAllTask()
    GKefuNetWorkControl.cancelPollLoginTask()
    Record.getInstance():stopTrack()
    Record.releaseInstance()
    UserData.resaveHistoryData()
    kefuCommon.deleteSendingItems()

    local data = UserData.getStatusData() or {}
    if not stayView then
        data.isOut = true
        GKefuViewManager.deleteAllView()

        local M = require('kefuSystem/init')
        if M.logoutCallback then
            KefuRootPath = nil
            M.logoutCallback()
            M.logoutCallback = nil
        else
            GKefuViewManager.showStartView(GKefuOnlyOneConstant.No)
        end
    end
    data.logoutType = logoutType or GKefuOnlyOneConstant.LOGOUT_TYPE_USER


    --只有已经登录才需要发logout消息
    if data.conversationStatus and
            (data.conversationStatus == ConversationStatus_Map.LOGINED
                    or data.conversationStatus == ConversationStatus_Map.SESSION) then
        GKefuNetWorkControl.sendProtocol("logout", data.logoutType)
    end
    data.conversationStatus = ConversationStatus_Map.LOGOUT
    UserData.setStatusData(data)

    if not stayView then
        GKefuNetWorkControl.sendProtocol("disconnect")
        UserData.clearAllData()
    end
end




return sessionControl