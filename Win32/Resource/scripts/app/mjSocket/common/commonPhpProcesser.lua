--[[
	通用的Php消息处理器  2015-03-04
]]
local CommonPhpProcesser = class(SocketProcesser)
local printInfo, printError = overridePrint("CommonPhpProcesser")

function CommonPhpProcesser:ctor()
	-- body
	EventDispatcher.getInstance():register(HttpModule.s_event, self, self.onHttpResponse);
end

function CommonPhpProcesser:dtor()
	-- body
	EventDispatcher.getInstance():unregister(HttpModule.s_event, self, self.onHttpResponse);
end

function CommonPhpProcesser:requestLogin()

end

function CommonPhpProcesser:onHttpResponse( command, ... )
	-- printInfo("CommonPhpProcesser.onHttpResponse");
	-- if not app:checkResponseOk(data) then
	-- 	return
	-- end
	--dd.dd.dd=0;
	-- MyUserData:initUserInfo(data.data);
	-- 
	local func = self.s_httpEventFuncMap[command];
	if func then
		func(self, ...);
	end
	
end

function CommonPhpProcesser:onLoginPhpResponse(isSuccess, data)
	writeTabToLog({data=data or "nil", isSuccess=isSuccess}, "php登录", "debug_common.lua")	
	--data.data.hallip = {"192.168.203.228:10003", "192.168.203.228:10003"}
	JLog.d("CommonPhpProcesser:onLoginPhpResponse isSuccess, data", isSuccess, data)
	if isSuccess and data then
		if 1 == data.code then
			if data.data then
				local sesskey 	= data.data.sesskey;
				local user 		= data.data.aUser;
				if user then
					user.sesskey = sesskey;
					MyUserData:initUserInfo(user);
					GameConfig:setLastUserType(MyUserData:getUserType())
						  :save()
					HallConfig:setHaveActivity(user.haveActivity)
				end
				local hallip = data.data.hallip;
				if hallip then
					local addrList = {};
					for i = 1, #hallip do
						local addr = {};
						addr.ip, addr.port = string.match(hallip[i], "(%d+.%d+.%d+.%d+):(%d+)");
						table.insert(addrList, addr)
					end
					HallConfig:setAddrList(addrList);
				end
				--URL
				MyUserData:setUrls(data.data.urls or {})
				--游戏列表 102:游戏大厅 1002:骰子
				HallConfig:setGameList(data.data.gameList or {} );
				-- init server2 url
				HttpModule.getInstance():resetServer2Url()
				--大厅游戏列表
				HallConfig:setLobbyGames(data.data.gamesListConfig or {})
				--大厅更新
				HallConfig:setUpdateUrl(data.data.updateUrl or {})
                
                -- HttpModule.s_config[HttpModule.s_cmds.create_room_config][HttpConfigContants.URL] = tostring(1000)
                -- HttpModule.getInstance():execute(HttpModule.s_cmds.create_room_config, {}, false, false)

                -- HttpModule.s_config[HttpModule.s_cmds.GET_ROOM_LIST][HttpConfigContants.URL] = tostring(GAME_ID.Casinohall)
                -- HttpModule.getInstance():execute(HttpModule.s_cmds.GET_ROOM_LIST, {}, false, true)

                -- HttpModule.s_config[HttpModule.s_cmds.GET_ROOM_LIST][HttpConfigContants.URL] = tostring(GAME_ID.PokdengCash)
                -- HttpModule.getInstance():execute(HttpModule.s_cmds.GET_ROOM_LIST, {}, false, true)

                -- --请求邀请好友任务列表
                -- HttpModule.getInstance():execute(HttpModule.s_cmds.GET_CASH_TASK_FRIEND, {}, true, true)
                --请求道具数量
                HttpModule.getInstance():execute(HttpModule.s_cmds.GET_USER_ALL_PROPS,{}, false, false)
				HttpModule.getInstance():execute(HttpModule.s_cmds.GET_PROP_CFG_LIST, {}, false, false)
                -- --查询所有开关
                -- HttpModule.getInstance():execute(HttpModule.s_cmds.CHECK_SWITCH_FOR_ALL, {}, false, false)
                -- --查询礼物列表
                -- HttpModule.getInstance():execute(HttpModule.s_cmds.GIFT_STORE_GET_LIST, {}, false, false)

                HttpModule.getInstance():execute(HttpModule.s_cmds.GET_URGENT_NOTICE, {}, false, false)
				--登录有奖
				local signAward = data.data.signAward
				if signAward then
					
					--今天没签到
					if signAward.type == 1 then
                        --签到数据
						local attendenceData = {}
                        --FB账号的奖励倍数
                        attendenceData.override = signAward.override
                        --连续签到日子
						attendenceData.signNum = signAward.signNum
                        attendenceData.hasSigned = false
						local configs = signAward.prizelist or {}
						for i = 1, #configs do
							local config = {}
							--金币奖励
							config.type = configs[i].type and tonumber(configs[i].type) or 0
							if config.type == 1 then
								config.money = configs[i].money and tonumber(configs[i].money) or 0
							--金币和道具奖励
							elseif config.type == 2 then
								config.money = configs[i].money and tonumber(configs[i].money) or 0
								config.pnid = configs[i].pnid or 0
								config.props = configs[i].props and tonumber(configs[i].props) or 0
							--现金币奖励
							elseif config.type == 3 then
								config.diamond = configs[i].diamond and tonumber(configs[i].diamond) or 0
							end
							table.insert(attendenceData, config)
						end
						MyUserData.dailyReward = {rewardType = WindowTag.AttendencePopu,  rewardData = attendenceData}
                        HallConfig:setAttendenceReward(attendenceData)
                    else
                        --已经签到，清空签到数据
                        local attendenceData = {}
                        attendenceData.hasSigned = true
                        HallConfig:setAttendenceReward(attendenceData)
					end
				end
				-- if data.data.registerAward then
				-- 	local money = data.data.registerAward.addmoney or 0;
				-- 	local mtype = data.data.registerAward.type or 0
				-- 	local days = data.data.registerAward.days or 0
				-- 	local awardList = data.data.registerAward.awardList or {}
    --                 local propList = data.data.registerAward.propList or {}
				-- 	--mtype:1 登录成功 0：登录失败
				-- 	if mtype == 1 then
    --                     MyUserData.dailyReward = {rewardType =WindowTag.RegisterRewardPopu,  rewardData = {money = addmoney, day = days, awardList = awardList, propList = propList}}
				-- 		--WindowManager:showWindow(WindowTag.RegisterRewardPopu, {day = days, addmoney = money, awardList = awardList}, WindowStyle.POPUP)
				-- 	else

				-- 	end
				-- 	if days == 1 then
				-- 		NativeEvent.getInstance():boyaaAd({type = 2, value = MyUserData:getId()})
				-- 	end
				-- end
                
				--在此处添加系统公告
                --HttpModule.getInstance():execute(HttpModule.s_cmds.GET_GAMEINFO,{gameid = 1002}, false, false)
                HttpModule.getInstance():execute(HttpModule.s_cmds.INVITE_CONFIG,{sid = PhpManager:getGame()}, false, false)
                HttpModule.getInstance():execute(HttpModule.s_cmds.Friend_INIT_OLD_FRIEND_TO_PLAY_CFG,{}, false, false)
				--是否是FB登录,iscreate = 1是首次创建的用户
				if UserType.Facebook == MyUserData:getUserType() then
                    --FB用户存sesskey
                    GameSetting:setSesskey(sesskey)
                    GameSetting:save()
                    JLog.d("data.data.isCreate", data.data.isCreate, type(data.data.isCreate))
                    if data.data.isCreate then
					    NativeEvent.getInstance():getFbAppInfo();
                    end
				end
				--本地更新
				-- MyUpdate:update(HallConfig:getUpdateVerUrl(), HallConfig:getUpdateZipUrl())

				--广告
				NativeEvent.getInstance():loadAdData(MyUserData:getId(), true)
				--这时网络已断开，重新连接
				printInfo('CommonPhpProcesser tryReconnect()')
				GameSocketMgr:tryReconnect()
                --刷新gcm 的token值
				NativeEvent.getInstance():getClientId({})
                --从fb messenger回复进来的，发送统计事件
                --上报启动方式，1表示从fb messenger启动
                if not self.postStartWay and NativeEvent.getInstance():getStartWay() == 1 then
                    self.postStartWay = true
                    app:postFrontStaticstics("startFromMessenger")
                end
                --保留登录广告
				NativeEvent.getInstance():boyaaAd({type = 3, value = MyUserData:getId()})
				--新用户登陆
				-- if data.data.isCreate then
				--  	WindowManager:showWindow(WindowTag.RegisterAwardPopu, {day=1,waitTime=3824}, WindowStyle.POPUP)
				-- end
			end
        --封号通知，弹窗提示
        elseif data.code == -5 then
			WindowManager:showWindow(
				WindowTag.LobbyConfirmPopu,
				{
                content = data.codemsg or "",
                confirm = STR_EXIT_GAME_CONFIRM,
				},
				WindowStyle.POPUP
			)
		else
			AlarmTip.play(data.codemsg or "");
		end
	else
		if NativeEvent.getInstance():GetNetAvaliable() == 1 then
			AlarmTip.play(STR_LOGIN_FAILED_NO_NETWORK)
		else
			AlarmTip.play(STR_LOGIN_FAILED_BAD_NETWORK)
		end
	end
