local ShopPopu = class(require("app.popu.gameWindow"))

local viewMultiPayModeView = require("app.view.popu.lobby.shop.multiPayModeView")
local viewPayModeItem = require("app.view.popu.lobby.shop.payModeItem")
local viewShopItem = require("app.view.popu.lobby.shop.shopItem")
local viewShopIconItem_b = require("app.view.popu.lobby.shop.shopIconItem_b")
local viewShopIconItem_s = require("app.view.popu.lobby.shop.shopIconItem_s")
local viewBuyRecordItem = require("app.view.popu.lobby.shop.buyRecordItem")

local kChip = 1
local kCash = 2
local kProp = 3
local kRecord = 4

local kPayModeIcon = {
	[kAndroidCheckout] = "google",
	[kAndroidJMT] = "JMT",
	[kAndroid12Call] = "onetwocall",
	[kAndroidMolTrueMoney] = "onetwocall",
	[kAndroidE2p] = "e2p",
	[kAndroidLinePay] = "linePay",

	[kIOSPay] = "appStore",
	[kIOSJMT] = "JMT",
	[kIOS12call] = "onetwocall",
	[kIOSTureMoney] = "truemoney",
	[kIOSE2p] = "e2p",
	[kIOSLinePay] = "linePay",
}

function ShopPopu:ctor()
end

function ShopPopu:dtor()
end

function ShopPopu:initView(data)
	local viewTop = self:findChildByName("view_top")
	local text_chipNum = viewTop:findChildByName("text_chipNum")
	text_chipNum:setText(ToolKit.formatMoney(MyUserData:getMoney()))
	UIEx.bind(self, MyUserData, "money", function(value)
		text_chipNum:setText(ToolKit.formatMoney(value))
	end)
	local text_cardNum = self:findChildByName("text_cardNum")
	text_cardNum:setText(MyUserData:getCashPoint())
	UIEx.bind(self, MyUserData, "cashPoint", function(value)
		text_cardNum:setText(value)
	end)
	viewTop:findChildByName("btn_back"):setOnClick(
		nil,
		function()
			self:dismiss()
		end)
	local imgTitle = self:findChildByName("img_titleBg")
	self.btns = {
		imgTitle:findChildByName("btn_chip"),
		imgTitle:findChildByName("btn_prop"),
		imgTitle:findChildByName("btn_cash"),
		imgTitle:findChildByName("btn_record"),
	}
	self.shopViews = {
		self:findChildByName("view_chip"),
		self:findChildByName("view_prop"),
		self:findChildByName("view_cash"),
		self:findChildByName("view_record"),
	}
	for i = 1, #(self.btns) do
		self.btns[i]:setOnClick(self, function ()
			self:switchTab(i)
		end)
	end
	self.data = data
end

function ShopPopu:switchTab(i)
	for j = 1, #(self.btns) do
		self.btns[j]:findChildByName("img_select"):setVisible(i == j)
	end
	for j = 1, #self.shopViews do
		self.shopViews[j]:setVisible(i == j)
	end
	if i > 3 then
		return
	end
	if self.currPayModeIndex == nil then
		self.currPayModeIndex = 1
	end
	local itmeShopView = self.shopViews[i]
	local svPayMode = itmeShopView:findChildByName("sv_payMode")
	local svPayModeChildren = svPayMode:getChildren()
	if svPayModeChildren == nil or #svPayModeChildren == 0 then
		return
	end 
	local btn = svPayModeChildren[self.currPayModeIndex]:findChildByName("btn_tab")
	if btn then
		btn.m_eventCallback.func(btn.m_eventCallback.obj)
	end
end	

function ShopPopu:onShowEnd()
	self.super.onShowEnd(self)
	if MyPayMode then
		self:initMulPayModeView(1)
		self:initMulPayModeView(2)
		self:initMulPayModeView(3)
		if self.data then
			if self.data.tab then
				self:switchTab(self.data.tab)
			end
			self.data = nil
		end
	else
		HttpModule.getInstance():execute(HttpModule.s_cmds.GET_PAY_MODE, {}, false, false)
	end
	HttpModule.getInstance():execute(HttpModule.s_cmds.GET_BUY_RECORD, {}, false, false)
	HttpModule.getInstance():execute(HttpModule.s_cmds.Payment_getUserPayList, {}, false, false)
end

