function compressPhpInfo(content)
	local compress = 0
	if not COMPRESS_FLAG then return compress, content end
	
	local jsonstr = NativeEvent.getInstance():compressString(json.encode({content = content}))
	if jsonstr then
		local retData = json.decode(jsonstr)
		if retData then
			compress = retData.flag
			content  = retData.result
		end
	end
	return compress, content
end

function unCompressString(content)
	local compress = 0
	if not COMPRESS_FLAG then return compress, content end

	local jsonstr = NativeEvent.getInstance():unCompressString(json.encode({content = content}))
	if jsonstr then
		local retData = json.decode(jsonstr)
		if retData then
			compress = retData.flag
			content  = retData.result
		end
	end
	return compress, content
end

function playOutCardSound(card, sex)
	local soundPrefix = sex == 0 and "ManCard" or "WomanCard"
	local fileName = soundPrefix .. tostring(card);
	local soundTb = Effects.mutiEffectMap[GameSetting:getSoundType()]
	if soundTb then
		local sound = soundTb[fileName]
		if type(sound) == "table" then
			kEffectPlayer:play(sound[math.random(1, #sound)])
		elseif type(sound) == "string" then
			kEffectPlayer:play(sound)
		end
	end
end

function isHuOperate(opValue)
	-- 胡牌放大动画
	return bit.band(opValue, kOpeHu) > 0 or
		bit.band(opValue, kOpeZiMo) > 0 or 
		bit.band(opValue, kOpePengGangHu) > 0 
end

function isAnGangOperate(opValue)
	return bit.band(opValue, kOpeAnGang) > 0
end

function isPengGangOperate(opValue)
	return bit.band(opValue, kOpePengGang) > 0 or
		bit.band(opValue, kOpeBuGang) > 0
end

function isPengOperate(opValue)
	return bit.band(opValue, kOpePeng) > 0
end

function isChiOperate(opValue)
	return bit.band(opValue, kOpeLeftChi) > 0 or
		bit.band(opValue, kOpeMiddleChi) > 0 or
		bit.band(opValue, kOpeRightChi) > 0
end

function playOperateSound(opValue, sex)
	local sexPrefix = sex == 0 and "Man" or "Woman"
	local fileName;
	if opValue == kOpeLeftChi or opValue == kOpeMiddleChi or opValue == kOpeRightChi then
		fileName = sexPrefix .. "Chi";
	elseif opValue == kOpePeng then
		fileName = sexPrefix .. "Peng";
	elseif opValue == kOpeAnGang then
		fileName = sexPrefix .. "GangAG";
	elseif opValue == kOpePengGang or opValue == kOpeBuGang then
		fileName = sexPrefix .. "Gang";
	elseif opValue == kOpeHu or opValue == kOpeHuaHu or opValue == kOpePengGangHu then
		fileName = sexPrefix .. "Hu";
	elseif opValue == kOpeZiMo then
		fileName = sexPrefix .. "ZiMo";
	elseif opValue == kOpeBuHua then
		fileName = sexPrefix .. "BuHua"
	end

	local soundTb = Effects.mutiEffectMap[GameSetting:getSoundType()]
	if soundTb then
		local sound = soundTb[fileName]
		if type(sound) == "table" then
			kEffectPlayer:play(sound[math.random(1, #sound)])
		elseif type(sound) == "string" then
			kEffectPlayer:play(sound)
		end
	end
end

function playChatSound(chatInfo, sex)
	local sexPrefix = sex == 0 and "Man" or "Woman"
	for k,v in ipairs(SysChatArray) do
		if v == chatInfo then
			local fileName = sexPrefix .. string.format("Chat%d", k-1)
			local soundTb = Effects.mutiEffectMap[GameSetting:getSoundType()]
			if soundTb then
				kEffectPlayer:play(soundTb[fileName])
			end
			break
		end
	end
end

function checkOperateData(operation, cardValue, anGang, buGang)
	operation = operation or 0
	cardValue = cardValue or 0
	anGang = anGang or {};
	buGang = buGang or {};

	local operateValue = 0
	local opBundle = {
		count = 0;
		chi  = false;
		chiOp = {};
		peng = false;
		gang = false;
		gangTb = {};
		ting = false;
		hu = false;
		huTb = {},
		opValue = 0,
	}
	--chi 
	local chiOpTb = {kOpeRightChi , kOpeMiddleChi , kOpeLeftChi};
	for k , v in ipairs(chiOpTb) do
		if ( bit.band(operation, v) ~= 0 ) then
			printInfo("检测到吃操作")
			opBundle.chi = true;
			opBundle.count = opBundle.count + 1;
			table.insert(opBundle.chiOp, {
				operation =	v, 
				card = cardValue
			});
			operateValue = bit.bor(operateValue, v)
		end
	end
	--peng
	if( bit.band(operation , kOpePeng) ~= 0 ) then
		printInfo("检测到碰操作")
		opBundle.count = opBundle.count + 1;
		opBundle.peng = true;
		operateValue = bit.bor(operateValue, kOpePeng)
	end

	--pengGang 保存操作和 操作的麻将子
	if ( bit.band(operation, kOpePengGang) ~= 0 ) then
		printInfo("检测到碰杠操作")
		opBundle.gang = true;
		opBundle.count = opBundle.count + 1;
		table.insert(opBundle.gangTb, {
			operation = kOpePengGang, 
			card = cardValue
		});
		operateValue = bit.bor(operateValue, kOpePengGang)
	end
	
	if anGang and #anGang > 0 then
		for k, val in pairs(anGang) do
			if val > 0 then
				printInfo("检测到暗杠操作" ..  cardValue)
				opBundle.gang = true;
				opBundle.count = opBundle.count + 1;
				table.insert(opBundle.gangTb, {
					operation = kOpeAnGang, 
					card = val
				});
				operateValue = bit.bor(operateValue, kOpeAnGang)
			end
		end
	end

	if buGang and #buGang > 0 then
		for k, val in pairs(buGang) do
			if val > 0 then
				opBundle.gang = true;
				opBundle.count = opBundle.count + 1;
				table.insert(opBundle.gangTb, {
					operation = kOpeBuGang, 
					card = val,
				});
				operateValue = bit.bor(operateValue, kOpeBuGang)
			end
		end
	end
	
	--ting
	if( bit.band(operation , kOpeTing) ~= 0 ) then
		printInfo("检测到听牌操作")
		opBundle.count = opBundle.count + 1;
		opBundle.ting = true;
		operateValue = bit.bor(operateValue, kOpeTing)
	end

	local isHu = bit.band(operation, kOpeHu) > 0 or bit.band(operation, kOpeZiMo) > 0
		or bit.band(operation, kOpePengGangHu) > 0
	if isHu then
		printInfo("检测到胡牌操作")
		opBundle.count = opBundle.count + 1;
		opBundle.hu = true
	end
	if bit.band(operation, kOpeHu) > 0 then
		table.insert(opBundle.huTb, {
			operation = kOpeHu, 
			card = cardValue,
		});
		operateValue = bit.bor(operateValue, kOpeHu)
	elseif bit.band(operation, kOpeZiMo) > 0 then
		table.insert(opBundle.huTb, {
			operation = kOpeZiMo, 
			card = cardValue,
		});
		operateValue = bit.bor(operateValue, kOpeZiMo)
	elseif bit.band(operation, kOpePengGangHu) > 0 then
		table.insert(opBundle.huTb, {
			operation = kOpePengGangHu, 
			card = cardValue,
		});
		operateValue = bit.bor(operateValue, kOpePengGangHu)
	end
	opBundle.opValue = operateValue
	return opBundle;
end 

function getCardsTbByOpAndCard(opValue, card)
	local extraTb, operateValue = {}, 0
	
	if bit.band(opValue, kOpeLeftChi) > 0 then
		extraTb = {card, card + 1, card + 2}
		operateValue = kOpeLeftChi

	elseif bit.band(opValue, kOpeMiddleChi) > 0 then
		extraTb = {card - 1, card, card + 1}
		operateValue = kOpeMiddleChi

	elseif bit.band(opValue, kOpeRightChi) > 0 then
		extraTb = {card - 2, card - 1, card}
		operateValue = kOpeRightChi

	elseif bit.band(opValue, kOpePeng) > 0 then
		extraTb = {card, card, card}
		operateValue = kOpePeng

	elseif bit.band(opValue, kOpePengGang) > 0 then
		extraTb = {card, card, card, card}
		operateValue = kOpePengGang

	elseif bit.band(opValue, kOpeAnGang) > 0 then
		extraTb = {0, 0, 0, card}
		operateValue = kOpeAnGang

	elseif bit.band(opValue, kOpeBuGang) > 0 then
		extraTb = {card, card, card, card}
		operateValue = kOpeBuGang

	end
	return extraTb, operateValue
end


function getFullEffectPath(fileMap)
	local newMap = {}
	local pathPrefix = "ogg/"
	local fileSuffix = ".ogg"
	local nameTb = {}
	for _, value in pairs(fileMap) do
		if type(value) == "string" then
			value = pathPrefix .. value .. fileSuffix
			if not nameTb[value] then
				-- printInfo("common = %s", value)
				sys_set_string("search_name",value)
				newMap[#newMap + 1] = sys_get_string("audio_search")
				nameTb[value] = true
			end
		elseif type(value) == "table" then
			-- 区分语种的音效
			for k, soundTb in pairs(value) do
				for soundType, name in pairs(soundTb) do
					if soundType == SoundType.GDMJ and PhpManager:getGdmjCanUse() ~= 1 then
						break
					end
					if soundType == SoundType.SHMJ and PhpManager:getShmjCanUse() ~= 1 then
						break
					end
					if type(name) == "table" then
						for i, soundName in ipairs(name) do
							soundName = pathPrefix .. soundName .. fileSuffix
							if not nameTb[soundName] then
								-- printInfo("common = %s", soundName)
								sys_set_string("search_name",soundName)
								newMap[#newMap + 1] = sys_get_string("audio_search")
								nameTb[soundName] = true
							end
						end
					else
						name = pathPrefix .. name .. fileSuffix
						if not nameTb[name] then
							-- printInfo("common = %s", name)
							sys_set_string("search_name",name)
							newMap[#newMap + 1] = sys_get_string("audio_search")
							nameTb[name] = true
						end
					end
				end
			end
		end
	end
	return newMap
end

function getMutiEffectPath(fileMap)
	local newMap = {}
	local pathPrefix = "ogg/"
	local fileSuffix = ".ogg"
	local nameTb = {}
	for key, value in pairs(fileMap) do
		if type(value) == "string" then
			value = pathPrefix .. value .. fileSuffix
			if not nameTb[value] then
				-- printInfo("common = %s", value)
				sys_set_string("search_name",value)
				newMap[#newMap + 1] = sys_get_string("audio_search")
				nameTb[value] = true
			end
		elseif type(value) == "table" then
			-- 区分语种的音效
			for k, soundTb in pairs(value) do  -- gameType
				if type(soundTb) == "table" then
					for _, soundName in ipairs(soundTb) do
						soundName = pathPrefix .. soundName .. fileSuffix
						if not nameTb[soundName] then
							sys_set_string("search_name", soundName)
							newMap[#newMap + 1] = sys_get_string("audio_search")
							nameTb[soundName] = true
						end
					end
				elseif type(soundTb) == "string" then
					soundTb = pathPrefix .. soundTb .. fileSuffix
					if not nameTb[soundTb] then
						-- printInfo("common = %s", soundTb)
						sys_set_string("search_name",soundTb)
						newMap[#newMap + 1] = sys_get_string("audio_search")
						nameTb[soundTb] = true
					end
				end
			end
		end
	end
	dump(newMap)
	return newMap
end