local GKefuOnlyOneConstant = require('kefuSystem/common/kefuConstant')

--- 历史消息文件名
local HISTORY_MSG_PATH = "kefu_history_msg_file"
local LEAVE_MSG_PATH = "kefu_leave_msg_file"
local HACK_MSG_PATH = "kefu_hack_msg_file"
local KEFU_APPEAL_MSG_PATH = "kefu_appeal_msg_file"

local dataInstance = {}
local historyDict = nil
local historyData = nil
local historyNum = 0
local leaveMsgDict = nil
local leaveNum = 0
local hackMsgDict = nil
local hackNum = 0
local appealMsgDict = nil
local appealNum = 0
local data = {}
--标记显示过的历史消息索引
local showId = 0



local viewInfo = {
    "Status", --状态数据
    "StartView", --各个界面独有的数据
    "HackAppealView",
    "ChatView",
    "LeaveMessageView",
    "PlayerReportView",
}

local leaveSaveInfo = {
    phone = "phone",
    types = "type",
    content = "content",
    imgPath = "imgPath",
    imgUrl = "imgUrl",
}

local hackSaveInfo = {
    id = "hackId",
    types = "type",
    content = "content",
    imgPath = "imgPath",
    imgUrl = "imgUrl",
}


local function initData()
    for i, name in ipairs(viewInfo) do
        local setName = string.format("set%sData", name)
        dataInstance[setName] = function(dt)
            data[name] = dt
        end

        local getName = string.format("get%sData", name)

        dataInstance[getName] = function()
            return data[name]
        end

        local clearName = string.format("clear%sData", name)
        dataInstance[clearName] = function()
            data[name] = nil
        end
    end
end

dataInstance.clearAllData = function()
    data = {}
    historyData = nil
    historyNum = 0
    showId = 0
    if historyDict then
        delete(historyDict)
        historyDict = nil
    end

    leaveNum = 0
    if leaveMsgDict then
        delete(leaveMsgDict)
        leaveMsgDict = nil
    end

    hackNum = 0
    if hackMsgDict then
        delete(hackMsgDict)
        hackMsgDict = nil
    end
end

dataInstance.isClear = function()
    return historyDict and leaveMsgDict and hackMsgDict
end

--当历史消息到达超过某个数量时，清理之,保存最新部分消息.
dataInstance.resaveHistoryData = function()
    if historyDict and historyData and #historyData > 200 then
        historyDict:delete()
        historyNum = 0
        local num = 100
        for i = 1, num do
            historyData[i]:saveToDict()
        end
        historyDict:setInt("msgNum", num)
        historyDict:save()
    end
end

--处理服务器发送过来的历史消息
--先记录在historyData中，之后saveToDict
dataInstance.addHistoryMsg = function(content)
    local ChatMessage = require('kefuSystem/conversation/chatMessage')

    for i, v in ipairs(content) do
        local tb = ChatMessage(v.seq_id, v.msg_type, v.msg, v.session_id, v.from_client)

        --如果是图片，则msg存储的是部分路径
        if tb.types == 1 then
            tb:faceChar2UnicodeChar()
        elseif tb.types == 2 then
            v.msg = string.gsub(v.msg, [[\]], [[\\]])
            local msgTb = cjson.decode(v.msg)
            tb.msg = string.gsub(msgTb.localUri, System.getStorageImagePath(), "")

            tb.remoteUrl = msgTb.remoteUrl
        elseif tb.types == 3 then
            --如果是语音，msg保存全路径
            v.msg = string.gsub(v.msg, [[\]], [[\\]])
            local msgTb = cjson.decode(v.msg)
            tb.msg = msgTb.localUri
            tb.remoteUrl = msgTb.remoteUrl
            tb.voiceLength = msgTb.voiceLength
        end

        --todo:需要考虑图片和语音数据不存在本地的情况
        --这时候需要先拉去全部图片和语音数据后再更新界面

        table.insert(historyData, tb)
        tb:saveToDict()
    end

    historyDict:save()
end

