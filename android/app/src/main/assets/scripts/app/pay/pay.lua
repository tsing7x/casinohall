local Pay = {}


--文档在这里 http://god.oa.com/wiki/index.php?title=%E6%94%AF%E4%BB%98%E7%B3%BB%E7%BB%9F%E6%8E%A5%E5%8F%A3#BluePay.28JMT.29.E6.94.AF.E4.BB.98

function Pay:ctor()
    -- body
    EventDispatcher.getInstance():register(HttpModule.s_event, self, self.onHttpResponse);
end

function Pay:dtor()
	-- body
	EventDispatcher.getInstance():unregister(HttpModule.s_event, self, self.onHttpResponse);
end

--将所有下单的数据整理到这个接口下，避免下单的参数变更，方便修改
function Pay:payOrder(pmode, shop, imgFile)
    JLog.d("Pay:payOrder", pmode, shop)
    --JMT和E2P支付需要短信权限
    if pmode == kAndroidJMT or pmode == kAndroidE2p then
        if NativeEvent.getInstance():getPermission({permission = "sms"}) ~= "success" then
            AlarmTip.play(STR_PERMISSION_NO_SMS)
        end
    end
    if pmode == kAndroidJMT or  pmode == kIOSJMT then --(240 安卓的bluePay 741 IOS bluePay)
        local content = shop:getName()
        if shop:getExtra() > 0 then
            content = content.."+"..shop:getExtra()
        end
        WindowManager:showWindow(WindowTag.ShopBuyConfirmPopu, {
            title = STR_JMT_BUY_CONFIRM,
            content = content,
            confirm = STR_EXIT_GAME_CONFIRM,
            imgIcon = imgFile,
            confirmFunc = function()
                AlarmTip.play(STR_CREATING_ORDER);
		        HttpModule.getInstance():execute(HttpModule.s_cmds.GET_PAY_ORDER, {id=shop:getId(),pmode = pmode, sitemid = MyUserData:getSiteId(), mid = MyUserData:getId()}, true, true);
            end,
        }, WindowStyle.POPUP)
    elseif pmode == kIOSE2p  or pmode == kAndroidE2p  or pmode == kAndroidLinePay or pmode == kIOSLinePay then
        local params = {
            id=shop:getId(),
            pmode = pmode,
            sitemid = MyUserData:getSiteId(),
            uid = MyUserData:getId(),
            mid = MyUserData:getId(),
            channel = 'psms',
        }
        local content = shop:getName()
        if shop:getExtra() > 0 then
            content = content.."+"..shop:getExtra()
        end
        WindowManager:showWindow(WindowTag.ShopBuyConfirmPopu, {
            title = STR_JMT_BUY_CONFIRM,
            content = content,
            confirm = STR_EXIT_GAME_CONFIRM,
            imgIcon = imgFile,
            confirmFunc = function()
                AlarmTip.play(STR_CREATING_ORDER);
                HttpModule.getInstance():execute(HttpModule.s_cmds.GET_PAY_ORDER, params, true, true);
            end,
        }, WindowStyle.POPUP)
    elseif pmode == kIOS12call then
        local data = {
            pmode = tostring(pmode),
            mid = tostring(MyUserData:getId()),
            channel = '12call',
            id =  shop:getId(),--商品ID
            sitemid =  MyUserData:getSiteId(),
            pin_no = nil,
            sid =  PhpManager:getGame(),
            lid = '',
        }
        MyPay:callPay_IOS(data); 
    elseif pmode == kIOSTureMoney then
        local data = {
            pmode = tostring(pmode),
            username = tostring(MyUserData:getId()),
            channel = 'truemoney',
            id =  shop:getId(),--商品ID
            sitemid =  MyUserData:getSiteId(),
            cardno = nil,
            sid =  PhpManager:getGame(),
            lid = '',
        }
        MyPay:callPay_IOS(data);   
    elseif pmode == kAndroidMolTrueMoney  then
        local data = {
            pmode = tostring(pmode),
            username = tostring(MyUserData:getId()),
            id = shop:getId(),--商品ID
            sitemid =  MyUserData:getSiteId(),
            pin_no = nil,
            sid =  PhpManager:getGame(),
            lid = '',
        }
        WindowManager:showWindow(WindowTag.ShopPinNoEdit, {
        title  = "TRUEMONEY",
        cancel = STR_EXIT_GAME_CANCEL,
        confirm = STR_EXIT_GAME_CONFIRM,
        placeHolder = STR_PAY_INPUTCARDNO,
        confirmFunc = function(pinNo)
            print_string(json.encode(data))
            print_string("trueMoney")
            data.pin_no = pinNo
            AlarmTip.play(STR_CREATING_ORDER)
            HttpModule.getInstance():execute(HttpModule.s_cmds.GET_PAY_ORDER, data, true, true)
        end,
        }, WindowStyle.POPUP)
    elseif pmode == kAndroid12Call or pmode == kAndroidTrueMoney then
        AlarmTip.play(STR_CREATING_ORDER);
        HttpModule.getInstance():execute(HttpModule.s_cmds.GET_PAY_ORDER, {id=shop:getId(),pmode = pmode ,sitemid = MyUserData:getSiteId(), mid = MyUserData:getId()}, true, true);
    else
        AlarmTip.play(STR_CREATING_ORDER);
        HttpModule.getInstance():execute(HttpModule.s_cmds.GET_PAY_ORDER, {id=shop:getId(),pmode = pmode, sitemid = MyUserData:getSiteId(), mid = MyUserData:getId()}, true, true);
    end
