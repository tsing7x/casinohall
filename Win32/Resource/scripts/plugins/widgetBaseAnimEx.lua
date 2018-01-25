
--------------------------------------------

local ActionUnitManager = class()

local s_ActionUnitManagerInstance = nil

local s_isUpdating = false
local dirtyWidgetClock = nil
local dirtyList = {}
local s_curSt = 0

function ActionUnitManager.getInstance()
    if not s_ActionUnitManagerInstance then
        s_ActionUnitManagerInstance = new(ActionUnitManager)
    end
    return s_ActionUnitManagerInstance
end

function ActionUnitManager:ctor()
    self.actionUnitList = {}
end

function ActionUnitManager:dtor()
    self.actionUnitList = nil
end

function ActionUnitManager:add(action)
    for k, actionUnit in ipairs(action:getUnits()) do
        table.insert(self.actionUnitList, actionUnit)
    end
    if not self.scheduleClock then
        self.scheduleClock = Clock.instance():schedule(function(dt)
            return self:update(dt)
        end)
    end
end

function ActionUnitManager:update(dt)
    s_curSt = dt
    s_isUpdating = true
    if not self.actionUnitList then return true end
    local list = {}
    for k, actionUnit in ipairs(self.actionUnitList) do
        table.insert(list, actionUnit)
    end
    for k, actionUnit in ipairs(list) do
        if not actionUnit.ignore then
            local past = actionUnit.past
            local time = actionUnit.time
            past = past + dt * 1000
            local progress = past/time
            progress = progress > 1 and 1 or progress
            local totalOffset = actionUnit.totalOffset
            if totalOffset and not actionUnit.override then
                actionUnit.originValue = actionUnit.originValue or actionUnit.getValue()
                local interpolationFunc = actionUnit.interpolationFunc
                -- local curValue = actionUnit.getValue()
                local lastOffset = actionUnit.lastOffset
                local newOffset = interpolationFunc(totalOffset, progress)
                -- local newValue = curValue + (newOffset - lastOffset)
                local newValue = actionUnit.originValue + newOffset
                actionUnit.setValue(newValue)
                actionUnit.lastOffset = newOffset
            end
            actionUnit.past = past
            actionUnit.setProgress(progress)
        end
    end
    local index = 1
    local actionList = self.actionUnitList
    while index <= #actionList do
        local actionUnit = actionList[index]
        if actionUnit.ignore or actionUnit.progress == 1 then
            table.remove(actionList, index)
        else
            index = index + 1
        end
    end
    s_isUpdating = false
    if #dirtyList > 0 then
        for k, v in ipairs(dirtyList) do
            if v.__dirty then
                v:___updateMatrix()
                v.__dirty = false
            end
        end
        dirtyList = {}
    end
    if #actionList == 0 then 
        self.scheduleClock = nil
        return true 
    end
end

function ActionUnitManager:resume()
    if self.scheduleClock then
        self.scheduleClock.paused = false
    end
end

function ActionUnitManager:pause()
    if self.scheduleClock then
        self.scheduleClock.paused = true
    end
end

--------------------------------------------

Action = {}

local linearFunc = function(offset, progress)
    return offset * progress
end

Action.easeInBack = function(offset, progress)
    local t = progress
    return offset *(t) * t *((1.70158 + 1) * t - 1.70158)
end

Action.easeOutBack = function(offset, progress)
    local s = 1.70158
    local t = progress - 1
    return offset *(t * t *((1.70158 + 1) * t + 1.70158) + 1)
end

Action.easeInOutQuad = function(offset, progress)
    t = progress / (1 / 2)
    if (t < 1) then
        return offset / 2 * t * t
    end
    t = t - 1
    return - offset / 2 *(t *(t - 2) -1)
end

local emptyFunc = function()

end

Action.easeInOutBack = function(offset, progress)
    local s = 1.70158
    local t = progress * 2
    if (t < 1) then
        s = s * (1.525)
        return offset / 2 *(t * t *((s + 1) * t - s))
    end
    s = s * (1.525)
    t = t - 2
    return offset / 2 *(t * t *((s + 1) * t + s) + 2)
end

