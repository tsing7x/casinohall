--[[
	通用的socket消息处理器  2015-03-03
]]
local CommonProcesser = class(SocketProcesser)
local printInfo, printError = overridePrint("CommonProcesser")

function CommonProcesser:ctor()
	testCommonProcesser = self
end




function CommonProcesser:onMapDoNothing(data)
end
function CommonProcesser:onLoginLobbyServerRsp(data)
	EventDispatcher.getInstance():dispatch(Event.Message, "loginserver", data)
end

function CommonProcesser:onBroadcastRsp(data)
	JLog.d("CommonProcesser:onBroadcastRsp", data)
	if data.type == 1 then --加金币
		JLog.d("kkk1",data)
		if data.data and data.data.addMoney then
			MyUserData:addMoney(tonumber(data.data.addMoney) or 0, true)
			AlarmTip.play(string.format(Hall_string.STR_PAY_ACOUNT, data.data.addMoney));
		end
		if data.data and data.data.money then
			--            AlarmTip.play(string.format(STR_PAY_ACOUNT, data.data.money));
			MyUserData:setMoney(tonumber(data.data.money))
		end
		if data.data and data.data.diamond then
			AlarmTip.play(string.format(" ซื้อ %s ชิปเงินสด สำเร็จ！",data.data.addcoins)); 
			MyUserData:setCashPoint(tonumber(data.data.diamond))
			AnimationParticles.play(AnimationParticles.DropCoin)
		end
		--遍历商品，确定用户购买的价格, 支付上报boyaa广告SDK
		for i = 1, #MyPayMode do
			local shops = MyPayMode[i].pay
			if shops then
				for j = 1, shops:count() do
					local shop = shops:get(j)
					if shop:getPchips() == tonumber(data.data.addMoney or 0) then
						local payMoney = shop:getPamount()
						local payUnit = shop:getCurrency()
						NativeEvent.getInstance():boyaaAd({type = 5, value = MyUserData:getId(), pay_money = payMoney or "0", currencyCode = payUnit or "USD"})
						return
					end
				end
			end
		end

	elseif data.type == 2 then --好友请求
		MyUserData:setUnreadApply(MyUserData:getUnreadApply() + 1);
		-- local str= data.data and data.data.name
		-- if str then
		-- 	if string.len(str) > 9	then
		-- 		str=ToolKit.utf8_subStringByLen(str, 8)..".."
		-- 	end
		-- 	AlarmTip.play2Btn(string.format('%s ขอคุณเป็นเพื่อน',str or ''),
		-- 										'common/btn_refuse.png', 'common/btn_accept.png', self, function (self, which)
		-- 											-- body
		-- 											if which == 1 then--拒绝
		-- 												HttpModule.getInstance():execute(HttpModule.s_cmds.FRIEND_REFUSE,{fid = data.data.id, isagree = 0}, false, false)
		-- 												MyUserData:setUnreadApply(MyUserData:getUnreadApply() - 1);
		-- 											elseif which == 2 then--接受
		-- 												HttpModule.getInstance():execute(HttpModule.s_cmds.FRIEND_ACCEPT,{fid = data.data.id, isagree = 1}, false, false)
		-- 												MyUserData:setUnreadApply(MyUserData:getUnreadApply() - 1);
		-- 											end
		-- 											AlarmTip.stop();
		-- 	end)
		-- end
	elseif data.type == 3 then --好友赠送金币
		MyUserData:setUnreadGigt(MyUserData:getUnreadGigt() + 1);
	elseif data.type == 5 then --有任务完成
		HallConfig:setTaskAward(1)
	elseif data.type == 6 then   --通过好友请求
		AlarmTip.play(string.format("%s ได้อนุมัติให้คุณเป็นเพื่อนกันแล้ว", data.data or ""))
		HttpModule.getInstance():execute(HttpModule.s_cmds.GET_FRIENDS_LIST, {gameid = PhpManager:getGame()}, true, true)
	elseif data.type == 7 then --活动加减金币
		if data.data and data.data.money then
			MyUserData:addMoney(tonumber(data.data.money) or 0);
		end
	elseif data.type == 8 then    --活动加减道具通知
		--    data = {
		--        count = 78,
		--        num = "58",
		--        pnid = "1000"
		--    },
		--道具变动通知，使用最终值，不使用累加值
		JLog.d("kkk1 ",data)
		local propType = tonumber(data.data.pnid)
		if propType == 1000 then
		elseif propType ==4000 then
			MyUserData:setPropNum(propType,(tonumber(data.data.count.data["4000"].pcnter) or 0))
			AlarmTip.play(string.format("ซื้อ %s ลำโพง สำเร็จ!", tonumber(data.data.num) or 0))
		elseif propType == 2001 then
			MyUserData:setPropNum(propType,(tonumber(data.data.count.data["2001"].pcnter) or 0))
			AlarmTip.play(string.format("ซื้อ %s ไอเทม สำเร็จ!", tonumber(data.data.num) or 0))

		end
		--遍历商品，确定用户购买的价格, 支付上报boyaa广告SDK
		for i = 1, #MyPayMode do
			local shops = MyPayMode[i].prop
			if shops then
				for j = 1, shops:count() do
					local shop = shops:get(j)
					if tonumber(shop:getPcard()) == propType and tonumber(data.data.num) == tonumber(shop:getCount()) then
						local payMoney = shop:getPamount()
						local payUnit = shop:getCurrency()
						NativeEvent.getInstance():boyaaAd({type = 5, value = MyUserData:getId(), pay_money = payMoney or "0", currencyCode = payUnit or "USD"})
						return
					end
				end
			end
		end
	elseif data.type == 9 then     --邀请好友加入好友房
		local roomId = tonumber(data.data.roomid)
		local name = data.data.name or ""
		local gameId = tonumber(data.data.gameid) or 0
		local game = app:getGame(gameId)
		if game then
			AlarmTip.play2Btn(string.format(STR_BUDDY_INVITE_TO_GAME, name, game:getName()),
												"common/btn_ignore.png", "common/btn_accept.png", self, function (self, which)
													if which == 1 then  --拒绝邀请

													elseif which == 2 then  --接受邀请
														--离开房间的请求
														GameSocketMgr:sendMsg(0x1002)
														game:enterBuddyRoom(States.Lobby, kFalse, roomId, tonumber(data.data.serverid))
													end
													AlarmTip.stop();
			end)
		end
	elseif data.type == 10 then     --收到礼物的广播
		local receiver = data.data.receiver or {}
		if #receiver == 0 then
			return
		end
		local gift = data.data.gift or {}
		--可能会有多个礼物，方便后续扩展
		for k, v in pairs(gift) do
			local giftType = tonumber(k)
			local giftId = tonumber(v)
			if giftType and giftId then
				--如果接受者里头有我，要刷新自己的礼物
				for i = 1, #receiver do
					if receiver[i] == MyUserData:getId() then
						MyUserData:setGiftId({giftType, giftId})
						break;
					end
				end
				EventDispatcher.getInstance():dispatch(Event.Message, "giftSendBroadcast", {sender = tonumber(data.data.sender), receiver = receiver, gift = {giftType, giftId}, name = data.data.name or ""})
			end
		end
	elseif data.type == 11 then

	elseif data.type == 15 then    --活动加减道具通知
		--道具变动通知，使用最终值，不使用累加值
		local propType = tonumber(data.data.pnid)
		if propType == 1000 then

		elseif propType == 2001 then
			MyUserData:setPropCount(tonumber(data.data.count) or 0)
			AlarmTip.play(string.format(STR_PAY_GET_PROP, tonumber(data.data.num) or 0))
		end
		--通知未读消息生成
	elseif data.type == 16 then
		HallConfig:setHasUnckeckMsg(true)
	elseif data.type == 17 then
		HallConfig:setHasUnckeckMsg(true)		
		if G_CUR_GAME_ID == tonumber(GAME_ID.PokdengCash) then
			MyUserData:setCashPoint(tonumber(data.data.money))
		else
			MyUserData:setMoney(tonumber(data.data.money))
		end
		--MyUserData:setMoney(tonumber(data.data.money))
		AlarmTip.play(STR_MONEY_EXCEPTION)
	end

