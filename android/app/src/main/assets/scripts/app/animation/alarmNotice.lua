require("app.common.animFactory");
require("app.common.uiFactory");

AlarmNotice = class();

AlarmNotice.ctor = function()
	
end

AlarmNotice.load = function(str, params)
	params = params or {}
	local isTop = params.isTop
	local time = params.time
	local loading = params.loading
	local callBack = params.callBack
	AlarmNotice.params = params

	if AlarmNotice.root then
		AlarmNotice.stop();
	end
	AlarmNotice.root = new(Node);
	AlarmNotice.root:addToRoot();
	AlarmNotice.root:setLevel(51);
	AlarmNotice.tipBg  = UIFactory.createImage("animation/awardTipBg.png");
	local w,h = AlarmNotice.tipBg:getSize();
	AlarmNotice.root:setSize(w,h);
	AlarmNotice.tipText = UIFactory.createText({
			text = str,
			size = 36,
			width = 0,
			height = 0,
			align = kAlignCenter,
			color = c3b(198, 12, 0),
		});
	AlarmNotice.tipText:setAlign(kAlignCenter);

	if isTop then
		AlarmNotice.root:setAlign(kAlignCenter);
		AlarmNotice.root:setPos(0,-180)
	else
		AlarmNotice.root:setAlign(kAlignCenter);
	end
	AlarmNotice.root:addChild(AlarmNotice.tipBg);
	AlarmNotice.root:addChild(AlarmNotice.tipText);

	if loading then
		local width, height = AlarmNotice.tipText:getSize()		
		AlarmNotice.loadingText = UIFactory.createText({
			text = "",
			size = 36,
			width = 160,
			height = 0,
			align = kAlignLeft,
			color = c3b(198, 12, 0),
		})
		AlarmNotice.loadingText:setAlign(kAlignCenter);
		AlarmNotice.loadingText:setPos(width / 2 + 85)
		AlarmNotice.root:addChild(AlarmNotice.loadingText);

		local index = 0
		local suffixs = {"", ".", "..", "...", "....", ".....", "......"}
		AlarmNotice.textAnim = AnimFactory.createAnimInt(kAnimRepeat, 0, 1, 200, 0)
		AlarmNotice.textAnim:setDebugName("AlarmNotice || textAnim")
		AlarmNotice.textAnim:setEvent(nil, function()
			local suffix = suffixs[index + 1]
			index = (index + 1) % 7
			if AlarmNotice.loadingText and AlarmNotice.loadingText.m_res then
				AlarmNotice.loadingText:setText(suffix or "")
			end
		end)
	end
	
	-- 渐显
	AlarmNotice.root:addPropTransparency(0, kAnimNormal, 300, 0, 0, 1);
	AlarmNotice.anim = new(AnimDouble, kAnimNormal,0,1, time or 2500,0);
	AlarmNotice.anim:setDebugName("AlarmNotice || anim");
	AlarmNotice.anim:setEvent(nil, function()
		if callBack then callBack() end
		AlarmNotice.stop()
	end);
end

AlarmNotice.play = function(str, params)
	if not str or str == "" then
		return;
	end
	AlarmNotice.load(str, params);
end

AlarmNotice.stop = function()
	if not AlarmNotice.root then return; end
	if AlarmNotice.textAnim then
		delete(AlarmNotice.textAnim);
		AlarmNotice.textAnim = nil;
	end
	if AlarmNotice.loadingText then
		delete(AlarmNotice.loadingText)
	end
	if AlarmNotice.anim then
		delete(AlarmNotice.anim);
		AlarmNotice.anim = nil;
	end
	if not AlarmNotice.root:checkAddProp(0) then
        AlarmNotice.root:removeProp(0);  -- 移除属性
    end 
	AlarmNotice.root:removeAllChildren();
	AlarmNotice.root = nil;
	AlarmNotice.tipText = nil
	AlarmNotice.loadingText = nil
end

AlarmNotice.updateTip = function(tip)
	if AlarmNotice.root and ToolKit.isValidString(tip) then
		AlarmNotice.play(tip, AlarmNotice.params)
		return true
	end
end

AlarmNotice.dtor = function()

end