Action.Move = function(args)
    local action = {}
    local _target
    local unitList = nil
    action.setTarget = function(target)
        local onComplete = args.onComplete or emptyFunc
        unitList = {}
        _target = target
        local offsetX, offsetY
        local x, y = target:getPos()
        if args.x then
            offsetX = args.offset and args.x or args.x - x
        end
        if args.y then
            offsetY = args.offset and args.y or args.y - y
        end
        args.interpolationFunc = args.interpolationFunc or args.ease
        if offsetX and offsetX ~= 0 then
            local actionUnit = {}
            table.insert(unitList, actionUnit)
            actionUnit.past = 0
            actionUnit.time = (args.time and args.time > 0) and args.time * 1000  or 1
            actionUnit.totalOffset = offsetX
            actionUnit.lastOffset = 0
            actionUnit.interpolationFunc = args.interpolationFunc or linearFunc
            actionUnit.getValue = function()
                local x, y = target:getPos()
                return x
            end
            actionUnit.setValue = function(value)
                local x, y = target:getPos()
                target:setPos(value, y)
            end
            actionUnit.setProgress = function(progress)
                actionUnit.progress = progress
                if progress == 1 and onComplete then
                    onComplete()
                    onComplete = nil
                    if action.___onActionComplete then action.___onActionComplete() end
                end
                if progress == 1 then
                    target:___clearActionUnitByType("x", actionUnit)
                end
            end
            target:___setActionUnitByType("x", actionUnit)
        end
        if offsetY and offsetY ~= 0 then
            local actionUnit = {}
            table.insert(unitList, actionUnit)
            actionUnit.past = 0
            actionUnit.time = (args.time and args.time > 0) and args.time * 1000  or 1
            actionUnit.totalOffset = offsetY
            actionUnit.lastOffset = 0
            actionUnit.interpolationFunc = args.interpolationFunc or linearFunc
            actionUnit.getValue = function()
                local x, y = target:getPos()
                return y
            end
            actionUnit.setValue = function(value)
                local x, y = target:getPos()
                target:setPos(x, value)
            end
            actionUnit.setProgress = function(progress)
                actionUnit.progress = progress
                if progress == 1 and onComplete then
                    onComplete()
                    onComplete = nil
                    if action.___onActionComplete then action.___onActionComplete() end
                end
                if progress == 1 then
                    target:___clearActionUnitByType("y", actionUnit)
                end
            end
            target:___setActionUnitByType("y", actionUnit)
        end
        if #unitList == 0 then
            local actionUnit = {}
            table.insert(unitList, actionUnit)
            actionUnit.past = 0
            actionUnit.time = (args.time and args.time > 0) and args.time * 1000  or 1
            actionUnit.setProgress = function(progress)
                actionUnit.progress = progress
                if progress == 1 and onComplete then
                    onComplete()
                    onComplete = nil
                    if action.___onActionComplete then action.___onActionComplete() end
                end
            end
        end
    end
    action.getUnits = function()
        return unitList
    end
    action.getTarget = function()
        return _target
    end
    action.stop = function()
        for k, v in ipairs(unitList) do
            v.ignore = true
        end
    end
    return action
end

