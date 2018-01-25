function c3b(r, g, b)
	return {r = r, g=g, b=b}
end

function ccp(x, y)
	return {x=x, y=y}
end

function ccs(w, h)
    return {width=w, height=h}
end

function ccrect(x, y, width, height)
	return {x=x, y=y, width=width, height=height}
end

function containsPoint(rect, p)
	return p.x >= rect.x and p.x <= rect.x + rect.width 
		and p.y >= rect.y and p.y <= rect.y + rect.height
end

--[[
	判断table是否为空
]]
function table.isEmpty(t)
	if t and type(t)=="table" then --FIXME 此句可以判空，为何还要循环表内元素？
		return next(t)==nil;  
	end
	return true;			
end

--[[
    判断table是否为nil
]]
function table.isNil(t)
    if t and type(t)=="table" then 
        return false;
    end
    return true;            
end


--[[
    判断table是否为table
]]
function table.isTable(t)
    if type(t)=="table" then 
        return true;
    end
    return false;            
end

--[[
    复制table，只复制数据，对table内的function无效
]]
function table.copyTab(st)
    local tab = {}
    for k, v in pairs(st or {}) do
        if type(v) ~= "table" then
            tab[k] = v
        else
            tab[k] = table.copyTab(v)
        end
    end
    return tab
end

--[[
    table校验，返回自身或者{}
]]
function table.verify(t)   
    if t and type(t)=="table" then
        return t;
    end
    return {};
end

function table.getSize(t)   
    local size =0;
    if t and type(t)=="table" then
        for k,v in pairs(t) do
            size=size+1;
        end
    end
    return size;
end

--XXX 不符合格式时 是否需要直接返回？根据模块需求，自行修改是否放行，确认后请把此注释删除。