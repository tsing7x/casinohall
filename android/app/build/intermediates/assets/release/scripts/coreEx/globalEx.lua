GetNumFromJsonTable = function(tb, key, default)
    local ret = default or 0;
    if tb[key] ~= nil then
        if tb[key]:get_value() ~= nil then
            ret = tonumber(tb[key]:get_value());
            if ret == nil then
                ret = default or -1;
            end
        end
    end
    return ret;
end

GetStrFromJsonTable = function(tb, key, default)
    local ret = default or "";
    if tb[key] ~= nil then
        if tb[key]:get_value() ~= nil then
            ret = tb[key]:get_value() or "";
            if string.len(ret)  == 0 then
                ret = default;
            end
        end
    end
    return ret;
end

GetBlooeanFromJsonTable = function(tb, key, default)
    local ret = default;
    if tb and tb[key] ~= nil then
        if tb[key]:get_value() ~= nil then
            ret = tb[key]:get_value();
        end
    end
    return ret;
end

GetTableFromJsonTable = function(tb, key, default)
    local ret = default;
    if tb and tb[key] ~= nil then
        if tb[key]:get_value() ~= nil then
            ret = tb[key]:get_value();
            if type(ret) ~= "table" then
                ret = default;
            end
        end
    end
    return ret;
end

Joins = function(t, mtkey)
    local str = "K";
    if t == nil or type(t) == "boolean"  or type(t) == "byte" then
        return str;
    elseif type(t) == "number" or type(t) == "string" then
        str = string.format("%sT%s%s", str.."", mtkey, string.gsub(t, "[^a-zA-Z0-9]",""));
    elseif type(t) == "table" then
        for k,v in orderedPairs(t) do
            str = string.format("%s%s=%s", str, tostring(k), Joins(v, mtkey));
        end
    end
    return str;
end