function ShopPopu:initMulPayModeView(typeIndex)
	print("initMulPayModeView")
	local view = SceneLoader.load(viewMultiPayModeView)
	local parentView = self.shopViews[typeIndex]
	parentView:addChild(view)
	local svPayMode = view:findChildByName("sv_payMode")
	svPayMode:removeAllChildren()
	svPayMode:setDirection(kVertical)
	svPayMode:setAutoPosition(true)
	local viewGoods = view:findChildByName("view_good")
	viewGoods:removeAllChildren()
	for i = 1, #MyPayMode do
		local index = i
		local pmode = MyPayMode[i]:getId()
		local payModeItem = SceneLoader.load(viewPayModeItem)
		if kPayModeIcon[pmode] then
			local imgUnselect = payModeItem:findChildByName("img_unselect")
			local unselectPmode = imgUnselect:findChildByName("img_pmode")
			unselectPmode:setFile(string.format("popu/shop/payMode/%s_0.png", kPayModeIcon[pmode]))
			unselectPmode:setSize(unselectPmode.m_res.m_width, unselectPmode.m_res.m_height)

			local imgSelect = payModeItem:findChildByName("img_select")
			local selectPmode = imgSelect:findChildByName("img_pmode")
			selectPmode:setFile(string.format("popu/shop/payMode/%s_1.png", kPayModeIcon[pmode]))
			selectPmode:setSize(selectPmode.m_res.m_width, selectPmode.m_res.m_height)
		end
		svPayMode:addChild(payModeItem)
		local payModeShopView = new(Node)
		payModeShopView:setSize(viewGoods:getSize())
		viewGoods:addChild(payModeShopView)
		local btnSwitch = payModeItem:findChildByName("btn_tab")
		btnSwitch:setOnClick(
			self,
			function(self)
				local children = svPayMode:getChildren()
				for j = 1, #children do
					children[j]:findChildByName("img_select"):setVisible(false)
					print("img_select unvisible "..children[j]:getName())
				end
				payModeItem:findChildByName("img_select"):setVisible(true)
				print("item visible "..payModeItem:getName())
				self.currPayModeIndex = index
				local viewChildren = viewGoods:getChildren()
				for j = 1, #viewChildren do
					viewChildren[j]:setVisible(false)
				end
				payModeShopView:setVisible(true)
			end
		)
		local svShopView = new(ScrollView)
		svShopView:setSize(payModeShopView:getSize())
		svShopView:setDirection(kVertical)
		svShopView:setAutoPosition(true)
		payModeShopView:addChild(svShopView)
		self:initShopItem(typeIndex, MyPayMode[i], svShopView)
	end
	local children = svPayMode:getChildren()
	if children and children[1] then
		local btn = children[1]:findChildByName("btn_tab")
		btn.m_eventCallback.func(btn.m_eventCallback.obj)
	end
end

function ShopPopu:initSinglePayModeView(typeIndex)
	print("initSinglePayModeView")
	local parentView = self.shopViews[typeIndex]
	local svShopView = new(ScrollView)
	svShopView:setSize(parentView:getSize())
	print(string.format("parentView:getSize ", parentView:getSize()))
	svShopView:setDirection(kVertical)
	svShopView:setAutoPosition(true)
	parentView:addChild(svShopView)
	self:initShopItem(typeIndex, MyPayMode[1], svShopView)
end

