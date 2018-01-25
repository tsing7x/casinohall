ToolKit = {};

-- 将long转换成:xx年xx月xx日xx时xx分xx秒格式
function ToolKit.getTimeYMD(time)
    local days = "";
    if time and tonumber(time) then
        local timeNum = tonumber(time);
        timeNum = math.abs(timeNum);
        local str = "%Y" .. string_get("yearStr") .. "%m" .. string_get("mouthStr") .. "%d" .. string_get("dayStr") .. "%H" .. string_get("hourStr") .. "%M" .. string_get("minStr") .. "%S".. string_get("secStr");
        days = os.date(str,timeNum);
    end
    return days;
end

-- 将long转换成:xx月xx日xx:xx:xx格式
function ToolKit.getTimeMDHMS(time)
    local days = "";
    if time and tonumber(time) then
        local timeNum = tonumber(time);
        timeNum = math.abs(timeNum);
        local str = "%m" .. string_get("mouthStr") .. "%d" .. string_get("dayStr") .. "%H" .. ":%M" .. ":%S";
        days = os.date(str,timeNum);
    end
    return days;
end

-- 拆分时间：00时:00分:00秒
function ToolKit.skipTime(time)
    local times = nil;
    if time then
        local timeNum = tonumber(time);
        if timeNum and timeNum > 0 then
            local hour = os.date("*t",timeNum).hour - 8;
            local min  = os.date("*t",timeNum).min;
            local sec  = os.date("*t",timeNum).sec;

            hour = string.format("%02d",hour);
            min = string.format("%02d",min);
            sec = string.format("%02d",sec);
            times = hour .. ":" .. min .. ":" .. sec;
        end
    end
    return times or string_get("initTimeStr");
end

-- 拆分时间：00时:00分
function ToolKit.skipTimeHM(time)
    local times = nil;
    if time then
        local timeNum = tonumber(time);
        if timeNum and timeNum > 0 then
            local hour = os.date("*t",timeNum).hour - 8;
            local min  = os.date("*t",timeNum).min;

            hour = string.format("%02d",hour);
            min = string.format("%02d",min);
            times = hour .. ":" .. min;
        end
    end
    return times or string_get("initTimeStr");
end

