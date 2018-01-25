local BoyaaConversation = require('kefuSystem/mqttModule/boyaaConversation')
local HTTP2 = require("network.http2")
local UserData = require('kefuSystem/conversation/sessionData')
local Log = require('kefuSystem/common/log')
local URL = require("kefuSystem/mqttModule/mqttConstants")

local GKefuOnlyOneConstant = require('kefuSystem/common/kefuConstant')

--接收协议后的回调函数
-- local receviceCallback = require("kefuSystem/conversation/protocalFunc")
local loginTaskClock = nil

local CODE = {
-------------------1xx: 信息-------------------------------
	CONTINUE = 100,					-- 服务器仅接收到部分请求，但是一旦服务器并没有拒绝该请求，客户端应该继续发送其余的请求。
	SWITCHING_PROTOCOLS = 101 ,		-- 服务器转换协议：服务器将遵从客户的请求转换到另外一种协议。

-------------------2xx: 成功-------------------------------
	OK	= 200,						-- 请求成功（其后是对GET和POST请求的应答文档。）
	Created = 201,					-- 请求被创建完成，同时新的资源被创建。
	Accepted = 202,					-- 供处理的请求已被接受，但是处理未完成。
	NON_AUTHORITATIVE_INFORMATION = 203, -- 文档已经正常地返回，但一些应答头可能不正确，因为使用的是文档的拷贝。
	NO_CONTENT = 204,				-- 没有新文档。浏览器应该继续显示原来的文档。如果用户定期地刷新页面，而Servlet可以确定用户文档足够新，这个状态代码是很有用的。
	RESET_CONTENT = 205,			-- 没有新文档。但浏览器应该重置它所显示的内容。用来强制浏览器清除表单输入内容。
	PARTIAL_CONTENT = 206,			-- 客户发送了一个带有Range头的GET请求，服务器完成了它。

-------------------3xx: 重定向-------------------------------

 	MULTIPLE_CHOICES = 300,			-- 多重选择。链接列表。用户可以选择某链接到达目的地。最多允许五个地址。
	MOVED_PERMANENTLY = 302	,		-- 所请求的页面已经转移至新的url。
	FOUND	= 303,					-- 所请求的页面已经临时转移至新的url。
	SEE_OTHER	= 304,				-- 所请求的页面可在别的url下被找到。
	NOT_MODIFIED	= 305,			-- 未按预期修改文档。客户端有缓冲的文档并发出了一个条件性的请求（一般是提供If-Modified-Since头表示客户只想比指定日期更新的文档）。服务器告诉客户，原来缓冲的文档还可以继续使用。
	USE_PROXY	= 306	,			-- 客户请求的文档应该通过Location头所指明的代理服务器提取。
	UNUSED	= 307,					-- 此代码被用于前一版本。目前已不再使用，但是代码依然被保留。
	TEMPORARY_REDIRECT	= 308,		-- 被请求的页面已经临时移至新的url。

-------------------4xx: 客户端错误-------------------------------

	BAD_REQUEST	 = 400 ,				-- 服务器未能理解请求。
	UNAUTHORIZED	= 401,			-- 被请求的页面需要用户名和密码。
	PAYMENT_REQUIRED	= 402,		-- 此代码尚无法使用。
	FORBIDDEN		= 403	,		-- 对被请求页面的访问被禁止。
	NOT_FOUND		= 404	,		-- 服务器无法找到被请求的页面。
	METHOD_NOT_ALLOWED	= 405,		-- 请求中指定的方法不被允许。
	NOT_ACCEPTABLE		= 406	,	-- 服务器生成的响应无法被客户端所接受。
	PROXY_AUTHENTICATION_REQUIRED	= 407,	-- 用户必须首先使用代理服务器进行验证，这样请求才会被处理。
	REQUEST_TIMEOUT		= 408,		-- 请求超出了服务器的等待时间。
	CONFLICT		= 409,			-- 由于冲突，请求无法被完成。
	GONE		= 410	,			-- 被请求的页面不可用。
	LENGTH_REQUIRED	 = 411,			--  "CONTENT-LENGTH" 未被定义。如果无此内容，服务器不会接受请求。
	PRECONDITION_FAILED	 = 412,		-- 请求中的前提条件被服务器评估为失败。
	REQUEST_ENTITY_TOO_LARGE  = 413,	-- 由于所请求的实体的太大，服务器不会接受请求。
	REQUEST_URL_TOO_LONG = 414,		-- 由于URL太长，服务器不会接受请求。当POST请求被转换为带有很长的查询信息的GET请求时，就会发生这种情况。
	UNSUPPORTED_MEDIA_TYPE = 415,	-- 由于媒介类型不被支持，服务器不会接受请求。
}


