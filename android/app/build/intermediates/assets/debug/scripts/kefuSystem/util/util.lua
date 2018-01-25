local util = {}

util.FileUtils = require("kefuSystem/util.FileUtils")
util.Serialize = require("kefuSystem/util.Serialize")

function util.cloneObject( obj )
    local cloneObj = nil
    local meta = getmetatable(obj)
    if meta then
        if meta.class then
            cloneObj = meta.class()
        else
            cloneObj = setmetatable({}, meta)
        end
    else
        cloneObj = {}
    end

    for k, v in pairs(obj or {}) do
        if type(v) ~= "table" then
            cloneObj[k] = v
        else
            cloneObj[k] = util.cloneObject(v)
        end
    end

    return cloneObj
end

return util