end
function CommonPhpProcesser:onGetFbInviteAwardResponse(isSuccess, data)
	if isSuccess and data then
		if 1 == data.code then
			if data.data then
				local addmoney 	= data.data.addmoney;
				local money 		= data.data.money;
				if money then
					MyUserData:setMoney(money);
				end
				AlarmTip.play(string.format(Hall_string.STR_INVITE_AWARD, PhpManager:getAppname(), addmoney));
				--金币雨动画
				AnimationParticles.play(AnimationParticles.DropCoin)
				kEffectPlayer:play('audio_get_gold')
			end
		else
			AlarmTip.play(data.codemsg or "");
		end
	end
end

function CommonPhpProcesser:onGetFbInviteSucAwardResponse(isSuccess, data)
	JLog.d("CommonPhpProcesser:onGetFbInviteSucAwardResponse", isSuccess, data)
	if isSuccess and data then
		if 1 == data.code then
			if data.data then
				local money 		= data.data.money;
				if money then
					MyUserData:setMoney(money);
				end
				AlarmTip.play(data.codemsg or "");
				--金币雨动画
				AnimationParticles.play(AnimationParticles.DropCoin)
				kEffectPlayer:play('audio_get_gold')
			end
		else
			AlarmTip.play(data.codemsg or "");
		end
	end
end

function CommonPhpProcesser:onGetBrokenMoneyResponse(isSuccess, data)
	
	if isSuccess and data then
		if 1 == data.code then
			if data.data then
				local addmoney 	= data.data.addmoney;
				local money 		= data.data.money;
				if money then
					MyUserData:setMoney(money);
				end
				AlarmTip.play(string.format(Hall_string.STR_BROKEN,addmoney))
				--金币雨动画
				AnimationParticles.play(AnimationParticles.DropCoin)
				kEffectPlayer:play('audio_get_gold')
				EventDispatcher.getInstance():dispatch(Event.Message, "hallBankrupt", 0)
			end
		else
			AlarmTip.play(data.codemsg or "");
		end
	end
end

function CommonPhpProcesser:onPayModeResponse( isSuccess, data )
	-- writeTabToLog(data,"pmode数据源","debug_common.lua")
	-- local str = '{"code":1,"codemsg":null,"data":[{"name":"checkout","pmode":12,"time":1462442752,"sort":1},{"name":"JMT","pmode":240,"time":1462442752,"sort":2}],"time":1500456778,"exetime":0.013514041900635}'
	-- local data = json.decode(str)
	-- local isSuccess = true
	JLog.d("onPayModeResponse", isSuccess, data)
	if app:checkResponseOk(isSuccess, data) then
        MyPayMode = {};
        for i = 1, #data.data do
            local d = data.data[i]
            local payMode = setProxy(new(require('app.data.payMode')))
            payMode:setId(d.pmode or 0)
            payMode:setName(d.name or 0)
            payMode:setTime(d.time or 0)

            table.insert(MyPayMode, payMode);
        end
    end
end
function CommonPhpProcesser:onPayListResponse( isSuccess, data )
	-- writeTabToLog(data,"payList","debug_common.lua")
	-- body
	-- {"code":1,"codemsg":"",
	-- "data":[{"id":"123802","sid":"7","appid":"1332","pmode":"240","pamount":"29","discount":"1","pcoins":"0","pchips":"1722600","pcard":"0","item_id":"0","ptype":"0","pnum":"1","getname":"1,722,600\u0e0a\u0e34\u0e1b","desc":"{\"url1\":\"\",\"url2\":\"\",\"desc\":\"\"}","stag":"1","currency":"THB","prid":"36","expire":"0","state":"","device":"1","sortid":"0","etime":"1442310241","status":"2","use_status":"0"},
	-- 		{"id":"123803","sid":"7","appid":"1332","pmode":"240","pamount":"49","discount":"1","pcoins":"0","pchips":"3234000","pcard":"0","item_id":"0","ptype":"0","pnum":"1","getname":"3,234,000\u0e0a\u0e34\u0e1b","desc":"{\"url1\":\"\",\"url2\":\"\",\"desc\":\"\"}","stag":"1","currency":"THB","prid":"36","expire":"0","state":"","device":"1","sortid":"0","etime":"1442310241","status":"2","use_status":"0"},{"id":"123804","sid":"7","appid":"1332","pmode":"240","pamount":"99","discount":"1","pcoins":"0","pchips":"7623000","pcard":"0","item_id":"0","ptype":"0","pnum":"1","getname":"7,623,000\u0e0a\u0e34\u0e1b","desc":"{\"url1\":\"\",\"url2\":\"\",\"desc\":\"\"}","stag":"1","currency":"THB","prid":"36","expire":"0","state":"","device":"1","sortid":"0","etime":"1442310241","status":"2","use_status":"0"},{"id":"123805","sid":"7","appid":"1332","pmode":"240","pamount":"149","discount":"1","pcoins":"0","pchips":"12456400","pcard":"0","item_id":"0","ptype":"0","pnum":"1","getname":"12,456,400\u0e0a\u0e34\u0e1b","desc":"{\"url1\":\"\",\"url2\":\"\",\"desc\":\"\"}","stag":"1","currency":"THB","prid":"36","expire":"0","state":"","device":"1","sortid":"0","etime":"1442310241","status":"2","use_status":"0"}],"time":1442890249,"exetime":1442890249.5111}
	-- local isSuccess = true
	-- local str = '{"code":1,"codemsg":"","data":[{"id":203710,"sid":7,"appid":1515,"pmode":12,"pamount":19,"discount":1,"pcoins":0,"pchips":950000,"pcard":0,"ptype":0,"pnum":0,"getname":"950000\u0e0a\u0e34\u0e1b","currency":"THB","bid":0,"productid":0,"version":0,"extrasend":0,"desc":"","datastream":0,"sendstarttime":"","sendendtime":""},{"id":203711,"sid":7,"appid":1515,"pmode":12,"pamount":29,"discount":1,"pcoins":0,"pchips":1600000,"pcard":0,"ptype":0,"pnum":0,"getname":"1600000\u0e0a\u0e34\u0e1b","currency":"THB","bid":0,"productid":0,"version":0,"extrasend":0,"desc":"\u0e40\u0e15\u0e34\u0e21\u0e0a\u0e34\u0e1b + 10%","datastream":0,"sendstarttime":"","sendendtime":""},{"id":203712,"sid":7,"appid":1515,"pmode":12,"pamount":49,"discount":1,"pcoins":0,"pchips":3100000,"pcard":0,"ptype":0,"pnum":0,"getname":"3100000\u0e0a\u0e34\u0e1b","currency":"THB","bid":0,"productid":0,"version":0,"extrasend":0,"desc":"\u0e40\u0e15\u0e34\u0e21\u0e0a\u0e34\u0e1b + 26%","datastream":0,"sendstarttime":"","sendendtime":""},{"id":203713,"sid":7,"appid":1515,"pmode":12,"pamount":99,"discount":1,"pcoins":0,"pchips":7500000,"pcard":0,"ptype":0,"pnum":0,"getname":"7500000\u0e0a\u0e34\u0e1b","currency":"THB","bid":0,"productid":0,"version":0,"extrasend":0,"desc":"\u0e40\u0e15\u0e34\u0e21\u0e0a\u0e34\u0e1b + 50%","datastream":0,"sendstarttime":"","sendendtime":""},{"id":203714,"sid":7,"appid":1515,"pmode":12,"pamount":199,"discount":1,"pcoins":0,"pchips":16000000,"pcard":0,"ptype":0,"pnum":0,"getname":"16000000\u0e0a\u0e34\u0e1b","currency":"THB","bid":0,"productid":0,"version":0,"extrasend":0,"desc":"\u0e40\u0e15\u0e34\u0e21\u0e0a\u0e34\u0e1b + 60%","datastream":0,"sendstarttime":"","sendendtime":""},{"id":203715,"sid":7,"appid":1515,"pmode":12,"pamount":399,"discount":1,"pcoins":0,"pchips":34000000,"pcard":0,"ptype":0,"pnum":0,"getname":"34000000\u0e0a\u0e34\u0e1b","currency":"THB","bid":0,"productid":0,"version":0,"extrasend":0,"desc":"\u0e40\u0e15\u0e34\u0e21\u0e0a\u0e34\u0e1b + 70%","datastream":0,"sendstarttime":"","sendendtime":""},{"id":203716,"sid":7,"appid":1515,"pmode":12,"pamount":999,"discount":1,"pcoins":0,"pchips":90000000,"pcard":0,"ptype":0,"pnum":0,"getname":"90000000\u0e0a\u0e34\u0e1b","currency":"THB","bid":0,"productid":0,"version":0,"extrasend":0,"desc":"\u0e40\u0e15\u0e34\u0e21\u0e0a\u0e34\u0e1b + 80%","datastream":0,"sendstarttime":"","sendendtime":""},{"id":203717,"sid":7,"appid":1515,"pmode":12,"pamount":1999,"discount":1,"pcoins":0,"pchips":190000000,"pcard":0,"ptype":0,"pnum":0,"getname":"190000000\u0e0a\u0e34\u0e1b","currency":"THB","bid":0,"productid":0,"version":0,"extrasend":0,"desc":"\u0e40\u0e15\u0e34\u0e21\u0e0a\u0e34\u0e1b + 90%","datastream":0,"sendstarttime":"","sendendtime":""},{"id":203718,"sid":7,"appid":1515,"pmode":12,"pamount":3999,"discount":1,"pcoins":0,"pchips":400000000,"pcard":0,"ptype":0,"pnum":0,"getname":"400000000\u0e0a\u0e34\u0e1b","currency":"THB","bid":0,"productid":0,"version":0,"extrasend":0,"desc":"\u0e40\u0e15\u0e34\u0e21\u0e0a\u0e34\u0e1b + 100%","datastream":0,"sendstarttime":"","sendendtime":""}],"time":1500455563,"exetime":0.0029380321502686}'
	-- local data = json.decode(str)
	JLog.d("onPayListResponse", isSuccess, data)
	if app:checkResponseOk(isSuccess, data) then
		local pay 	= new(require('app.data.pay'));
		for i = 1, #data.data do
			local d = data.data[i]
			local shop = setProxy(new(require('app.data.shop')));
			
			pay:setMode(tonumber(d.pmode or 0));
			shop:setId(tonumber(d.id or 0));
			shop:setPamount(tonumber(d.pamount or 0));
			shop:setCurrency(d.currency or "$")
			shop:setPchips(tonumber(d.pchips or 0))
			shop:setPrevchips(tonumber(d.prevchips or 0))
            shop:setDiscount(tonumber(d.discount) or 1)
            shop:setPcard(tonumber(d.pcard) or 0)
            shop:setName(d.getname or "")
			shop:setPdesc(string.format('1%s=%s', shop:getCurrency(), ToolKit.skipMoney(math.floor(shop:getPchips() > 0 and shop:getPchips() / shop:getPamount() or 0))));
			pay:add(shop)
		end

		if MyPayMode then
			for i = 1, #MyPayMode do
				if MyPayMode[i]:getId() == pay:getMode() then
					MyPayMode[i]:setPay(pay)
				end
			end 
		end
	end