local function getToken( cb )
	local info = mqtt_client_config
	local args = {
      	url = URL.HTTP_GET_DYNAMIC_TOKEN,
--      	url = 'https://cs-test.boyaagame.com/auth',
      	headers = {
      		'charset:utf-8'
      	},
      	timeout = 10,                    
	    connecttimeout = 5,
	    post = {
	    		{
				     type = "content",      -- post 发送的变量
				     name = "gid",             -- 服务器接受此内容的变量名称
				     contents = info.gameId,   -- 发送的内容
				     content_type = ""       -- 发送的类型,按照服务器端的要求来填写
				 },
				 {
				     type = "content",      -- post 发送的变量
				     name = "site_id",             -- 服务器接受此内容的变量名称
				     contents = info.siteId ,   -- 发送的内容
				     content_type = ""       -- 发送的类型,按照服务器端的要求来填写
				 },
				 {
				     type = "content",      -- post 发送的变量
				     name = "station_id",             -- 服务器接受此内容的变量名称
				     contents = info.stationId,   -- 发送的内容
				     content_type = ""       -- 发送的类型,按照服务器端的要求来填写
				 },
		},
	}
	print_string("666666666666666666",args.url,args.timeout)
--	https://cs-test.boyaagame.com/auth
	HTTP2.request_async(args,
	    function(rsp)
			print_string('getToken rsp.code',rsp.content)
	    	if rsp.code == CODE.OK then
	    		local content = cjson.decode(rsp.content)
	    		Log.v(inspect(content),content.token)
	    		cb(content.token)
	    	else
	    		local rsp = {}
				rsp.errmsg = "not token"
				rsp.code = 400
				if cb then
					cb(rsp)
				end
	    	end 
	    end
    )

end

local netWorkControl = {}

netWorkControl.init = function ()
	netWorkControl.destroy()

	netWorkControl.initClock = Clock.instance():schedule_once(function()
		netWorkControl.MQTT = new(BoyaaConversation, mqtt_client_config, mqtt_client_info);
		-- EventDispatcher.getInstance():register(GKefuOnlyOneConstant.mqttReceive, netWorkControl, netWorkControl.receiveProtocal)
		netWorkControl.sendProtocol("connect") 
			          
	end, 0.4)


end

netWorkControl.prepareChat = function ()
	if netWorkControl.MQTT then
		netWorkControl.MQTT:prepareChat()
	end
end

netWorkControl.generateClientInfo = function (avatarUri)
	if netWorkControl.MQTT then
		return netWorkControl.MQTT:generateClientInfo(avatarUri)
	end

	return "" 
end

netWorkControl.getToken = function ()
	if netWorkControl.MQTT then
		return netWorkControl.MQTT:getToken()
	end
end

netWorkControl.sendProtocol = function (proName, ...)
	if netWorkControl.MQTT and netWorkControl.MQTT[proName] then
		return netWorkControl.MQTT[proName](netWorkControl.MQTT, ...)
	end
end


netWorkControl.receiveProtocal = function (self, proName, ...)
	if proName == "end" then
		proName = "xend"
	end

	if receviceCallback[proName] then
		receviceCallback[proName](...)
	end
end

--不断发Login协议
netWorkControl.schedulePollLoginTask = function ()
	if not loginTaskClock then
		loginTaskClock = Clock.instance():schedule(function()
             netWorkControl.sendProtocol("login")   
        end, GKefuOnlyOneConstant.DELAY_POLL_LOGIN)
	else
		loginTaskClock.paused = false
	end
end


--取消循环login操作
netWorkControl.cancelPollLoginTask = function ()
	if loginTaskClock then
		loginTaskClock.paused = true
	end
end


netWorkControl.downLoadFile = function (url, filePath, callback)
	
	local data = UserData.getStatusData() or {}

	local args = {
      	url = url, 
	    headers = {

	    },

	    query = {                      -- optional, query_string
	        fid = string.format("%s/%s/%s", mqtt_client_config.gameId, mqtt_client_config.siteId, mqtt_client_config.stationId),
	        session_id = data.sessionId,
	    },
	    timeout = 10,                    -- optional, seconds
	    connecttimeout = 10,             -- optional, seconds
	      writer = {                     -- optional, override writer behaviour.
		     type = 'file',                  -- save to file, rsp.content would be empty.
		     filename = filePath,
		     mode = 'wb',
		},
	}

	HTTP2.request_async(args,
	    function(rsp)
	    	--print("LoadHistoryMsg:"..rsp.content)
	    	if rsp.errmsg then
	    		Log.v("DownLoadFile Fail:"..rsp.errmsg)
	    	elseif rsp.code == 200 and callback then
		     	callback()
		    end
	    end
    )