function ShopPopu:initShopItem(typeIndex, pmodeData, svParent)
	print("initShopItem "..typeIndex)
	local keyName = {"pay", "cash", "prop"}
	local httpCmd = {
		HttpModule.s_cmds.GET_PAY_LIST,
		HttpModule.s_cmds.Payment_getDiamondPayList,
		HttpModule.s_cmds.GET_PAY_PROP_LIST,
	}
	UIEx.bind(
		self,
		pmodeData,
		keyName[typeIndex],
		function(shopList)
			print("shopList bind call "..keyName[typeIndex])
			if not shopList then
				print("http get shopList")
				self:execHttpCmd(httpCmd[typeIndex], {pmode = pmodeData:getId()}, false, false)
			else
				for i = 1, shopList:count() do
					local shop = shopList:get(i)
					local shopItem = SceneLoader.load(viewShopItem)
					shopItem:setSize(svParent:getSize(), nil)
					print("size "..svParent:getSize().." item size "..shopItem:getSize())
					svParent:addChild(shopItem)
					local viewGoods = shopItem:findChildByName("view_goods")
					local iconItem = SceneLoader.load(viewShopIconItem_b)
					viewGoods:addChild(iconItem)
					local iconFile = iconItem:findChildByName("img_icon")
					local imgFile = nil
					local text_original = iconItem:findChildByName("text_original")
					local provchips = shop:getPrevchips()
					local viewNum = iconItem:findChildByName("view_now")
					if provchips and provchips ~= "" and provchips ~= "0" and provchips ~= 0 then
						text_original:setText(shop:getPrevchips())
					else
						text_original:setVisible(false)
						local viewNumX = viewNum:getPos()
						viewNum:setPos(viewNumX, 0)
					end

					local propCfgList = MyUserData.propCfgList or {}
					local prop = propCfgList[tostring(shop:getPcard())]
					print("shop:getPcard "..tostring(shop:getPcard()).." prop is "..tostring(prop))
					-- local textNum = new(Text, shop:getName(), 0, 0, kAlignCenter, "", 24, 0xff, 0xff, 0xff)
					-- textNum:setAlign(kAlignLeft)
					-- viewNum:addChild(textNum)
					--商品是道具商品
					if prop then
						print(typeIndex.." is prop")
						--检查icon目录下是否有这张图片，有就用，没有就下载
						if NativeEvent.getInstance():isFileExist((prop.keyName or "")..".png", "popu/shop/propIcon/") == 1 then
							imgFile = string.format("popu/shop/propIcon/%s.png", prop.keyName or "")
						else
							imgFile = prop:getImgName()
						end
						local textNum = new(Text, shop:getName(), 0, 0, kAlignCenter, "", 32, 0xff, 0xff, 0xff)
						textNum:setAlign(kAlignLeft)
						viewNum:addChild(textNum)
						-- local textNum = new(Text, tostring(prop.name)..":"..shop:getCount(), 0, 0, kAlignCenter, "", 24, 0xff, 0xff, 0xff)
						-- textNum:setAlign(kAlignLeft)
						-- viewNum:addChild(textNum)
					else
						local imgNum = new(
							require("uiEx.imageNumber"),
							{
								['0'] = "popu/shop/number_yellow/0.png",
								['1'] = "popu/shop/number_yellow/1.png",
								['2'] = "popu/shop/number_yellow/2.png",
								['3'] = "popu/shop/number_yellow/3.png",
								['4'] = "popu/shop/number_yellow/4.png",
								['5'] = "popu/shop/number_yellow/5.png",
								['6'] = "popu/shop/number_yellow/6.png",
								['7'] = "popu/shop/number_yellow/7.png",
								['8'] = "popu/shop/number_yellow/8.png",
								['9'] = "popu/shop/number_yellow/9.png",
								[','] = "popu/shop/number_yellow/,.png",
						})
						if typeIndex == 1 then
							imgFile = "popu/shop/propIcon/shop_chip.png"
							imgNum:setNumber(ToolKit.skipMoney(shop:getPchips()))
						else
							imgFile = "popu/shop/propIcon/cash_coins.png"
							imgNum:setNumber(ToolKit.skipMoney(shop:getPcoins()))
						end
						imgNum:setAlign(kAlignLeft)
						viewNum:addChild(imgNum)
					end

					print("imgFile is "..imgFile)
					iconFile:setFile(imgFile)
					local iconW, iconH = iconFile.m_res.m_width, iconFile.m_res.m_height
					-- if iconW > 103 then
					-- 	iconH = 103 / iconW * iconH
					-- 	iconW = 103
					-- end
					iconFile:setSize(iconW, iconH)
					local btnBuy = shopItem:findChildByName("btn_buy")
					btnBuy:setOnClick(
						nil,
						function()
							MyPay:payOrder(pmodeData:getId(), shop, imgFile)
						end
					)
					local price = btnBuy:findChildByName("text_price")
					price:setText(string.format("%s%s", shop:getPamount(), shop:getCurrency()))
				end
			end
		end
	)
	pmodeData[keyName[typeIndex]] = pmodeData[keyName[typeIndex]]

end