end

function CommonPhpProcesser:onPayOrderResponse( isSuccess, data )
	writeTabToLog(data,"下单返回","debug_common.lua")
	JLog.d("CommonPhpProcesser:onPayOrderResponse", isSuccess, data)
	--{"code":1,"codemsg":"","data":{"ORDER":"000713320240BYORDFLG002224938428","SID":"7","APPID":"1332","PMODE":"240","PAMOUNT":"29","PCOINS":"0","PCHIPS":"1722600","PCARD":"0","PNUM":"1","PAYCONFID":123802,"CURRENCY":"THB","DESC":"{\"url1\":\"\",\"url2\":\"\",\"desc\":\"\"}","RET":0,"MSG":"succ","SITEMID":"06DCB1D14E41BBD34FBC6D141F2E5122dddd","user_ip":"172.20.42.146","macid":""},"time":1442902863,"exetime":1442902863.9888}
	if app:checkResponseOk(isSuccess, data) then
		MyPay:pay(data.data.PMODE, data.data);
	end
end

function CommonPhpProcesser:onPhpResponse( data )
	-- printf("========[[ 接收PHP命令 0x%04x ]] ============================", data.cmd)
	-- dump(data);
	-- server访问不到php
	if data.status == 404 then
		AlarmTip.play(data.msg)
		return
	end
	local func = self.s_severCmdEventFuncMap[data.cmd];
	if func then
		if data.data then
			func(self, data.data);
		else
			printInfo(string.format("0x%04X数据异常, 请稍后重试", data.cmd))
			AlarmTip.play(string.format("0x%04X数据异常, 请稍后重试", data.cmd))
		end
	end
	GameLoading:onCommandResponse(data.cmd)
end

function CommonPhpProcesser:onPhpTimeout( data )
end

function CommonPhpProcesser:onLoginResponse( data )
	if not app:checkResponseOk(data) then
		return
	end
	-- 本地没有缓存的游戏类型 或者 新注册 则按照推荐的选择玩法
	if GameConfig:getLastType() == 0 or MyUserData:getIsRegister() == 1 then
		local gameId = data.data.game_id or GameType.GBMJ
		local gameType = GameSupportStateMap[gameId] and gameId or GameType.GBMJ
		GameConfig:setLastType(gameType)
			:save()
		-- 通知选择游戏类型
		EventDispatcher.getInstance():dispatch(Event.Message, "SelectGameType", gameType)
	end
	MyUserData:initUserInfo(data.data);
	GameConfig:setLastUserType(data.data.usertype or MyUserData:getUserType())
		:save()
	-- EventDispatcher.getInstance():dispatch(HttpModule.s_event, Command.LOGIN_PHP_REQUEST, data);
end

function CommonPhpProcesser:onUserInfoResponse( data )
	-- EventDispatcher.getInstance():dispatch(HttpModule.s_event, Command.USERINFO_PHP_REQUEST, data);
end
--系统公告
function CommonPhpProcesser:onNoticeResponse( data )
	
	if app:checkResponseOk(data, true) then

		MyNoticeData:clear();

		for i = 1, #data.data do

			local notice = setProxy(new(require("app.data.notice")));

			notice:setTitle(data.data[i].title);
			notice:setContent(data.data[i].content)
			notice:setLink_type(data.data[i].link_type);
			notice:setLink_content(data.data[i].link_content);
			notice:setStart_time(data.data[i].start_time);

			MyNoticeData:add(notice);

		end

		EventDispatcher.getInstance():dispatch(HttpModule.s_event, Command.NOTICE_PHP_REQUEST, data);
	end
end

--商城
function CommonPhpProcesser:onPayResponse( data )
	printInfo("CommonPhpProcesser:onPayResponse");
	if app:checkResponseOk(data) then
		MyPayData:clear();
		for i = 1, #data.data do
			local shop = new(require("app.data.shop"));

			shop:setId(data.data[i].id);
			shop:setPamount(data.data[i].pamount)
			shop:setPcard(data.data[i].pcard);
			shop:setPchips(data.data[i].pchips);
			shop:setPcoins(data.data[i].pcoins);
			shop:setPdesc(data.data[i].pdesc);
			shop:setPimg(data.data[i].pimg);
			shop:setPname(data.data[i].pname);
			shop:setPnum(data.data[i].pnum);
			shop:setPsort(data.data[i].psort);
			shop:setPtype(data.data[i].ptype);

			MyPayData:add(shop);
		end
		MyPayData:setInit(true)
	end
end

--计费配置
function CommonPhpProcesser:onPayConfigResponse( data )

	EventDispatcher.getInstance():dispatch(HttpModule.s_event, Command.PAY_CONFIG_PHP_REQUEST, data);
end
--计费配置
function CommonPhpProcesser:onPayConfigLimitResponse( data )

	EventDispatcher.getInstance():dispatch(HttpModule.s_event, Command.PAY_CONFIG_LIMIT_PHP_REQUEST, data);
end

--下单
function CommonPhpProcesser:onOrderResponse( data )

	EventDispatcher.getInstance():dispatch(HttpModule.s_event, Command.ORDER_PHP_REQUEST, data);
end