end


netWorkControl.upLoadFile = function (fullPath, callback,fileType)
	local data = UserData.getStatusData() or {}
	local args = {
      	url = URL.FILE_UPLOAD_URI,
--      	url = 'https://cs-test.boyaagame.com/upload',
	    headers = {

	    },

	    query = {                      -- optional, query_string
	        fid = string.format("%s/%s/%s", mqtt_client_config.gameId, mqtt_client_config.siteId, mqtt_client_config.stationId),
	        session_id = data.sessionId,
	        sign = string.format("%s/%s/%s", mqtt_client_config.gameId, mqtt_client_config.siteId, mqtt_client_config.stationId),
	    },
	    timeout = 10,                    -- optional, seconds
	    connecttimeout = 10,             -- optional, seconds
	    post = {
            {
                type = "file",
                name = "file",
                filepath = fullPath,
                file_type = fileType,
            },                      
	    },
	}

	getToken(function ( token )
		print_string("333333333333333",args.url)
		if type(token) == "string" then
			args.query.token = token
			HTTP2.request_async(args,
			    function(rsp)
			    	if callback then
			    		callback(rsp)
			    	end
			    end
		    )
		else
			if callback then
				callback(token)
			end
		end
	end)
	
end


--从网络拉取历史消息
netWorkControl.loadHistoryMsgFromNetwork = function (seqId, callback)
	local args = {
      	url = URL.HTTP_NETWORK_HISTORY_MESSAGE_URI,
      	headers = {},
      	query = {
      		gid = mqtt_client_config.gameId,
      		site_id = mqtt_client_config.siteId,
      		client_id = mqtt_client_config.stationId,
      		seq_id = seqId,					--当前显示的最早的消息的seqId
      		limit = GKefuOnlyOneConstant.NETWORK_MESSAGE_LIMIT,						
      	},
      	timeout = 10,                    
	    connecttimeout = 5,
      
	}

	
    getToken(function ( token )
		if type(token) == "string" then
			args.query.token = token
			HTTP2.request_async(args,
			    function(rsp)
			      	if rsp.errmsg then
			      		Log.d("LoadHistoryMsg", "Fail:"..rsp.errmsg)
			    	elseif rsp.code == 200 and callback then
			    		Log.d("LoadHistoryMsg", "success: "..rsp.content)		    	
				    end

			     	callback(rsp)
			    end
		    )
		else
			if callback then
				callback(token)
			end
		end
	end)
    
end

--获取用户留言,盗号，举报历史记录
netWorkControl.obtainUserTabHistroy = function (start, limit, url, callback)

	local args = {
      	url = url,
      	headers = {},
      	query = {
      		gid = mqtt_client_config.gameId,
      		site_id = mqtt_client_config.siteId,
      		client_id = mqtt_client_config.stationId,
      		start = start,					
      		limit = limit,
      	},
      	timeout = 10,                    
	    connecttimeout = 5,
      
	}


	getToken(function ( token )
		if type(token) == "string" then
			args.query.token = token
			HTTP2.request_async(args,
			    function(rsp)
			      	if rsp.errmsg then
			    		Log.v("obtainUserTabHistroy","Fail:" ,rsp.errmsg);
			    	elseif rsp.code == 200 and callback then
			    		Log.v("obtainUserTabHistroy","sucess" ,rsp.content);
			    		if UserData.isClear() then
			    			callback(rsp.content)
			    		end
				    end
			    end
		    )
		else
			if callback then
				callback(token)
			end
		end
	end)

end