--获取最早的消息时间
dataInstance.getLastMsgSeqId = function()
    if not next(historyData) then
        return (os.time() - 10) * 1000
    end

    return historyData[#historyData].seqId
end


local initHistoryDict = function()
    local ChatMessage = require('kefuSystem/conversation/chatMessage')

    if not historyDict then
        historyData = historyData or {}
        local path = HISTORY_MSG_PATH .. mqtt_client_config.stationId
        historyDict = new(Dict, path)
        historyDict:load()

        historyNum = historyDict:getInt("msgNum", 0)
        if historyNum > 0 then
            for i = 1, historyNum do
                local key = string.format("k_%d", i)
                local v = historyDict:getString(key)
                if v ~= "" then
                    local tb = cjson.decode(v)
                    local msg = ChatMessage(tb.seqId, tb.types, tb.msg, 1, tb.isClient)
                    table.insert(historyData, msg)
                end
            end
        end

        --按消息时间降序排序
        table.sort(historyData, function(v1, v2)
            if v1.seqId > v2.seqId then
                return true
            end
            return false
        end)
    end
end

--获取本地历史 msg data
-- historyData 维护了历史消息队列(降序排序)，每次用户和客服人员发送的消息都需要插入到historyData 
dataInstance.getHistoryMsgFromDB = function(num)
    initHistoryDict()

    if showId >= #historyData then return end
    local realNum = num or GKefuOnlyOneConstant.PAGE_SIZE

    local data = {}
    local eIdx = showId + realNum < #historyData and showId + realNum or #historyData
    for i = showId + 1, eIdx do
        table.insert(data, historyData[i])
    end

    showId = eIdx


    return data
end


--序列化一条历史消息, msg参数是json字符串, isSave 表示是否调用dict:save
dataInstance.insertHistoryMsg = function(msg, isSave)
    initHistoryDict()
    print_string("msg inserthistory type = ", msg.types)
    historyNum = historyNum + 1
    local key = string.format("k_%d", historyNum)
    historyDict:setString(key, msg)
    historyDict:setInt("msgNum", historyNum)
    if isSave then
        historyDict:save()
    end
end

--插入一条最新的消息
dataInstance.insertNewMessage = function(message)
    historyData = historyData or {}
    table.insert(historyData, 1, message)
    --移动显示的消息id, 用于历史记录
    showId = showId + 1
end

--重置历史消息显示的索引
dataInstance.resetHistoryIndex = function()
    showId = 0
end

--获取消息的时间tips，两条消息时间间隔超过1分钟才获取
dataInstance.getNewMsgTimeTips = function()
    if not historyData then return nil end

    if #historyData == 1 then
        return historyData[1]:getStringTime()
    end

    if tonumber(historyData[1].seqId) - tonumber(historyData[2].seqId) > GKefuOnlyOneConstant.INTERVAL_IN_MILLISECONDS then
        return historyData[1]:getStringTime()
    end

    return nil
end

--初始化留言记录，用于记录是否被浏览了
dataInstance.initLeaveDict = function()
    if not leaveMsgDict then

        local path = LEAVE_MSG_PATH .. mqtt_client_config.stationId
        leaveMsgDict = new(Dict, path)
        leaveMsgDict:load()
    end

    leaveNum = leaveMsgDict:getInt("msgNum", 0)
    local info = {}
    if leaveNum > 0 then
        for i = 1, leaveNum do
            --id 的key
            local idx = string.format("k_%d", i)
            --内容的id
            local key = leaveMsgDict:getInt(idx)
            --内容
            local v = leaveMsgDict:getString(tostring(key))
            if v ~= "" then
                local tb = cjson.decode(v)
                tb.id = tonumber(tb.id)
                info[tb.id] = tb
            end
        end
    end

    local leaveData = dataInstance.getLeaveMessageViewData() or {}
    leaveData.dictData = info
    dataInstance.setLeaveMessageViewData(leaveData)
end

dataInstance.insertLeaveMsg = function(msg)
    if not leaveMsgDict then return end
    leaveNum = leaveNum + 1
    leaveMsgDict:setInt("msgNum", leaveNum)
    local key = string.format("k_%d", leaveNum)
    leaveMsgDict:setInt(key, msg.id)

    local content = cjson.encode(msg)
    leaveMsgDict:setString(tostring(msg.id), content)
end

dataInstance.updateLeaveMsg = function(msg)
    if not leaveMsgDict then return end
    local content = cjson.encode(msg)
    leaveMsgDict:setString(tostring(msg.id), content)
end

dataInstance.saveLeaveMsg = function()
    if leaveMsgDict then
        leaveMsgDict:save()
    end
end


--初始化举报记录，用于记录是否被浏览了
dataInstance.initHackDict = function()
    if not hackMsgDict then
        local path = HACK_MSG_PATH .. mqtt_client_config.stationId
        hackMsgDict = new(Dict, path)
        hackMsgDict:load()
    end

    hackNum = hackMsgDict:getInt("msgNum", 0)
    local info = {}
    if hackNum > 0 then
        for i = 1, hackNum do
            --id 的key
            local idx = string.format("k_%d", i)
            --内容的id
            local key = hackMsgDict:getInt(idx)
            --内容
            local v = hackMsgDict:getString(tostring(key))
            if v ~= "" then
                local tb = cjson.decode(v)
                info[tb.id] = tb
            end
        end
    end

    data["HackAppealView"] = data["HackAppealView"] or {}
    data["HackAppealView"].dictData = info
end

dataInstance.insertHackMsg = function(msg)
    if not hackMsgDict then return end
    hackNum = hackNum + 1
    hackMsgDict:setInt("msgNum", hackNum)
    local key = string.format("k_%d", hackNum)
    hackMsgDict:setInt(key, msg.id)

    local content = cjson.encode(msg)
    hackMsgDict:setString(tostring(msg.id), content)
end


dataInstance.updateHackMsg = function(msg)
    if not hackMsgDict then return end
    local content = cjson.encode(msg)
    hackMsgDict:setString(tostring(msg.id), content)
end

dataInstance.saveHackMsg = function()
    if hackMsgDict then
        hackMsgDict:save()
    end
end

dataInstance.initAppealDict = function()
    if not appealMsgDict then
        local path = KEFU_APPEAL_MSG_PATH .. mqtt_client_config.stationId
        appealMsgDict = new(Dict, path)
        appealMsgDict:load()
    end

    appealNum = appealMsgDict:getInt("msgNum", 0)

    local info = {}
    if appealNum > 0 then
        for i = 1, appealNum do
            local idx = string.format("k_%d", i)
            --内容的id
            local key = appealMsgDict:getInt(idx)
            --内容
            local v = appealMsgDict:getString(tostring(key))
            if v ~= "" then
                local tb = cjson.decode(v)
                info[tb.id] = tb
            end
        end

        data["PlayerReportView"] = data["PlayerReportView"] or {}
        data["PlayerReportView"].dictData = info
    end
end

dataInstance.insertAppealMsg = function(msg)
    if not appealMsgDict then return end
    appealNum = appealNum + 1
    appealMsgDict:setInt("msgNum", appealNum)
    local key = string.format("k_%d", appealNum)
    appealMsgDict:setInt(key, msg.id)

    local content = cjson.encode(msg)
    appealMsgDict:setString(tostring(msg.id), content)
end

dataInstance.updateAppealMsg = function(msg)
    if not appealMsgDict then return end
    local content = cjson.encode(msg)
    appealMsgDict:setString(tostring(msg.id), content)
end

dataInstance.saveAppealMsg = function()
    if appealMsgDict then
        appealMsgDict:save()
    end
end


---------------- leave-------------
dataInstance.saveLeavePhoneNumber = function(phone)
    if leaveMsgDict then
        leaveMsgDict:setString(leaveSaveInfo.phone, phone)
    end
end

dataInstance.getLeavePhoneNumber = function()
    return leaveMsgDict and leaveMsgDict:getString(leaveSaveInfo.phone)
end

dataInstance.saveLeaveTypes = function(types)
    if leaveMsgDict then
        leaveMsgDict:setString(leaveSaveInfo.types, types)
    end
end

dataInstance.getLeaveTypes = function()
    return leaveMsgDict and leaveMsgDict:getString(leaveSaveInfo.types)
end

dataInstance.saveLeaveContent = function(content)
    if leaveMsgDict then
        leaveMsgDict:setString(leaveSaveInfo.content, content)
    end
end

dataInstance.getLeaveContent = function()
    return leaveMsgDict and leaveMsgDict:getString(leaveSaveInfo.content)
end

dataInstance.saveLeaveImgPath = function(imgPath)
    if leaveMsgDict then
        leaveMsgDict:setString(leaveSaveInfo.imgPath, imgPath)
    end
end

dataInstance.getLeaveImgPath = function()
    return leaveMsgDict and leaveMsgDict:getString(leaveSaveInfo.imgPath)
end

dataInstance.saveLeaveImgUrl = function(imgUrl)
    if leaveMsgDict then
        leaveMsgDict:setString(leaveSaveInfo.imgUrl, imgUrl)
    end
end

dataInstance.getLeaveImgUrl = function()
    return leaveMsgDict and leaveMsgDict:getString(leaveSaveInfo.imgUrl)
end

---------------- hack-------------
dataInstance.saveHackId = function(id)
    if not hackMsgDict then return end
    hackMsgDict:setString(hackSaveInfo.id, id)
end

dataInstance.getHackId = function()
    if not hackMsgDict then return end
    return hackMsgDict:getString(hackSaveInfo.id)
end

dataInstance.saveHackTypes = function(types)
    if not hackMsgDict then return end
    hackMsgDict:setString(hackSaveInfo.types, types)
end

dataInstance.getHackTypes = function()
    if not hackMsgDict then return end
    return hackMsgDict:getString(hackSaveInfo.types)
end

dataInstance.saveHackContent = function(content)
    if not hackMsgDict then return end
    hackMsgDict:setString(hackSaveInfo.content, content)
end

dataInstance.getHackContent = function()
    if not hackMsgDict then return end
    return hackMsgDict:getString(hackSaveInfo.content)
end

dataInstance.saveHackImgPath = function(imgPath)
    if not hackMsgDict then return end
    hackMsgDict:setString(hackSaveInfo.imgPath, imgPath)
end

dataInstance.getHackImgPath = function()
    if not hackMsgDict then return end
    return hackMsgDict:getString(hackSaveInfo.imgPath)
end

dataInstance.saveHackImgUrl = function(imgUrl)
    if not hackMsgDict then return end
    hackMsgDict:setString(hackSaveInfo.imgUrl, imgUrl)
end

dataInstance.getHackImgUrl = function()
    if not hackMsgDict then return end
    return hackMsgDict:getString(hackSaveInfo.imgUrl)
end


initData()

return dataInstance 