Action.Scale = function(args)
    local action = {}
    local _target
    local unitList = nil
    action.setTarget = function(target)
        local onComplete = args.onComplete or emptyFunc
        _target = target
        unitList = {}
        local offsetX, offsetY
        local x, y = target:getScaleX(), target:getScaleY()
        if args.scaleX then
            offsetX = args.offset and args.scaleX or args.scaleX - x
        end
        if args.scaleY then
            offsetY = args.offset and args.scaleY or args.scaleY - y
        end
        args.interpolationFunc = args.interpolationFunc or args.ease
        if offsetX and offsetX ~= 0 then
            local actionUnit = {}
            table.insert(unitList, actionUnit)
            actionUnit.past = 0
            actionUnit.time = (args.time and args.time > 0) and args.time * 1000  or 1
            actionUnit.totalOffset = offsetX
            actionUnit.lastOffset = 0
            actionUnit.interpolationFunc = args.interpolationFunc or linearFunc
            actionUnit.getValue = function()
                return target:getScaleX()
            end
            actionUnit.setValue = function(value)
                target:setScaleX(value)
            end
            actionUnit.setProgress = function(progress)
                actionUnit.progress = progress
                if progress == 1 and onComplete then
                    onComplete()
                    onComplete = nil
                    if action.___onActionComplete then action.___onActionComplete() end
                end
                if progress == 1 then
                    target:___clearActionUnitByType("scaleX", actionUnit)
                end
            end
            target:___setActionUnitByType("scaleX", actionUnit)
        end
        if offsetY and offsetY ~= 0 then
            local actionUnit = {}
            table.insert(unitList, actionUnit)
            actionUnit.past = 0
            actionUnit.time = (args.time and args.time > 0) and args.time * 1000  or 1
            actionUnit.totalOffset = offsetY
            actionUnit.lastOffset = 0
            actionUnit.interpolationFunc = args.interpolationFunc or linearFunc
            actionUnit.getValue = function()
                return target:getScaleY()
            end
            actionUnit.setValue = function(value)
                target:setScaleY(value)
            end
            actionUnit.setProgress = function(progress)
                actionUnit.progress = progress
                if progress == 1 and onComplete then
                    onComplete()
                    onComplete = nil
                    if action.___onActionComplete then action.___onActionComplete() end
                end
                if progress == 1 then
                    target:___clearActionUnitByType("scaleY", actionUnit)
                end
            end
            target:___setActionUnitByType("scaleY", actionUnit)
        end
        if #unitList == 0 then
            local actionUnit = {}
            table.insert(unitList, actionUnit)
            actionUnit.past = 0
            actionUnit.time = (args.time and args.time > 0) and args.time * 1000  or 1
            actionUnit.setProgress = function(progress)
                actionUnit.progress = progress
                if progress == 1 and onComplete then
                    onComplete()
                    onComplete = nil
                    if action.___onActionComplete then action.___onActionComplete() end
                end
            end
        end
    end
    action.setOverride = function()
        for k, v in ipairs(unitList) do
            v.override = true
        end
    end
    action.getUnits = function()
        return unitList
    end
    action.getTarget = function()
        return _target
    end
    action.stop = function()
        for k, v in ipairs(unitList) do
            v.ignore = true
        end
    end
    return action
end

Action.Rotate = function(args)
    local action = {}
    local _target
    local unitList = nil
    action.setTarget = function(target)
        local onComplete = args.onComplete or emptyFunc
        _target = target
        unitList = {}
        local offset
        local angle = target:getRotation()
        args.angle = args.angle or args.rotate
        args.interpolationFunc = args.interpolationFunc or args.ease
        if args.angle then
            offset = args.offset and args.angle or args.angle - angle
        end
        if offset and offset ~= 0 then
            local actionUnit = {}
            table.insert(unitList, actionUnit)
            actionUnit.past = 0
            actionUnit.time = (args.time and args.time > 0) and args.time * 1000  or 1
            actionUnit.totalOffset = offset
            actionUnit.lastOffset = 0
            actionUnit.interpolationFunc = args.interpolationFunc or linearFunc
            actionUnit.getValue = function()
                return target.__angle or 0
            end
            actionUnit.setValue = function(value)
                target:setRotation(value)
            end
            actionUnit.setProgress = function(progress)
                actionUnit.progress = progress
                if progress == 1 and onComplete then
                    onComplete()
                    onComplete = nil
                    if action.___onActionComplete then action.___onActionComplete() end
                    target:___clearActionUnitByType("rotation", actionUnit)
                end
            end
            target:___setActionUnitByType("rotation", actionUnit)
        end
        if #unitList == 0 then
            local actionUnit = {}
            table.insert(unitList, actionUnit)
            actionUnit.past = 0
            actionUnit.time = (args.time and args.time > 0) and args.time * 1000  or 1
            actionUnit.setProgress = function(progress)
                actionUnit.progress = progress
                if progress == 1 and onComplete then
                    onComplete()
                    onComplete = nil
                    if action.___onActionComplete then action.___onActionComplete() end
                end
            end
        end
    end
    action.getUnits = function()
        return unitList
    end
    action.getTarget = function()
        return _target
    end
    action.stop = function()
        for k, v in ipairs(unitList) do
            v.ignore = true
        end
    end
    return action
end

