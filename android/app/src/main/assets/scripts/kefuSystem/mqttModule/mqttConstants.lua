local URL = {}

URL.CONNECT_TCP_PORT = "3333";
URL.CONNECT_HTTP_PORT = "1323";
URL.CONNECT_TCP_TEST_PORT = "3333"



----------------国内地址--------------------
--正式环境
URL.HTTP_URL_OFFICAL = "https://cs-cn.boyaagame.com/";
URL.CONNECT_TCP_HOST = "cs-cn.boyaagame.com";

URL.CurrentHost = URL.CONNECT_TCP_HOST
URL.CurrentPort = URL.CONNECT_TCP_PORT

--测试服
URL.HTTP_URL_TEST_PREFIX = "https://cs-test.boyaagame.com/";
URL.CONNECT_TCP_HOST_TEST = "cs-test.boyaagame.com";

--预发布
URL.HTTP_URL_PRE_RELEASE_PREFIX = "https://cs-pre.boyaagame.com/";
URL.CONNECT_TCP_HOST_PRE_Release = "cs-pre.boyaagame.com";


--临时环境
URL.HTTP_URL_TEMP_PREFIX = "https://cs-cn-temp.boyaagame.com/";
URL.CONNECT_TCP_HOST_TEMP = "cs-cn-temp.boyaagame.com";

------------------海外地址-------------
--海外正式服  只有正式和temp才有海外线
URL.HTTP_URL_ABROAD_PREFIX = "https://cs-usa.boyaagame.com/";
URL.CONNECT_TCP_HOST_ABROAD = "cs-usa.boyaagame.com";
--海外临时环境
URL.HTTP_URL_ABROAD_TEMP_PREFIX = "https://cs-test-usa.boyaagame.com/";
URL.CONNECT_TCP_HOST_TEMP_ABROAD = "cs-test-usa.boyaagame.com";

-------------------安全模式-----------------
URL.HTTPS_URL_PREFIX = "https://cs-cn.boyaagame.com/";
URL.HTTPS_URL_TEST_PREFIX = "https://cs-test.boyaagame.com/";
URL.HTTPS_URL_PRE_RELEASE_PREFIX = "https://cs-pre.boyaagame.com/";
URL.HTTPS_URL_TEMP_PREFIX = "https://cs-cn-temp.boyaagame.com/";
URL.HTTPS_URL_ABROAD_PREFIX = "https://cs-usa.boyaagame.com/";
URL.HTTPS_URL_ABROAD_TEMP_PREFIX = "https://cs-test-usa.boyaagame.com/";


URL.setURLPrefix = function (idx, isAboard)
	-- 1 为测试
	if idx == 1 then
		URL.HTTP_URL_PREFIX = URL.HTTP_URL_TEST_PREFIX
		URL.CurrentHost = URL.CONNECT_TCP_HOST_TEST
	elseif idx == 2 then
		if not isAboard then
			URL.HTTP_URL_PREFIX = URL.HTTP_URL_OFFICAL
		else
			URL.HTTP_URL_PREFIX = URL.HTTP_URL_ABROAD_PREFIX
		end

		URL.CurrentHost = URL.CONNECT_TCP_HOST

	elseif idx == 3 then
		URL.HTTP_URL_PREFIX = URL.HTTPS_URL_PRE_RELEASE_PREFIX
		URL.CurrentHost = URL.CONNECT_TCP_HOST_PRE_Release
		URL.CurrentPort = URL.CONNECT_TCP_TEST_PORT
	elseif idx == 4 then
		URL.CurrentHost = URL.CONNECT_TCP_HOST_TEMP
		if not isAboard then
			URL.HTTP_URL_PREFIX = URL.HTTP_URL_TEMP_PREFIX
		else
			URL.HTTP_URL_PREFIX = URL.CONNECT_TCP_HOST_TEMP_ABROAD
		end

	end

	URL.FILE_UPLOAD_URI = URL.HTTP_URL_PREFIX .. "upload";
	URL.FILE_UPLOAD_HOST = URL.HTTP_URL_PREFIX;

	-- 获取离线消息数目
	URL.HTTP_OBTAIN_OFFLINE_MESSAGES = URL.HTTP_URL_PREFIX .. "offmsgnum";
	-- 提交用户评分数据
	URL.HTTP_SUBMIT_RATING_URI = URL.HTTP_URL_PREFIX .. "rating";
	-- 提交用户投诉相关事情
	URL.HTTP_SUBMIT_APPEAL_URI = URL.HTTP_URL_PREFIX .. "appeal";
	-- 提交用户举报相关事情
	URL.HTTP_SUBMIT_REPORT_URI = URL.HTTP_URL_PREFIX .. "report";
	-- 提交用户留言相关事情
	URL.HTTP_SUBMIT_ADVISE_URI = URL.HTTP_URL_PREFIX .. "advise";
	-- 获取用户投诉解决历史记录
	URL.HTTP_SUBMIT_APPEAL_HISTORY_URI = URL.HTTP_URL_PREFIX .. "appeal/history";
	-- 获取用户举报相关解决历史记录
	URL.HTTP_SUBMIT_REPORT_HISTORY_URI = URL.HTTP_URL_PREFIX .. "report/history";
	-- 获取用户留言相关解决历史记录
	URL.HTTP_SUBMIT_ADVISE_HISTORY_URI = URL.HTTP_URL_PREFIX .. "advise/history";
	-- 获取网络历史消息记录
	URL.HTTP_NETWORK_HISTORY_MESSAGE_URI = URL.HTTP_URL_PREFIX .. "chat/history";
	-- 提交用户留言评分
	URL.HTTP_SUBMIT_COMMENT_RATING_URI = URL.HTTP_URL_PREFIX .. "advise/reply/feedback";
	-- 提交用户追加留言
	URL.HTTP_SUBMIT_ADDITION_COMMENT__URI = URL.HTTP_URL_PREFIX .. "advise/reply";
	-- 统计信息
	URL.HTTP_SUBMIT_STATISTICAL_MESSAGE_URI = URL.HTTP_URL_PREFIX .."uplog";
	-- 查询动态显示Module信息
	URL.HTTP_GET_DYNAMIC_INFO_URI = URL.HTTP_URL_PREFIX .."client/settings"

	-- 获取token
	URL.HTTP_GET_DYNAMIC_TOKEN = URL.HTTP_URL_PREFIX .."auth"
end

return URL





