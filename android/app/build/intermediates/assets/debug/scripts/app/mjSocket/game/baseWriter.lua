--[[
    写socket基类
    用作各个writer的基类
]]
local BaseWriter = class(SocketWriter)

function BaseWriter:ctor()
    self:initCommandFuncMap()
end

function BaseWriter:initCommandFuncMap()
    self.s_clientCmdFunMap = {}
end

return BaseWriter