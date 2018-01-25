Http.getRequestUrl = function(self)
	return self.m_requestUrl or "";
end

local ctor = Http.ctor;
Http.ctor = function(self, requestType, responseType, url)
	ctor(self, requestType, responseType, url);
	self.m_requestUrl = url;
end