local ConstString = require('kefuSystem/common/kefuStringRes')

--设计分辨率
local DESIGNWIDTH = 720 
local DESIGNHEIGHT = 1280
local DESIGNSCALE = 1.0

local kefuConstant = {}



kefuConstant.KefuSetDesign = function ()

	local sW = System.getScreenWidth()
	local sH = System.getScreenHeight()

	local xScale = sW / DESIGNWIDTH
	local yScale = sH / DESIGNHEIGHT

	--按height计算
	if xScale > yScale then
		if sH - DESIGNHEIGHT > 1000 then
			DESIGNSCALE = 1.25
		elseif sH - DESIGNHEIGHT > 800 then
			DESIGNSCALE = 1.2
		elseif sH - DESIGNHEIGHT > 600 then
			DESIGNSCALE = 1.15
		elseif sH - DESIGNHEIGHT > 400 then
			DESIGNSCALE = 1.1
		elseif sH - DESIGNHEIGHT > 200 then
			DESIGNSCALE = 1.05
		end 
	else  
	--按width计算
		if sW - DESIGNWIDTH > 1000 * 0.9 then
			DESIGNSCALE = 1.25
		elseif sW - DESIGNWIDTH > 800 * 0.9 then
			DESIGNSCALE = 1.2
		elseif sW - DESIGNWIDTH > 600 * 0.9 then
			DESIGNSCALE = 1.15
		elseif sW - DESIGNWIDTH > 400 * 0.9 then
			DESIGNSCALE = 1.1
		elseif sW - DESIGNWIDTH > 200 * 0.9 then
			DESIGNSCALE = 1.05
		end

	end

	System.setLayoutWidth(DESIGNWIDTH * DESIGNSCALE)
	System.setLayoutHeight(DESIGNHEIGHT * DESIGNSCALE)

	local xScale = sW / System.getLayoutWidth();
	local yScale = sH / System.getLayoutHeight();
	local scale = xScale>yScale and yScale or xScale;
	Window.instance().drawing_root.size = Point(sW/scale, sH/scale);
	Window.instance().drawing_root.scale = Point(scale,scale);

	kefuConstant.SCREENWIDTH = sW/scale
	kefuConstant.SCREENHEIGHT = sH/scale
end


--时间常量
kefuConstant.DELAY_CONNECT_DEADLINE = 8
kefuConstant.DELAY_POLL_LOGIN = 60
kefuConstant.DELAY_TIMEOUT = 3*60
kefuConstant.DELAY_END_SESSION = 5*60


--logout的结束类型,1-用户；2-离线；3-超时；4-客服 
kefuConstant.LOGOUT_TYPE_USER = 1
kefuConstant.LOGOUT_TYPE_OFFLINE = 2;
kefuConstant.LOGOUT_TYPE_TIMEOUT = 3;
kefuConstant.LOGOUT_TYPE_KEFU = 4;

--显示时间item间隔
kefuConstant.INTERVAL_IN_MILLISECONDS = 60*1000

kefuConstant.HTMLTB = {
	["&quot;"] = [["]],
	["&nbsp;"] = [[ ]],
	["&lt;"] = 	[[<]],
	["&gt;"] = 	[[>]],
	["&amp;"] = 	[[&]],
	["&apos;"] = 	[[￠]],
	["&cent;"] = 	[[£]],
	["&pound;"] = 	[[']],
	["&yen;"] = 	[[¥]],
	["&sect;"] = 	[[§]],
	["&copy;"] = 	[[©]],
	["&reg;"] = 	[[®]],
	["&trade;"] = 	[[™]],
	["&times;"] = 	[[×]],
	["&divide;"] = 	[[÷]],	
}


--每次显示的历史消息条数
kefuConstant.PAGE_SIZE = 18

--是否有新回复
kefuConstant.HasNewReport = {
	yes = 1,
	no = 0,
}


kefuConstant.No = 0
--从左到右
kefuConstant.LTOR = 1
--从右到左
kefuConstant.RTOL = 2


--事件
kefuConstant.voice = "kefu_audio_event"
kefuConstant.mqttReceive = "kefu_mqtt_receive"
kefuConstant.connectLost = "kefu_connect_lost"
kefuConstant.msgSendResult = "kefu_msg_send_result"


--通牌作弊 1；滥发广告2；刷分倒币3；捣乱游戏4；不雅用语5；其他6
kefuConstant.HackMsg2NumType = {
    [ConstString.tong_pai_zuo_bi] = 1,
    [ConstString.lan_fa_guan_gao] = 2,
    [ConstString.shua_fen_bao_bi] = 3,
    [ConstString.dao_luan_you_xi] = 4,
    [ConstString.bu_ya_yong_yu] = 5,
    [ConstString.other_txt] = 6,
}

kefuConstant.HackNum2MsgType = {}
for i, v in pairs(kefuConstant.HackMsg2NumType) do
    kefuConstant.HackNum2MsgType[v] = i
end


--文件类型
kefuConstant.TXT = "text/plain"
kefuConstant.JPG = "image/jpeg"
kefuConstant.MP3 = "audio/mp3"

kefuConstant.MsgType = {
	["TXT"]     = "1", -- text
	["IMG"]     = "2", -- picture
	["VOICE"]   = "3", -- voice
	["ROBOT"]   = "4", -- bot message
}

-- 每次网络加载消息的消息条目数 
kefuConstant.NETWORK_MESSAGE_LIMIT = 10

kefuConstant.showLeaveModule = 1
--控制举报模块是否可见
kefuConstant.showHackModule = 1
--控制盗号申述模块
kefuConstant.showReportModule = 1


--最大输入限制
kefuConstant.MAX_INPUT_LENGTH = 1000

--最大回复数目
kefuConstant.MAX_REPLYS_VALID_COUNT = 8

return kefuConstant