Action.Fade = function(args)
    local action = {}
    local _target
    local unitList = nil
    
    action.setTarget = function(target)
        local onComplete = args.onComplete or emptyFunc
        _target = target
        unitList = {}
        local offset
        local alpha = target:getTransparency()
        args.alpha = args.alpha or args.opacity
        args.interpolationFunc = args.interpolationFunc or args.ease
        if args.alpha then
            offset = args.offset and args.alpha or args.alpha - alpha
        end
        if offset and offset ~= 0 then
            local actionUnit = {}
            table.insert(unitList, actionUnit)
            actionUnit.past = 0
            actionUnit.time = (args.time and args.time > 0) and args.time * 1000  or 1
            actionUnit.totalOffset = offset
            actionUnit.lastOffset = 0
            actionUnit.interpolationFunc = args.interpolationFunc or linearFunc
            actionUnit.getValue = function()
                return target:getTransparency()
            end
            actionUnit.setValue = function(value)
                if value < 0 then value = 0 end
                if value > 1 then value = 1 end
                target:setTransparency(value)
            end
            actionUnit.setProgress = function(progress)
                actionUnit.progress = progress
                if progress == 1 and onComplete then
                    onComplete()
                    onComplete = nil
                    if action.___onActionComplete then action.___onActionComplete() end
                    target:___clearActionUnitByType("alpha", actionUnit)
                end
            end
            target:___setActionUnitByType("alpha", actionUnit)
        end
        if #unitList == 0 then
            local actionUnit = {}
            table.insert(unitList, actionUnit)
            actionUnit.past = 0
            actionUnit.time = (args.time and args.time > 0) and args.time * 1000  or 1
            actionUnit.setProgress = function(progress)
                actionUnit.progress = progress
                if progress == 1 and onComplete then
                    onComplete()
                    onComplete = nil
                    if action.___onActionComplete then action.___onActionComplete() end
                end
            end
        end
    end
    action.getUnits = function()
        return unitList
    end
    action.getTarget = function()
        return _target
    end
    action.stop = function()
        for k, v in ipairs(unitList) do
            v.ignore = true
        end
    end
    return action
end

Action.Delay = function(args)
    local action = {}
    local _target
    local unitList = nil
    action.setTarget = function(target)
        local onComplete = args.onComplete or emptyFunc
        _target = target
        unitList = {}
        local actionUnit = {}
        table.insert(unitList, actionUnit)
        actionUnit.past = 0
        actionUnit.time = (args.time and args.time > 0) and args.time * 1000  or 1
        actionUnit.setProgress = function(progress)
            actionUnit.progress = progress
            if progress == 1 and onComplete then
                onComplete()
                onComplete = nil
                if action.___onActionComplete then action.___onActionComplete() end
            end
        end
    end
    action.getUnits = function()
        return unitList
    end
    action.getTarget = function()
        return _target
    end
    action.stop = function()
        for k, v in ipairs(unitList) do
            v.ignore = true
        end
    end
    return action
end

Action.Sequence = function(actions)
    -- local actions = {...}
    for k, v in ipairs(actions) do
        v.tag = actions -- then the actions can remove
    end
    actions.actionType = "Sequence"
    return actions
end

Action.Spawn = function(actions)
    -- local actions = {...}
    for k, v in ipairs(actions) do
        v.tag = actions -- then the actions can remove
    end
    actions.actionType = "Spawn"
    return actions
end

Action.Repeat = function(actions)
    -- local actions = {...}
    for k, v in ipairs(actions) do
        v.tag = actions -- then the actions can remove
    end
    actions.actionType = "Repeat"
    return actions
end

--------------------------------------------

