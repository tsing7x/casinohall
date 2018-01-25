--------------------界面管理--------------------

-- local startView = require('kefuSystem/view/startView')
-- local hackAppealView = require('kefuSystem/view/hackAppealView')
-- local vipChatView = require('kefuSystem/view/vipChatView')
-- local leaveMessageView = require('kefuSystem/view/leaveMessageView')
-- local playerReportView  = require('kefuSystem/view/playerReportView')
-- local normalChatView = require('kefuSystem/view/normalChatView')
local Am = require('animation')
local GKefuOnlyOneConstant = require('kefuSystem/common/kefuConstant')

local currentView = nil
local currentName = nil
local preView = nil
local preName = nil
local viewManager = {}

--界面配置信息
local sceneInfo = {
    ["StartView"] = "kefuSystem/view/startView",
    ["HackAppealView"] = "kefuSystem/view/hackAppealView",
    ["VipChatView"] = "kefuSystem/view/vipChatView",
    ["LeaveMessageView"] = "kefuSystem/view/leaveMessageView",
    ["PlayerReportView"] = "kefuSystem/view/playerReportView",
    ["NormalChatView"] = "kefuSystem/view/normalChatView",

}



local sceneInstance = {}


local function sceneInit()
    --显示上个界面
    viewManager.showPreView = function (...)
        if preName and preView then
            viewManager["show"..preName](...)
        end
    end

    viewManager.getViewName = function (view)
        for name, v in pairs(sceneInstance) do
            if v == view then
                return name
            end
        end
    end

    for name, classPath in pairs(sceneInfo) do
        local funcName = "show"..name
        viewManager[funcName] = function (animType, ...)
            local classType = require(classPath)
            if currentName == name then return end 
            preName = currentName
            currentName = name

            preView = currentView

            if sceneInstance[name] then
                currentView = sceneInstance[name];
                
            else
                sceneInstance[name] = classType(...);
                currentView = sceneInstance[name];
            end
            currentView:onUpdate(...)
            currentView:onShow(animType or GKefuOnlyOneConstant.RTOL);
            if preView then 
                preView:onHide(animType or GKefuOnlyOneConstant.RTOL)
            end

            return sceneInstance[name]

        end

        local loadFunc = "preLoad"..name
        viewManager[loadFunc] = function (...)
            local classType = require(classPath)
            if not sceneInstance[name] then
                sceneInstance[name] = classType(...)
            end
        end

        local hideFunc = "hide"..name
        viewManager[hideFunc] = function ()
            if sceneInstance[name] then
                sceneInstance[name]:onHide()
                if currentName and currentName == name then
                    currentName = ""
                    currentView = nil
                end
            end
        end

        local getViewFunc = "get"..name
        viewManager[getViewFunc] = function ()
            return sceneInstance[name]
        end

        local deleteFunc = "delete"..name
        viewManager[deleteFunc] = function ()
            if sceneInstance[name] then
                if currentName and currentName == name then
                    currentName = ""
                    currentView = nil
                end

                sceneInstance[name]:onDelete()
                sceneInstance[name] = nil
            end
        end


    end

    viewManager.onBackEvent = function ()
        if currentView and currentView.onBackEvent then
            currentView:onBackEvent()
        end
    end

    

    viewManager.deleteAllView = function ()
        EventDispatcher.getInstance():unregister(Event.Back, viewManager, viewManager.onBackEvent)
        
        for name, v in pairs(sceneInstance) do
            if name ~= "StartView" then
                v:onDelete()
                v = nil
                sceneInstance[name] = nil
            end
        end

        currentView = nil
        currentName = nil
        preView = nil
        preName = nil

    end
end

sceneInit()


return viewManager