--获取模块配置信息
netWorkControl.abtainModuleInfoCfg = function (cb)
	--默认为开启状态
	GKefuOnlyOneConstant.showLeaveModule = 1
	GKefuOnlyOneConstant.showHackModule = 1
	GKefuOnlyOneConstant.showReportModule = 0

	local args = {
      	url = URL.HTTP_GET_DYNAMIC_INFO_URI,
      	headers = {},
      	query = {
      		fid = string.format("%s/%s/%s", mqtt_client_config.gameId, mqtt_client_config.siteId, mqtt_client_config.stationId),
      	},
      	timeout = 10,                    
	    connecttimeout = 5,      
	}

    getToken(function ( token )
		if type(token) == "string" then
			args.query.token = token
			HTTP2.request_async(args,
			    function(rsp)
			    	Log.v("abtainModuleInfoCfg","result:" ,rsp.content)    	
			      	if rsp.errmsg then
			    		Log.w("abtainModuleInfoCfg","Fail:" ,rsp.errmsg)
			    		cb(false)
			    	elseif rsp.code == 200 then
				     	local tb = cjson.decode(rsp.content)
				     		
				     	if tb.code == 0 then
				     		local modules = tb.data.modules
				     		GKefuOnlyOneConstant.showLeaveModule = modules.advise
				     		GKefuOnlyOneConstant.showHackModule = modules.report
				     		GKefuOnlyOneConstant.showReportModule = modules.appeal
				     		cb(true)
				     	else
				     		cb(false)
				     	end	    	
				    end
			    end
		    )
		else
			if cb then
				cb(false)
			end
		end
	end)

end

netWorkControl.getOffMsgNum = function (callback)
	local args = {
      	url = URL.HTTP_OBTAIN_OFFLINE_MESSAGES,
      	headers = {},
      	query = {
      		fid = string.format("%s/%s/%s", mqtt_client_config.gameId, mqtt_client_config.siteId, mqtt_client_config.stationId),
      	},
      	timeout = 10,                    
	    connecttimeout = 5,      
	}

	HTTP2.request_async(args,
	    function(rsp)
	    	Log.v("getOffMsgNum","result:" ,rsp.content)    	
	      	if rsp.errmsg then
	    		Log.w("getOffMsgNum","Fail:" ,rsp.errmsg)
	    	elseif rsp.code == 200 then
		     	local tb = cjson.decode(rsp.content)
		     	--todo:	
		     	if tb.code == 0 and callback then
		     		callback(tb.num)
		     	end	    	
		    end
	    end
    )

end



netWorkControl.postString = function (url, content, callback)
	-- getToken(  )

	local args = {
      	url = url,
      	headers = {
      		'Content-Type:application/json',
      		'Accept:application/json',
      		'charset:utf-8'
      	},
      	timeout = 10,                    
	    connecttimeout = 5,
	    post = content,
	}
	getToken(function ( token )
		if type(token) == "string" then
			args.query = {token = token}
			HTTP2.request_async(args,
			    function(rsp)
			    	if callback then
			    		callback(rsp)
			    	end
			    end
		    )
		else
			if callback then
				callback(token)
			end
		end
	end)
	

end

netWorkControl.putString = function (url, content, callback)
	local args = {
      	url = url,
      	put = content,
      	headers = {
      		'Content-Type:application/json',
      		'Accept:application/json',
      		'charset:utf-8'
      	},
      	timeout = 10,                    
	    connecttimeout = 5,

	}
	getToken(function ( token )
		if type(token) == "string" then
			args.query = {token = token}
			HTTP2.request_async(args,
			    function(rsp)
			    	if rsp.errmsg then
			    		Log.v("putString","Fail:" ,rsp.errmsg);
			    	elseif rsp.code == 200 and callback then    		
				     	callback(rsp.content);	    	
				    end
			    end
		    )
		end
	end)
end


netWorkControl.destroy = function ()
	-- EventDispatcher.getInstance():unregister(GKefuOnlyOneConstant.mqttReceive, netWorkControl, netWorkControl.receiveProtocal)

	if netWorkControl.initClock then
		netWorkControl.initClock:cancel()
		netWorkControl.initClock = nil
	end

	if netWorkControl.MQTT then
		delete(netWorkControl.MQTT)
		netWorkControl.MQTT = nil
	end	            

end


--获取用户留言,盗号，举报历史记录
local function localObtainUserTabHistroy(start, limit, url, callback)
	local args = {
      	url = url,
      	headers = {},
      	query = {
      		gid = mqtt_client_config.gameId,
      		site_id = mqtt_client_config.siteId,
      		client_id = mqtt_client_config.stationId,
      		start = start,					
      		limit = limit,
      	},
      	timeout = 10,                    
	    connecttimeout = 5,
      
	}


	getToken(function ( token )
		if type(token) == "string" then
			args.query.token = token
			HTTP2.request_async(args,
			    function(rsp)
			      	if rsp.errmsg then
			    		Log.v("localObtainUserTabHistroy","Fail:" ,rsp.errmsg);
			    	elseif rsp.code == 200 and callback then
			    		Log.v("localObtainUserTabHistroy","sucess" ,rsp.content);
		    			callback(rsp.content)
				    end
			    end
		    )
		else
			if callback then
				callback(token)
			end
		end
	end)