end

function Pay:pay(pmode, data)
    local pmode = tonumber(pmode or 0)
    if Pay.s_pmode2Pay[pmode] then
        Pay.s_pmode2Pay[pmode](self, pmode, data);
    end
end

--登录时回调
function Pay:logincb()
	-- 检查未完成订单
	NativeEvent.getInstance():checkUnfinishIAP()
end

function Pay:jmtPay(pmode, data)

	-- transactionId	String	Y	订单ID,保证用户付费成功	为本次的支付订单号， 最大长度 20 位字符
	-- currency	String	N	货币单位	货币单位，注:填写标准ISO_4217
	-- 泰铢为”THB”，默认为泰铢

	-- price	int	Y	价格	为本次支付的金额(单位为泰铢)
	-- smsId	int	Y	商品关联的短信内容	与商品关联，有需要时指定的下发短信记录,不需要特殊指定填0,如果需要特殊设定下发短信,比如:特殊的客服联系方式等,请联系BluePay管理员获取详情.一般情况下商务会向BluePay申请分配
	-- propsName	String	Y	道具名称	产生效果:
	-- 1.填写:用户下发道具提示短信中加载道具名称.
	-- 2.不填写:用户下发道具将没有道具名称.

	-- isShowDialog	boolean	N	sms计费时是否显示loading条	不设置的话默认为true
	-- 1.true: 将会在计费开始显示系统LOADING条,直到确认是否付费成功或失败,持续时间最长1分钟
	-- 2.False:不显示loading框
	-- 注意:当满足条件(isShowDialog == true && price==0)时,将会调用ref文件中的price参数列表做为付费列表

	-- pmode	String	Y	支付渠道号	在支付中心申请的支付渠道号，BluePay的pmode为240

	-- printInfo("Pay:jmtPay = "..pmode);

    --{"code":1,"codemsg":"","data":{"X-RET":200,"X-MSG":"SUCC","RET":0,"MSG":"SUCC","PID":"2461180568","ORDER":"000715470240BYORDFLG002461180568","SID":"7","APPID":"1547","SITEMID":"861006036589310","MID":"3859793","PMODE":240,"PAMOUNT":"19","ITEMID":"142215","PAYCONFID":"142215","PAMOUNT_UNIT":"THB","PAMOUNT_RATE":"0.0278433","PAMOUNT_USD":0.53,"productid":"142215"},"time":1478155986,"exetime":0.46681809425354}

    local pay = nil
    if pmode == kAndroidJMT then
        pay = {	transactionId 	= data.ORDER, 
                currency 		= data.PAMOUNT_UNIT,
                price 			= tonumber(data.PAMOUNT or 0),
                smsId 			= 0,
                propsName 		= data.productid,
                pmode 			= tostring(pmode),
				}
    elseif pmode == kIOSJMT then
        pay = {	transactionId 	= data.ORDER, 
                currency 		= data.PAMOUNT_UNIT,
                price 			= tonumber(data.PAMOUNT or 0),
                smsId 			= 0,
                propsName 		= data.productid,
                pmode 			= tostring(pmode)
				}
    end
    NativeEvent:getInstance():pay(pay);
end