function CommonPhpProcesser:onModifyUserInfoResponse( data )
	-- if app:checkResponseOk(data) then	
	-- 	AlarmTip.play(data.msg)

	-- 	if data.data.nick then
	-- 		MyUserData:setNick(data.data.nick);
	-- 	end

	-- 	if data.data.sex then
	-- 		if data.data.sex and tonumber(data.data.sex) > 0 then
	-- 			MyUserData:setSex(tonumber(data.data.sex) - 1)
	-- 		else
	-- 			MyUserData:setSex(0)
	-- 		end
	-- 	end

	-- 	if data.data.tid then
	-- 		MyUserData:setTid(data.data.tid);
	-- 		local tarr = MyUserData:getTarr();
	-- 		MyUserData:setTitle(tarr[tonumber(MyUserData:getTid())]);
	-- 	end
	-- end
end
--更新奖励
function CommonPhpProcesser:onUpdateAwardResponse( data )
	--加金币
	if data.status == 1 then
		MyUserData:addMoney(tonumber(data.data.money or 0), true);
		MyUpdateData:setAward(0);
		ToolKit.setDict("UPDATE", { version = ""});
	else
		AlarmTip.play(data.msg);
	end
	EventDispatcher.getInstance():dispatch(HttpModule.s_event, Command.UPDATE_AWARD_PHP_REQUEST, data);
end

--通知更新奖励
function CommonPhpProcesser:onNotifyUpdateAwardResponse( data )
	--加金币
	if data.status == 1 then
		ToolKit.setDict("UPDATE", { version = "" });
	end
end
--使用互动道具的回调
function CommonPhpProcesser:onSendProp( isSuccess, data )
	if app:checkResponseOk(isSuccess, data) then
		MyUserData:setPropCount(data.data.pcnter)
	end
end

function CommonPhpProcesser:onGetPropList( isSuccess, data )
	-- dump(data)
	if app:checkResponseOk(isSuccess, data) then
		MyUserData:setPropCount(data.data[1] and data.data[1].pcnter or 0)
--		EventDispatcher.getInstance():dispatch(Event.Message, "updateUserInfoPros", '')
	end
end

function CommonPhpProcesser:onSendChip( isSuccess, data )
  if app:checkResponseOk(isSuccess, data) then
		MyUserData:addMoney(-tonumber(data.data.sendMoney or 0))
	end
end
function CommonPhpProcesser:onGivingTips( isSuccess, data )
  if app:checkResponseOk(isSuccess, data) then
		MyUserData:addMoney(-tonumber(data.data.sendMoney or 0))
	end
end

function CommonPhpProcesser:onHasTaskAward( isSuccess, data )
  if app:checkResponseOk(isSuccess, data) then
  		HallConfig:setTaskAward(tonumber(data.data.unclainedReward));
	end
end
function CommonPhpProcesser:onGetBankruptTag(isSuccess, data)
	if isSuccess and data then
		if 1 == data.code and data.data then
			if data.data.allnum and data.data.nums then
				if data.data.nums < data.data.allnum then
					EventDispatcher.getInstance():dispatch(Event.Message, "hallBankruptTag", data.data)
				end
			end
		else
			--
		end
	else
		EventDispatcher.getInstance():dispatch(Event.Message, "hallBankruptTimeOut",nil)
	end
end
--获取破产补助后的回调
function CommonPhpProcesser:onGetHallBankrupt(isSuccess, data)
	if isSuccess and data then
		if 1 == data.code then
			if data.data then
				local addmoney 	= data.data.addmoney;
				local money 		= data.data.money;
				if money then
					MyUserData:setMoney(money);
				end
				AlarmTip.play(string.format(Hall_string.STR_BROKEN, addmoney))
				--金币雨动画
				AnimationParticles.play(AnimationParticles.DropCoin)
				kEffectPlayer:play('audio_get_gold')
				EventDispatcher.getInstance():dispatch(Event.Message, "hallBankrupt", 0)
			end
		else
			AlarmTip.play(data.codemsg or "");
		end
	end
end

--function CommonPhpProcesser:onHallUserNewsDel(isSuccess, data)
--end

--function CommonPhpProcesser:onHallUserNoticeDel(isSuccess, data)
--end
function CommonPhpProcesser:onHallUserNoticeAward(isSuccess, data)

	if app:checkResponseOk(isSuccess, data) then
		local award = data.data
		--钱
		if award.money then
			MyUserData:addMoney(tonumber(award.money), true);
			
		end
		if award.pinfo then
			local prop = award.pinfo["2001"]
			local num  = prop and prop.num or 0
			MyUserData:addProp(num)
		end

		if award.diamond then
			--todo
			MyUserData:setCashPoint(MyUserData:getCashPoint() + tonumber(award.diamond))
		end

		AnimationParticles.play(AnimationParticles.DropCoin)
		kEffectPlayer:play('audio_get_gold')
	end
end

function CommonPhpProcesser:onHallGameNoticeAward(isSucc, data)
	-- body
	if app:checkResponseOk(isSucc, data) then
		local award = data.data
		if award.money then
			MyUserData:addMoney(tonumber(award.money), true)
			
		end

		if award.pinfo then
			local prop = award.pinfo["2001"]
			local num  = prop and prop.num or 0
			MyUserData:addProp(num)
		end

		if award.diamond then
			--todo
			MyUserData:setCashPoint(MyUserData:getCashPoint() + tonumber(award.diamond))
		end

		AnimationParticles.play(AnimationParticles.DropCoin)
		kEffectPlayer:play('audio_get_gold')
	end
end

function CommonPhpProcesser:onGetUpgradeReward(isSuccess, data)

	-- JLog.d("CommonPhpProcesser:onGetUpgradeReward(isSuccess :" .. tostring(isSuccess) .. ").data :===============", data)
	if app:checkResponseOk(isSuccess, data) then
		if data.data then
			local level = data.data.level
			local addMoney = data.data.addMoney
			local money = data.data.money
			local addProps = data.data.addProps
			if level then
                WindowManager:showWindow(WindowTag.UpgradePopu, data.data, WindowStyle.POPUP)
                MyUserData:setLevel(level)
				GameSetting:setLevel(level)
				GameSetting:save()
			end
			MyUserData:addMoney(tonumber(addMoney) or 0)
			AnimationParticles.play(AnimationParticles.DropCoin)
			kEffectPlayer:play('audio_get_gold')
		end
	end
end

function CommonPhpProcesser:onGetDuijiangReward(isSuccess, data)
	if isSuccess and data then
		if data.code == 1 then
			if data.data then
				local addMoney = data.data.addMoney
				if addMoney and type(addMoney) == 'number' then
					EventDispatcher.getInstance():dispatch(Event.Message, "showAddMoneyAnim", addMoney)

                    AlarmTip.play(data.data.msg)      
				end
				local money = data.data.money;
				if money then
					MyUserData:setMoney(money);
				end
				--金币雨动画
				AnimationParticles.play(AnimationParticles.DropCoin)
                
				kEffectPlayer:play('audio_get_gold')
			end
        elseif data.code == -4 then
            AlarmTip.play(STR_EXCHANGECODE_NO_REMAIN)
        elseif data.code == -1 then
            AlarmTip.play(STR_EXCHANGECODE_HAS_DONE)
		else
			AlarmTip.play(STR_CODE_ERROR)
		end
	end
end

function CommonPhpProcesser:onGetMyProsInfo(isSuccess, data)
	if isSuccess and data then
		if data.code == 1 then
			if data.data then
				local addMoney = data.data.addMoney
				if addMoney and type(addMoney) == 'number' then
					EventDispatcher.getInstance():dispatch(Event.Message, "showAddMoneyAnim", addMoney)
				end
			end
		else
			--AlarmTip.play(STR_CODE_ERROR)
		end
	end
end
--[[{"code":1,"codemsg":"",
	"data":{"mid":10909,"name":"hehe2222","micon":"","money":220000,"level":1,"msex":"0","exp":1,"wintimes":0,"losetimes":0,
	"maxmoney":"100000","maxwmoney":"0"},"time":1446601212,"exetime":1446601212.2646}]]
--[[zyh
function CommonPhpProcesser:onGetGameInfo(isSuccess, data)
	if isSuccess and data then
		if data.code == 1 and data.data then
			EventDispatcher.getInstance():dispatch(Event.Message, "updateUserGameinfo", data.data)
		end
	end
end
--]]
--修改性别
function CommonPhpProcesser:onUpdateUserSex(isSuccess, data)
	if isSuccess and data then
		if data.code and data.code == 1 then
			AlarmTip.play(STR_UPDATE_SEX_SUCC)
		end
	end
end

