-- require("gameBase/httpManager");
require("libs/json_wrap");
require("app/animation/toastShade");

-- 上传包，在电脑本地输入：
-- \\192.168.100.133\wwwroot\w7poker_swf\apkft
-- 获取二维码，在浏览器输入：
-- http://pirates133.by.com/w7poker_swf/apkft/

if LOCAL_NET then
	HOST_URL = 'http://192.168.203.228/casinohall/game/hall/index.php'
	-- HOST_URL = 'http://gamehall.oa.com/game/hall/index.php'
else
	HOST_URL = 'http://thaicasino.boyaagame.com/game/hall/index.php'
end

Joins = function(data,isSig)
	local str = "";
	local key = {};
	local sig = 0;

	if data == nil then
		return str;
	end

	for i,v in pairs(data) do
		table.insert(key,i);
	end
	table.sort(key);
	for k=1,table.maxn(key) do
		sig = isSig;
		local b = key[k];
		if sig ~= 1 and string.sub(b,1,4) == "sig_" then
			sig = 1;
		end
		local obj = data[b];
		local oType = type(obj);
		local s = "";
		if sig == 1 and oType ~= "table" then
			str = string.format("%s&%s=%s",str.."",b,obj);
		end
		if oType == "table" then
			local ret = Joins(obj, 0);
			if ret ~= "" then
				str = str..ret;
			end
			-- str = string.format("%s%s=%s",str.."",b,Joins(obj,sig));
		end
	end

	return str;
end

HttpModule = class();
HttpModule.CommonUrl = nil;
HttpModule.s_event = EventDispatcher.getInstance():getUserEvent();

HttpModule.getInstance = function()
	if not HttpModule.s_instance then
		HttpModule.s_instance = new(HttpModule);
	end
	return HttpModule.s_instance;
end

HttpModule.releaseInstance = function()
	delete(HttpModule.s_instance);
	HttpModule.s_instance = nil;
end

HttpModule.ctor = function(self)
	self.m_httpManager = new(HttpManager,HttpModule.s_config,HttpModule.postDataOrganizer,HttpModule.urlOrganizer);
	EventDispatcher.getInstance():register(HttpManager.s_event,self,self.onHttpResponse);
	self:initUrlConfig()
end

HttpModule.dtor = function(self)
	EventDispatcher.getInstance():unregister(HttpManager.s_event,self,self.onHttpResponse);
	delete(self.m_httpManager);
	self.m_httpManager = nil;
end

HttpModule.postDataOrganizerNoEncode = function(method, data)
	local post_data = {};
	HttpModule.postDataInit(post_data, data);
	if method and method ~= "" and not string.find( method, "#") then
		post_data.method = method;
	end

	if data then
		if method == 'Feedback.mGetFeedback' or method == 'Feedback.sendFeedback' then
			post_data.param = data;
		else
			post_data.game_param = data;
		end
	end
	local signature = HttpModule.joins(post_data.mtkey,post_data);
	post_data.sig = string.upper(md5_string(signature));
	method = method or "";
	-- 不进行编码
	print_string(method .. "|api = " .. json.encode(post_data));
	return "api=".. json.encode(post_data);
end
--[[
  post data
]]
HttpModule.postDataOrganizer = function(method, data)
	local post_data = {};
	--初始化基础参数
	HttpModule.postDataInit(post_data, data);
	--参数为方法名
	if method and method ~= "" and not string.find( method, "#") then
		post_data.method = method;
	end

	if data then
		if method == 'Feedback.mGetFeedback' or method == 'Feedback.sendFeedback' then
			post_data.param = data;
		else
			post_data.game_param = data;
		end
	end
	-- dump(post_data,"  http请求-- ")
	JLog.d("http请求-- ", post_data)
	writeTabToLog({post_data=post_data}, "http请求","debug_http.lua")
	--md5
	printInfo("sig = "..HttpModule.joins(post_data, 0))
	local md5Str = HttpModule.joins(post_data, 0);
	printInfo("md5str = "..md5Str);
	post_data.sig   = md5_string(md5Str);
	--json
	local dataStr = HttpModule.dataEncode_lua(json.encode(post_data));
	--print
	print_string((method or "") .. "|api = " .. dataStr);
	return "api=".. dataStr..(LOCAL_NET and '&demo=1' or "");
end

HttpModule.dataEncode_lua = function(str)

	if str == nil then
		return "";
	end

	local platformStr = sys_get_string("platform");
	if platformStr == kPlatformWin32 then
		str = string.gsub (str, "\n", "\r\n");
		str = string.gsub (str, "([^%w ])",
											 function (c) return string.format ("%%%02X", string.byte(c)) end);
		str = string.gsub (str, " ", "+");
		return str;
	end

	-- return NativeEvent.getInstance():encodeStr(str);
	return string.urlencode(str);
end

HttpModule.postDataInit = function(post_data, param_data)

	post_data.sesskey   = MyUserData:getSessionId();    --会话ID，登录前此值为空
	post_data.sid     = param_data.sid or tonumber(PhpManager:getGame());	--平台ID
	post_data.lid     = MyUserData:getUserType();   --登录帐号类型ID(1:FB, 2:游客)
	post_data.version   = PhpManager:getVersionName() --版本号
	local channel = require("app.adChannel")		--如果有广告渠道文件，参数里额外加个
	if channel ~= "" then
		post_data.channel = channel.."_"..(PhpManager:getGame())
	end
	-- post_data.demo     = 1;    --是否为测试环境，正式环境不用传此参数
end

HttpModule.joins = function(data, isSig)
	return '['..Joins(data, isSig)..']';
end

HttpModule.urlOrganizer = function(url,method,httpType)
	if httpType == kHttpGet then
		return url;
	end

	if  string.find(method, "#") then
		local indexs =  string.find( method, "#");
		local m = "";
		local p = "";
		if indexs then
			m = string.sub(method , 1 , indexs-1);
			p = string.sub(method , indexs + 1 );
		end
		if m ~="" and p ~= "" then
			url = url .. "?m=".. m .. "&p=" .. p;
		elseif m ~= "" and p == "" then
			url = url .. "?m=" .. m;
		elseif m == "" and p ~= "" then
			url = url .. "?m=" .. p;
		end
		-- else
		--    url=url.."?m="..method;
	elseif not string.find(url, "http") then
		local gameList = HallConfig:getGameList();
		local gateway = gameList and gameList[url] or {};
		if gateway['gateway'] then
			url = gateway['gateway'];
		end
	end
	--JLog.d("urlOrganizer", url, method,httpType)
	return url;