function Pay:iosPay(pmode,data)
	printInfo('iosPay')
	data.productid = (PhpManager:getPackageName() or "com.boyaa.hallgame") .. data.productid

	-- 是否沙箱测试订单
	local isSandbox = false

	local pay = {
					productId 		= tostring(data.productid or ""), 
					orderId 		= tostring(data.ORDER or ""),
					pmode 			= tostring(pmode),
					ORDER           = tostring(data.ORDER or ""),
					sandbox         = (isSandbox and "ture" or "false")
				}

	NativeEvent:getInstance():pay(pay);
end

function Pay:googlePay(pmode, data)
	--{"code":1,"codemsg":"","data":{"ORDER":"000713320240BYORDFLG002224938428","SID":"7","APPID":"1332","PMODE":"240","PAMOUNT":"29","PCOINS":"0","PCHIPS":"1722600","PCARD":"0","PNUM":"1","PAYCONFID":123802,"CURRENCY":"THB","DESC":"{\"url1\":\"\",\"url2\":\"\",\"desc\":\"\"}","RET":0,"MSG":"succ","SITEMID":"06DCB1D14E41BBD34FBC6D141F2E5122dddd","user_ip":"172.20.42.146","macid":""},"time":1442902863,"exetime":1442902863.9888}
	-- productId	String	Y	产品ID	购买的产品ID
	-- orderId		String	Y	订单Id，用于查询订单	为本次的支付订单号

    printInfo("Pay:googlePay = "..pmode);

    local pay = {
        productId 		= tostring(data.productid or ""), 
        orderId 		= tostring(data.ORDER or ""),
        pmode 			= tostring(pmode)
    }
    self.checkoutproductId = data.productid
    NativeEvent:getInstance():pay(pay);
end

function Pay:callPay(pmode, data)
    printInfo('callPay')
	--{"code":1,"codemsg":"","data":{"ORDER":"000713320240BYORDFLG002224938428","SID":"7","APPID":"1332","PMODE":"240","PAMOUNT":"29","PCOINS":"0","PCHIPS":"1722600","PCARD":"0","PNUM":"1","PAYCONFID":123802,"CURRENCY":"THB","DESC":"{\"url1\":\"\",\"url2\":\"\",\"desc\":\"\"}","RET":0,"MSG":"succ","SITEMID":"06DCB1D14E41BBD34FBC6D141F2E5122dddd","user_ip":"172.20.42.146","macid":""},"time":1442902863,"exetime":1442902863.9888}

	--{"code":1,"codemsg":"","data":{"ORDER":"000713320240BYORDFLG002224938428","SID":"7","APPID":"1332","PMODE":"240","PAMOUNT":"29","PCOINS":"0","PCHIPS":"1722600","PCARD":"0","PNUM":"1","PAYCONFID":123802,"CURRENCY":"THB","DESC":"{\"url1\":\"\",\"url2\":\"\",\"desc\":\"\"}","RET":0,"MSG":"succ","SITEMID":"06DCB1D14E41BBD34FBC6D141F2E5122dddd","user_ip":"172.20.42.146","macid":""},"time":1442902863,"exetime":1442902863.9888}

	-- 	customId	String	Y	用户ID,用于支付卡的支付,保证用户唯一即可	注:限定40位字符生成办法:
	-- 1.在网游中.可以使用游戏ID.或者生成UUID 2.在单机中.可以直接使用UUID的转化

	-- transactionId	String	Y	订单ID,保证用户付费成功	为本次的支付订单号(向支付中心下单时生成)， 最大长度 20 位字符
	-- SerialNo	String	N	越南等地的支付卡需要填入的值	越南支付必须填写
	-- Publisher	String	Y	卡类型, 如:trueMoney, 12call	12Call的方式:PublisherCode.PUBLISHER_12CALL（定义在BluePay的API里，其值为"12call"）
	-- TrueMoney的方式: PublisherCode.PUBLISHER_TRUEMONEY（定义在BluePay的API里，其值为"truemoney"） viettel的方式: PublisherCode.PUBLISHER_VIETTEL vinafone的方式: PublisherCode.PUBLISHER_VINAPHONE mobifone的方式: PublisherCode.PUBLISHER_MOBIFONE Unipin的方式：PublisherCode.PUBLISHER_UNIPIN VTCPay的方式： PublisherCode.PUBLISHER_VTC;

	-- CardNo	String	N	12Call, TrueMoney两种支付卡的PIN码	填写好: 不显示BluePay SDK的UI，未填写或空字符串: 将会弹出BluePay SDK的UI框(在UI框中要求用户输入PIN码).
	-- propsName	String	Y	道具名称	产生效果:
	-- 1.填写:用户下发道具提示短信中加载道具名称.
	-- 2.不填写:用户下发道具将没有道具名称.

	-- isShowDialog	boolean	N	使用支付卡的情况下，确定进度条是否显示	不设置的话默认为false
	-- 设置true： 在用户确认支付后, 会显示LOADING进度条,结果返回时取消显示； 设置false ： 不显示进度条。

	-- pmode	String	Y	支付渠道号	在支付中心申请的支付渠道号，支持JMT(pmode=240)、12call(pmode=645)和truemoney(pmode=646)

    local pay = {
        customId 		= data.ORDER,
        transactionId 	= data.ORDER, 
        propsName 		= data.ORDER,
        pmode 			= tostring(pmode),
        isShowDialog 	= true
    }

    NativeEvent:getInstance():pay(pay);