function WidgetBase:runAction(actionOrList)
    local isList = #actionOrList > 0
    if isList then
        if actionOrList.actionType == "Sequence" or actionOrList.actionType == "Repeat" then
            local curIndex = 1
            local totalLen = #actionOrList
            local function popupActions()
                if totalLen >= curIndex then
                    local action = actionOrList[curIndex]
                    action.___onActionComplete = function()
                        popupActions()
                    end
                    self:runAction(action)
                    if totalLen == curIndex and actionOrList.actionType == "Repeat" then
                        curIndex = 1
                    else
                        curIndex = curIndex + 1
                    end
                else
                    if actionOrList.___onActionComplete then
                        actionOrList.___onActionComplete()
                    end
                end
            end
            popupActions()
        else
            local cnt = #actionOrList
            local ___onActionComplete = function()
                cnt = cnt - 1
                if cnt == 0 then
                    if actionOrList.___onActionComplete then
                        actionOrList.___onActionComplete()
                    end
                end
            end
            for k, action in ipairs(actionOrList) do
                action.___onActionComplete = function()
                    ___onActionComplete()
                end
                self:runAction(action)
            end
        end
    else
        local action = actionOrList
        action.setTarget(self)
        self.__actionList = self.__actionList or {}
        table.insert(self.__actionList, action)
        ActionUnitManager.getInstance():add(action)
    end
    return actionOrList
end

function WidgetBase:stopAction(actionOrList)
    local isList = #actionOrList > 0
    if isList then
        self:stopActionByTag(actionOrList)
    else
        if action.getTarget() == self then
            action.stop()
            for k, v in ipairs(self.__actionList) do
                if v == action then
                    table.remove(self.__actionList, k)
                    break
                end
            end
        end
    end
end

function WidgetBase:_stopAllActions()
    local list = self.__actionList
    while list and 0 < #list do
        local action = list[1]
        action.stop()
        table.remove(list, 1)
    end
end

-- 不支持Spawn和Sequence
function WidgetBase:stopActionByTag(tag)
    if self.__actionList then
        local list = self.__actionList
        local index = 1
        while index <= #list do
            local action = list[index]
            if action.tag == tag then
                action.stop()
                table.remove(list, index)
            else
                index = index + 1
            end
        end
    end
end

-- {[x], [y], [onComplete], [interpolationFunc], time(second)}
function WidgetBase:_moveTo(args)
    local action = Action.Move(args)
    local mainAction
    if args.delay and args.delay > 0 then
        mainAction = self:runAction(Action.Sequence({Action.Delay({time = args.delay}), action}))
    else
        mainAction = self:runAction(action)
    end
    return self, mainAction
end

-- 注意：offset的意思为，所有的坐标点都是相对于起始点的偏移。若非此意图，使用movesTo2
function WidgetBase:_movesTo(args)
    local cnt = #args.pos_t
    local eachTime = args.time/cnt
    local actions = {}
    local origX, origY = self:getPos()
    for k, pos in ipairs(args.pos_t) do
        if args.offset then
            pos.x = origX + pos.x
            pos.y = origY + pos.y
        end
        table.insert(actions, Action.Move({x = pos.x, y = pos.y, time = eachTime}))
    end
    if args.delay and args.delay > 0 then
        table.insert(actions, 1, Action.Delay({time = args.delay}))
    end
    table.insert(actions, Action.Delay({onComplete = args.onComplete}))
    local action = Action.Sequence(actions)
    local mainAction = self:runAction(action)
    return self, mainAction
end

function WidgetBase:_movesTo2(args)
    local cnt = #args.pos_t
    local eachTime = args.time/cnt
    local actions = {}
    for k, pos in ipairs(args.pos_t) do
        table.insert(actions, Action.Move({x = pos.x, y = pos.y, offset = args.offset, time = eachTime}))
    end
    if args.delay and args.delay > 0 then
        table.insert(actions, 1, Action.Delay({time = args.delay}))
    end
    table.insert(actions, Action.Delay({onComplete = args.onComplete}))
    local action = Action.Sequence(actions)
    local mainAction = self:runAction(action)
    return self, mainAction
end

-- {[scaleX], [scaleY], [onComplete], [interpolationFunc], time(second)}
function WidgetBase:_scaleTo(args)
    if args.srcX then
        self:setScaleX(args.srcX)
    end
    if args.srcY then
        self:setScaleY(args.srcY)
    end
    local action = Action.Scale(args)
    local mainAction
    if args.delay and args.delay > 0 then
        mainAction = self:runAction(Action.Sequence({Action.Delay({time = args.delay}), action}))
    else
        mainAction = self:runAction(action)
    end
    return self, mainAction
end

