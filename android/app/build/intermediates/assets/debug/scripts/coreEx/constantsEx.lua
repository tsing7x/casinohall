--SocketProtocal
kGameId             = 1;
kProtocalVersion 	= 1;
kProtocalSubversion	= 1;
kClientVersionCode 	= "1.1.2"; --没有使用，

--Socket type
kGameSocket	= "hall";

PROTOCOL_TYPE_BUFFER="BUFFER"
PROTOCOL_TYPE_BY9="BY9"
PROTOCOL_TYPE_BY14="BY14"
PROTOCOL_TYPE_QE="QE"
PROTOCOL_TYPE_TEXAS="TEXAS"
PROTOCOL_TYPE_VOICE="VOICE"
PROTOCOL_TYPE_BY7="BY7"

------------------------------------Third Part SDK---------------------------------
kCallLuaEvent="event_call"; -- 原生语言调用lua 入口方法
kLuaCallEvent = "LuaCallEvent"; -- 获得 指令值的key

Kwin32Call="gen_guid";

kFBLogin="FBLogin"; -- facebook 登录
kFBShare="FBShare"; -- facebook 分享
kFBLogout="FBLogout" -- facebook 退出
kGuestZhLogin="GuestZhLogin"; -- 简体游客 登录
kGuestZwLogin="GuestZwLogin"; -- 繁体游客 登录
kGuestLogout="GuestLogout" -- 游客 退出
kWeiXinLogin="WeiXinLogin"; -- 微信登录
kMobileLogin="MobileLogin";--移动基地登录
kSinaLogin="SinaLogin"; -- 新浪 登录
kSinaShare="SinaShare"; -- 新浪 分享
kSinaLogout="SinaLogout" -- 新浪 退出
kQQConnectLogin="QQConnectLogin"; -- QQ互联 登录
kQQConnectLogout="QQConnectLogout" -- QQ互联 退出
kRenRenLogin="RenRenLogin"; --人人 登录
kRenRenShare="RenRenShare"; -- 人人 分享
kRenRenLogout="RenRenLogout" -- 人人 退出
kKaiXinLogin="KaiXinLogin"; -- 开心 登录
kKaiXinLogout="KaiXinLogout" -- 开心 退出
kBaiduDKLogin="BaiduDKLogin"; --百度多酷登录
kUserLogout = "UserLogout";
kCallResult="CallResult"; --结果标示  0 -- 成功， 1--失败,2 -- ...
kResultPostfix="_result"; --返回结果后缀  与call_native(key) 中key 连接(key.._result)组成返回结果key
kparmPostfix="_parm"; --参数后缀 
ksubString = "subString";	--字符串截取
kencodeStr = "encodeStr";
kGetGeTuiId = "GetGeTuiId";
-----------------------------------------------------------------------------------

------------------------------------Language---------------------------------------
kZhCNLang="zh_CN";
kZhLang="zh";
kZhTW="zh_TW";
kZhHKLang="zh_HK";
kEnLang="en";
kFRLang="fr_FR";
-----------------------------------------------------------------------------------

------------------------------------Android Keys-----------------------------------
kBackKey="BackKey";
kHomeKey="HomeKey";
kEventPause="EventPause";
kEventResume="EventResume";
kExit="Exit";
-----------------------------------------------------------------------------------

----------------------------------- 活动界面跳转常量 --------------------------------

kMessage= "message";    -- 消息界面
kGame 	= "game";       -- 快速开始游戏
kRoom 	= "room"    	-- 游戏房间
kInvite = "invite" 		-- 邀请
kTask 	= "task" 		-- 任务
kShare 	= "share" 		-- 分享
kShop   = "shop";       -- 商城


-------------------------------------Sound-----------------------------------------
ksetBgSound = "setBgSound"; -- 设置音效 
kbgSoundsync="bgSound__sync";--设置音效数据 key
ksetBgMusic = "setBgMusic"; -- 设置音乐
kbgMusicsync="bgMusic__sync";-- 设置音乐数据 key
-----------------------------------------------------------------------------------

-------------------------------take a photo or pick a photo------------------------
kTakePhoto = "takePhoto"
kPickPhoto = "pickPhoto"
KChooseFeedBackImg = "chooseFeedBackImg"
-----------------------------------------------------------------------------------

-------------------------------activity function-----------------------------------
kActivity = "openActivity"  -- IOS Obligate 

kActCenter = "setupActcenter"
kActcenterSwicthSvr = "actcenterSwitchSvr"
kActcenterSetSkin = "setActCenterSkin"
kActcenterDisplay = "actcenterDisplay"
kActcenterDisplayAct = "actcenterDisplayAct"
kActcenterDisplayRelate = "actcenterDisplayRelate"
kActcenterClearCache = "actcenterClearCache"

kActCenterCall      = "ActcenterCall"
-----------------------------------------------------------------------------------

-------------------------------upload image----------------------------------------
kUploadImage 		 = "uploadImage"
kUploadFeedbackImage = "uploadFeedbackImage"
-----------------------------------------------------------------------------------

-------------------------------open web----------------------------------------
kOpenWeb  	= "openWeb"
kCloseWeb 	= "closeWeb"
-----------------------------------------------------------------------------------
-------------------------------login----------------------------------------
kLogin 		= "login"
kLogout 		= "logout"
-------------------------------get friend by Facebook----------------------------------------
kGetFbFriend= "getFbFriend"
kInviteFbFriend = "inviteFbFriend";
kInviteSmsFriend= "inviteSmsFriend";
-----------------------------------------------------------------------------------
-------------------------------open web----------------------------------------
kOpenRule  	= "openRule"
kCloseRule 	= "closeRule"
kOpenLink 	= "openLink"
-----------------------------------------------------------------------------------