--修改昵称
function CommonPhpProcesser:onUpdateUserName(isSuccess, data)
	if isSuccess and data then
		if data.code and data.code == 1 then
			AlarmTip.play(STR_UPDATE_NAME_SUCC)
		end
	end
end

--[[11-03 22:07:41.954: D/lua(10150): requestUrl ===========>> http://gamehall.oa.com/api/gateway.php?sid=102&lid=2
11-03 22:07:41.954: D/lua(10150): resultStr  ===========>> {"code":1,"codemsg":"","data":{"micon":"http:\/\/bycdn5-i.akamaihd.net\/images\/androidtl\/icon\/92\/10092-1446559660.png"},"time":1446559661,"exetime":1446559661.0198}
]]
function CommonPhpProcesser:onUpdateUserIcon(isSuccess, data)
	JLog.d("CommonPhpProcesser:onUpdateUserIcon", isSuccess, data)
	if isSuccess and data then
		if data.code == 1 and data.data then
			-- 头像
			MyUserData:setHeadUrl(data.data.micon)
			EventDispatcher.getInstance():dispatch(Event.Message, "updateUserInfo", '')
			AlarmTip.play(STR_UPDATE_HEADER_SUCC)
		end
	end
end

function CommonPhpProcesser:onUpdateMemberBest(isSuccess, data)
printInfo("")
    --更新个人的最高资产和最高奖励
    if app:checkResponseOk(isSuccess, data) then
        if data.data.maxmoney then
            MyUserData:setMaxMoney(tonumber(data.data.maxmoney) or 0)
        end
        if data.data.maxwmoney then
            MyUserData:setMaxwMoney(tonumber(data.data.maxwmoney) or 0)
        end
    end
end

function CommonPhpProcesser:onInviteConfig(isSuccess, data)
	if isSuccess and data then
		if data.code == 1 and data.data then
			HallConfig:setInvitesum(data.data.sum and data.data.sum or 100)
			HallConfig:setInvitemoney(data.data.invitemoney and data.data.invitemoney or 500)
			HallConfig:setSuccessmoney(data.data.successmoney and data.data.successmoney or 1000)
		end
	end
end

function CommonPhpProcesser:onGetRoomList( isSuccess, data )
	-- writeTabToLog(data,"房间列表","debug_common.lua")
	dump(data)
	if app:checkResponseOk(isSuccess, data) then
		local gameId = data.data.gameId
		if gameId then
			local roomList = MyRoomConfig:get(gameId) or new(require('app.data.dataList'))
			--先清除
			roomList:clear()
			--初始化
			local info = data.data;
			
			for i = 1, #info.room do
				local room = setProxy(new(require('app.data.room')))
				room:init(info.room[i]);
				roomList:add(room);
			end
			roomList:setVersion(info.configVersion);
			MyRoomConfig:set(gameId, roomList)
			local game = app:getGame(gameId)
			if game then
				JLog.d("测试 存在",gameId);
				game:initRoom(roomList)
			else
				JLog.d("测试 不存在",gameId);
			end
		end
	end
end

