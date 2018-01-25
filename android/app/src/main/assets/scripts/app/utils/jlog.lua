
require("core/system");	
-- require("config")
-- local DEBUG_MODE = false;

JLog = class();

JLog.s_tab = "";

JLog.s = function(tag,...)
	JLog.base(0x00008b,"SOCKET--",tag,...);--蓝色
end

JLog.v = function(tag,...)
	JLog.base(0x00ff00,"VERBORSE--",tag,...); --绿色
end 

JLog.i = function(tag,...)
	JLog.base(0x00fa9a,"INFO--",tag,...); --绿青
end

JLog.e = function(tag,...)
	JLog.base(0x8b0000,"ERROR--",tag,...); --红色
	JLog.crash(tag,...); 
end

JLog.w = function(tag,...)
	JLog.base(0xff8080,"WARN--",tag,...); --粉色
end

JLog.d = function(tag,...)
	JLog.base(0xffff00,"DEBUG--",tag,...); --黄色
end

JLog.a = function(tag,...)
	JLog.base(0xffffff,"ASSERT--",tag,...); --白色
end

-----------------------------------------
JLog.sWF = function(tag,...)
	JLog.s(tag,...);
	JLog.writeFile(tag,...);
end

JLog.vWF = function(tag,...)
	JLog.v(tag,...);
	JLog.writeFile(tag,...);
end

JLog.dWF = function(tag,...)
	JLog.d(tag,...);
	JLog.writeFile(tag,...);
end

JLog.iWF = function(tag,...)
	JLog.i(tag,...);
	JLog.writeFile(tag,...);
end

JLog.eWF = function(tag,...)
	--JLog.e(tag,...);
	JLog.writeFile(tag,...);
end

JLog.wWF = function(tag,...)
	JLog.w(tag,...);
	JLog.writeFile(tag,...);
end

JLog.aWF = function(tag,...)
	JLog.a(tag,...);
	JLog.writeFile(tag,...);
end

JLog.module = function(tag, ...)
	JLog.a(tag,...);
	JLog.writeFile(tag,...);
end
--------------------------------------------------------------------
JLog.crash = function(tag,...)
	if not DEBUG_MODE then 
		return;
	end
	
	local strInfo = JLog.getStrInfo("ERROR--",tag,...);
	error("--业务逻辑错误 请及时周知开发--" .. strInfo);
end

---------------------------------------------------------------------
JLog.getStrInfo = function(tagPrefix,tag,...)
	local strInfo = JLog.getData(tagPrefix,tag,...);
	return strInfo;
end


JLog.base = function(color,tagPrefix,tag,...)
	if not DEBUG_MODE then 
		return;
	end
	
	-- System.setWin32ConsoleColor(color);
	local strInfo = JLog.getStrInfo(tagPrefix,tag,...);
	print_string(strInfo);
end

JLog.writeFile = function(tag,...)
	if not DEBUG_MODE then 
		return;
	end
	local datePreFix = os.date("%Y-%m-%d %H:%M:%S") or "";
	local strInfo = string.format("%s%s%s%s",datePreFix , " : ", JLog.getData(tag,...) , "\n");
	local fileFullPath = JLog._getJLogFileFullPath(tag);
	local file = io.open(fileFullPath,"a");
	if file then
		file:write(strInfo);
		file:close();
	end
end

JLog.readFile = function(tag)
	local fileFullPath = JLog._getJLogFileFullPath(tag);
	local file = io.open(fileFullPath,"r");
	local info = "";
	if file then 
		info = file:read("*all");
		file:close();
	end 

	return info;
end

JLog.clearFile = function(tag)
	local fileFullPath = JLog._getJLogFileFullPath(tag);
	local file = io.open(fileFullPath,"w+");
	if file then 
		file:close();
	end 
end

JLog._getJLogFileFullPath = function(tag)
	local dateFileName = tag or os.date("%Y_%m_%d") or "";
	local fileFullPath = string.format("%s%s%s%s",System.getStorageJLogPath() , "/log_" , dateFileName , ".log");
	return fileFullPath;
end

JLog.getData = function(tagPrefix,tag,...)
	tag = tag or "";
	tagPrefix = tagPrefix or "INFO--";
	local info = "";
	for _,v in pairs({...}) do
		local tempType = type(v); 
		if tempType == "table" then
			local str = JLog.loadTable(v);
			info = info..tostring(str);
		else
			info = info..tostring(v);
		end
		info = info .. " ";
	end
	
	return string.format("%s%s: %s",tagPrefix,tag,info);

end

JLog.loadTable = function(t)
	if type(t) ~= "table" then 
		return t;
	end 

	local tab = JLog.s_tab;
	JLog.s_tab = JLog.s_tab.."    ";
	local temp = "";
	for k,v in pairs(t) do 
		if v ~= nil then 
			local key = JLog.s_tab;
			if type(k) == "string" then
				key = key.."[\""..tostring(k).."\"] = ";
			else 
				key = key.."["..tostring(k).."] = ";
			end 
			
			if type(v) == "table" then 
				temp = temp..key..JLog.loadTable(v);
			else 
				temp = temp..key..tostring(v)..";\n";
			end 
		end 
	end 
	JLog.s_tab = tab;
	temp = "\n"..JLog.s_tab.."{\n"..temp..JLog.s_tab.."}\n";
	
	return temp;
end 


------------------- 日志记录及上报开始 -------------------------------
--记录日志
JLog.recordData = {};

JLog.clearRecord = function()
	JLog.recordData = {};
end

