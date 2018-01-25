
function global_http_readUrlFile(url, callback)
	require("app/common/downAddReadFile")
	local request = new(DownAddReadFile, url , 5000)
	request:setEvent(callback)
	request:execute()
end

function global_http_downloadImage(url, folder, name, callback)
	NativeEvent.getInstance():downloadImage(url, folder, name, callback);
end

--[[
	获取商品列表
]]
function globalRequestChargeList(force)
	-- 根据平台来决定怎么拉取商品列表
	PlatformManager:executeAdapter(PlatformManager.s_cmds.RequestChargeList, force);
end


--[[
	支付入口
]]
function globalRequestCharge(goodsInfo, sceneChargeData, isLuoMaFirst)
	PlatformManager:executeAdapter(PlatformManager.s_cmds.SelectPayWay, goodsInfo, isLuoMaFirst, sceneChargeData);
end

--支付场景上报
function getChargeSceneData(paySceneData)
	local bundleData = {
		bankrupt = app:checkIsBroke() and 1 or 0;
		party_level =  app:isInRoom() and G_RoomCfg:getLevel() or 0;	
		scene_id = scene_id or 1;
	}
    
    
    local ChargeSceneMap = {
			Market = 1,
			Room = 2,
			Broke = 3,
			LessMoney = 4,
			Lobby = 5,	
			UserInfo = 6,
			Help = 6,
	      }
	-- 二级界面
	local sceneIdMap = {
		[WindowTag.UserPopu] = ChargeSceneMap.UserInfo,
		[WindowTag.ShopPopu] = ChargeSceneMap.Market,
		[WindowTag.RechargePopu] = ChargeSceneMap.Broke,
	}

	if kCurrentState == States.Room then
		bundleData.scene_id = ChargeSceneMap.Room; 
	elseif paySceneData.chargeType == ChargeType.NotEnoughMoney then --金币不足
		bundleData.scene_id = ChargeSceneMap.LessMoney;
	elseif paySceneData.chargeType == ChargeType.BrokeCharge then --破产了
		bundleData.scene_id = ChargeSceneMap.Broke;
	elseif kCurrentState == States.Lobby then
		bundleData.scene_id = ChargeSceneMap.Lobby;
	else
		bundleData.scene_id = ChargeSceneMap.Lobby;
	end
	if GameSetting:getIsSecondScene() then
		for tag, sceneId in pairs(sceneIdMap) do
			if WindowManager:containsWindowByTag(tag) then
				bundleData.scene_id = sceneId;
				break
			end
		end
	else
       bundleData.scene_id = ChargeSceneMap.Lobby;
	end
	
	return bundleData;
end 