-------------------------------update----------------------------------------
kUpdateByLocal  	= "updatePackByLocal"
kUpdateByUmeng 		= "updatePackByUmeng"
kCheckPackByLocal  	= "checkPackByLocal"


-----------------------------------------------------------------------------------

-------------------------------download image----------------------------------------
kDownloadImage  = "downloadImage"
-----------------------------------------------------------------------------------
-------------------------------rename image----------------------------------------
kRenameImage 	= "renameImage"
-------------------------------download file----------------------------------------
kDownloadFile 	= "downloadFile"
kDownloadUpdate = "downloadUpdate"
-------------------------------unzip file----------------------------------------
kUnzip 			= "unzip"
-------------------------------unzip game----------------------------------------
kUnzipGame 		= "unzipGame"
-------------------------------pay----------------------------------------
kPay 			= "pay"
-------------------------------统计----------------------------------------
kCollectByUmeng = "collectByUmeng"
-------------------------------推广----------------------------------------
kLoadAdData 	= 'loadAdData'
kShowAd 		= 'showAd'
-------------------------------record and play back----------------------------------------
kStartRecord 	= "startRecord"
kStopRecord 	= "stopRecord"
kPlayBack 		= "playBack"
kStopPlayBack 	= "stopPlayBack"
-------------------------------------Android Update version------------------------
kVersion_sync="Version_sync"; -- 获得android 版本 
kversionCode  = "versionCode"; -- 获得android versionCode  数据 key
kversionName  = "versionName"; --  获得android versionName  数据 key
kupdateVersion ="updateVersion"; -- 更新版本
kupdateUrl = "updateUrl"; -- 设置更新版本数据 key
-----------------------------------------------------------------------------------

kWin32ConsoleColor = "win32_console_color"; -- win32 print_string 设置颜色


----------------------font style-----------------
kFontTextBold 			= "<b>"; -- 加粗
kFontTextItalic 		= "<i>"; -- 斜体
kFontTextUnderLine 		= "<u>"; -- 下划线
kFontTextDeleteLine 	= "<s>"; -- 中划线

----------------------share---------------------
kShare 					= "share" --分享

----------------------score---------------------
kScore 					= "score" --评分

------------------------------------------------
kClientId 				= "getClientId" --获取clientId

---------------------fb messanger调用-----------
kShareToMessenger       = "shareToMessenger"  --分享到fb messanger上

-----------------------等级经验-----------------
userLevelExp = { 
	{x1 = 0, x2 = 620},
	{x1 = 620, x2 = 2030},
	{x1 = 2030, x2 = 4670},
	{x1 = 4670, x2 = 9300},
	{x1 = 9300, x2 = 17060},
	{x1 = 17060, x2 = 29500},
	{x1 = 29500, x2 = 48640},
	{x1 = 48640, x2 = 76970},
	{x1 = 76970, x2 = 117480},
	{x1 = 117480, x2 = 182480},
	{x1 = 182480, x2 = 267480},
	{x1 = 267480, x2 = 377480},
	{x1 = 377480, x2 = 517480},
	{x1 = 517480, x2 = 692480},
	{x1 = 692480, x2 = 912480},
	{x1 = 912480, x2 = 1182480},
	{x1 = 1182480, x2 = 1512480},
	{x1 = 1512480, x2 = 1912480},
	{x1 = 1912480, x2 = 2382480},
	{x1 = 2382480, x2 = 2942480},
	{x1 = 2942480, x2 = 3602480},
	{x1 = 3602480, x2 = 4362480},
	{x1 = 4362480, x2 = 5252480},
	{x1 = 5252480, x2 = 6272480},
	{x1 = 6272480, x2 = 7442480},
	{x1 = 7442480, x2 = 8772480},
	{x1 = 8772480, x2 = 10282480},
	{x1 = 10282480, x2 = 11982480},
	{x1 = 11982480, x2 = 13902480},
	{x1 = 13902480, x2 = 16052480},
	{x1 = 16052480, x2 = 18452480},
	{x1 = 18452480, x2 = 21112480},
	{x1 = 21112480, x2 = 24072480},
	{x1 = 24072480, x2 = 27342480},
	{x1 = 27342480, x2 = 30942480},
	{x1 = 30942480, x2 = 34942480},
	{x1 = 34942480, x2 = 39292480},
	{x1 = 39292480, x2 = 44042480},
	{x1 = 44042480, x2 = 49242480},
	{x1 = 49242480, x2 = 54892480},
	{x1 = 54892480, x2 = 61042480},
	{x1 = 61042480, x2 = 67742480},
	{x1 = 67742480, x2 = 74992480},
	{x1 = 74992480, x2 = 82792480},
	{x1 = 82792480, x2 = 91242480},
	{x1 = 91242480, x2 = 100342480},
	{x1 = 100342480, x2 = 110092480},
	{x1 = 110092480, x2 = 120592480},
	{x1 = 120592480, x2 = 131842480},
	{x1 = 131842480, x2 = 143892480},
	{x1 = 143892480, x2 = 156742480},
	{x1 = 156742480, x2 = 170492480},
	{x1 = 170492480, x2 = 185142480},
	{x1 = 185142480, x2 = 200742480},
	{x1 = 200742480, x2 = 217342480},
	{x1 = 217342480, x2 = 234992480},
	{x1 = 234992480, x2 = 253742480},
	{x1 = 253742480, x2 = 273642480},
	{x1 = 273642480, x2 = 294742480},
	{x1 = 294742480, x2 = 317042480}
}

--levelTemp = 1


