--[[
    读socket基类
    用作各个reader的基类
]]
local BaseReader = class(SocketReader)
-------------------通用协议-------------------------
function BaseReader:ctor()
    self:initCommandFuncMap()
end

function BaseReader:initCommandFuncMap()
    self.s_severCmdFunMap = {}
end

return BaseReader