function ShopPopu:initRecordItem(record)
	local item = SceneLoader.load(viewBuyRecordItem)

	local propCfgList = MyUserData.propCfgList or {}
	local prop = propCfgList[tostring(record.pcard)]
	local imgFile = nil
	--商品是道具商品
	if prop then
		--检查icon目录下是否有这张图片，有就用，没有就下载
		if NativeEvent.getInstance():isFileExist((prop.keyName or "")..".png", "popu/shop/propIcon/") == 1 then
			imgFile = string.format("popu/shop/propIcon/%s.png", prop.keyName or "")
		else
			imgFile = prop:getImgName()
		end
	else
		if tonumber(record.pcard) == 0 then
			imgFile = "popu/shop/propIcon/cash_coins.png"
		else
			imgFile = "popu/shop/propIcon/shop_chip.png"
		end
	end
	local iconFile = item:findChildByName("img_icon")
	iconFile:setFile(imgFile)
	local iconW, iconH = iconFile.m_res.m_width, iconFile.m_res.m_height
	-- if iconW > 103 then
	-- 	iconH = 103 / iconW * iconH
	-- 	iconW = 103
	-- end
	iconFile:setSize(iconW, iconH)
	
	item:findChildByName("text_time"):setText(record.order_time)
	local textShop = item:findChildByName("text_shop")
	textShop:setText(record.name)
	local tW,tH = textShop:getSize()
	local pX,pY = textShop:getPos()
	local textNum = item:findChildByName("text_num")
	textNum:setText('x'..record.num)
	textNum:setPos(tW + pX + 5, pY)
	if record.status == 2 then
		item:findChildByName("text_status"):setText(Hall_string.str_record_status_2)
	elseif record.status == 1 then
		item:findChildByName("text_status"):setText(Hall_string.str_record_status_1)
	else
		item:findChildByName("text_status"):setText(Hall_string.str_record_status_3)
	end
	return item
end

function ShopPopu:onGetPayMode(isSuccess, data)
	if #MyPayMode > 1 then
		self:initMulPayModeView(kChip)
		self:initMulPayModeView(kCash)
		self:initMulPayModeView(kProp)
		if self.data then
			if self.data.tab then
				self:switchTab(self.data.tab)
			end
			self.data = nil
		end
	else
		self:initSinglePayModeView(kChip)
		self:initSinglePayModeView(kCash)
		self:initSinglePayModeView(kProp)
	end

end

function ShopPopu:onGetPayList(isSuccess, data)

end

function ShopPopu:onGetPropList(isSuccess, data)

end

function ShopPopu:onGetCashList(isSuccess, data)

end

function ShopPopu:onGetBuyRecord(isSuccess, data)
	if app:checkResponseOk(isSuccess, data) then
		
	end
end

function ShopPopu:onGetUserPayList(isSuccess, data)
	JLog.d("onGetUserPayList", isSuccess, data)
	if app:checkResponseOk(isSuccess, data) then
		local shopView = self.shopViews[4]
		local text_record_empty = shopView:findChildByName("text_record_empty")
		local parentView = shopView:findChildByName("view_list")
		parentView:removeAllChildren()
		if #(data.data) == 0 then
			text_record_empty:setText(Hall_string.str_record_empty)
			text_record_empty:setVisible(true)
			return
		end
		text_record_empty:setVisible(false)
		local svShopView = new(ScrollView)
		svShopView:setSize(parentView:getSize())
		svShopView:setDirection(kVertical)
		svShopView:setAutoPosition(true)
		parentView:addChild(svShopView)
		local posTop = 0
		for i=1, #(data.data) do
			local itemData = data.data[i]
			local itemView = self:initRecordItem(itemData)
			itemView:setPos(0, posTop)
			local itemW, itemH = itemView:getSize()
			svShopView:addChild(itemView)
			posTop = posTop + itemH + 5
		end
	end
end

ShopPopu.s_severCmdEventFuncMap = {
	[HttpModule.s_cmds.GET_PAY_MODE] = ShopPopu.onGetPayMode,
	[HttpModule.s_cmds.GET_PAY_LIST] = ShopPopu.onGetPayList,
	[HttpModule.s_cmds.GET_PAY_PROP_LIST] = ShopPopu.onGetPropList,
	[HttpModule.s_cmds.GET_CASH_LIST] = ShopPopu.onGetCashList,
	[HttpModule.s_cmds.GET_BUY_RECORD] = ShopPopu.onGetBuyRecord,
	[HttpModule.s_cmds.Payment_getUserPayList] = ShopPopu.onGetUserPayList,
}
return ShopPopu