end
function Pay:callPay_IOS(data)

    NativeEvent:getInstance():pay(data);
end
function Pay:linePay_android(pmode, data)
    print("linePay_android",pmode)
    local pay ={
        pmode = tostring(pmode),
        url = data.URL
    }
    NativeEvent:getInstance():pay(pay);
end
function Pay:linePay_IOS(pmode, data)
    print("linePay_IOS",pmode)
    local pay ={
        pmode = tostring(pmode),
        URL = data.URL
    }
    GameSetting.userPayMode = "iosLinePay"
    NativeEvent:getInstance():pay(pay);
end

function Pay:e2p_IOS(pmode, data)
    print("e2p_IOS",pmode)
    local pay ={
        pmode = tostring(pmode),
        URL = data.URL
    }
    NativeEvent:getInstance():pay(pay);
end

function Pay:molTrueMoenyPay(pmode, data)
    local code = tonumber(data.RET) 
    local content = nil
    if code == 0 then
        content = STR_PAY_SUC
    else
        content =STR_PAY_FAILED
    end
    WindowManager:showWindow(WindowTag.LobbyConfirmPopu, {
        content = content,
        confirm = STR_EXIT_GAME_CONFIRM,
    }, WindowStyle.POPUP)
end

function Pay:e2p_android(pmode, data)
    print_string("_______600______________")
    print_string(json.encode(data))
    dump(data)
    local pay ={
        pmode = tostring(pmode),
        ORDER  = data.ORDER ,
        PAMOUNT = data.PAMOUNT ,
        PAMOUNT_UNIT =data.PAMOUNT_UNIT,
        sitemid 	= MyUserData:getSiteId(),
        payID 		= tostring(data.serviceid),
    }
    NativeEvent:getInstance():pay(pay)
end

function Pay:truemoenyPay(pmode, data)
	--{"code":1,"codemsg":"","data":{"ORDER":"000713320240BYORDFLG002224938428","SID":"7","APPID":"1332","PMODE":"240","PAMOUNT":"29","PCOINS":"0","PCHIPS":"1722600","PCARD":"0","PNUM":"1","PAYCONFID":123802,"CURRENCY":"THB","DESC":"{\"url1\":\"\",\"url2\":\"\",\"desc\":\"\"}","RET":0,"MSG":"succ","SITEMID":"06DCB1D14E41BBD34FBC6D141F2E5122dddd","user_ip":"172.20.42.146","macid":""},"time":1442902863,"exetime":1442902863.9888}

	-- 	customId	String	Y	用户ID,用于支付卡的支付,保证用户唯一即可	注:限定40位字符生成办法:
	-- 1.在网游中.可以使用游戏ID.或者生成UUID 2.在单机中.可以直接使用UUID的转化

	-- transactionId	String	Y	订单ID,保证用户付费成功	为本次的支付订单号(向支付中心下单时生成)， 最大长度 20 位字符
	-- SerialNo	String	N	越南等地的支付卡需要填入的值	越南支付必须填写
	-- Publisher	String	Y	卡类型, 如:trueMoney, 12call	12Call的方式:PublisherCode.PUBLISHER_12CALL（定义在BluePay的API里，其值为"12call"）
	-- TrueMoney的方式: PublisherCode.PUBLISHER_TRUEMONEY（定义在BluePay的API里，其值为"truemoney"） viettel的方式: PublisherCode.PUBLISHER_VIETTEL vinafone的方式: PublisherCode.PUBLISHER_VINAPHONE mobifone的方式: PublisherCode.PUBLISHER_MOBIFONE Unipin的方式：PublisherCode.PUBLISHER_UNIPIN VTCPay的方式： PublisherCode.PUBLISHER_VTC;

	-- CardNo	String	N	12Call, TrueMoney两种支付卡的PIN码	填写好: 不显示BluePay SDK的UI，未填写或空字符串: 将会弹出BluePay SDK的UI框(在UI框中要求用户输入PIN码).
	-- propsName	String	Y	道具名称	产生效果:
	-- 1.填写:用户下发道具提示短信中加载道具名称.
	-- 2.不填写:用户下发道具将没有道具名称.

	-- isShowDialog	boolean	N	使用支付卡的情况下，确定进度条是否显示	不设置的话默认为false
	-- 设置true： 在用户确认支付后, 会显示LOADING进度条,结果返回时取消显示； 设置false ： 不显示进度条。

	-- pmode	String	Y	支付渠道号	在支付中心申请的支付渠道号，支持JMT(pmode=240)、12call(pmode=645)和truemoney(pmode=646)
    printInfo('truemoenyPay')
    local pay = {	
        customId 		= data.ORDER,
        transactionId 	= data.ORDER, 
        propsName 		= data.ORDER,
        pmode 			= tostring(pmode),
        isShowDialog 	= true
    }

    NativeEvent:getInstance():pay(pay);

