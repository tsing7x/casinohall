require("core/object");
require("core/system");
require("core/constants");
require("core/global")

DownloadImageFile = class();

DownloadImageFile.s_objs = {}--CreateTable("v");
DownloadImageFile.request_id = 0;
DownloadImageFile.kRequestExecute="image_request_execute";
DownloadImageFile.kResponse="image_response";
DownloadImageFile.kId="id";

DownloadImageFile.kUrl="url";
DownloadImageFile.kTimeout="timeout";
DownloadImageFile.kName="name"
DownloadImageFile.kFolder="folder"

DownloadImageFile.kError="error";

DownloadImageFile.allocId = function ()
	DownloadImageFile.request_id = DownloadImageFile.request_id + 1;
	return DownloadImageFile.request_id;
end

DownloadImageFile.getKey = function ( iRequestId )
	local key = string.format("image_request_%d",iRequestId or 0);
	return key;
end

DownloadImageFile.ctor = function(self, url, folder, imageName, timeout)
	self.m_requestID = DownloadImageFile.allocId();
	DownloadImageFile.s_objs[self.m_requestID] = self;
	self.m_requestUrl = url;
	self.m_folder = folder
	self.m_name = imageName
	self.m_timeout = timeout;
end

DownloadImageFile.getTimeout = function(self, timeout)
	return self.m_timeout or 0;
end

DownloadImageFile.execute = function(self)


	local key = DownloadImageFile.getKey(self.m_requestID);
	dict_set_int(DownloadImageFile.kRequestExecute, DownloadImageFile.kId, self.m_requestID);
	dict_set_string(key, DownloadImageFile.kUrl, self.m_requestUrl);
	dict_set_string(key, DownloadImageFile.kFolder, self.m_folder);
	dict_set_string(key, DownloadImageFile.kName, self.m_name);
	dict_set_string(key, DownloadImageFile.kTimeout, self.m_timeout);
	call_native("DownloadImageFile");
end

DownloadImageFile.setEvent = function(self, callback)
	self.m_eventCallback = callback
end

DownloadImageFile.dtor = function(self)
	request_destroy(self.m_requestID);
end

local function request_destroy(iRequestId)
	local key = DownloadImageFile.getKey(iRequestId);
	dict_delete(key);
end

function event_downloadImageFile_response()
	printInfo("event_downloadImageFile_response");
	local requestID = dict_get_int(DownloadImageFile.kResponse, DownloadImageFile.kId, 0);
	local key = DownloadImageFile.getKey(requestID);
	local errors = dict_get_int(key,DownloadImageFile.kError,-1);
	local folder = dict_get_string(key,DownloadImageFile.kFolder);
	local name = dict_get_string(key,DownloadImageFile.kName);

	request_destroy(requestID);
	local downAddReadFile = DownloadImageFile.s_objs[requestID];

	-- print_string("event_downAddReadFile_response==========id:" ..requestID);
	-- print_string("event_downAddReadFile_response==========key:" ..key);
	-- print_string("event_downAddReadFile_response==========errors:" ..errors);
	-- print_string("event_downAddReadFile_response==========folder:" ..folder);
	-- print_string("event_downAddReadFile_response==========name:" ..name);
	printInfo("requestID=" .. (requestID and requestID or 'nil'));

	printInfo("downAddReadFile=" .. (downAddReadFile and 'not nil' or 'nil'));
	printInfo("name=" .. (name and name or 'nil'));
	printInfo("folder=" .. (folder and folder or 'nil'));
	printInfo("downAddReadFile.m_eventCallback" .. (downAddReadFile.m_eventCallback and 'not nil' or 'nil'));

	if downAddReadFile and  downAddReadFile.m_eventCallback then
		printInfo("event_downloadImageFile_response2");
		downAddReadFile.m_eventCallback(errors, folder, name);
	end
end