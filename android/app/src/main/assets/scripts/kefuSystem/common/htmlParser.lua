local HtmlParser = {};

local tags =
{
    ["&quot;"]      = "\"",
    ["&amp;"]       = "&",
    ["&nbsp;"]      = " ",
    ["&cent;"]      = "¢",
    ["&pound;"]     = "£",
    ["&curren;"]    = "¤",
    ["&yen;"]       = "¥",
    ["&sect;"]      = "§",
    ["&uml;"]       = "¨",
    ["&copy;"]      = "©",
    ["&ordf;"]      = "ª",
    ["&laquo;"]     = "«",
    ["&not;"]       = "¬",
    ["&reg;"]       = "®",
    ["&macr;"]      = "¯",
    ["&deg;"]       = "°",
    ["&acute;"]     = "´",
    ["&raquo;"]     = "»",
    ["&frac14;"]    = "¼",
    ["&frac12;"]    = "½",
    ["&frac34;"]    = "¾",
    ["&plusmn;"]    = "±",
    ["&sup2;"]      = "²",
    ["&sup3;"]      = "³",
    ["&sup1;"]      = "¹",
    ["&ordm;"]      = "º",
}

HtmlParser.parser = function (src)
    return string.gsub(src, "(&%w+;)", function(v)
        return tags[v] or "*"
    end)
end

return HtmlParser