end

function Pay:paycb(result)
    if kPlatformIOS == System.getPlatform() then

        local pmode = tonumber(result.pmode and result.pmode:get_value() or 0);

        self.pmode = pmode
        if pmode == kIOSPay then
            local payState = tonumber(result.status and result.payState:get_value() or 0);
            dump(payState,"pmode==99")
            if 1 == payState then
				-- ios pay

                local payState = result.payState:get_value()
                local sandbox = result.sandbox:get_value()
                local productId = result.productid:get_value()
                local pdealno = result.pdealno:get_value()
                local receipt =result.receipt:get_value() or ""
                local orderId = result.orderId:get_value()
                -- sandbox = "true"

                self.pdealno = pdealno

                local param = 
                    {
                        pmode = tostring(pmode),
                        sitemid 	= MyUserData:getSiteId(),
                        id = productid,
                        pdealno = pdealno,
                        receipt = receipt,
                        pid = (orderId or "")
                    }

                if sandbox and (sandbox == "true") then
                    param.test = "test"
                end

                self.deliveryParams = param

                HttpModule.getInstance():execute(HttpModule.s_cmds.GET_PAY_NOTIFY, param, false, true);

            elseif 0 == payState then

            elseif 3 == payState then

            end
        elseif pmode == kIOSJMT then
            print("bluePay支付返回")
            print("支付结果code：",result.code:get_value())
            local code = result.code:get_value()
            if code == 200 then
                print_string("支付成功")
	            WindowManager:showWindow(WindowTag.LobbyConfirmPopu, {
                content = STR_PAY_SUC,
                confirm = STR_EXIT_GAME_CONFIRM,
                }, WindowStyle.POPUP)
            elseif code ==201 then
                print_string("正在支付")
            elseif code == 403 then
                WindowManager:showWindow(WindowTag.LobbyConfirmPopu, {
                    content = STR_PAY_JMTSMS_NOCARD,
                    confirm = STR_EXIT_GAME_CONFIRM,
                }, WindowStyle.POPUP)
                HttpModule.getInstance():execute(HttpModule.s_cmds.REPORT_DEBUG_INFO, {log = "IOS JMT payFail no sim code 403" })
            elseif code == 603 then
                WindowManager:showWindow(WindowTag.LobbyConfirmPopu, {
                    content = STR_PAY_JMTSMS_ORDERCANEL,
                    confirm = STR_EXIT_GAME_CONFIRM,
                }, WindowStyle.POPUP)
                HttpModule.getInstance():execute(HttpModule.s_cmds.REPORT_DEBUG_INFO, {log = "IOS JMT payFail order cancel code 603" })
            elseif code == 601 then
                WindowManager:showWindow(WindowTag.LobbyConfirmPopu, {
                    content = STR_PAY_JMTSMS_NOTENOUGHT,
                    confirm = STR_EXIT_GAME_CONFIRM,
                }, WindowStyle.POPUP)
                HttpModule.getInstance():execute(HttpModule.s_cmds.REPORT_DEBUG_INFO, {log = "IOS JMT payFail money not enough code 601" })
            else
                print_string("支付失败")
	            WindowManager:showWindow(WindowTag.LobbyConfirmPopu, {
                    content = STR_PAY_JMTSMS_FAILD,
                    confirm = STR_EXIT_GAME_CONFIRM,
                }, WindowStyle.POPUP)
                HttpModule.getInstance():execute(HttpModule.s_cmds.REPORT_DEBUG_INFO, {log = "IOS JMT payFail code "..tostring(code) })
            end
        end

    else
        local status = tonumber(result.status and result.status:get_value() or 0);
        if status == 0  then
            AlarmTip.play(STR_PAY_SUC)
            local pmode = tonumber(result.pmode and result.pmode:get_value() or 0);
            if pmode == kAndroidCheckout then
                local signedData = result.signedData and result.signedData:get_value() or ""
                local signature  = result.signature and result.signature:get_value() or ""

                local param = { pmode 		= tostring(kAndroidCheckout),
                                sitemid 	= MyUserData:getSiteId(),
                                signedData 	= base64.encode(signedData),
                                signature 	= signature};
                HttpModule.getInstance():execute(HttpModule.s_cmds.GET_PAY_NOTIFY, param, false, true);
            end
        else
            local mainStatus = tonumber(result.mainStatus and result.mainStatus:get_value() or -1);
            local subStatus  = tonumber(result.subStatus and result.subStatus:get_value() or -1);
            local errmsg  	 = result.errmsg and result.errmsg:get_value() or "";
            AlarmTip.play(string.format("(%s,%s):%s", mainStatus, subStatus, errmsg));
            local pmode = tonumber(result.pmode:get_value()) or 0
            local errorLog = "payFail "..pmode.." "..tostring(mainStatus).." "..tostring(subStatus)
            HttpModule.getInstance():execute(HttpModule.s_cmds.REPORT_DEBUG_INFO, {log = errorLog})
            if pmode == kAndroidCheckout and subStatus == 7 and self.checkoutproductId then
                NativeEvent.getInstance():consumeProduct(self.checkoutproductId)
                self.checkoutproductId = nil
            end
        end
    end