end

HttpModule.execute = function(self, command, data, isShowLoading, continueLast)
	printInfo("command=%s,",command or "")
	return self.m_httpManager:execute(command, data, continueLast);
end

-- 根据指定的域名来
HttpModule.executeDirect = function(self, command, domain, data, isShowLoading)
	return self.m_httpManager:executeDirect(command, domain, data);
end

HttpModule.onHttpResponse = function(self,command,errorCode,data, resultStr)

	local errMsg = nil;
	if errorCode == HttpErrorType.NETWORKERROR then
		printInfo(command .. "netWorkError")
		errMsg = GameString.get("netWorkError") or "";
	elseif  errorCode == HttpErrorType.TIMEOUT then
		printInfo(command .. "netWorkTimeout")
		errMsg = GameString.get("netWorkTimeout") or "";
	elseif  errorCode == HttpErrorType.JSONERROR then
		printInfo(command .. "netWorkJsonError")
		errMsg = GameString.get("netWorkJsonError") or "";
	end
	-- JLog.d("HttpModule.onHttpResponse", command, errorCode, data, resultStr)
	dump(data,"httpModule返回")
	writeTabToLog({data=data,errorCode=errorCode,method=HttpModule.s_config[command] and HttpModule.s_config[command][2]}, "httpModule返回","debug_http.lua")
	EventDispatcher.getInstance():dispatch(HttpModule.s_event,command,errMsg == nil, errMsg or data, resultStr);
end

local cIndex = 1
local function getIndex()
	cIndex = cIndex + 1
	return cIndex
end

HttpModule.resetServer2Url = function (self) 
	local gameList = HallConfig:getGameList();
	local gateway = gameList and gameList[PhpManager:getGame()] or {};
	if not gateway['gateway1'] and not gateway["gateway"] then
		return
	end
	local url = gateway['gateway1']

	for key,config in pairs(self.s_config) do
		if config[HttpConfigContants.URL] == PhpManager:getGame() then
			local has = false
			for key2, value2 in pairs(self.s_server2_Info) do
				if not has and key == value2 then
					has = true
				end
			end
			if not has then 
				config[HttpConfigContants.URL] = url
			end
		end
	end
end