function CommonPhpProcesser:onUrgentNotice(isSuccess, data)
--紧急公告查看的是个人消息的内容，检查一下用来计算是否有新消息以确定大厅按钮上是否需要显示红点
    local textUrgentNotice = {}
    if app:checkResponseOk(isSuccess, data) then
        if GameSetting:getLoginType() == UserType.Visitor then
            if #data.data > GameSetting:getTotalNoticeNumGuest() then
                GameSetting:setTotalNoticeNumGuest(#data.data)
                MyUserData:setHasNewNotice(true)
            end
        else
            if #data.data > GameSetting:getTotalNoticeNumFb() then
                GameSetting:setTotalNoticeNumFb(#data.data)
                MyUserData:setHasNewNotice(true)
            end
        end
        HallConfig:setHasUnckeckMsg(HallConfig:getHasUnckeckMsg() or HallConfig:getHasNewNotice())

        --处理需要弹窗的消息
        local messages = data.data 
        for i = 1, #messages do
            if (tonumber(messages[i].popup) == 1) and (tonumber(messages[i].islook) == 0)then
            --if (tonumber(messages[i].popup) == 1) then
                local urgentNotice = {}
                urgentNotice.id = messages[i].id and tonumber(messages[i].id) or 0
                urgentNotice.title = messages[i].title or ""
                urgentNotice.content = messages[i].content or ""
                urgentNotice.reward = tonumber(messages[i].reward) or 0
                urgentNotice.getway = tonumber(messages[i].getway) or 0
                textUrgentNotice[#textUrgentNotice+1] = urgentNotice
           end
        end
    end
    if #textUrgentNotice ~= 0 then
        WindowManager:showWindow(WindowTag.UrgentNoticePopu, textUrgentNotice, WindowStyle.POPUP)
    elseif MyUserData.dailyReward then
        WindowManager:showWindow(MyUserData.dailyReward.rewardType, MyUserData.dailyReward.rewardData, WindowStyle.POPUP)
        MyUserData.dailyReward = nil
    end
end


function CommonPhpProcesser:onCheckSwitchForAll(isSuccess, data)
    if app:checkResponseOk(isSuccess, data) then
        MySwitchData:init(data.data)
    end
end

function CommonPhpProcesser:onGetPayPropList(isSuccess, data)
	-- writeTabToLog(data,"payPropList","debug_common.lua")
	-- local isSuccess = true
	-- local str = '{"code":1,"codemsg":"","data":[{"id":203698,"sid":7,"appid":1515,"pmode":12,"pamount":29,"discount":1,"pcoins":0,"pchips":0,"pcard":5000,"ptype":2,"pnum":16,"getname":"\u0e0a\u0e49\u0e32\u0e07\u0e19\u0e49\u0e2d\u0e22 16 \u0e27\u0e31\u0e19","currency":"THB","bid":0,"productid":0,"version":0,"extrasend":0,"desc":"","datastream":0,"sendstarttime":"","sendendtime":""},{"id":203699,"sid":7,"appid":1515,"pmode":12,"pamount":49,"discount":1,"pcoins":0,"pchips":0,"pcard":5000,"ptype":2,"pnum":26,"getname":"\u0e0a\u0e49\u0e32\u0e07\u0e19\u0e49\u0e2d\u0e22 26 \u0e27\u0e31\u0e19","currency":"THB","bid":0,"productid":0,"version":0,"extrasend":0,"desc":"","datastream":0,"sendstarttime":"","sendendtime":""},{"id":203700,"sid":7,"appid":1515,"pmode":12,"pamount":19,"discount":1,"pcoins":0,"pchips":0,"pcard":6000,"ptype":2,"pnum":16,"getname":"\u0e04\u0e34\u0e07\u0e42\u0e1a\u0e22\u0e48\u0e32 16 \u0e27\u0e31\u0e19","currency":"THB","bid":0,"productid":0,"version":0,"extrasend":0,"desc":"","datastream":0,"sendstarttime":"","sendendtime":""},{"id":203701,"sid":7,"appid":1515,"pmode":12,"pamount":49,"discount":1,"pcoins":0,"pchips":0,"pcard":6000,"ptype":2,"pnum":40,"getname":"\u0e04\u0e34\u0e07\u0e42\u0e1a\u0e22\u0e48\u0e32 40 \u0e27\u0e31\u0e19","currency":"THB","bid":0,"productid":0,"version":0,"extrasend":0,"desc":"","datastream":0,"sendstarttime":"","sendendtime":""},{"id":203702,"sid":7,"appid":1515,"pmode":12,"pamount":29,"discount":1,"pcoins":0,"pchips":0,"pcard":4000,"ptype":2,"pnum":5,"getname":"\u0e25\u0e33\u0e42\u0e1e\u0e07 5 \u0e2d\u0e31\u0e19","currency":"THB","bid":0,"productid":0,"version":0,"extrasend":0,"desc":"","datastream":0,"sendstarttime":"","sendendtime":""},{"id":203703,"sid":7,"appid":1515,"pmode":12,"pamount":49,"discount":1,"pcoins":0,"pchips":0,"pcard":4000,"ptype":2,"pnum":9,"getname":"\u0e25\u0e33\u0e42\u0e1e\u0e07 9 \u0e2d\u0e31\u0e19","currency":"THB","bid":0,"productid":0,"version":0,"extrasend":0,"desc":"","datastream":0,"sendstarttime":"","sendendtime":""},{"id":203704,"sid":7,"appid":1515,"pmode":12,"pamount":19,"discount":1,"pcoins":0,"pchips":0,"pcard":3000,"ptype":2,"pnum":1,"getname":"\u0e01\u0e32\u0e23\u0e4c\u0e14 1 \u0e43\u0e1a","currency":"THB","bid":0,"productid":0,"version":0,"extrasend":0,"desc":"","datastream":0,"sendstarttime":"","sendendtime":""},{"id":203705,"sid":7,"appid":1515,"pmode":12,"pamount":149,"discount":1,"pcoins":0,"pchips":0,"pcard":3000,"ptype":2,"pnum":9,"getname":"\u0e01\u0e32\u0e23\u0e4c\u0e14 9 \u0e43\u0e1a","currency":"THB","bid":0,"productid":0,"version":0,"extrasend":0,"desc":"","datastream":0,"sendstarttime":"","sendendtime":""},{"id":203706,"sid":7,"appid":1515,"pmode":12,"pamount":10,"discount":1,"pcoins":0,"pchips":0,"pcard":1000,"ptype":2,"pnum":20,"getname":"\u0e15\u0e31\u0e4b\u0e27\u0e0a\u0e48\u0e27\u0e22\u0e14\u0e31\u0e21\u0e21\u0e35\u0e48 20 \u0e04\u0e23\u0e31\u0e49\u0e07","currency":"THB","bid":0,"productid":0,"version":0,"extrasend":0,"desc":"","datastream":0,"sendstarttime":"","sendendtime":""},{"id":203707,"sid":7,"appid":1515,"pmode":12,"pamount":29,"discount":1,"pcoins":0,"pchips":0,"pcard":1000,"ptype":2,"pnum":60,"getname":"\u0e15\u0e31\u0e4b\u0e27\u0e0a\u0e48\u0e27\u0e22\u0e14\u0e31\u0e21\u0e21\u0e35\u0e48 60 \u0e04\u0e23\u0e31\u0e49\u0e07","currency":"THB","bid":0,"productid":0,"version":0,"extrasend":0,"desc":"","datastream":0,"sendstarttime":"","sendendtime":""},{"id":203708,"sid":7,"appid":1515,"pmode":12,"pamount":19,"discount":1,"pcoins":0,"pchips":0,"pcard":2001,"ptype":2,"pnum":32,"getname":"\u0e44\u0e2d\u0e40\u0e17\u0e21 32 \u0e04\u0e23\u0e31\u0e49\u0e07","currency":"THB","bid":0,"productid":0,"version":0,"extrasend":0,"desc":"","datastream":0,"sendstarttime":"","sendendtime":""},{"id":203709,"sid":7,"appid":1515,"pmode":12,"pamount":29,"discount":1,"pcoins":0,"pchips":0,"pcard":2001,"ptype":2,"pnum":55,"getname":"\u0e44\u0e2d\u0e40\u0e17\u0e21 55 \u0e04\u0e23\u0e31\u0e49\u0e07","currency":"THB","bid":0,"productid":0,"version":0,"extrasend":0,"desc":"","datastream":0,"sendstarttime":"","sendendtime":""}],"time":1500455563,"exetime":0.0017251968383789}'
	-- local data = json.decode(str)
	-- dump(data)
	-- isSuccess = true
	JLog.d("onGetPayPropList", isSuccess, data)
    if app:checkResponseOk(isSuccess, data) then
        local pay = new(require('app.data.pay'));
		for i = 1, #data.data do
			local d = data.data[i]
			local shop = setProxy(new(require('app.data.shop')));
			
			pay:setMode(tonumber(d.pmode or 0));
			shop:setId(tonumber(d.id or 0));
			shop:setPamount(tonumber(d.pamount or 0));
			shop:setCurrency(d.currency or "$")
			shop:setCount(tonumber(d.pnum or 0))
            shop:setDiscount(tonumber(d.discount) or 1)
            shop:setPcard(tonumber(d.pcard) or 0)
            shop:setName(d.getname or "")
            shop:setPrevchips(tonumber(d.prevchips or 0))
			shop:setPdesc(string.format('1%s=%s', shop:getCurrency(), ToolKit.skipMoney(math.floor(shop:getPchips() > 0 and shop:getPchips() / shop:getPamount() or 0))));
			pay:add(shop)
		end

		if MyPayMode then
			for i = 1, #MyPayMode do
				if MyPayMode[i]:getId() == pay:getMode() then
					MyPayMode[i]:setProp(pay)
				end
			end 
		end
    end
end

function CommonPhpProcesser:onGetDiamondPayList(isSuccess, data)
	JLog.d("onGetDiamondPayList", isSuccess, data)
	if app:checkResponseOk(isSuccess, data) then
		local pay		= new(require('app.data.pay'));
		for i = 1, #data.data do
			local d = data.data[i]
			local shop = setProxy(new(require('app.data.shop')));
			
			pay:setMode(tonumber(d.pmode or 0));
			shop:setId(tonumber(d.id or 0));
			shop:setPamount(tonumber(d.pamount or 0));
			shop:setCurrency(d.currency or "$")
			shop:setCount(tonumber(d.pnum or 0))
            shop:setDiscount(tonumber(d.discount) or 1)
            shop:setPcard(tonumber(d.pcard) or 0)
            shop:setName(d.getname or "")
            shop:setPrevchips(tonumber(d.prevchips or 0))
            shop:setPcoins(tonumber(d.pcoins or 0))
			shop:setPdesc(string.format('1%s=%s', shop:getCurrency(), ToolKit.skipMoney(math.floor(shop:getPchips() > 0 and shop:getPchips() / shop:getPamount() or 0))));
			pay:add(shop)
		end

		if MyPayMode then
			for i = 1, #MyPayMode do
				if MyPayMode[i]:getId() == pay:getMode() then
					MyPayMode[i]:setCash(pay)
				end
			end 
		end
    end
end

function CommonPhpProcesser:onGiftStoreBuy(isSuccess, data)
    if app:checkResponseOk(isSuccess, data) then
        local giftType = tonumber(data.data.giftType)
        local giftId = tonumber(data.data.giftId)
        if giftType and giftId then
            MyUserData:setGiftId({giftType, giftId})
        else
            MyUserData:setGiftId(nil)
        end
        MyUserData:setMoney(tonumber(data.data.money) or 0)
    elseif data and data.code == 4 then
        AlarmTip.play(STR_SORRY_FOR_NO_MONEY)
    end
end

function CommonPhpProcesser:onGiftStoreGetList(isSuccess, data)
dump(data)
    if app:checkResponseOk(isSuccess, data) then
        local giftList = {}
        --这个表用来记录原始数据，为了后台可以排序，在商城界面用这个数据显示，但是不好查找，所以用giftList里的数据查找。
        giftList.originalData = {}
        local gifts = data.data.giftList or {}
        for i = 1, #gifts do
            local gift = setProxy(new(require("app.data.giftItemData")))
            gift:init(gifts[i])
            --礼物按type和id做双重索引，用这个表是为了方便寻找
            local giftType = tonumber(gift.type) or 0
            if not giftList[giftType] then
                giftList[giftType] = {}
            end
            giftList[giftType][gift.id] = gift
            table.insert(giftList.originalData, gift)
        end
        MyUserData:setGiftList(giftList)
        local wearGift = data.data.wearGift or {}
        local expireTime = tonumber(wearGift.expireTime) or 0
        --礼物还没过期
        if expireTime > os.time() then
            local giftType = tonumber(wearGift.giftType)
            local giftId = tonumber(wearGift.giftId)
            if giftType and giftId then
                MyUserData:setGiftId({giftType, giftId})
            end
        end
    end

end

function CommonPhpProcesser:onGiftUpdateMine(isSuccess, data)
    if app:checkResponseOk(isSuccess, data) then
        local giftType = tonumber(data.data.giftType)
        local giftId = tonumber(data.data.giftId)
        if giftType and giftId then
            MyUserData:setGiftId({giftType, giftId})
            AlarmTip.play("更换成功")
        end
    end
end

function CommonPhpProcesser:onGiftStoreSend(isSuccess, data)
    if app:checkResponseOk(isSuccess, data) then
        MyUserData:setMoney(tonumber(data.data.money) or 0)
        AlarmTip.play("赠送成功")
    end
end

function CommonPhpProcesser:onGetUserAllProps(isSuccess, data)
	-- body
	JLog.d("初始化道具",data);
	if app:checkResponseOk(isSuccess, data) then
		for i = 1,#data.data do
			MyUserData:setPropNum(data.data[i].pnid, data.data[i].pcnter)
		end
	end
end

function CommonPhpProcesser:onGetFbCallbackReward(isSuccess, data)
	JLog.d("CommonPhpProcesser:onGetFbCallbackReward", isSuccess, data)
    if app:checkResponseOk(isSuccess, data) then
        local addMoney = tonumber(data.data.addMoney) or 0
        if addMoney > 0 then
            AlarmTip.play(string.format(Hall_string.STR_INVITE_AWARD, PhpManager:getAppname(), addMoney))
        end
        MyUserData:setMoney(tonumber(data.data.money) or 0)
        --金币雨动画
		AnimationParticles.play(AnimationParticles.DropCoin)
		kEffectPlayer:play('audio_get_gold')
    end
end

function CommonPhpProcesser:onCreateRoomConfig(isSuccess,data)
	writeTabToLog({isSuccess=isSuccess,data=data},"房间列表数据","debug_common.lua")
	if not app:checkResponseOk(isSuccess, data) then
		return
	end
	CreateRoomConfigData = CreateRoomConfigData or new(require("app.data.createConfigData"))
	JLog.d("测试gameinfo",data.data.room)
	for i=1,#data.data.room do

		local gameInfo = data.data.room[i]
		JLog.d("测试gameinfo",gameInfo)
		local createConfig = CreateRoomConfigData:getConfigByGameId(gameInfo.gameId)
		if not createConfig then
			createConfig = CreateRoomConfigData:addNew(gameInfo.gameId)
		end
		printInfo("\n\n\n\n\n\n\n\ngameInfo.gameId=%s",gameInfo.gameId)
		dump(gameInfo.config,"gameInfo.config")
		createConfig:init(gameInfo)
	end


		-- local gameId = data.data.gameid
		-- if gameId then
		-- 	local roomList = MyRoomConfig:get(gameId) or new(require('app.data.dataList'))
		-- 	--先清除
		-- 	roomList:clear()
		-- 	--初始化
		-- 	local info = data.data;
			
		-- 	for i = 1, #info.room do
		-- 		local room = setProxy(new(require('app.data.room')))
		-- 		room:init(info.room[i]);
		-- 		roomList:add(room);
		-- 	end
		-- 	roomList:setVersion(info.configVersion);
		-- 	MyRoomConfig:set(gameId, roomList)
		-- 	local game = app:getGame(gameId)
		-- 	if game then
		-- 		game:initRoom(roomList)
		-- 	end
		-- end
end

function CommonPhpProcesser:onSignInLoad(isSuccess,data)
	JLog.d("onSignInLoad", isSuccess, data)
	if not app:checkResponseOk(isSuccess,data) then
		return
	end
	if data.data.todayCanSign == 1 then
		WindowManager:showWindow(WindowTag.SignPopu, data.data, WindowStyle.POPUP)
	end
end

function CommonPhpProcesser:onSignIn(isSuccess,data)
	if not app:checkResponseOk(isSuccess,data) then
		return
	end
	MyUserData:setMoney(MyUserData:getMoney() + data.data.chips);
	--金币雨动画
	AnimationParticles.play(AnimationParticles.DropCoin)
	kEffectPlayer:play('audio_get_gold')
end


function CommonPhpProcesser:onGetPropCfgList(isSuccess, data)
	-- local str = '{"code":1,"codemsg":null,"data":[{"pnid":"1000","name":"\u0e15\u0e31\u0e4b\u0e27\u0e0a\u0e48\u0e27\u0e22\u0e14\u0e31\u0e21\u0e21\u0e35\u0e48","image":"https:\/\/mvlptldt01-static.akamaized.net\/images\/tl\/props\/1000.png","keyName":"tips"},{"pnid":"2001","name":"\u0e44\u0e2d\u0e40\u0e17\u0e21","image":"https:\/\/mvlptldt01-static.akamaized.net\/images\/tl\/props\/2001.png","keyName":"interProps"},{"pnid":"3000","name":"\u0e01\u0e32\u0e23\u0e4c\u0e14","image":"https:\/\/mvlptldt01-static.akamaized.net\/images\/tl\/props\/3000.png","keyName":"privateRoomCard"},{"pnid":"4000","name":"\u0e25\u0e33\u0e42\u0e1e\u0e07","image":"http:\/\/mvlptldt01-static.akamaized.net\/images\/tl\/props\/speaker.png","keyName":"speakers"},{"pnid":"5000","name":"\u0e0a\u0e49\u0e32\u0e07\u0e19\u0e49\u0e2d\u0e22","image":"http:\/\/mvlptldt01-static.akamaized.net\/images\/tl\/props\/elephant.png","keyName":"elephant"},{"pnid":"6000","name":"\u0e04\u0e34\u0e07\u0e42\u0e1a\u0e22\u0e48\u0e32","image":"http:\/\/mvlptldt01-static.akamaized.net\/images\/tl\/props\/King.png","keyName":"King"},{"pnid":"7000","name":"\u0e15\u0e31\u0e4b\u0e27\u0e0a\u0e34\u0e07\u0e41\u0e0a\u0e21\u0e1b\u0e4c","image":"http:\/\/mvlptldt01-static.akamaized.net\/images\/tl\/props\/mahaTickets.png","keyName":"mahaTickets"}],"time":1500533197,"exetime":0.00013995170593262}'
	-- local data = json.decode(str)
	-- isSuccess = true
	JLog.d("CommonPhpProcesser:onGetPropCfgList", isSuccess, data)
	if app:checkResponseOk(isSuccess, data) then
		local propList = {}
		local lists = data.data or {}
		for i = 1, #lists do
			local prop = setProxy(new(require("app.data.propsCfgData")))
			prop:init(lists[i])
			propList[tostring(lists[i].pnid)] = prop
		end
		MyUserData.propCfgList = propList
	end
end

function CommonPhpProcesser:onGetHallMsgData(isSucc, data)
	-- body
	-- dump(data, "CommonPhpProcesser:onGetHallMsgData(isSucc :" .. tostring(isSucc) .. ").data :================")
	if app:checkResponseOk(isSucc, data) then
		--todo
		if MyUserData:getUserType() == UserType.Visitor then
			if #data.data > GameSetting:getTotalNoticeNumGuest() then
				GameSetting:setTotalNoticeNumGuest(#data.data)
				HallConfig:setHasNewNotice(true)
			end
		else
			if #data.data > GameSetting:getTotalNoticeNumFb() then
				GameSetting:setTotalNoticeNumFb(#data.data)
				HallConfig:setHasNewNotice(true)
			end
		end
		HallConfig:setHasUnckeckMsg(MyUserData:getHasUnckeckMsg() or MyUserData:getHasNewNotice())

		local messages = data.data
		local msgContDataList = {}

		local isNewUnCheckMsg = false
		local msgContPopu = require("app.popu.lobby.MessageContPopu")
		for i = 1, #messages do
			if tonumber(messages[i].islook) == 0 then
				--todo
				isNewUnCheckMsg = true

				if tonumber(messages[i].popup) == 1 then
					--todo
					local msgContData = {}
					msgContData.msgType = msgContPopu.MSGTYPE_ANNOUNCE
					msgContData.id = messages[i].id and tonumber(messages[i].id) or 0
					msgContData.title = messages[i].title or ""
					msgContData.content = messages[i].content or ""
					msgContData.reward = tonumber(messages[i].reward) or 0
					-- msgContData.getway = tonumber(messages[i].getway) or 0
					-- if msgContData.reward > 0 then
					-- 	--todo
					-- 	msgContData.dtorActionCallBack = function()
					-- 		-- body
					-- 		AnimationParticles.play(AnimationParticles.DropCoin)
					-- 		kEffectPlayer:play("audio_get_gold")
					-- 	end
					-- end

					-- table.insert(msgContDataList, msgContData)
					msgContDataList[#msgContDataList + 1] = msgContData
				end
			end
		end

		MyUserData:setHasUnckeckMsg(isNewUnCheckMsg)

		for i = 1, #msgContDataList do

			msgContDataList[i].confrimActionCallBack = function()
				-- body

				if msgContDataList[i].reward > 0 then
					--todo
					HttpModule.getInstance():execute(HttpModule.s_cmds.GET_HALL_USER_NOTICES_AWARD, {nid = msgContDataList[i].id}, false, false)
				else
					HttpModule.getInstance():execute(HttpModule.s_cmds.GET_HALL_USER_NOTICES_READED, {id = msgContDataList[i].id}, false, false)
				end

				if msgContDataList[i + 1] then
					--todo
					WindowManager:showWindow(WindowTag.MsgContPopu, msgContDataList[i + 1], WindowStyle.POPUP)
				end
			end
		end

		-- dump(msgContDataList, "CommonPhpProcesser:onGetHallMsgData.msgContDataList :===============")

		if #msgContDataList > 0 then
			--todo
			WindowManager:showWindow(WindowTag.MsgContPopu, msgContDataList[1], WindowStyle.POPUP)
		end

	-- MyUserData.textUrgentNotice = nil
	-- if MyUserData.dailyReward and MyUserData.dailyReward.rewardType == WindowTag.RegisterRewardPopu then
	-- 	WindowManager:showWindow(MyUserData.dailyReward.rewardType, MyUserData.dailyReward.rewardData, WindowStyle.POPUP)
	-- 	MyUserData.dailyReward = nil
	-- else
	-- 	if #textUrgentNotice ~= 0 then
	-- 		MyUserData.textUrgentNotice = textUrgentNotice
	-- 		WindowManager:showWindow(WindowTag.ActCenterPopu, 1, WindowStyle.POPUP)
	-- 	elseif MyUserData.hasSpectialAct == 1 then
	-- 		WindowManager:showWindow(WindowTag.ActCenterPopu, 0, WindowStyle.POPUP)
	-- 	elseif MyUserData.dailyReward and MyUserData.dailyReward.rewardType == WindowTag.AttendencePopu then
	-- 		WindowManager:showWindow(WindowTag.ActCenterPopu, 3, WindowStyle.POPUP)
	-- 	end
	-- end
	else
		printInfo("Get Data @index[HttpModule.s_cmds.GET_URGENT_NOTICE] Failed!")
	end
end

function CommonPhpProcesser:onUpdateUserInfo(isSuccess,data)
	-- JLog.d("CommonPhpProcesser:onUpdateUserInfo(isSuccess :" .. tostring(isSuccess) .. ").data :=============", data)
	if app:checkResponseOk(isSuccess, data) then
		--todo
		MyUserData:setNick(data.data.name or "Unknow")
		MyUserData:setSex(tonumber(data.data.msex or 2))
	end
end
function CommonPhpProcesser:onAddFriend(isSuccess,data)
	if app:checkResponseOk(isSuccess, data) then
		AlarmTip.play(Hall_string.STR_FRIEND_SEND_APPLY_SUC);
	else
		if isSuccess and data.code == -3 then
			AlarmTip.play(Hall_string.STR_FRIEND_SEND_APPLY_ALREADY);
		else
			AlarmTip.play(Hall_string.STR_FRIEND_SEND_APPLY_FAILD);
		end
	end
end

function CommonPhpProcesser:onInitOldFriendToPlayCfg(isSuccess, data)
	if isSuccess and data then
		if data.code == 1 and data.data then
			HallConfig:setPerReward(data.data.perReward and data.data.perReward or 100)
			HallConfig:setPerRewardMsg(data.data.msg and data.data.msg or "")
		end
	end
end

function CommonPhpProcesser:onSendSpeaker(isSuccess, data)
	if app:checkResponseOk(isSuccess, data) then
		MyUserData:setPropNum(kIDSpeaker, tonumber(data.data.pcnter))
	else
		AlarmTip.play(data and data.codemsg or "")
		--发送小喇叭的时候已经加进去了，发送失败就要把它删掉
		local record = MyUserData:getSpeakerRecord()
		table.remove(record, #record)
	end
end
--[[
	通用的（大厅）协议
]]
CommonPhpProcesser.s_severCmdEventFuncMap = {

}
--HTTP 回调
CommonPhpProcesser.s_httpEventFuncMap = {
	[HttpModule.s_cmds.LOGIN_PHP]				= CommonPhpProcesser.onLoginPhpResponse,
	[HttpModule.s_cmds.GET_FB_INVITE_AWARD]		= CommonPhpProcesser.onGetFbInviteAwardResponse,
	[HttpModule.s_cmds.GET_FB_INVITE_SUC_AWARD] = CommonPhpProcesser.onGetFbInviteSucAwardResponse,
	[HttpModule.s_cmds.GET_BROKEN_MONEY] 		= CommonPhpProcesser.onGetBrokenMoneyResponse,
	[HttpModule.s_cmds.GET_PAY_MODE] 			= CommonPhpProcesser.onPayModeResponse,
	[HttpModule.s_cmds.GET_PAY_LIST] 			= CommonPhpProcesser.onPayListResponse,
	[HttpModule.s_cmds.GET_PAY_ORDER] 			= CommonPhpProcesser.onPayOrderResponse,

   	[HttpModule.s_cmds.GET_SEND_PROP] 		    = CommonPhpProcesser.onSendProp,
	[HttpModule.s_cmds.GET_MY_PROP_LIST]					= CommonPhpProcesser.onGetPropList,

	[HttpModule.s_cmds.GET_HALL_BANKRUPT]		= CommonPhpProcesser.onGetHallBankrupt,
    [HttpModule.s_cmds.GET_SEND_GAME_CHIP]      = CommonPhpProcesser.onSendChip,
    [HttpModule.s_cmds.GET_HALL_USER_NOTICES_AWARD] = CommonPhpProcesser.onHallUserNoticeAward,
    [HttpModule.s_cmds.GET_GAMEMSG_REW] = CommonPhpProcesser.onHallGameNoticeAward,
	-- [HttpModule.s_cmds.GET_HALL_BANKRUPT_TAG]   = CommonPhpProcesser.onGetBankruptTag,
    [HttpModule.s_cmds.GET_UPGRADE_REWARD]      = CommonPhpProcesser.onGetUpgradeReward,
    [HttpModule.s_cmds.GET_DUIJIANG_REWARD]		= CommonPhpProcesser.onGetDuijiangReward,

    [HttpModule.s_cmds.UPDATE_USER_SEX]         = CommonPhpProcesser.onUpdateUserSex,
    [HttpModule.s_cmds.UPDATE_USER_NAME]        = CommonPhpProcesser.onUpdateUserName,
    [HttpModule.s_cmds.UPDATE_USER_ICON]		= CommonPhpProcesser.onUpdateUserIcon,
    [HttpModule.s_cmds.UPDATE_MEMBER_BEST]      = CommonPhpProcesser.onUpdateMemberBest,
    [HttpModule.s_cmds.INVITE_CONFIG]			= CommonPhpProcesser.onInviteConfig,
    [HttpModule.s_cmds.GIVING_TIPS]				= CommonPhpProcesser.onGivingTips,
    [HttpModule.s_cmds.HAS_TASK_AWARD]			= CommonPhpProcesser.onHasTaskAward,
    [HttpModule.s_cmds.GET_ROOM_LIST] 			= CommonPhpProcesser.onGetRoomList,

    [HttpModule.s_cmds.CHECK_SWITCH_FOR_ALL]    = CommonPhpProcesser.onCheckSwitchForAll,
    [HttpModule.s_cmds.GET_PAY_PROP_LIST]       = CommonPhpProcesser.onGetPayPropList,
    [HttpModule.s_cmds.GIFT_STORE_BUY]          = CommonPhpProcesser.onGiftStoreBuy,
    [HttpModule.s_cmds.GIFT_STORE_GET_LIST]     = CommonPhpProcesser.onGiftStoreGetList,
    [HttpModule.s_cmds.GIFT_UPDATE_MINE]        = CommonPhpProcesser.onGiftUpdateMine,
    [HttpModule.s_cmds.GIFT_STORE_SEND]         = CommonPhpProcesser.onGiftStoreSend,
    [HttpModule.s_cmds.GET_USER_ALL_PROPS]      = CommonPhpProcesser.onGetUserAllProps,
    [HttpModule.s_cmds.GET_FB_CALLBACK_REWARD]  = CommonPhpProcesser.onGetFbCallbackReward,

    --=============================================================================
    [HttpModule.s_cmds.create_room_config] 		= CommonPhpProcesser.onCreateRoomConfig,
    [HttpModule.s_cmds.SIGN_IN_LOAD] 		= CommonPhpProcesser.onSignInLoad,
    [HttpModule.s_cmds.SIGN_IN]					= CommonPhpProcesser.onSignIn,
    [HttpModule.s_cmds.PERINFO_UPDATE_USERIINFO]= CommonPhpProcesser.onUpdateUserInfo,
    [HttpModule.s_cmds.GET_PROP_CFG_LIST]       = CommonPhpProcesser.onGetPropCfgList,
    [HttpModule.s_cmds.GET_URGENT_NOTICE] = CommonPhpProcesser.onGetHallMsgData,

	[HttpModule.s_cmds.ADD_FRIEND]       = CommonPhpProcesser.onAddFriend,
	[HttpModule.s_cmds.Friend_INIT_OLD_FRIEND_TO_PLAY_CFG] = CommonPhpProcesser.onInitOldFriendToPlayCfg,
	[HttpModule.s_cmds.Payment_getDiamondPayList] = CommonPhpProcesser.onGetDiamondPayList,
	[HttpModule.s_cmds.SEND_SPEAKER]      = CommonPhpProcesser.onSendSpeaker,

}
return CommonPhpProcesser