-- {angle, [onComplete], [interpolationFunc], time(second)}
function WidgetBase:_rotateTo(args)
    local action = Action.Rotate(args)
    local mainAction
    if args.delay and args.delay > 0 then
        mainAction = self:runAction(Action.Sequence({Action.Delay({time = args.delay}), action}))
    else
        mainAction = self:runAction(action)
    end
    return self, mainAction
end

-- {alpha, [onComplete], [interpolationFunc], time(second)}
function WidgetBase:_fadeTo(args)
    local action = Action.Fade(args)
    local mainAction
    if args.delay and args.delay > 0 then
        mainAction = self:runAction(Action.Sequence({Action.Delay({time = args.delay}), action}))
    else
        mainAction = self:runAction(action)
    end
    return self, mainAction 
end

function WidgetBase:_fadeIn(args)
    self:setTransparency(0)
    args.opacity = 1
    return self:_fadeTo(args)
end

function WidgetBase:_fadeOut(args)
    self:setTransparency(1)
    args.opacity = 0
    return self:_fadeTo(args)
end

function WidgetBase:___setActionUnitByType(type, action)
    self.__actionUnitMap = self.__actionUnitMap or {}
    if self.__actionUnitMap[type] then
        self.__actionUnitMap[type].override = true
    end
    self.__actionUnitMap[type] = action
end

function WidgetBase:___clearActionUnitByType(type, action)
    if self.__actionUnitMap and self.__actionUnitMap[type] == action then
        self.__actionUnitMap[type] = nil
    end
end

function WidgetBase:setScale(scale)
    if scale and scale ~= self.__scaleX then
        self.__scaleX = scale
        self:___setDirty("scale")
    end
    if scale and scale ~= self.__scaleY then
        self.__scaleY = scale
        self:___setDirty("scale")
    end
end

function WidgetBase:setScaleX(scale)
    self.__scaleX = scale
    self:___setDirty("scale")
end

function WidgetBase:setScaleY(scale)
    self.__scaleY = scale
    self:___setDirty("scale")
end

function WidgetBase:getScaleX()
    return self.__scaleX or 1
end

function WidgetBase:getScaleY()
    return self.__scaleY or 1
end

function WidgetBase:getRotation()
    return self.__angle or 0
end

function WidgetBase:setRotation(angle)
    if angle and self.__angle ~= angle then
        self.__angle = angle
        self:___setDirty("angle")
    end
end

function WidgetBase:setAnchor(anchorX, anchorY)
    if anchorX and anchorX ~= self.__anchorX then
        self.__anchorX = anchorX
        self:___setDirty("anchor")
    end
    if anchorY and anchorY ~= self.__anchorY then
        self.__anchorY = anchorY
        self:___setDirty("anchor")
    end
end

function WidgetBase:getAnchorX()
    return self.__anchorX or 0.5
end

function WidgetBase:getAnchorY()
    return self.__anchorY or 0.5
end

function WidgetBase:getAnchor()
    return self.__anchorX or 0.5, self.__anchorY or 0.5
end

function WidgetBase:___setDirty(factor)
    -- self.__dirtyMap = self.__dirtyMap or {}
    -- self.__dirtyMap[factor] = true
    -- table.insert(dirtyList, self)
    -- if not dirtyWidgetClock then
    --     dirtyWidgetClock = Clock.instance():schedule_once(function()
    --         dirtyWidgetClock = nil
    --         for k, v in ipairs(dirtyList) do
    --             v:___updateMatrix()
    --         end
    --         dirtyList = {}
    --     end)
    -- end
    if s_isUpdating then
        self.__dirty = true
        table.insert(dirtyList, self)
    else
        self:___updateMatrix()
    end
end

local originalDtor = WidgetBase.dtor
function WidgetBase:dtor( ... )
    self:_stopAllActions()
    originalDtor(self, ...)
end

-------private----------------------------------------------------------------