HttpModule.s_cmds = {
	GetFeedbackList = getIndex(),
	SendFeedback    = getIndex(),
	SolveFeedback   = getIndex(),
	VoteFeedback    = getIndex(),

	LOGIN_PHP        = getIndex(),
	GET_DICE_LOGIN       = getIndex(),
	GET_FB_INVITE_AWARD  = getIndex(),
	GET_FB_INVITE_SUC_AWARD = getIndex(),
	GET_BROKEN_MONEY      = getIndex(),
	GET_PAY_MODE        = getIndex(),
	GET_PAY_LIST        = getIndex(),
	GET_PAY_ORDER       = getIndex(),
	GET_PAY_NOTIFY        = getIndex(),

	GET_REGISTER_REWARD   = getIndex(),

	GET_SEND_PROP           = getIndex(),
	GET_MY_PROP_LIST           = getIndex(),
	GET_CASH_LIST           = getIndex(),
	GET_BUY_RECORD          = getIndex(),

	GET_HALL_BANKRUPT       = getIndex(),
	GET_HALL_BANKRUPT_TAG   = getIndex(),
	GET_SEND_GAME_CHIP      = getIndex(),	--送筹码
	FRONTSTATISTICS     = getIndex(),   --数据统计
	GET_HALL_SYS_MESSAGE   = getIndex(),	--公告消息
	GET_HALL_GAME_MESSAGE      = getIndex(),	--游戏消息
	-- GET_HALL_ANNOUCEMENT   = getIndex(),	--公告消息
	GET_HALL_USER_NEWS_DEL  = getIndex(),	--删除公告消息
	GET_HALL_USER_NOTICES_DEL = getIndex(),	--删除公告消息
	GET_HALL_USER_NOTICES_AWARD = getIndex(),	--公告消息
	GET_HALL_USER_NOTICES_READED = getIndex(),  --公告已读过
	GET_GAMEMSG_READED = getIndex(),
	GET_GAMEMSG_REW = getIndex(),

	GET_URGENT_NOTICE = getIndex(),  -- 紧急公告消息
	-- GET_MARQUEE_NOTICES             = getIndex(),  --获取小喇叭公告
	SET_HALL_ATTENDENCE       = getIndex(),   --确认今天签到
	GET_H3_LOGIN            = getIndex(),   --鱼虾蟹的登陆，获取在线
	GET_UPGRADE_REWARD				= getIndex(),	--等级礼包
	GET_DUIJIANG_REWARD				= getIndex(),   --兑换码
	GET_GAMEINFO					= getIndex(),	--个人资料
	UPDATE_USER_SEX					= getIndex(),	--修改性别
	UPDATE_USER_NAME				= getIndex(),   --修改昵称
	UPDATE_USER_ICON				= getIndex(),	--更新用户图像
	UPDATE_MEMBER_BEST				= getIndex(),   --更新用户赢取最大筹码
	INVITE_CONFIG					= getIndex(),	--邀请好友配置

	GET_FRIENDS           = getIndex(),   --获取好友列表
	GET_APPLY             = getIndex(),   --获取申请列表
	ADD_FRIEND              = getIndex(),   --添加好友
	SEARCH_FRIEND           = getIndex(),   --获取查询结果
	GET_GIFT              = getIndex(),   --获取礼物列表
	GIVING_TIPS						= getIndex(),	--给荷官送小费

	FRIEND_ACCEPT           = getIndex(),   --接受好友请求
	FRIEND_REFUSE           = getIndex(),   --拒绝好友请求
	GET_OTHER_FORM_FRIEND       = getIndex(),   --获取他人资料
	SEND_GIFT             = getIndex(),   --赠送礼物
	FETCH_GIFT              = getIndex(),   --接受礼物
	FRIEND_DELETE           = getIndex(),   --好友删除

	POST_CLIENTID					= getIndex(),   --上报个推ID
	FRIEND_UNREAD					= getIndex(),   --好友未读

	GET_TASK              = getIndex(),	--获取任务
	GET_TASK_AWARD            = getIndex(),	--获取任务奖励
	HAS_TASK_AWARD            = getIndex(),   --是否有任务奖励
	GET_ROOM_LIST           = getIndex(),   --获取房间列表（所有的游戏都是通过该命令去获取）
	GET_GAME_LOGIN            = getIndex(),   --登录某一款游戏（所有的游戏都是通过该命令去获取）

	GET_MAKHOS_ROOM_LIST        = getIndex(),   --马哈的房间列表
	GET_MAKHOS_LOGIN          = getIndex(),   --马哈的登陆，获取在线

	UPDATE_GAME_EVENT         = getIndex(),   --统计热更新

	GET_USER_MONEY                  = getIndex(),   --获取玩家的金币数量，用来必要时同步金钱
	GET_INVITE_TASK_PROGRESS        = getIndex(),   --邀请好友的任务列表
	GET_CASH_AWARDS                 = getIndex(),   --现金币能兑换的商品列表
	EXCHANGE_AWARD_BY_ID            = getIndex(),   --兑换某种商品
	GET_CASH_EXCHANGE_RECORD        = getIndex(),   --现金币兑换记录
	DEL_CASH_EXCHANGE_RECORD        = getIndex(),   --删除兑换记录
	GET_CASH_TASK_FRIEND                   = getIndex(),   --现金币任务
	GET_CASH_TASK_FRIEND_REWARD            = getIndex(),   --领取现金币任务积分
	GET_CASH_TOTAL                  = getIndex(),   --查询自己的现金币积分
	GET_CASH_ON_CLICK_STATISTICS    = getIndex(),   --统计自己的现金币点击次数
	GET_ACTIVITY_REWARD_CONFIG      = getIndex(),   --获取奖励配置
	GET_ACTIVITY_GAME_RECORD        = getIndex(),   --获取活动比赛记录
	GET_ACTIVITY_REWARD_RECORD      = getIndex(),   --获取活动领奖记录
	GET_IS_ACTIVITY_TIME            = getIndex(),   --查询是否处于马哈活动时间
	GET_MAKHOS_ACTIVITY_GAME_RESULT = getIndex(),   --马哈活动结束,查询奖励
	RESET_MAKHOS_WIN_STREAK         = getIndex(),   --离开房间终止连胜
	POST_GCM_BACK_USER_ID           = getIndex(),  --反馈长时间不登陆后谷歌推送的点击统计
	GET_BUDDY_ROOM_LIST             = getIndex(),  --获取好友房列表
	GET_BUDDY_ONLINE_LIST           = getIndex(),  --获取在线好友列表
	SEND_BUDDY_ROOM_INVITE          = getIndex(),  --邀请好友加入好友房
	SEND_ACTIVITY_SHARE_STATISTIC   = getIndex(),  --活动中心分享成功统计
	CHECK_SWITCH_FOR_ALL            = getIndex(),  --所有开关列表，后续需要开关控制的功能都放在这个接口里
	GET_PAY_PROP_LIST               = getIndex(),  -- 获取商城道具列表
	MAKHOS_BUYREGRET                = getIndex(),  -- 单机马哈购买悔棋道具
	GIFT_STORE_SEND                 = getIndex(),  --赠送好友礼物
	GIFT_STORE_BUY                  = getIndex(),  --购买礼物
	GIFT_UPDATE_MINE                = getIndex(),  --更换自己的礼物
	GIFT_GET_ALL_MINE               = getIndex(),  --查询自己的礼物
	GIFT_STORE_GET_LIST             = getIndex(),  --获取礼物列表
	DUMMY_GET_TIPS_COUNT			= getIndex(),  --大米获取提示剩余次数
	GET_USER_ALL_PROPS				= getIndex(),  --获取用户所有的道具数量
	GET_FB_CALLBACK_REWARD_CFG      = getIndex(),  --获取召回奖励配置
	GET_FB_CALLBACK_LIST            = getIndex(),  --获取可召回玩家列表
	GET_FB_CALLBACK_REWARD          = getIndex(),  --获取FB好友召回奖励
	GET_BANKRUPT_RELIEF             = getIndex(),  --破产时请求好友救济
	SEND_REGISTER_GAME_STA          = getIndex(),  --玩家首次进入游戏发送统计请求
	GET_NOTIFICATION_REWARD         = getIndex(),  --点击推送进入游戏领奖
	GET_PROP_CFG_LIST               = getIndex(),  --获取道具配置列表，便于新增拓展道具
	REPORT_DEBUG_INFO               = getIndex(),  --上传调试信息给PHP

	GET_DEALER_ROOM_LIST        = getIndex(),	--获取上庄场房间列表
	GIFT_GET_BADGE					= getIndex(),	-- 获取用户徽章
	GIFT_WEAR_BADGE					= getIndex(),	-- 用户佩戴徽章
	GET_PRIVATE_ROOM_BILL_LIST      = getIndex(),  --私人房获取房间列表和账单列表
	GET_PRIVATE_ROOM_UNREAD_BILL    = getIndex(),  --获取私人房是否有未读账单

	GET_HALL_ACTIVITY_LIST          = getIndex(),  --大厅活动列表
	GET_HALL_ACTIVITY_REWARD        = getIndex(),  --大厅活动奖励
	HALL_ACTIVITY_JOIN              = getIndex(),  --大厅活动更新用户点击参加活动
	HALL_ACTIVITY_FINISH            = getIndex(),  --大厅活动更新用户完成活动
	GET_ACT_SHARE_URL               = getIndex(),  --大厅活动更新用户完成活动
	GET_ACT_PLAY_DUMMY_REWARD       = getIndex(),  --大米玩牌活动领取游戏币奖励
	SEND_SPEAKER                    = getIndex(),  --发送小喇叭消息
	SEND_SPEAKER_BY_SYSTEM          = getIndex(),  --系统事件触发小喇叭，没有验证真伪，只做了防刷处理
	GET_ACT_PAY_BOX_REWARD            = getIndex(),  --充值满额赠宝箱奖励
	ACT_LOTTERY_PLAY                = getIndex(),  --大厅玩牌活动

	ACT_GET_NEW_PLAYER_TASK_LIST    = getIndex(), --新手任务列表
	ACT_GET_NEW_PLAYER_TASK_REWARD  = getIndex(), --新手任务领奖
	ACT_NEW_PLATER_TASK_DONE        = getIndex(), --新手任务完成通知

	ACT_GET_BACK_FLOW_TASK_LIST     = getIndex(), --回流任务列表
	ACT_GET_BACK_FLOW_TASK_REWARD   = getIndex(), --领取回流奖励

	FRIEND_SEND_RECALL              = getIndex(), --通知php发送推送去召回好友
	CHECK_IF_PAY                    = getIndex(), --查询用户是否付费
	GET_PAYMENT_COURSE              = getIndex(),--获取支付帮助图片
  GET_EXIT_GAME_TIPS              = getIndex(), --获取退出游戏时的提示
	GET_HALL_USER_NEWS_REWARD       = getIndex(), --领取消息奖励
	DEL_HALL_USER_NEWS_REWARD       = getIndex(), --删除领奖消息

	--===========================================以下是新增的===============================
	create_room_config              = getIndex(), --可用建房参数列表，登陆后自动推送
	SIGN_IN_LOAD                    = getIndex(), --获取签到初始号数据
	SIGN_IN                    = getIndex(), --签到
	Turntable_GET_TABLE_CFG         = getIndex(), --获取登陆转盘配置信息
	Turntable_LOTTERY               = getIndex(), --登陆转盘抽奖接口
	PERINFO_UPDATE_USERIINFO        = getIndex(), -- 修改昵称和性别
    PROPS_GET_USERPROPS_LIST        = getIndex(), -- 获取用户道具
    GIFT_SYSTEM_GET_USERGIFT_LIST   = getIndex(), -- 获取用户礼物.
    GET_FRIENDS_LIST				= getIndex(), -- 获取好友列表
    APPLY_ADD_FRIENDS_LIST 			= getIndex(), -- 获取申请添加我为好友的列表
    SEARCH_FRIEND 					= getIndex(), -- 根据好友ID搜索好友信息（不是好友也可以搜索） 
    ADD_FRIEND 						= getIndex(), -- 添加好友
	FRIEND_ACCEPT           = getIndex(),   --接受好友请求
	FRIEND_REFUSE           = getIndex(),   --拒绝好友请求
	DailyTask_Init = getIndex(),
	DailyTask_getRew = getIndex(),
	VERSION_UPDATE_MSG=getIndex(), --获取版本更新消息
	Friend_INIT_OLD_FRIEND_TO_PLAY_CFG = getIndex(),-- 获取召回配置
	Payment_getDiamondPayList = getIndex(), -- 获取现金币购买列表
	Payment_getUserPayList = getIndex(), -- 获取玩家支付记录
	FRIEND_DELETE=getIndex(),	--删除好友
}