--拆分金币每3位用逗号隔开
function ToolKit.skipMoney(curMoney)
    local moneyStr = nil;
    local moneyPrefix = ""; -- 负的时候为-
    if curMoney and tonumber(curMoney) then
        local money = curMoney .. "";
        if curMoney < 0 then
            moneyPrefix = "-";
            money = string.sub(money .. "", 2, #money)
        end
        local length = #money;
        local spead = 1;
        for i=length,0, -3 do
            local x = length - spead*3 + 1;
            if x < 1 then
                x=1;
            end
            if moneyStr then
                moneyStr = string.sub(money, x, length - (spead-1)*3) .. "," .. moneyStr;
            else
                moneyStr = string.sub(money, x, length - (spead-1)*3);
            end
            spead = spead +1;
        end
        if string.sub(moneyStr, 1, 1) == "," then
            moneyStr = string.sub(moneyStr, 2, #moneyStr);
        end
    end
    if not moneyStr then
        moneyStr = curMoney or 0;
    end
    moneyStr = moneyPrefix .. moneyStr;
    return moneyStr;
end
--123,456
--12.2万
--12.18亿
--100000000
function ToolKit.formatNumber( number )
    -- body
    number = number and tostring(number) or "";

    if string.len(number) <= 3 then
        return number;
    elseif string.len(number) <= 6 then
        local insertPos = string.len(number) - 3;
        return string.sub(number, 1, insertPos) .. tostring(',') .. string.sub(number, insertPos + 1, string.len(number));
    elseif string.len(number) <= 8 then
        return string.format("%0.01fw", (math.floor(number/1000) * 1000) / 10000);
    else
        return string.format("%0.02fy", (math.floor(number/1000000) * 1000000) / 100000000);
    end

    return number;
    
end

--judge whether is english
function ToolKit.utf8_isAllEnglish(str)
    local length = string.len(str)
    local i = 1
    while i <= length do
        local cp = string.byte(str, i)
        if cp >= 0xC0 then
            return false
        else
            i = i + 1
        end
    end
    return true
end
--获取utf8字符串的子字符串
function ToolKit.utf8_substring(str, first, num)

  local e   = nil
  local b   = nil
  local n   = string.len(str);
  first     = tonumber(first) or 1;
  num       = tonumber(num) or 0;
  local i   = 1;

  if num == 0 then
    return "";
  end;

  while i <= n do

    num = num -1;
    first = first -1;
  
    if first == 0 then
        b = i;
    end

    local cp = string.byte(str, i);
    if cp >= 0xF0 then
      i = i + 4;
    elseif cp >= 0xE0 then
      i = i + 3;
    elseif cp >= 0xC0 then
      i = i + 2;
    else
      i = i + 1;
    end;

    if num == 0 then
        e = i - 1;
        break;
    end

  end;

  if not e then
    e = n;
  end;
  return string.sub(str, b, e);
end;

function ToolKit.subString(str,strMaxLen)
  if (nil == str) or (string.len(str) == 0) then
    return "";
  end
  return ToolKit.utf8_substring(str, 1, strMaxLen);
end

function ToolKit.split(str, delim, maxNb)
    -- Eliminate bad cases...
    if string.find(str, delim) == nil then
        return { str }
    end
    if maxNb == nil or maxNb < 1 then
        maxNb = 0    -- No limit
    end
    local result = {}
    local pat = "(.-)" .. delim .. "()"
    local nb = 0
    local lastPos
    for part, pos in string.gfind(str, pat) do
        nb = nb + 1
        result[nb] = part
        lastPos = pos
        if nb == maxNb then break end
    end
    -- Handle the last field
    if nb ~= maxNb then
        result[nb + 1] = string.sub(str, lastPos)
    end
    return result;
end

function ToolKit.formatNick(nick, length)
  length = length or 10;
  local subStr = ToolKit.subString(nick, length);
  if subStr == "" then
  elseif subStr ~= nick then
    subStr = subStr .. ".."
  end;
  return subStr;
end

-- function ToolKit.formatMoney(money)
--     money = money or 0
--     local moneyBitCount =  math.floor(math.log10(money)) + 1;
--     if moneyBitCount > 8 then
--         money = string.format("%0.02f", money / 100000000);
--         money = money .. "亿";
--     elseif(moneyBitCount > 6) then
--         money = string.format("%0.01f", money / 10000);
--         money = money .. "万";
--     else
--         money = ToolKit.skipMoney(money);
--     end
--     return money;
-- end

--麻将合集
-- function ToolKit.formatMoney(number)
-- --123,456
-- --12.2万
-- --12.18亿
-- --100000000
--     -- body
--     number = number and tostring(number) or "";

--     if string.len(number) <= 3 then
--         return number;
--     elseif string.len(number) <= 6 then
--         local insertPos = string.len(number) - 3;
--         return string.sub(number, 1, insertPos) .. tostring(',') .. string.sub(number, insertPos + 1, string.len(number));
--     elseif string.len(number) <= 8 then
--         return string.format("%0.01f万", number/10000);
--     else
--         return string.format("%0.02f亿", number/100000000);
--     end

--     return number;
-- end

--骰子游戏
function ToolKit.formatMoney(number)
--1234          1234
--12345         12345
--123456        123.45K
--1234567       1.23M
--12345678      12.34M
--123456789     123.45M
--1234567890    1.23B
--12345678900   12.34B
--123456789000  123.45B

    -- body
    if number and tonumber(number) then
        number = math.floor(tonumber(number))--去除小数点
    end
    number = number and tostring(number) or "";

    if string.len(number) <= 5 then
        return number;
    elseif string.len(number) == 6 then
        return string.sub(number, 1, 3) .. tostring('.') .. string.sub(number, 4, 5) .. "k";
    elseif string.len(number) == 7 then
        return string.sub(number, 1, 1) .. tostring('.') .. string.sub(number, 2, 3) .. "m";
    elseif string.len(number) == 8 then
        return string.sub(number, 1, 2) .. tostring('.') .. string.sub(number, 3, 4) .. "m";
    elseif string.len(number) == 9 then
        return string.sub(number, 1, 3) .. tostring('.') .. string.sub(number, 4, 5) .. "m";
    elseif string.len(number) == 10 then
        return string.sub(number, 1, 1) .. tostring('.') .. string.sub(number, 2, 3) .. "b";
    elseif string.len(number) == 11 then
        return string.sub(number, 1, 2) .. tostring('.') .. string.sub(number, 3, 4) .. "b";
    elseif string.len(number) == 12 then
        return string.sub(number, 1, 3) .. tostring('.') .. string.sub(number, 4, 5) .. "b";
    end
    return number;
end

function ToolKit.formatMoneyWithSixDigit(number)
    local strNum = number and tostring(number) or "";
    local length = string.len(strNum)
    if length <= 3 then
        return strNum;
    elseif length <= 6 then
        return string.sub(strNum, 1, length - 3)..","..string.sub(strNum, length - 2, length)
    elseif length <= 9 then
        return string.sub(strNum, 1, length - 6)..","..string.sub(strNum, length - 5, length - 3).."k"
    elseif length <= 12 then
        return string.sub(strNum, 1, length - 9)..","..string.sub(strNum, length - 8, length - 6).."m"
    else
        number = math.floor(number / 1000000000)
        return ToolKit.formatMoneyWithSixDigit(number).."b"
    end
end

function ToolKit.formatChip(number)
    --50            50
    --100           100
    --500           500
    --1000          1k
    --5000          5k
    --10000         10k
    --100000        100k
    --1000000       1m
    --10000000      10m
    --100000000     100m
    --1000000000    1b
    --10000000000   10b
    --10000000000   100b

    number = number and tonumber(number) or 0;

    if number < 1000 then
        return tostring(number);
    elseif number < 1000000 then
        return tostring(number/1000) .. 'k';
    elseif number < 1000000000 then
        return tostring(number/1000000) .. 'm';
    else
        return tostring(number/1000000000) .. 'b';
    end
    return number;
end

function ToolKit.formatAnteWithoutFloor(number)
     number = number and tonumber(number) or 0;
     if number < 1000 then
         return tostring(number);
     elseif number < 1000000 then
         return tostring(number/1000) .. 'K';
     elseif number < 1000000000 then
         return tostring(number/1000000) .. 'M';
     else
         return tostring(number/1000000000) .. 'B';
     end
     return number;
end

function ToolKit.formatAnte(number)
    --50            50
    --100           100
    --500           500
    --1000          1K
    --5000          5K
    --10000         10K
    --100000        100K
    --1000000       1M
    --10000000      10M
    --100000000     100M
    --1000000000    1B
    --10000000000   10B
    --10000000000   100B

    number = number and tonumber(number) or 0;

    if number < 1000 then
        return tostring(math.floor(number));
    elseif number < 1000000 then
        return tostring(math.floor(number/1000)) .. 'K';
    elseif number < 1000000000 then
        return tostring(math.floor(number/1000000)) .. 'M';
    else
        return tostring(math.floor(number/1000000000)) .. 'B';
    end
    return number;
end

function ToolKit.formatTurnMoney(money)
    money = money or 0
    return (money >= 0 and "+" or "-") .. math.abs(money)
end

ToolKit.weakValues = {};
setmetatable(ToolKit.weakValues, {__mode="v"});

-- 提示登录
function ToolKit.showDialog(_title,_msg,left,_leftCmd,right,_rightCmd,callback,own)
  if ToolKit.dialog then
    delete(ToolKit.dialog);
    ToolKit.dialog = nil;
  end;
  ToolKit.weakValues.dialogOwn = own;
  ToolKit.weakValues.dialogCallback = callback; 
  local data = {title=_title,leftStr=left,leftCmd=_leftCmd,rightStr=right,rightCmd=_rightCmd,msgStr=msg};
  ToolKit.dialog = new(Dialog,data);
  ToolKit.dialog:create();
  ToolKit.dialog:setCallBackClick(nil,ToolKit.dialogCallback);
end

function ToolKit.dialogCallback(self,param)
  if ToolKit.dialog then
    delete(ToolKit.dialog);
    ToolKit.dialog = nil;
  end;
  if ToolKit.weakValues.dialogCallback then
    ToolKit.weakValues.dialogCallback(ToolKit.weakValues.Own, param);
  end;
end;


function ToolKit.setDebugName( obj , name)
   if obj then
        obj:setDebugName(name);
   end 
end


--获取从头开始的指定长度的子字符串，可以避免子字符串末尾处中文乱码问题
--str：源字符串
--count：子字符串长度
--return：子字符串，无需进行转码，即可显示
function ToolKit.getSubStr ( str,count )
    if str=="" then
        return str;
    end
    local s=GameString.convert2UTF8(str);
    local i=1;
    local cn={};
    while i<=string.len(s) do
        local ss=string.sub(s,1,i);
        local len=string.lenutf8(ss);
        if len+#cn*2<i then
            table.insert(cn,i);
            i=i+3;
        else
            i=i+1;
        end
    end
    for i=1,#cn do
        cn[i]=cn[i]-(i-1);
        if cn[i]==count then
            count=count-1;
            break;
        end
    end
    return string.sub(GameString.convert2UTF8(s),1,count);
end

--return：  集合:t1-t2
function ToolKit.difference ( t1,t2 )
    local ret={};
    local index=1;
    for _,v in ipairs(t1) do
        if index<=#t2 and v==t2[index] then
            index=index+1;
        else
            ret[#ret+1]=v;
        end
    end

    return ret;
end

-- 文本超过显示长度时，让文本内容一个一个往左循环移动（暂只支持纯英文的文本）
-- textObj:可设置文本的对象，类型：Text、EditText
-- src:源字符串，类型：String
-- size:显示字符的长度，类型：Number
function ToolKit.CharacterMovement(textObj,src,size)
    if not src or src == "" then
        return src;
    end

    local count = string.len(tostring(src));
    local i = 0;
    if count > size then      
         local anim = new(AnimDouble,kAnimLoop,0,1,1000,-1);
         anim:setDebugName("ToolKit | anim");
         anim:setEvent(src,function()
             i = i + 1;
             if i + (size-1)<= count then 
                str = string.sub(src,i,i+(size-1));
             elseif i <= count and i + (size-1) > count then 
                str = string.sub(src,i,count).."   "..string.sub(src,1,(size-1)-(count-i));
             elseif i == count+1 then 
                 i = 1;
                str = string.sub(src,i,i+(size-1));
             end
             textObj:setText(str);
         end);
    end
end 

------------------------------------用于动态显示图片------------------------
function ToolKit.getNextImagePos(pos , obj , space , imageWidth)
    space = space or 0;
    if(not imageWidth) then
        local width , height = obj:getSize();
        pos.x = pos.x + width + space;
    else
        pos.x = pos.x + imageWidth + space;
    end
    return pos;
end

ToolKit.getNum=function (val,arr,count )
    local val=val;
    local index=1;
    if val==0 then 
        arr[1]=0;
    else
        while val>0 do
            arr[index]= val%10;
            val=math.floor(val/10);
            index=index+1;
        end
        for i=index,count do
            arr[i]=0;
        end
    end
end

--去除空格
function ToolKit.trim(s)
    -- return (string.gsub(s,"^%s*(.-)%s*$","%1"));
    return (string.gsub(s, " ", ""));
end

function ToolKit.isValidString(str)
    return str and str ~= ""; 
end

-- 将前缀 key 和 图片地址进行md5加密
function ToolKit.getMd5ImageName(kPrefix, key, imgUrl)
    key = key or 0;
    imgUrl = imgUrl or "";
    kPrefix = kPrefix or "";
    local md5Str = string.sub(md5_string(imgUrl) or "",9,24);
    return kPrefix .. "_" .. key .. "_" .. md5Str .. ".png";
end

function ToolKit.getMd5Key(md5Str)
    local startPos, endPos = string.find(md5Str, "%_%w+%_");
    if startPos and endPos then
        return string.sub(md5Str, startPos + 1, endPos - 1);
    end
    return "";
end

function ToolKit.getIntPart(num)
   
    if num <= 0 then
       return math.ceil(num);
    end
    if math.ceil(num) == num then
       num = math.ceil(num);
    else
       num = math.ceil(num) - 1;
    end
    return num;
end

--深度拷贝一个table
function ToolKit.deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

function ToolKit.formatCard(cardValue)
    cardValue = cardValue or 0;
    return string.format("0x%02x", cardValue); 
end

-- 传入3张图片引用，返回imgM处在imgL和imgR中间时的位置x，flag=0代表返回的x是相对imgL，flag=1代表返回的x是相对imgR
function ToolKit.getMidPosOf2Img(imgL, imgM, imgR, flag)
    local up_abs_x, up_abs_y = imgL:getAbsolutePos();
    local t_x, t_y = imgR:getAbsolutePos();
    local w,_ = imgL:getSize();
    local ad_w,_ = imgM:getSize();
    local up_x,_ = imgL:getPos();
    local r_x,_ = imgR:getPos();
    local midPos_x;
    if flag == 0 then
        midPos_x = (up_x+w+(t_x-(up_abs_x+w))/2 -ad_w/2);
    elseif flag == 1 then
        midPos_x = (r_x-(t_x-(up_abs_x+w))/2 -ad_w/2);
    end
    return midPos_x;
end

-- 判断utf8字符byte长度
-- 0xxxxxxx - 1 byte
-- 110yxxxx - 192, 2 byte
-- 1110yyyy - 225, 3 byte
-- 11110zzz - 240, 4 byte
local function chsize(char)
    if not char then
        print("not char")
        return 1
    elseif char > 240 then
        return 4
    elseif char > 225 then
        return 3
    elseif char > 192 then
        return 2
    else
        return 1
    end
end

-- 计算utf8字符串字符数, 各种字符都按一个字符计算
-- 例如utf8len("1你好") => 3
function ToolKit.utf8len(str)
    local len = 0
    local currentIndex = 1
    while currentIndex <= #str do
        local char = string.byte(str, currentIndex)
        currentIndex = currentIndex + chsize(char)
        len = len +1
    end
    return len, currentIndex
end

-- 截取字符串指定长度
function ToolKit.subStr(str, num, startIndex, noSuffix)
    startIndex = startIndex or 1
    noSuffix   = noSuffix or false;  
    local len = #str
    local numChars = ToolKit.utf8len(str)
    local result = ""
    local currentIndex = startIndex
    while currentIndex - startIndex < num do
        local char = string.byte(str, currentIndex)
        local temp = chsize(char)
        result = result .. string.sub(str, currentIndex, currentIndex + temp - 1)
        currentIndex = currentIndex + temp
    end
    if not noSuffix and result ~= str then
        result = result .. "..."
    end
    return result
end

-- 截取字符串指定长度
function ToolKit.isAllAscci(str)
    for i = 1, #str do
        if chsize(string.byte(str, i)) > 1 then
            return false;
        end
    end
    return true;
end

-- 截取字符串指定长度
function ToolKit.isValidTelNo(tel)
    local ret = string.gsub(tel, '%d*', '');
    return string.len(ret) == 0 and string.len(tel) == 11;
end

--字典
function ToolKit.getDict( dictName, fields )
    -- body
    local dict = new(Dict, dictName); dict:load();
    local data = {};

    for k, v in pairs(fields) do
        data[v] = dict:getString(v) or "";
    end

    return data;
end

function ToolKit.setDict( dictName, field2value )
    -- body
    local dict = new(Dict, dictName);

    for k, v in pairs(field2value) do
        dict:setString(k, tostring(v));
    end

    dict:save();
end

function ToolKit.tableLen(tbl)
    local count = 0;
    for k, v in pairs(tbl) do
        count = count + 1;
    end
    return count;
end

--判断lua文件是否存在
function ToolKit.luaFileExists(path)
   
   if(path == nil) then return false end 
   
   local storageScriptPath = System.getStorageScriptPath()
   local defaultPath = string.sub(storageScriptPath,0,string.find(storageScriptPath, "Resource", 0) + 7).."/scripts/";
         path = defaultPath..path;
   local file = io.open(path, "rb")

   if file then file:close() end
   return file ~= nil

end

function ToolKit.intersect(x, y, w, h, cx, cy, cw, ch)
    return not (cx + cw < x or cx > x + w or cy + ch < y or cy > y + h)
end

function ToolKit.intersectPoint(x, y, w, h, cx, cy, cw, ch)
    
    if cx < x then
        xs = x - cx;
        xe = cw;
        if cy < y then
            ys = y - cy
            ye = ch
        else
            ys = 1;
            ye = y + h - cy;
        end
    else
        xs = 1;
        xe = x + w - cx;
        if cy < y then
            ys = y - cy
            ye = ch
        else
            ys = 1;
            ye = y + h - cy;
        end
    end
    return xs, xe, ys, ye;
end

--parentNode 新生成文本的父节点
--需要格式化的字符串，替换字符串中的第一个%s
--replaceStr，将*替换成replaceStr
--defaultSizeAndColor str中出*外的其他文字的大小和颜色，用于Text构造的参数{size, r, g, b}
--specialSizeAndColor replaceStr的大小和颜色，结构同上
function ToolKit.formatRichText(parentNode, str, replaceStr, defaultSizeAndColor, specialSizeAndColor, align)
    if not parentNode then
        return
    end
    local s, e = string.find(str, "%%s")
    local curLen = 0
    --str分割成3段，中间是%s部分替换成replaceStr
    if s and e then
        if s > 1 then
            local text1 = new(Text, string.sub(str, 1, s - 1), 0, 0, kAlignLeft, "", unpack(defaultSizeAndColor))
            curLen = text1.m_res.m_width
            parentNode:addChild(text1)
        end
        local textSpe = new(Text, tostring(replaceStr), 0, 0, kAlignLeft, "", unpack(specialSizeAndColor))
        curLen = curLen + textSpe.m_res.m_width
        parentNode:addChild(textSpe)
        if e < string.len(str) then
            local text2 = new(Text, string.sub(str, e + 1, string.len(str)), 0, 0, kAlignLeft, "", unpack(defaultSizeAndColor))
            parentNode:addChild(text2)
            curLen = curLen + text2.m_res.m_width
        end
        --使字体居中显示
        local start = (parentNode:getSize() - curLen) / 2
        if align == kAlignLeft then
            start = 0
        end
        local children = parentNode:getChildren()
        for i = 1, #children do
            children[i]:setPos(start, 0)
            start = children[i].m_res.m_width + start
        end
    end
end

--获取utf8字符串的子字符串，根据byte长度来计算，确保字符完整显示，len长度不超过总长度
function ToolKit.utf8_subStringByLen(str, len)
    --最长不超过整个字符
    len = tonumber(len)
    if not len or len >= string.len(str) then
        return str
    end

    local to = 1
    while to <= len do
        local pre = to
        local c = string.byte(str, to)
        if c >= 0xF0 then
            to = to + 4
        elseif c >= 0xE0 then
          to = to + 3;
        elseif c >= 0xC0 then
          to = to + 2;
        else
          to = to + 1;
        end;
        --to的位置是新字符的起始位置，所以结束符是在to - 1,最后一个字符不读留着..
        if to > len then
            to = pre - 1
            break
        end
    end
    return string.sub(str, 1, to)
end;
--str，需要显示的字符串
--textNode, 该节点需要设置成str的字符串，主要是因为字体的原因需要知道该text的实际宽度
--maxLen，该textNode节点所能占用的最长宽度
function ToolKit.formatTextLength(str, textNode, maxLen)
    textNode:setText(str)
    local w = textNode.m_res.m_width
    if w <= maxLen then
        return
    end
    local percent = math.floor(maxLen * 100 / w)
    local strLen = math.floor(string.len(str) * percent / 100)
    local subStr = ToolKit.utf8_subStringByLen(str, strLen)..".."
    textNode:setText(subStr)
end

function ToolKit.createTexts(texts)
    -- body
    local node = new(Node)
    local x = 0
    local h = 0
    for i = 1, #texts do
        local text = new(Text, texts[i].text, 0, 0, kAlignLeft, "", texts[i].size, texts[i].r, texts[i].g, texts[i].b)
        text:setAlign(kAlignLeft)
        h = math.max(h, text.m_res.m_height)
        text:setPos(x, 0)
        x = x + text.m_res.m_width
        node:addChild(text)
    end
    node:setSize(x, h)
    return node
end

--将时间长度格式化为 XX时：XX分：XX秒
function ToolKit.formatTimeLength(leftTime)
    if leftTime > 0 then
        local hour = math.floor(leftTime / 3600)
        local minute = math.floor((leftTime - hour * 3600) / 60)
        local second = leftTime % 60
        return string.format("%02d : %02d : %02d", hour, minute, second)
    else
        return "0 : 0 : 0"
    end
end

--将节点以及子节点全部设置成灰色
function ToolKit.setNodeGray(node)
    local setChildGray
    setChildGray = function(node)
        if not node then
            return
        end
        if node.setGray then
            node:setGray(true)
        end
        local children = node.getChildren and node:getChildren()
        if children then
            for i = 1, #children do
                local child = children[i]
                setChildGray(child)
            end
        end
    end
    setChildGray(node)
end
