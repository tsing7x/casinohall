--[[
    读socket基类
    用作各个reader的基类
]]
local BaseProcesser = class(SocketProcesser)
-------------------通用协议-------------------------
function BaseProcesser:ctor()
    self:initCommandFuncMap()
end

function BaseProcesser:initCommandFuncMap()
    self.s_severCmdEventFuncMap = {}
end

return BaseProcesser