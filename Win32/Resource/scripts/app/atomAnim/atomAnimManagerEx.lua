
local playAnim = AtomAnimManager.playAnim
AtomAnimManager.playAnim = function(self, luaPath, params)
    local x = params.x or display.cx
    local y = params.y or display.cy
    local width = params.width or 0
    local height = params.height or 0
    local parent = params.parent
    local autoRelease = true
    if params.autoRelease == false then
        autoRelease = false
    end
    local level = params.level
    x = x - width/2
    y = y - height/2
    local anim = playAnim(self, luaPath, parent, x, y, autoRelease, params)
    if anim then
        anim:setLevel(level)
        anim:setEvent(anim, params.onComplete)
    end
    return anim
end