end

function Pay:onHttpResponse( command, ... )
    local func = self.s_httpEventFuncMap[command];
    if func then
        func(self, ...);
    end
end

function Pay:onPayNotifyResponse( isSuccess, data )
    print_string('onPayNotifyResponse')
    JLog.d("Pay:onPayNotifyResponse", isSuccess, data)
    if isSuccess and data and data.code == 1 and data.data then
        if System.getPlatform() == kPlatformIOS then
            local data = data.data
            local pmode = tonumber(data.pmode or self.pmode)
            if pmode == kIOSPay then
                local pdealno = data.pdealno --or self.pdealno
                if pdealno then
                    NativeEvent.getInstance():IosPayResultCallback(pdealno);
                end
            end
        else
            local data = data.data
            local pmode = tonumber(data.pmode or 0) or 0
            if pmode == kAndroidCheckout then
                if data.productId then
                    printInfo(data.productId)
                    NativeEvent.getInstance():consumeProduct(data.productId)
                end
            end
        end
    end

end

Pay.s_pmode2Pay = {
    [kAndroidJMT] 	          = Pay.jmtPay,				--（bluePay android, SMS)
    [kAndroidCheckout] 	      = Pay.googlePay,
    [kAndroid12Call] 	        = Pay.callPay,				--(12Call  android)
    [kAndroidTrueMoney] 	    = Pay.truemoenyPay,
    [kAndroidMolTrueMoney]  	= Pay.molTrueMoenyPay,		--(molTrueMoenyPay)
    [kAndroidE2p]	            = Pay.e2p_android,          --(E2P, SMS)

    [kIOSPay]                 = Pay.iosPay, 
    [kIOSJMT]	                = Pay.jmtPay,				--(bluePay IOS)
    [kIOS12call]	            = Pay.callPay_IOS,			--(12Call  IOS)
    [kIOSE2p]                 = Pay.e2p_IOS,
    [kIOSTureMoney]	          = Pay.callPay_IOS,			--(truemoney IOS)
    [kAndroidLinePay]         = Pay.linePay_android,	--(linePay  android)
    [kIOSLinePay]             = Pay.linePay_IOS,				--(linePay  IOS)
}

Pay.s_httpEventFuncMap = {
    [HttpModule.s_cmds.GET_PAY_NOTIFY]	= Pay.onPayNotifyResponse,

}

return Pay