JLog.getRecordStr = function()
	if type(JLog.recordData) == "table" then
		local str = "";
		for k, v in pairs(JLog.recordData) do
			if type(v) == "string" and v ~= "" then
				str = str .. v .. "\n";
			end
		end
		return str;
	end
	return "";
end

JLog.addRecord = function(recordStr)
	if type(recordStr) == "string" and recordStr ~= "" then
		if type(JLog.recordData) ~= "table" then
			JLog.recordData = {};
		end
		table.insert(JLog.recordData, recordStr);
		return true;
	else
		return false;
	end
end

--没设置过默认打开写记录
JLog.setRecordSwitch = function(isOpen)
	JLog.m_isOpenRecordSwitch = isOpen;
end

JLog.isRecordJLog = function()
	return JLog.m_isOpenRecordSwitch ~= false;
end
--[[
	日志记录1.0版本
		1.0 日志存缓存

	@tag  日志标记，可变参数
	@author JasonWang
	@time 2015-1-13
]]
JLog.record = function(tag, ...)
	if type(tag) ~= "string" or tag == "" then
		return false;
	end
	
	JLog.i(tag, ...);

	if not JLog.isRecordJLog() then 
		return false;
	end 
	
	local t = {...};
	if type(t) == "table" and #t > 0 then
		--此处将t内容拼接
		local contentStr = "";
		for k,v in pairs(t) do
			local str = "null";
			if type(v) == "string" or type(v) == "number" then
				str = v;
			elseif type(v) == "boolean" then
				str = v and "true" or "false";
			end
			contentStr = contentStr .. str;
		end

		local netWorkType = NativeEvent.getInstance():getNetworkType();
		--1：wifi  2:2G  3:3G  4:4G  -1:未知或无网络
		local netStr = "unknown";
		if netWorkType == 1 then
			netStr = "wifi";
		elseif netWorkType == 2 then
			netStr = "2G";
		elseif netWorkType == 3 then
			netStr = "3G";
		elseif netWorkType == 4 then
			netStr = "4G";
		end

		-- local xinhao = NativeEvent.getInstance():getSignalStrength();
		-- JLog.d("wanpg-----NativeEvent.getInstance():getSignalStrength()--", xinhao);
		-- xinhao = tonumber(xinhao) or 0; 
		local hall_version = GameManager.getInstance():getGameVersion(GameType.HALL) or 0;
		local gameDes = "";
		local curGameId = GameManager.getInstance():getCurGameId();
		if curGameId ~= GameType.HALL and curGameId ~= 0 then
			local game_version = GameManager.getInstance():getGameVersion(curGameId) or 0;
			gameDes = gameDes.."-gameId:"..curGameId.."-game_version:"..game_version;
		end 
		local time  = os.date("%Y-%m-%d %H:%M:%S") or "";
		local result = "appid-" .. kAppId .. "-" .. time .."-netType:" .. netStr .. "-hall_version:" .. hall_version .. gameDes .. "-" .. tag ..  "--".. contentStr;
		
		return JLog.addRecord(result);
	else
		return false;
	end
end

JLog.setUploadConfig = function(info)
	info = table.verify(info);

	JLog.uploadJLoginType = number.valueOf(info.report_srvlog_login, 1);--登录是否需要上报，默认为开启（单独判断、不需要和UploadType组合使用）
	JLog.uploadJLogsType = number.valueOf(info.report_srvlog, 1);--除登录外的其余日志上报类型， 默认为开启
	JLog.uploadJLogsList = table.verify(info.report_srvlog_games);--需要上报的日志类型

	local dict = new(Dict, "LOG_SER_ERROR");
	dict:load();
	dict:setInt("upload_login_type", JLog.uploadJLoginType);
	dict:setInt("upload_logs_type", JLog.uploadJLogsType);
	dict:setString("upload_logs", json.encode(JLog.uploadJLogsList));
	dict:save();
	delete(dict);
	dict = nil;
end

JLog.loadUploadConfig = function()
	local dict = new(Dict, "LOG_SER_ERROR");
	dict:load();
	JLog.uploadJLoginType = dict:getInt("upload_login_type", 1);
	JLog.uploadJLogsType = dict:getInt("upload_logs_type", 1);
	local logs = dict:getString("upload_logs");
	JLog.uploadJLogsList = table.verify(json.decode(logs));
	delete(dict);
	dict = nil;
end

JLog.getIsUploadJLoginJLog = function()
	if tonumber(JLog.uploadJLoginType) then
		return JLog.uploadJLoginType;
	end
	JLog.loadUploadConfig();

	return JLog.uploadJLoginType ~= 0;
end


JLog.getUploadJLogsType = function()
	if tonumber(JLog.uploadJLogsType) then
		return JLog.uploadJLogsType;
	end
	JLog.loadUploadConfig();
	return JLog.uploadJLogsType;
end

JLog.getUploadJLogsList = function()
	if JLog.uploadJLogsList then 
		return table.verify(JLog.uploadJLogsList);
	end

	JLog.loadUploadConfig();

	return JLog.uploadJLogsList;
end

--游戏中的日志类型为游戏的gameId
JLog.checkIsNeedUpload = function(logType)
	if not logType then 
		return false;
	end 

	if JLog.getUploadJLogsType() == 0 then 
		return false;
	end 

	local logsList = JLog.getUploadJLogsList();
	for k,v in pairs(logsList) do 
		if tostring(v) == tostring(logType) then 
			return true;
		end 
	end 
	return false;
end
------------------- 日志记录及上报结束 -------------------------------