end

function CommonProcesser:onEntireBroadcastRsp(data)
	local dataType = tonumber(data.data and data.data.type or -1)
	if dataType == 3 or dataType == 4 or dataType == 5 or dataType == 6 then
		MySpeakerQueue:addNewMsg(data.data)
		local v=WindowManager:containsWindowByTag(WindowTag.RoomChatAndSpeakerPopu)
		if v then
			v:addHistorySpeaker(data.data)
		end
	end
end

function CommonProcesser:onServerRetire(data)
	printInfo('CommonProcesser:onServerRetire');
	AlarmTip.play(STR_SERVER_RETIRE);--提醒退休
	--StateChange.changeState(States.GameLobby);
end

--[[
	通用的（大厅）协议
]]
local onMapDoNothing = CommonProcesser.onMapDoNothing

CommonProcesser.s_severCmdEventFuncMap = {
	[Command.LOGIN_SERVER_RSP]      = CommonProcesser.onLoginLobbyServerRsp, --大厅登录返回
	[Command.BROADCAST_RSP]         = CommonProcesser.onBroadcastRsp,
	[Command.ENTIRE_BROADCAST_RSP]  = CommonProcesser.onEntireBroadcastRsp,
	[Command.SERVER_RETIRE]         = CommonProcesser.onServerRetire,--服务器退休协议
}

return CommonProcesser
