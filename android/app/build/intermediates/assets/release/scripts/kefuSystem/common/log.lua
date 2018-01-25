
local Log = {}
Log.s_tab = ""
Log.s_serializePath = System.getStorageLogPath() .. "/" .. os.date("%Y-%m-%d %H-%M-%S", os.time()) .. ".txt";

Log.v = function(tag,...)
	Log.base(10,"VERBORSE--",tag,...); --绿色
end 

Log.d = function(tag,...)
	Log.base(14,"DEBUG--",tag,...); --黄色
end

Log.i = function(tag,...)
	Log.base(11,"INFO--",tag,...); --绿青
end

Log.e = function(tag,...)
	Log.base(12,"ERROR--",tag,...); --红色
end

Log.w = function(tag,...)
	Log.base(13,"WARN--",tag,...); --粉色
end

Log.a = function(tag,...)
	Log.base(15,"ASSERT--",tag,...); --白色
end

Log.s = function(tag,...) --红色
	local ret = Log.base(12,"SERIALIZI--",tag,...);
	if ret then
		local fp = io.open(Log.s_serializePath, "a+");
		if fp then
			fp:write(ret .. "\n");
			fp:close();
		end
	end
end

---------------------------------------------------------------------
local kefuDebug = false
Log.base = function(color,tagPrefix,tag,...)
	if not kefuDebug then 
		return;
	end

	if tag ~= nil then 
		tag = tostring(tag);
	end 
	tag = tag or "";
	local info = "";
	for _,v in pairs({...}) do 
		if v ~= nil then 
			if type(v) == "table" then
				local str = Log.loadTable(v);
				info = info..tostring(str).." ";
			else
				info = info..tostring(v).." ";
			end 
		end 
	end 
	ret = string.format("%s%s : %s",tagPrefix,tag,info);
	print_string(ret);
	return ret;
end

Log.loadTable = function(t)
	if type(t) ~= "table" then 
		return t;
	end 

	local tab = Log.s_tab;
	Log.s_tab = Log.s_tab.."    ";
	local temp = "";
	for k,v in pairs(t) do 
		if v ~= nil then 
			local key = Log.s_tab;
			if type(k) == "string" then
				key = key.."[\""..tostring(k).."\"] = ";
			else 
				key = key.."["..tostring(k).."] = ";
			end 
			
			if type(v) == "table" then 
				temp = temp..key..Log.loadTable(v);
			else 
				temp = temp..key..tostring(v)..";\n";
			end 
		end 
	end 
	Log.s_tab = tab;
	temp = "\n"..Log.s_tab.."{\n"..temp..Log.s_tab.."}\n";
	
	return temp;
end 

return Log
