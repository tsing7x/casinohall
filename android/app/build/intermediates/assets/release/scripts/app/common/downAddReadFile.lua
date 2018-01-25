require("core/object");
require("core/system");
require("core/constants");
require("core/global")

DownAddReadFile = class();

DownAddReadFile.s_objs = {};
DownAddReadFile.request_id = 0;
DownAddReadFile.kRequestExecute="request_execute";
DownAddReadFile.kResponse="response";
DownAddReadFile.kId="id";

DownAddReadFile.kUrl="url";
DownAddReadFile.kTimeout="timeout";

DownAddReadFile.kError="error";
DownAddReadFile.kRet="ret";

DownAddReadFile.allocId = function ()
	DownAddReadFile.request_id = DownAddReadFile.request_id + 1;
	return DownAddReadFile.request_id;
end

DownAddReadFile.getKey = function ( iRequestId )
	local key = string.format("request_%d",iRequestId or 0);
	return key;
end

DownAddReadFile.ctor = function(self, url , timeout)
	self.m_requestID = DownAddReadFile.allocId();
	DownAddReadFile.s_objs[self.m_requestID] = self;
	self.m_requestUrl = url;
	self.m_timeout = timeout;
end

DownAddReadFile.setTimeout = function(self, timeout)
	self.m_timeout = timeout;
end

DownAddReadFile.getTimeout = function(self, timeout)
	return self.m_timeout or 0;
end

DownAddReadFile.setRequestUrl = function(self , url)
	self.m_requestUrl = url;
end

DownAddReadFile.getRequestUrl = function(self)
	return self.m_requestUrl or "";
end

DownAddReadFile.setError = function(self , error)
	self.m_error = error;
end

DownAddReadFile.getError = function(self)
	return self.m_error or -1;
end

DownAddReadFile.setRet = function(self , ret)
	self.m_ret = ret;
end

DownAddReadFile.getRet = function(self)
	return self.m_ret or "";
end

DownAddReadFile.execute = function(self)
	local key = DownAddReadFile.getKey(self.m_requestID);
	dict_set_int(DownAddReadFile.kRequestExecute,DownAddReadFile.kId,self.m_requestID);
	dict_set_string(key,DownAddReadFile.kUrl,self.m_requestUrl);
	dict_set_string(key,DownAddReadFile.kTimeout,self.m_timeout);
	call_native("HttpDownAddReadFile");
end

DownAddReadFile.setEvent = function(self, callback)
	self.m_eventCallback = callback
end

DownAddReadFile.dtor = function(self)
	request_destroy(self.m_requestID);
end

local function request_destroy(iRequestId)
	local key = DownAddReadFile.getKey(iRequestId);
	dict_delete(key);
end

function event_downAddReadFile_response()

	local requestID = dict_get_int(DownAddReadFile.kRequestExecute,DownAddReadFile.kId,0);
	local key = DownAddReadFile.getKey(requestID);
	local errors = dict_get_int(key,DownAddReadFile.kError,-1);
	local ret = dict_get_string(key,DownAddReadFile.kRet);
	request_destroy(requestID);
	local downAddReadFile = DownAddReadFile.s_objs[requestID];
	-- print_string("event_downAddReadFile_response==========id:" ..requestID);
	-- print_string("event_downAddReadFile_response==========key:" ..key);
	-- print_string("event_downAddReadFile_response==========errors:" ..errors);
	-- print_string("event_downAddReadFile_response==========ret:" ..ret);
	if downAddReadFile and  downAddReadFile.m_eventCallback then
		downAddReadFile.m_eventCallback(errors, ret);
	end
end