end

function netWorkControl.hasNewMessage( cb )
	local function callback( ret )
		if cb then
			cb()
		end
	end

	--是否有新盗号回复
	local appealData = UserData.getPlayerReportViewData() or {}
	local dictData = appealData.dictData or {}
	appealData.hasNewReport = 0

	localObtainUserTabHistroy(0, 50, URL.HTTP_SUBMIT_APPEAL_HISTORY_URI, function (content)
		local tb
		if type(content) == "string" then
			tb = cjson.decode(content)
		else
			tb = content
		end
		
		if tb.code == 0 then
			if not tb.data then return end
			local replyData = {}
			for i, v in ipairs(tb.data) do
				--说明是新提交的消息
				if not dictData[v.id] then
					callback(true)
					return
				end
				--说明是新回复
				if v.reply ~= "" and dictData[v.id].reportContent ~= v.reply then
					callback(true)
					return
				end
			end
		else
			Log.w("hasNewMessage", "盗号内容获取失败")
		end
	end)

	local leaveData = UserData.getLeaveMessageViewData() or {}
	local dictData = leaveData.dictData or {}

	localObtainUserTabHistroy(0, 50, URL.HTTP_SUBMIT_ADVISE_HISTORY_URI, function (content)
		local tb
		if type(content) == "string" then
			tb = cjson.decode(content)
		else
			tb = content
		end
		if tb.code == 0 then
			if not tb.data then return end 
			table.sort(tb.data, function (v1,v2)
                if v1.id > v2.id then
                    return true
                end
                return false
            end)
            local replyData = {}
			for i, v in ipairs(tb.data) do
				--说明是新提交的消息
				if not dictData[v.id] then
					callback(true)
					return
				end

				if v.replies then
					local replyNum = #v.replies
					--需要找到最晚客服回复的那条消息与本地消息进行对比，不同则认为有新消息					
         			if v.replies[replyNum].from_client == 0 and dictData[v.id].reportContent ~= v.replies[replyNum].reply then
						callback(true)
						return	
         			end

            	end
            end
		else          
            Log.w("hasNewMessage", "留言内容获取失败")
		end
	end)

	local hackData = UserData.getHackAppealViewData() or {}
	local dictData = hackData.dictData or {}
	hackData.hasNewReport = 0

	localObtainUserTabHistroy(0, 50, URL.HTTP_SUBMIT_REPORT_HISTORY_URI, function (content)
        local tb
		if type(content) == "string" then
			tb = cjson.decode(content)
		else
			tb = content
		end

        if tb.code == 0 then
        	if not tb.data then return end
            table.sort(tb.data, function (v1,v2)
                if v1.id > v2.id then
                    return true
                end
                return false
            end)
            
            local replyData = {}
            for i, v in ipairs(tb.data) do
            	--说明是新提交的消息
            	v.id = tonumber(v.id)
				if not dictData[v.id] then
					callback(true)
					return
				end

				--说明是新回复
				if v.reply ~= "" and dictData[v.id].reportContent ~= v.reply then
					callback(true)
					return
				end
            end   
        else
            Log.w("hasNewMessage", "举报内容获取失败")
        end
    end)


    netWorkControl.getOffMsgNum(function ( count )
    	if count > 0 then
    		callback(true)
			return
    	end
    end) 
end


local RECONNECT_CUSTOMER_HANDLE = nil
-- 不断发起连接人工客服的协议
function netWorkControl.ReconnectCustomer(isVip)
	Log.v("--------netWorkControl.ReconnectCustomer------","start",str)
	local tab = {value = 1,type = 31,text = "转人工客服"};
	local str = cjson.encode(tab)
	if not RECONNECT_CUSTOMER_HANDLE then
		RECONNECT_CUSTOMER_HANDLE = Clock.instance():schedule(function()
			Log.v("--------netWorkControl.ReconnectCustomer------",tostring(str))
			if isVip then
            	netWorkControl.sendProtocol("login")
			else

				netWorkControl.sendProtocol("sendChatMsg",str, GKefuOnlyOneConstant.MsgType.ROBOT)
			end
        end, GKefuOnlyOneConstant.DELAY_POLL_LOGIN/6)
	end
end


--取消人工客服
function netWorkControl.CancelReconnectCustomer()
	Log.v("--------netWorkControl.ReconnectCustomer------","cancel")
	if RECONNECT_CUSTOMER_HANDLE then
		RECONNECT_CUSTOMER_HANDLE:cancel()
		RECONNECT_CUSTOMER_HANDLE = nil
	end
end
return netWorkControl