HttpModule.s_server2_Info = {
	HttpModule.s_cmds.SET_HALL_ATTENDENCE, 
	HttpModule.s_cmds.SIGN_IN_LOAD, 
	HttpModule.s_cmds.SIGN_IN, 
	HttpModule.s_cmds.GET_ROOM_LIST,
	HttpModule.s_cmds.Turntable_GET_TABLE_CFG,
	HttpModule.s_cmds.Turntable_LOTTERY,
	HttpModule.s_cmds.GET_OTHER_FORM_FRIEND,
	HttpModule.s_cmds.GET_HALL_BANKRUPT_TAG,
	HttpModule.s_cmds.GET_URGENT_NOTICE,

	HttpModule.s_cmds.ADD_FRIEND,
	HttpModule.s_cmds.FRIEND_ACCEPT,
	HttpModule.s_cmds.FRIEND_REFUSE,
	HttpModule.s_cmds.GET_FRIENDS_LIST,
	HttpModule.s_cmds.APPLY_ADD_FRIENDS_LIST,
	HttpModule.s_cmds.SEARCH_FRIEND,
	HttpModule.s_cmds.ADD_FRIEND,
	HttpModule.s_cmds.FRIEND_ACCEPT,
	HttpModule.s_cmds.FRIEND_REFUSE,
	HttpModule.s_cmds.FRIEND_SEND_RECALL,
	HttpModule.s_cmds.GET_HALL_BANKRUPT,
	HttpModule.s_cmds.PERINFO_UPDATE_USERIINFO,
	HttpModule.s_cmds.GET_PAY_MODE,
	HttpModule.s_cmds.GET_PAY_LIST,
	HttpModule.s_cmds.GET_PAY_PROP_LIST,
	HttpModule.s_cmds.GET_CASH_LIST,
	HttpModule.s_cmds.INVITE_CONFIG,
	HttpModule.s_cmds.Friend_INIT_OLD_FRIEND_TO_PLAY_CFG,
	HttpModule.s_cmds.Payment_getDiamondPayList,
	HttpModule.s_cmds.Payment_getUserPayList,
	HttpModule.s_cmds.PROPS_GET_USERPROPS_LIST,
	HttpModule.s_cmds.GET_SEND_PROP,
	HttpModule.s_cmds.SEND_SPEAKER,
	HttpModule.s_cmds.GET_USER_ALL_PROPS,
	HttpModule.s_cmds.GET_FB_INVITE_AWARD,
	HttpModule.s_cmds.GET_HALL_GAME_MESSAGE,
	HttpModule.s_cmds.GET_HALL_SYS_MESSAGE,
	HttpModule.s_cmds.GET_HALL_USER_NOTICES_AWARD,
	HttpModule.s_cmds.GET_HALL_USER_NOTICES_READED,
	HttpModule.s_cmds.GET_GAMEMSG_READED,
	HttpModule.s_cmds.GET_GAMEMSG_REW,
	HttpModule.s_cmds.DailyTask_Init,
	HttpModule.s_cmds.DailyTask_getRew,
	HttpModule.s_cmds.VERSION_UPDATE_MSG,
	HttpModule.s_cmds.DailyTask_getRew,
	HttpModule.s_cmds.GET_PROP_CFG_LIST,
	HttpModule.s_cmds.GET_FB_INVITE_SUC_AWARD,
	HttpModule.s_cmds.GET_PAY_ORDER,
	HttpModule.s_cmds.GET_FB_CALLBACK_LIST,
	HttpModule.s_cmds.GET_FB_CALLBACK_REWARD,
	HttpModule.s_cmds.FRIEND_DELETE,
	HttpModule.s_cmds.UPDATE_USER_ICON,
	HttpModule.s_cmds.FRIEND_UNREAD,
	HttpModule.s_cmds.GET_REGISTER_REWARD,
	HttpModule.s_cmds.GET_UPGRADE_REWARD,
	HttpModule.s_cmds.GET_GAMEINFO,
	HttpModule.s_cmds.GET_PAY_NOTIFY,
	HttpModule.s_cmds.REPORT_DEBUG_INFO,
}

