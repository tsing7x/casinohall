local PropsCfgData = class(require("app.data.imgData"))

addProperty(PropsCfgData, "name", "")
addProperty(PropsCfgData, "id", 0)
addProperty(PropsCfgData, "keyName", "")

function PropsCfgData:init(data)
    self:setImgUrl(data.image or "")
    self:setName(data.name or "")
    self:setId(tonumber(data.pnid) or 0)
    self:setKeyName(data.keyName or "")
end

return PropsCfgData
