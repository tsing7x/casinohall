---
-- @usage require('$EngingPath$/load.lua')('$EngingPath$')

return function()
    -- 加载引擎动画库
    require("core.animation")
    -- 加载core
    require("core.core")
    -- 加载3.0 的ui库
    require("core.ui")
    -- 加载工具库
    require("core.libutils")
    -- 加载特效库
    require("core.libEffect")
    -- 加载编辑器解析库
    require("core.editorRT")
    -- 加载协程库
    require("core.tasklet")
    -- 加载引擎网络库
    require("core.network")

    require("core.gamebase")
end