HttpModule.s_config = {}

HttpModule.initUrlConfig = function(self)
	HttpModule.s_config = {
		[HttpModule.s_cmds.GetFeedbackList] = {
			"http://feedback.kx88.net/api/api.php",
			"Feedback.mGetFeedback"
		},

		[HttpModule.s_cmds.SendFeedback] = {
			"http://feedback.kx88.net/api/api.php",
			"Feedback.sendFeedback"
		},

		[HttpModule.s_cmds.SolveFeedback] = {
			"http://feedback.kx88.net/api/api.php",
			"Feedback.mCloseTicket"
		},

		[HttpModule.s_cmds.VoteFeedback] = {
			"http://feedback.kx88.net/api/api.php",
			"Feedback.mPostScore"
		},

		[HttpModule.s_cmds.LOGIN_PHP] = {
			HOST_URL,
			""
		},

		[HttpModule.s_cmds.GET_DICE_LOGIN] = {
			'1002',
			"GameServer.load"
		},

		[HttpModule.s_cmds.GET_FB_INVITE_AWARD] = {
			PhpManager:getGame(),
			"Friends.setInviteFriends"
		},

		[HttpModule.s_cmds.GET_FB_INVITE_SUC_AWARD] = {
			PhpManager:getGame(),
			"Friends.inviteFbFriend"
		},

		[HttpModule.s_cmds.GET_BROKEN_MONEY] = {
			PhpManager:getGame(),
			'Task.getReward'
		},

		[HttpModule.s_cmds.GET_PAY_MODE] = {
			PhpManager:getGame(),
			"Payment.getPmode"
		},

		[HttpModule.s_cmds.GET_PAY_LIST] = {
			PhpManager:getGame(),
			"Payment.getAllPayList"
		},

		[HttpModule.s_cmds.GET_PAY_ORDER] = {
			PhpManager:getGame(),
			"Payment.callPayOrderV3"
		},

		[HttpModule.s_cmds.GET_PAY_NOTIFY] = {
			PhpManager:getGame(),
			"Payment.callClientPaymentV3"
		},

		[HttpModule.s_cmds.GET_REGISTER_REWARD] = {
			PhpManager:getGame(),
			"Award.upRegisterAward"
		},

		[HttpModule.s_cmds.GET_SEND_PROP] = {
			PhpManager:getGame(),
			"Props.interactiveProps"
		},

		[HttpModule.s_cmds.GET_MY_PROP_LIST] = {
			PhpManager:getGame(),
			"Props.getUserPropsList"
		},

		[HttpModule.s_cmds.GET_CASH_LIST] = {
			PhpManager:getGame(),
			"Props.getUserPropsList"
		},

		[HttpModule.s_cmds.GET_BUY_RECORD] = {
			PhpManager:getGame(),
			"Props.getUserPropsList"
		},

		[HttpModule.s_cmds.GET_HALL_BANKRUPT] = {
			PhpManager:getGame(),
			"Bankruptcy.bankruptcyGrant"
		},

		[HttpModule.s_cmds.GET_HALL_BANKRUPT_TAG] = {
			PhpManager:getGame(),
			"Bankruptcy.bankruptcyPopItem"
		},

		[HttpModule.s_cmds.GET_URGENT_NOTICE] = {
			PhpManager:getGame(),
			"Notice.getShowUserNotice"
		},

		[HttpModule.s_cmds.GET_SEND_GAME_CHIP] = {
			PhpManager:getGame(),
			"Room.sendInRoomMoney"
		},

		[HttpModule.s_cmds.FRONTSTATISTICS] = {
			PhpManager:getGame(),
			'GameServer.frontStatistics'
		},

		[HttpModule.s_cmds.GET_UPGRADE_REWARD] = {
			PhpManager:getGame(),
			'Level.upGrade'
		},

		[HttpModule.s_cmds.GET_DUIJIANG_REWARD] = {
			PhpManager:getGame(),
			'Invite.checkConversionCode'
		},

		[HttpModule.s_cmds.GET_HALL_GAME_MESSAGE] = {
			PhpManager:getGame(),
			'Message.getUserMessage'
		},

		[HttpModule.s_cmds.GET_HALL_USER_NEWS_DEL] = {
			PhpManager:getGame(),
			'Message.deleteUserMessage'
		},

		[HttpModule.s_cmds.GET_HALL_SYS_MESSAGE] = {
			PhpManager:getGame(),
			'Notice.getShowUserNotice'
		},

		-- [HttpModule.s_cmds.GET_HALL_ANNOUCEMENT] = {
		-- 	PhpManager:getGame(),
		-- 	'Notice.getShowUserNotice'
		-- },

		[HttpModule.s_cmds.GET_HALL_USER_NOTICES_DEL] = {
			PhpManager:getGame(),
			'Notice.deleteNotice'
		},

		[HttpModule.s_cmds.GET_HALL_USER_NOTICES_AWARD] = {
			PhpManager:getGame(),
			'Notice.receiveUserNotice'
		},

		[HttpModule.s_cmds.GET_HALL_USER_NOTICES_READED] = {
			PhpManager:getGame(),
			'Notice.updateUserNotice'
		},

		[HttpModule.s_cmds.GET_GAMEMSG_READED] = {
			PhpManager:getGame(),
			"Message.readedUserMessage"
		},

		[HttpModule.s_cmds.GET_GAMEMSG_REW] = {
			PhpManager:getGame(),
			"Message.getMsgReward"
		},

		[HttpModule.s_cmds.DailyTask_Init] = {
			PhpManager:getGame(),
			"Task.getAllTask"
		},

		[HttpModule.s_cmds.DailyTask_getRew] = {
			PhpManager:getGame(),
			"Task.getReward"
		},

		[HttpModule.s_cmds.SET_HALL_ATTENDENCE] = {
			PhpManager:getGame(),
			"Sign.singnIn",
		},

		-- [HttpModule.s_cmds.GET_MARQUEE_NOTICES] = {
		-- 	PhpManager:getGame(),
		-- 	'Notice.getShowUserNotice'
		-- },

		[HttpModule.s_cmds.GET_H3_LOGIN] = {
			'1003',
			"GameServer.load"
		},

		[HttpModule.s_cmds.GET_GAMEINFO] = {
			PhpManager:getGame(),
			'PerInfo.myGameInfo'
		},

		[HttpModule.s_cmds.UPDATE_USER_SEX] = {
			PhpManager:getGame(),
			'PerInfo.updateUserSex'
		},

		[HttpModule.s_cmds.UPDATE_USER_NAME] = {
			PhpManager:getGame(),
			'PerInfo.updateUserName'
		},

		[HttpModule.s_cmds.UPDATE_USER_ICON] = {
			PhpManager:getGame(),
			'PerInfo.updateUserIcon'
		},

		[HttpModule.s_cmds.UPDATE_MEMBER_BEST] = {
			PhpManager:getGame(),
			'Best.updateMemberBest'
		},

		[HttpModule.s_cmds.INVITE_CONFIG] = {
			PhpManager:getGame(),
			'Invite.getConfigInviteFriends'
		},

		[HttpModule.s_cmds.GET_FRIENDS] = {
			PhpManager:getGame(),
			'Friends.getFriendsList'
			--            'Friends.getFriendsListByPage'
		},

		[HttpModule.s_cmds.GET_APPLY] = {
			PhpManager:getGame(),
			'Friends.applyAddFriendsList'
		},

		-- 添加好友
		[HttpModule.s_cmds.ADD_FRIEND] = {
			PhpManager:getGame(),
			'Friends.addFriends'
		},

		[HttpModule.s_cmds.SEARCH_FRIEND] = {
			PhpManager:getGame(),
			'Friends.searchFriends'
		},

		[HttpModule.s_cmds.GET_GIFT] = {
			PhpManager:getGame(),
			'Friends.getGiftList'
		},

		[HttpModule.s_cmds.GIVING_TIPS] = {
			PhpManager:getGame(),
			'Room.givingTips'
		},

		[HttpModule.s_cmds.FRIEND_ACCEPT] = {
			PhpManager:getGame(),
			'Friends.isAgreeAdd'
		},

		[HttpModule.s_cmds.FRIEND_REFUSE] = {
			PhpManager:getGame(),
			'Friends.isAgreeAdd'
		},

		[HttpModule.s_cmds.GET_OTHER_FORM_FRIEND] = {
			PhpManager:getGame(),
			'Friends.friendInfo'
		},

		[HttpModule.s_cmds.SEND_GIFT] = {
			PhpManager:getGame(),
			'Friends.giveChouma'
		},

		[HttpModule.s_cmds.FETCH_GIFT] = {
			PhpManager:getGame(),
			'Friends.receiveChouma'
		},

		[HttpModule.s_cmds.FRIEND_DELETE] = {
			PhpManager:getGame(),
			'Friends.deleteFriends'
		},

		[HttpModule.s_cmds.POST_CLIENTID] = {
			PhpManager:getGame(),
			'Gcm.updateToken'
		},

		[HttpModule.s_cmds.FRIEND_UNREAD] = {
			PhpManager:getGame(),
			'Friends.getApplyGiftNum'
		},

		[HttpModule.s_cmds.GET_TASK] = {
			PhpManager:getGame(),
			'Task.getAllTask'
		},

		[HttpModule.s_cmds.GET_TASK_AWARD] = {
			PhpManager:getGame(),
			'Task.getReward'
		},

		[HttpModule.s_cmds.HAS_TASK_AWARD] = {
			PhpManager:getGame(),
			'Task.unclaimedReward'
		},

		[HttpModule.s_cmds.GET_ROOM_LIST] = {
			'',
			'Room.getConfigRoom'
		},

		[HttpModule.s_cmds.GET_GAME_LOGIN] = {
			'',
			'GameServer.load'
		},

		[HttpModule.s_cmds.GET_MAKHOS_ROOM_LIST] = {
			'1004',
			"Room.getNewConfigRoom"
		},

		[HttpModule.s_cmds.GET_MAKHOS_LOGIN] = {
			'1004',
			"GameServer.load"
		},

		[HttpModule.s_cmds.UPDATE_GAME_EVENT] = {
			PhpManager:getGame(),
			'GameServer.updateGameEvent'
		},

		[HttpModule.s_cmds.GET_USER_MONEY] = {
			PhpManager:getGame(),
			'PerInfo.getMoneyAfterPay',
		},

		[HttpModule.s_cmds.GET_INVITE_TASK_PROGRESS] = {
			PhpManager:getGame(),
			'Friends.diamondRewardStep',
		},

		[HttpModule.s_cmds.GET_CASH_AWARDS] = {
			PhpManager:getGame(),
			'Diamond.getAllExRule'
		},

		[HttpModule.s_cmds.EXCHANGE_AWARD_BY_ID] = {
			PhpManager:getGame(),
			'Diamond.exchange',
		},

		[HttpModule.s_cmds.GET_CASH_EXCHANGE_RECORD] = {
			PhpManager:getGame(),
			'Diamond.exHistory',
		},

		[HttpModule.s_cmds.DEL_CASH_EXCHANGE_RECORD] = {
			PhpManager:getGame(),
			'Diamond.exHistory',
		},

		[HttpModule.s_cmds.GET_CASH_TASK_FRIEND] = {
			PhpManager:getGame(),
			'Diamond.getSchedule',
		},

		[HttpModule.s_cmds.GET_CASH_TASK_FRIEND_REWARD] = {
			PhpManager:getGame(),
      		'Diamond.getReward',
		},

		[HttpModule.s_cmds.GET_CASH_TOTAL] = {
			PhpManager:getGame(),
			'Diamond.getDiamond',
		},

		[HttpModule.s_cmds.GET_CASH_ON_CLICK_STATISTICS] = {
			PhpManager:getGame(),
			'Diamond.iconClickStatistics',
		},

		[HttpModule.s_cmds.GET_ACTIVITY_REWARD_CONFIG] = {
			PhpManager:getGame(),
			'MahaWinActivity.getRewardConfig',
		},

		[HttpModule.s_cmds.GET_ACTIVITY_GAME_RECORD] = {
			PhpManager:getGame(),
			'MahaWinActivity.getRecently25PokerLog',
		},

		[HttpModule.s_cmds.GET_ACTIVITY_REWARD_RECORD] = {
			PhpManager:getGame(),
			'MahaWinActivity.getRecently25RewardLog',
		},

		[HttpModule.s_cmds.GET_IS_ACTIVITY_TIME] = {
			PhpManager:getGame(),
			'MahaWinActivity.getActivitySwitch',
		},

		[HttpModule.s_cmds.GET_MAKHOS_ACTIVITY_GAME_RESULT] = {
			PhpManager:getGame(),
			'MahaWinActivity.getWinReward',
		},

		[HttpModule.s_cmds.RESET_MAKHOS_WIN_STREAK] = {
			PhpManager:getGame(),
			'MahaWinActivity.clearUserContinueWinLog',
		},

		[HttpModule.s_cmds.POST_GCM_BACK_USER_ID] = {
			PhpManager:getGame(),
			'Gcm.backUserToD',
		},

		[HttpModule.s_cmds.GET_BUDDY_ROOM_LIST] = {
			PhpManager:getGame(),
			'Friends.friendRoomList',
		},

		[HttpModule.s_cmds.GET_BUDDY_ONLINE_LIST] = {
			PhpManager:getGame(),
			'Friends.getOnlineFriendList',
		},

		[HttpModule.s_cmds.SEND_BUDDY_ROOM_INVITE] = {
			PhpManager:getGame(),
			'Friends.sendPrivateRoomInvite',
		},

		[HttpModule.s_cmds.SEND_ACTIVITY_SHARE_STATISTIC] = {
			PhpManager:getGame(),
			"ActivityCenter.saveShareNum",
		},

		[HttpModule.s_cmds.CHECK_SWITCH_FOR_ALL] = {
			PhpManager:getGame(),
			"SwitchControl.getSwitch",
		},

		[HttpModule.s_cmds.GET_PAY_PROP_LIST] = {
			PhpManager:getGame(),
			'Payment.getPropsPayList',
		},

		[HttpModule.s_cmds.MAKHOS_BUYREGRET] = {
			PhpManager:getGame(),
			'MahaHuiQi.buyHuiQiNum',
		},

		[HttpModule.s_cmds.GIFT_STORE_GET_LIST] = {
			PhpManager:getGame(),
			--            'GiftSystem.getGiftConfList',
			'GiftSystem.newGetGiftConfList',
		},

		[HttpModule.s_cmds.GIFT_STORE_SEND] = {
			PhpManager:getGame(),
			'GiftSystem.sendGift',
		},

		[HttpModule.s_cmds.GIFT_STORE_BUY] = {
			PhpManager:getGame(),
			'GiftSystem.buyGift',
		},

		[HttpModule.s_cmds.GIFT_UPDATE_MINE] = {
			PhpManager:getGame(),
			'GiftSystem.wearGift',
		},

		[HttpModule.s_cmds.GIFT_GET_ALL_MINE] = {
			PhpManager:getGame(),
			'GiftSystem.getUserGiftList',
		},

		[HttpModule.s_cmds.GET_BANKRUPT_RELIEF] = {
			PhpManager:getGame(),
			'Bankruptcy.askForHelp',
		},

		[HttpModule.s_cmds.DUMMY_GET_TIPS_COUNT] = {
			PhpManager:getGame(),
			'Props.useProps',
		},

		[HttpModule.s_cmds.GET_USER_ALL_PROPS] = {
			PhpManager:getGame(),
			'Props.getUserPropsList',
		},

		[HttpModule.s_cmds.GET_FB_CALLBACK_REWARD_CFG] = {
			PhpManager:getGame(),
			"Friends.initOldFriendToPlayCfg"
		},

		[HttpModule.s_cmds.GET_FB_CALLBACK_LIST] = {
			PhpManager:getGame(),
			"Friends.callOldFriendToPlayList",
		},

		[HttpModule.s_cmds.GET_FB_CALLBACK_REWARD] = {
			PhpManager:getGame(),
			"Friends.rewardCallOldFriend",
		},

		[HttpModule.s_cmds.SEND_REGISTER_GAME_STA] = {
			PhpManager:getGame(),
			"ActivityCenter.countGameRegisterNum",
		},

		[HttpModule.s_cmds.GET_NOTIFICATION_REWARD] = {
			PhpManager:getGame(),
			"Gcm.rewardMoney",
		},

		[HttpModule.s_cmds.GET_PROP_CFG_LIST] = {
			PhpManager:getGame(),
			"Props.getConfigPropsList",
		},

		[HttpModule.s_cmds.REPORT_DEBUG_INFO] = {
			PhpManager:getGame(),
			"GameServer.findBug",
		},

		[HttpModule.s_cmds.GET_DEALER_ROOM_LIST] = {
      		"1009",
      		'Room.getDealerConfigRoom',
		},

		[HttpModule.s_cmds.GIFT_GET_BADGE] = {
			PhpManager:getGame(),
			'GiftSystem.getBadge',
		},

		[HttpModule.s_cmds.GIFT_WEAR_BADGE] = {
			PhpManager:getGame(),
			'GiftSystem.wearBadge',
		},

		[HttpModule.s_cmds.GET_PRIVATE_ROOM_BILL_LIST] = {
			PhpManager:getGame(),
			'Room.getFriendRoomBill',
		},

		[HttpModule.s_cmds.GET_PRIVATE_ROOM_UNREAD_BILL] = {
			PhpManager:getGame(),
			'Room.getFriendRoomBillFlag',
		},

		[HttpModule.s_cmds.GET_HALL_ACTIVITY_LIST] = {
			PhpManager:getGame(),
			'HallActivity.getActivityListV2',
		},

		[HttpModule.s_cmds.GET_HALL_ACTIVITY_REWARD] = {
			PhpManager:getGame(),
			'HallActivity.getActivityReward',
		},

		[HttpModule.s_cmds.HALL_ACTIVITY_JOIN] = {
			PhpManager:getGame(),
			'HallActivity.joinActivity',
		},

		[HttpModule.s_cmds.HALL_ACTIVITY_FINISH] = {
			PhpManager:getGame(),
			'HallActivity.finishActivity',
		},

		[HttpModule.s_cmds.GET_ACT_SHARE_URL] = {
			PhpManager:getGame(),
			'HallActivity.getActShareUrl',
		},

		[HttpModule.s_cmds.GET_ACT_PLAY_DUMMY_REWARD] = {
			PhpManager:getGame(),
			'HallActivity.getPlayDummyReward',
		},

		[HttpModule.s_cmds.SEND_SPEAKER] = {
			PhpManager:getGame(),
			"Props.useSpeakers",
		},

		[HttpModule.s_cmds.SEND_SPEAKER_BY_SYSTEM] = {
			PhpManager:getGame(),
			"Props.systemTriggerSpeakers",
		},

		[HttpModule.s_cmds.GET_ACT_PAY_BOX_REWARD] = {
			PhpManager:getGame(),
			'HallActivity.getPaySendBoxReward',
		},

		[HttpModule.s_cmds.ACT_LOTTERY_PLAY] = {
			PhpManager:getGame(),
			'HallActivity.lotteryByPlay',
		},

		[HttpModule.s_cmds.ACT_GET_NEW_PLAYER_TASK_LIST] = {
			PhpManager:getGame(),
			"Task.getAllRookieTask",
		},

		[HttpModule.s_cmds.ACT_GET_NEW_PLAYER_TASK_REWARD] = {
			PhpManager:getGame(),
			"Task.getRookieTaskReward",
		},

		[HttpModule.s_cmds.ACT_NEW_PLATER_TASK_DONE] = {
			PhpManager:getGame(),
			"Task.doRookieTask",
		},

		[HttpModule.s_cmds.ACT_GET_BACK_FLOW_TASK_LIST] = {
			PhpManager:getGame(),
			"Task.backFlowAlert",
		},

		[HttpModule.s_cmds.ACT_GET_BACK_FLOW_TASK_REWARD] = {
			PhpManager:getGame(),
			"Task.rewardBackFlow",
		},

		[HttpModule.s_cmds.FRIEND_SEND_RECALL] = {
			PhpManager:getGame(),
			"Friends.sendRecallPush",
		},

		[HttpModule.s_cmds.CHECK_IF_PAY] = {
			PhpManager:getGame(),
			"Payment.getUserPayInfo",
		},

		[HttpModule.s_cmds.GET_PAYMENT_COURSE] = {
			PhpManager:getGame(),
			"Payment.getPaymentCourse",
		},

    	[HttpModule.s_cmds.GET_EXIT_GAME_TIPS] = {
			PhpManager:getGame(),
			"GameServer.physicalBackData",
		},

		[HttpModule.s_cmds.GET_HALL_USER_NEWS_REWARD] = {
			PhpManager:getGame(),
			"Message.getMsgReward",
		},

		[HttpModule.s_cmds.DEL_HALL_USER_NEWS_REWARD] = {
			PhpManager:getGame(),
			"Message.delRewardMsg",
		},


		--===============================新增==========================
        [HttpModule.s_cmds.PROPS_GET_USERPROPS_LIST] = {
            PhpManager:getGame(),
            "Props.getUserPropsList",
        },

        [HttpModule.s_cmds.GIFT_SYSTEM_GET_USERGIFT_LIST] = {
            PhpManager:getGame(),
            "GiftSystem.getUserGiftList",
        },

		[HttpModule.s_cmds.create_room_config] = {
			PhpManager:getGame(),
			"Room.getConfigRoom",
		},

		[HttpModule.s_cmds.SIGN_IN_LOAD] = {
			PhpManager:getGame(),
			"Sign.signInLoad",
		},

		[HttpModule.s_cmds.SIGN_IN] = {
			PhpManager:getGame(),
			"Sign.singnIn",
		},

		[HttpModule.s_cmds.Turntable_GET_TABLE_CFG] = {
			PhpManager:getGame(),
			"Turntable.getTableCfg",
		},

		[HttpModule.s_cmds.Turntable_LOTTERY] = {
			PhpManager:getGame(),
			"Turntable.lottery",
		},

		[HttpModule.s_cmds.PERINFO_UPDATE_USERIINFO] = {
			PhpManager:getGame(),
			"PerInfo.updateUserInfo",
		},

		[HttpModule.s_cmds.GET_FRIENDS_LIST] = {
			PhpManager:getGame(),
			"Friends.getFriendsList",
		},

		[HttpModule.s_cmds.APPLY_ADD_FRIENDS_LIST] = {
			PhpManager:getGame(),
			"Friends.applyAddFriendsList",
		},

		[HttpModule.s_cmds.SEARCH_FRIEND] = {
			PhpManager:getGame(),
			"Friends.searchFriends",
		},

		[HttpModule.s_cmds.ADD_FRIEND] = {
			PhpManager:getGame(),
			"Friends.addFriends",
		},

		[HttpModule.s_cmds.FRIEND_ACCEPT] = {
			PhpManager:getGame(),
			"Friends.isAgreeAdd",
		},

		[HttpModule.s_cmds.FRIEND_REFUSE] = {
			PhpManager:getGame(),
			"Friends.isAgreeAdd",
		},

		[HttpModule.s_cmds.Friend_INIT_OLD_FRIEND_TO_PLAY_CFG] = {
			PhpManager:getGame(),
			"Friends.initOldFriendToPlayCfg",
		},

		[HttpModule.s_cmds.Payment_getDiamondPayList] = {
			PhpManager:getGame(),
			"Payment.getDiamondPayList",
		},

		[HttpModule.s_cmds.Payment_getUserPayList] = {
			PhpManager:getGame(),
			"Payment.getUserPayList",
		},
		[HttpModule.s_cmds.VERSION_UPDATE_MSG] = {
			PhpManager:getGame(),
			"VersionUpdate.popMsg",
		},
		
	}
	self.m_httpManager:setConfigMap(HttpModule.s_config);
end
