local class, mixin, super = unpack(require("byui/class"))
--local log = require("log.log")

local SerializeMeta = {}

local kCachePath = System.getStorageUserPath() .. "/";
local kImagePath = System.getStorageImagePath() .. "/";
local kTag = ""

function SerializeMeta:__init__(fileName, lastDays)
    self.m_name = fileName;
    self.m_lastDays = lastDays;
    self.m_cache = self:load(fileName, lastDays) or {};
    self:save();
end

function SerializeMeta:update(cache)
    self.m_cache = cache
end

function SerializeMeta:get(url)
    local name = self.m_cache[url] or "";
    --	local path = string.concat(kImagePath , name);
    local path = kImagePath .. name;
    local fp = io.open(path, "r");
    if name ~= "" and fp then
        io.close(fp);
        return name;
    end
    self.m_cache[url] = nil;
    return nil;
end

function SerializeMeta:lookup(func)
    for url, filename in pairs(self.m_cache) do
        func(url, filename)
    end
end

function SerializeMeta:set(url, fileName)
    self.m_cache[url] = fileName;
end

function SerializeMeta:load()
    local filePath = kCachePath .. self.m_name;
    local file = io.open(filePath, "r");
    if not file then
        --log.d("SerializeMeta:load() failed", filePath)
        return;
    else
        local isSuccess, file = pcall(dofile, filePath);
        if not isSuccess then
            --log.w("load Serialize file", filePath)
        else
            return file
        end
    end
end

function SerializeMeta:save()
    local fileName = kCachePath .. self.m_name;
    local file = io.open(fileName, "w");
    if not file then
        --log.d("SerializeMeta:save() failed", filePath)
        return;
    end

    file:write("return ");
    self:writeValue(file, self.m_cache);
    file:close();
end

function SerializeMeta:clearAll()
    self.m_cache = {};
end

function SerializeMeta:writeTable(fileName, src)
    if type(src) ~= "table" then
        return;
    end

    local tab = kTag;
    kTag = kTag .. "	";

    fileName:write("{\n");
    for k, v in pairs(src) do
        if type(k) == "string" or type(k) == "number" then
            fileName:write(kTag);
            self:writeKey(fileName, k);
            self:writeValue(fileName, v);
        end
    end
    fileName:write(tab .. "}");
    kTag = tab;
end

function SerializeMeta:writeString(fileName, value)
    fileName:write("\"");
    fileName:write(value);
    fileName:write("\"");
end

function SerializeMeta:writeBoolean(fileName, value)
    fileName:write(tostring(value));
end

function SerializeMeta:writeNumber(fileName, value)
    fileName:write(value);
end

function SerializeMeta:writeKey(fileName, key)
    fileName:write("[");
    if type(key) == "string" then
        self:writeString(fileName, key);
    else
        self:writeNumber(fileName, key);
    end
    fileName:write("] = ");
end

function SerializeMeta:writeValue(fileName, v)
    if type(v) == "table" then
        self:writeTable(fileName, v);
    elseif type(v) == "string" then
        self:writeString(fileName, v);
    elseif type(v) == "boolean" then
        self:writeBoolean(fileName, v);
    else
        fileName:write(v);
    end
    fileName:write(";\n");
end

return class("Serialize", nil, SerializeMeta)