local matrix44Metatable = {
    __mul = function(mat1, mat2)
        local matTemp = {};
        for i = 0, 3 do 
            matTemp[i*4+1] = mat1[1]*mat2[i*4+1]+mat1[5]*mat2[i*4+2]+mat1[9]*mat2[i*4+3]+mat1[13]*mat2[i*4+4]
            matTemp[i*4+2] = mat1[2]*mat2[i*4+1]+mat1[6]*mat2[i*4+2]+mat1[10]*mat2[i*4+3]+mat1[14]*mat2[i*4+4]
            matTemp[i*4+3] = mat1[3]*mat2[i*4+1]+mat1[7]*mat2[i*4+2]+mat1[11]*mat2[i*4+3]+mat1[15]*mat2[i*4+4]
            matTemp[i*4+4] = mat1[4]*mat2[i*4+1]+mat1[8]*mat2[i*4+2]+mat1[12]*mat2[i*4+3]+mat1[16]*mat2[i*4+4]
        end
        return matTemp;
    end
}

local s_systemScale = nil

function WidgetBase:___updateMatrix()
    -- self:getWidget().rotation = self.__angle
    -- FwLog("WidgetBase " .. self:getRotation())
    -- do return end
    -- FwLog("WidgetBase:___updateMatrix")
    -- if not self.__dirtyMap then return end
    local angle = self.__angle or 0
    local scaleX = self.__scaleX or 1
    local scaleY = self.__scaleY or 1
    angle = angle / 180 * 3.1415
    local w, h = self:getSize()
    -- w = w * scaleX
    -- h = h * scaleY
    local translate1Mat
    local translate2Mat
    local anchorX = self.__anchorX or 0.5
    local anchorY = self.__anchorY or 0.5
    -- if not self.__rotateMatrix or self.__dirtyMap["anchor"] or self.__dirtyMap["angle"] then
    --     translate1Mat = translate1Mat or {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, w * anchorX, h * anchorY, 0, 1}
    --     translate2Mat = translate2Mat or {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, -w * anchorX, -h * anchorY, 0, 1}
    --     local rotateMat =  {math.cos(angle), math.sin(angle), 0, 0, -math.sin(angle), math.cos(angle), 0, 0, 0, 0, 1, 0, 0, 0, 0, 1}
    --     setmetatable(translate1Mat, matrix44Metatable)
    --     setmetatable(translate2Mat, matrix44Metatable)
    --     setmetatable(rotateMat, matrix44Metatable)
    --     self.__rotateMatrix = translate1Mat * rotateMat * translate2Mat
    --     setmetatable(self.__rotateMatrix, matrix44Metatable)
    -- end
    -- if not self.__scaleMatrix or self.__dirtyMap["anchor"] or self.__dirtyMap["scale"] then
    --     translate1Mat = translate1Mat or {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, w * anchorX, h * anchorY, 0, 1}
    --     translate2Mat = translate2Mat or {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, -w * anchorX, -h * anchorY, 0, 1}
    --     local scaleMat = {scaleX, 0, 0, 0, 0, scaleY, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1}
    --     setmetatable(translate1Mat, matrix44Metatable)
    --     setmetatable(translate2Mat, matrix44Metatable)
    --     setmetatable(scaleMat, matrix44Metatable)
    --     self.__scaleMatrix = translate1Mat * scaleMat * translate2Mat
    --     setmetatable(self.__scaleMatrix, matrix44Metatable)
    -- end
    -- self:setPostMatrix(unpack(self.__scaleMatrix * self.__rotateMatrix))

    s_systemScale = s_systemScale or System.getLayoutScale()
    local anchorPixelX = w * anchorX * s_systemScale-- * math.abs(scaleX) 
    local anchorPixelY = h * anchorY * s_systemScale-- * math.abs(scaleY)
    local translate1Mat = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, anchorPixelX, anchorPixelY, 0, 1}
    local translate2Mat = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, -anchorPixelX, -anchorPixelY, 0, 1}
    local mixMat = {math.cos(angle) * scaleX, math.sin(angle) * scaleX, 0, 0, 
                        -math.sin(angle) * scaleY, math.cos(angle) * scaleY, 0, 0, 
                        0, 0, 1, 0, 
                        0, 0, 0, 1}
    setmetatable(translate1Mat, matrix44Metatable)
    setmetatable(translate2Mat, matrix44Metatable)
    setmetatable(mixMat, matrix44Metatable)
    self:setPostMatrix(unpack(translate1Mat * mixMat * translate2Mat))
    -- FwLog("image3 " .. self:getRotation())
    self.__dirtyMap = nil
end