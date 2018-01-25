ViewPath = "app.view.";

kDeviceTypeIOS = 1;
kDeviceTypeIPHONE = 1;
kDeviceTypeIPAD = 2;
kDeviceTypePC = 3;
kDeviceTypeANDROID = 4;
kDeviceTypeWIN7 = 5;
if kPlatformIOS == System.getPlatform() then
	FEEDBACK_APPID = "5500";
else
	FEEDBACK_APPID = "5501";
end
FEEDBACK_GAME  = "szdt";
FEEDBACK_FTYPE = 1;
FEEDBACK_IMG_FTYPE = 2;
--kBrokeMoney = 1000
--活动中心常量
ACTIVITY_SECRET_KEY = "boyaa&&@9607";
ACTIVITY_URL = "https://mvlptldc.boyaagame.com";
ACTIVITY_APPID = "9607";

PLAYER_COUNT = 4
SEAT_1 = 1
SEAT_2 = 2
SEAT_3 = 3
SEAT_4 = 4

ServerType = {
	Normal = 1,
	Test = 2,
	Dev = 3,
}

ChargeType = {
	QuickCharge = 1,
	FirstCharge = 2,
	BrokeCharge = 3,
	NotEnoughMoney = 4,
}

ChangeDeskType = {
	Change = 0,
		Down = 1,
		Up = 2,
}

CARD_UP_SCALE = 1.2

PropImages = {
	[1] = "anim_praise.png",
	[2] = "anim_egg.png",
	[3] = "anim_soap.png",
	[4] = "anim_heart.png",
	[5] = "anim_beer.png",
	[6] = "anim_stock.png",
	[7] = "anim_flower.png",
	[8] = "anim_bomb.png",
}

-- [1] = "点赞",
-- [2] = "鸡蛋",
-- [3] = "肥皂",
-- [4] = "亲吻",
-- [5] = "干杯",
-- [6] = "石头",
-- [7] = "玫瑰",
-- [8] = "炸弹",
local path = "animation/friendsAnim/"
PropConfig = {
	[1] = path .. "animationToPraise",
	[2] = path .. "animationThrowEgg",
	[3] = path .. "animationThrowSoap",
	[4] = path .. "animationSendKiss",
	[5] = path .. "animationCheers",
	[6] = path .. "animationThrowRock",
	[7] = path .. "animationSendRose",
	[8] = path .. "animationThrowBomb",
}

UserType = {
	Facebook	= 1,
	Visitor		= 2,
}

----------------------各种文件前后缀-------
kHeadImagePrefix = "userHead"
kHeadImageFolder = "head_images/"
kIconImageFolder = "icon_images/"

kPngSuffix = ".png"

kBuddyRoomID = -5001

--道具ID列表
kIDInteractiveProp      = 2001
kIDPrivateRoomCard      = 1000
kIDSpeaker              = 4000


--上报广告事件, 部分事件在新的SDK里部分事件已经不作为预留事件，保留是为了兼容以前的上报
kADStart                = 1
kADRegister             = 2
kADLogin                = 3
kADPlay                 = 4
kADPay                  = 5
kADCUSTOM               = 6
kADRecall               = 7
kADLogout               = 8
kADShare                = 9
kADInvite               = 10
kADPurchaseCancel       = 11


--支付渠道
kAndroidJMT           = 240
kAndroidCheckout      = 12
kAndroid12Call        = 645
kAndroidTrueMoney     = 646
kAndroidMolTrueMoney  = 474
kAndroidE2p           = 600
kAndroidLinePay       = 601
kAndroidAis           = 348

kIOSPay               = 99
kIOSJMT               = 741
kIOS12call            = 621
kIOSTureMoney         = 623
kIOSE2p               = 625
kIOSLinePay           = 763

--破产数值
gBankrupt = 5000
