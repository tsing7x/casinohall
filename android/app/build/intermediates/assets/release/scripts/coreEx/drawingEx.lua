if kPlatformIOS == System.getPlatform() then
		-------------DrawingImage---------------------------
		local ctor = DrawingImage.ctor
        function DrawingImage:ctor(...)
	        ctor(self, ...)
	        self.m_originWidth = self.m_width
	        self.m_originHeight = self.m_height
        end


		function DrawingImage:getResSize()
			return self.m_res:getWidth(), self.m_res:getHeight()
		end

		function WidgetBase:getOriginSize()
			return self.m_originWidth or 1, self.m_originHeight or 1
		end

		function WidgetBase:getScale()
			return self.m_scaleX or 1, self.m_scaleY or 1
		end

		local setSize = WidgetBase.setSize
		function WidgetBase:setSize(width, height)
			setSize(self, width, height)
			return self
		end

		function WidgetBase:setScale(scaleX, scaleY)
			scaleY = scaleY or scaleX
			local originWidth, originHeight = self:getOriginSize()
			self:setSize(scaleX * originWidth, scaleY * originHeight)

			self.m_scaleX = scaleX
			self.m_scaleY = scaleY
			return self
		end

		function WidgetBase:addTo(parent, level)
			parent:addChild(self)
			if level then self:setLevel(level) end
			return self
		end

		function WidgetBase:pos(x, y)
			self:setPos(x, y)
			return self
		end

		function WidgetBase:align(align, x, y)
			self:setAlign(align)
			if x and y then
				self:setPos(x, y)
			end
			return self
		end

		function WidgetBase:removeSelf()
			local parent = self:getParent()
			if parent then
				return parent:removeChild(self, true)
			else
				delete(self)
			end
		end

		function WidgetBase:show()
			self:setVisible(true)
			return self
		end

		function WidgetBase:hide()
			self:setVisible(false)
			return self
		end

		function DrawingBase:_addAnim(animLoop, animTime, delayTime)
			self._anims = self._anims or {}
			local anim = AnimFactory.createAnimDouble(animLoop, 0, 1, animTime, delayTime or 0)
			local animId = anim:getID()
			self._anims[animId] = anim
			return anim
		end

		function DrawingBase:schedule(func, perTime, delayTime)
			local anim = self:_addAnim(kAnimRepeat, perTime, delayTime)
			anim:setEvent(nil, func)
			return anim
		end

		function DrawingBase:performWithDelay(func, delayTime)
			local anim = self:_addAnim(kAnimNormal, delayTime)
			anim:setEvent(nil, func)
			return anim
		end

		function DrawingBase:getActionByTag(tag)
			return self._anims and self._anims[tag]
		end

		function DrawingBase:stopActionByTag(tag)
			if not self._anims then return end
			for k,v in pairs(self._anims) do
				if v:getTag() == tag then
					delete(v)
					self._anims[k] = nil
					break
				end
			end
		end

		function DrawingBase:stopAllActions()
			if type(self.m_props) == "table" then
				for sequence, v in pairs(self.m_props) do 
					drawing_prop_remove(self.m_drawingID, sequence)
					delete(v["prop"]);
					for _,anim in pairs(v["anim"]) do 
						delete(anim);
					end
					for _,res in pairs(v["res"]) do 
						delete(res);
					end
				end
			end
			self.m_props = {};

			if type(self._anims) == "table" then
				for k,v in pairs(self._anims) do
					delete(v)
				end
			end
			self._anims = {}
		end

		local dtor = DrawingBase.dtor
        function DrawingBase:dtor()
	        self:stopAllActions()
	        dtor(self)
        end


		function DrawingBase:setDebugNameByPropAndAnim(sequence , name)
			name = name or "";
			if self.m_props[sequence] then
				local prop = self.m_props[sequence]["prop"];
				if prop then
					prop:setDebugName(name);
					for _,v in pairs(self.m_props[sequence]["anim"]) do 
						if v then
							v:setDebugName(name);
						end
					end
				end
			end
		end


		function DrawingImage:playAnimation(param)
			local frames = param.frames;				-- 动画帧表，file or ResImage;
			local inteval = param.inteval or 500;		-- 隔多少时间更新一帧
			local repeatCount = param.repeatCount or 1;	-- 动画重复次数 如果要永久动画，设为 < 1 的值
			local delay = param.delay or 0;				-- 多长时间后开始播放动画。
			local onComplete = param.onComplete;		-- 动画全播放完后回调

			local currentIndex = 0;						-- 当前帧
			self.m_reses = self.m_reses or {};
			local reses = self.m_reses;					-- 帧资源

			-- 动画播放完后调用，永久性动画进不来这里
			local function playFinished()
				self:stopAnimation();
				if onComplete then
					onComplete();
				end
			end

			-- 更新帧
			local function updateFrame()
				currentIndex = currentIndex + 1;
				if currentIndex > #frames then
					if repeatCount > 0 then
						repeatCount = repeatCount - 1;
						if repeatCount <= 0 then
							playFinished();
							return;
						end
					end
					currentIndex = 1;
				end
			
				if currentIndex > 0 and not reses[currentIndex] then
					local frame = frames[currentIndex];
					if typeof(frame, ResImage) then
						reses[currentIndex] = frame;
					else
						reses[currentIndex] = new(ResImage, frame);
					end
					self:addImage(reses[currentIndex], currentIndex);
				end
				-- 设置当前帧
				self:setImageIndex(currentIndex);
			end

			-- 开始播放帧动画
			local function playAnim()
				self._frameAnimation = new(AnimInt, kAnimLoop, 0, 1, inteval, 0);
				self._frameAnimation:setDebugName(param.DebugName or "FrameAnimation");
				self._frameAnimation:setEvent(self, updateFrame);
			end

			-- 动画开始前先stop掉 前动画
			self:stopAnimation();
			self:setImageIndex(0);

			-- 如果有 延迟播放动画，先延迟
			if delay and delay > 0 then
				self._delayAnimation = new(AnimInt, kAnimNormal, 0, 1, delay, 0);
				self._delayAnimation:setDebugName("delayAnimation");
				self._delayAnimation:setEvent(self, playAnim);
			else
				playAnim();
			end
		end


		function DrawingImage:stopAnimation()
			if self._frameAnimation then delete(self._frameAnimation); self._frameAnimation = nil; end
			if self._delayAnimation then delete(self._delayAnimation); self._delayAnimation = nil; end
		end

		function DrawingImage:dtor()
            self:stopAnimation();
		end


		WidgetBase.s_root = nil;

		WidgetBase.s_rootNodes = {

		};

		local drawing_delete_all_ex = drawing_delete_all;
		drawing_delete_all = function()
		    drawing_delete_all_ex();
		    WidgetBase.s_root = nil;
		    WidgetBase.s_rootNodes = {};
		end

		WidgetBase.__createRootNode = function()
		    if not WidgetBase.s_root then
		        WidgetBase.s_root = new(Node);
		        WidgetBase.s_root:setSize(System.getScreenScaleWidth(), System.getScreenScaleHeight());
		        table.insert(DrawingBase.s_rootNodes, WidgetBase.s_root);
		        WidgetBase.s_root:setParent();
		    end
		end

		WidgetBase.getRootNode = function()
		    WidgetBase.__createRootNode();
		    return WidgetBase.s_root;
		end

		WidgetBase.refreshRootNodeSize = function(isVerticalScreen)
			WidgetBase.__createRootNode();
			if isVerticalScreen == 1 then
				WidgetBase.s_root:setSize(System.getScreenScaleHeight(), System.getScreenScaleWidth());
				local sw = System.getScreenScaleWidth();
				local sh = System.getScreenScaleHeight();
				local lx = (sw - sh) / 2;
				WidgetBase.s_root:setPos(lx,-lx);
				WidgetBase.s_root:addPropRotateSolid(0,-90,kCenterDrawing);

				WidgetBase.setClip = function(self, x, y, w, h)
				end
			else
				WidgetBase.s_root:setSize(System.getScreenScaleWidth(), System.getScreenScaleHeight());
				WidgetBase.s_root:setPos(0,0);
				if not WidgetBase.s_root:checkAddProp(0) then
		     		WidgetBase.s_root:removeProp(0);
                    WidgetBase.setClip = function(self, x, y, w, h)
					    local layoutScale = System.getLayoutScale();
					    _drawing_set_clip_rect(self.m_drawingID, x*layoutScale,y*layoutScale,w*layoutScale,h*layoutScale);
				    end
		     	end
			end
			
		end

		WidgetBase.getAlign = function(self)
			return self.m_align or kAlignTopLeft;
		end

        local addToRoot = WidgetBase.addToRoot;
		WidgetBase.addToRoot = function(self)
			addToRoot(self);
		    DrawingBase.__createRootNode();
		end


		WidgetBase.addChild = function(self, child)
		    if not child then
		        return;
		    end
		    
		    if child.m_parent then
		        child.m_parent:removeChild(child);
		    else
		        self:removeChildFromRoot(child);   
		    end


		    local ret = child:setParent(self); 
		    --local ret = drawing_set_parent(child.m_drawingID,self.m_drawingID);
		    
		    local index = #self.m_children+1;
		    self.m_children[index] = child;
		    self.m_rchildren[child] = index;
		    --child.m_parent = self;

		    --child:revisePos();

		    return ret;
		end


		WidgetBase.removeChildFromRoot = function(self, child)
		    local keys = {};
		    for k, v in pairs(WidgetBase.s_rootNodes) do 
		        if v == child then
		            keys[1+#keys] = k;
		        end
		    end
		    for i, key in pairs(keys) do 
		        WidgetBase.s_rootNodes[key] = nil;
		    end
		end

		DrawingImage.addPropImageIndex = function(self, sequence, animType, duration, delay, startValue, endValue)
		    return DrawingBase.addAnimProp(self, sequence, PropImageIndex, nil, nil, nil, animType, duration, delay, startValue, endValue);
		end

		DrawingImage.addPropClip = function(self, sequence, animType, duration, delay, startX, endX, startY, endY, startW, endW, startH, endH)
		    return DrawingBase.addAnimProp(self, sequence, PropClip, nil, nil, nil, animType, duration, delay, startX, endX, startY, endY, startW, endW, startH, endH);
		end

else

	local ctor = DrawingImage.ctor
	function DrawingImage:ctor(...)
		ctor(self, ...)
		self.m_originWidth = self.m_width
		self.m_originHeight = self.m_height
	end

	function DrawingImage:getResSize()
		return self.m_res:getWidth(), self.m_res:getHeight()
	end

	function WidgetBase:getOriginSize()
		return self.m_originWidth or 1, self.m_originHeight or 1
	end

	function WidgetBase:getScale()
		return self.m_scaleX or 1, self.m_scaleY or 1
	end

	local setSize = WidgetBase.setSize
	function WidgetBase:setSize(width, height)
		setSize(self, width, height)
		return self
	end

	function WidgetBase:setScale(scaleX, scaleY)
		scaleY = scaleY or scaleX
		local originWidth, originHeight = self:getOriginSize()
		self:setSize(scaleX * originWidth, scaleY * originHeight)

		self.m_scaleX = scaleX
		self.m_scaleY = scaleY
		return self
	end

	function WidgetBase:addTo(parent, level)
		parent:addChild(self)
		if level then self:setLevel(level) end
		return self
	end

	function WidgetBase:pos(x, y)
		self:setPos(x, y)
		return self
	end

	function WidgetBase:align(align, x, y)
		self:setAlign(align)
		if x and y then
			self:setPos(x, y)
		end
		return self
	end

	function WidgetBase:removeSelf()
		local parent = self:getParent()
		if parent then
			return parent:removeChild(self, true)
		else
			delete(self)
		end
	end

	function WidgetBase:show()
		self:setVisible(true)
		return self
	end

	function WidgetBase:hide()
		self:setVisible(false)
		return self
	end

	function DrawingBase:_addAnim(animLoop, animTime, delayTime)
		self._anims = self._anims or {}
		local anim = AnimFactory.createAnimDouble(animLoop, 0, 1, animTime, delayTime or 0)
		local animId = anim:getID()
		self._anims[animId] = anim
		return anim
	end

	function DrawingBase:schedule(func, perTime, delayTime)
		local anim = self:_addAnim(kAnimRepeat, perTime, delayTime)
		anim:setEvent(nil, func)
		return anim
	end

	function DrawingBase:performWithDelay(func, delayTime)
		local anim = self:_addAnim(kAnimNormal, delayTime)
		anim:setEvent(nil, func)
		return anim
	end

	function DrawingBase:getActionByTag(tag)
		return self._anims and self._anims[tag]
	end

	function DrawingBase:stopActionByTag(tag)
		if not self._anims then return end
		for k,v in pairs(self._anims) do
			if v:getTag() == tag then
				delete(v)
				self._anims[k] = nil
				break
			end
		end
	end

	function DrawingBase:stopAllActions()
		if type(self.m_props) == "table" then
			for sequence, v in pairs(self.m_props) do 
				drawing_prop_remove(self.m_drawingID, sequence)
				delete(v["prop"]);
				if v["anim"] then
				    for _,anim in pairs(v["anim"]) do 
					    delete(anim);
				    end
			    end
			    if v["res"] then
				    for _,res in pairs(v["res"]) do 
					    delete(res);
				    end
			    end
			end
		end
		self.m_props = {};

		if type(self._anims) == "table" then
			for k,v in pairs(self._anims) do
				delete(v)
			end
		end
		self._anims = {}
	end

	local dtor = DrawingBase.dtor
	function DrawingBase:dtor()
		self:stopAllActions()
		dtor(self)
	end

	function DrawingBase:setDebugNameByPropAndAnim(sequence , name)
		name = name or "";
		if self.m_props[sequence] then
			local prop = self.m_props[sequence]["prop"];
			if prop then
				prop:setDebugName(name);
				for _,v in pairs(self.m_props[sequence]["anim"]) do 
					if v then
						v:setDebugName(name);
					end
				end
			end
		end
	end


	function DrawingImage:playAnimation(param)
		local frames = param.frames;				-- 动画帧表，file or ResImage;
		local inteval = param.inteval or 500;		-- 隔多少时间更新一帧
		local repeatCount = param.repeatCount or 1;	-- 动画重复次数 如果要永久动画，设为 < 1 的值
		local delay = param.delay or 0;				-- 多长时间后开始播放动画。
		local onComplete = param.onComplete;		-- 动画全播放完后回调

		local currentIndex = 0;						-- 当前帧
		self.m_reses = self.m_reses or {};
		local reses = self.m_reses;					-- 帧资源

		-- 动画播放完后调用，永久性动画进不来这里
		local function playFinished()
			self:stopAnimation();
			if onComplete then
				onComplete();
			end
		end

		-- 更新帧
		local function updateFrame()
			currentIndex = currentIndex + 1;
			if currentIndex > #frames then
				if repeatCount > 0 then
					repeatCount = repeatCount - 1;
					if repeatCount <= 0 then
						playFinished();
						return;
					end
				end
				currentIndex = 1;
			end
		
			if currentIndex > 0 and not reses[currentIndex] then
				local frame = frames[currentIndex];
				if typeof(frame, ResImage) then
					reses[currentIndex] = frame;
				else
					reses[currentIndex] = new(ResImage, frame);
				end
				self:addImage(reses[currentIndex], currentIndex);
			end
			-- 设置当前帧
			self:setImageIndex(currentIndex);
		end

		-- 开始播放帧动画
		local function playAnim()
			self._frameAnimation = new(AnimInt, kAnimLoop, 0, 1, inteval, 0);
			self._frameAnimation:setDebugName(param.DebugName or "FrameAnimation");
			self._frameAnimation:setEvent(self, updateFrame);
		end

		-- 动画开始前先stop掉 前动画
		self:stopAnimation();
		self:setImageIndex(0);

		-- 如果有 延迟播放动画，先延迟
		if delay and delay > 0 then
			self._delayAnimation = new(AnimInt, kAnimNormal, 0, 1, delay, 0);
			self._delayAnimation:setDebugName("delayAnimation");
			self._delayAnimation:setEvent(self, playAnim);
		else
			playAnim();
		end
	end


	function DrawingImage:stopAnimation()
		if self._frameAnimation then delete(self._frameAnimation); self._frameAnimation = nil; end
		if self._delayAnimation then delete(self._delayAnimation); self._delayAnimation = nil; end
	end

	function DrawingImage:dtor()
        self:stopAnimation();
	end
end


local grayShader = require("libEffect/shaders/grayScale")

DrawingImage.setGray = function (self, isGray)
	if isGray then
		grayShader.applyToDrawing(self, {intensity=0})
	else
		grayShader.applyToDrawing(self, {intensity=1})
	end
end

WidgetBase.findChildByName = function(self, name)
	for _,v in pairs(self.m_children) do 
		if v.m_name == name then
			return v;
		end
	end

	for _,v in pairs(self.m_children) do 
		local child = WidgetBase.findChildByName(v, name);
		if child then
			return child
		end
	end
	return nil;
end

WidgetBase.findChildByDebugName = function(self, name)
	for _,v in pairs(self.m_children) do 
		if v.m_debugName == name then
			return v;
		end
	end

	for _,v in pairs(self.m_children) do 
		local child = WidgetBase.findChildByDebugName(v, name);
		if child then
			return child
		end
	end
	return nil;
end

WidgetBase.alive = function ()
	return true
end


--props

DrawingBase.removePropEase = function(self, sequence)
    if drawing_prop_remove(self.m_drawingID, sequence) ~= 0 then
    	return false;
    end

	if self.m_props[sequence] then
		delete(self.m_props[sequence]["prop"]);
		for _,v in pairs(self.m_props[sequence]["anim"]) do 
			delete(v);
		end
		for _,v in pairs(self.m_props[sequence]["res"]) do 
			delete(v);
		end 
		self.m_props[sequence] = nil;
	end
	return true;
end

DrawingBase.removePropEaseByID = function(self, propId)
	if drawing_prop_remove_id(self.m_drawingID, propId) ~= 0 then
		return false;
	end

	for k,v in pairs(self.m_props) do 
		if v["prop"]:getID() == propId then
			delete(v["prop"]);
			for _,anim in pairs(v["anim"]) do 
				delete(anim);
			end
			for _,res in pairs(v["res"]) do 
				delete(res);
			end 
			self.m_props[k] = nil;
			break;
		end
	end
	
	return true;
end

---------------------------------------------------------------------------------------
--------------------------function addPropEase-----------------------------------------
---------------------------------------------------------------------------------------
DrawingBase.addPropColorEase = function(self, sequence, animType, EaseType,duration, delay, rStart, rEnd, gStart, gEnd, bStart, bEnd)
	return DrawingBase.addAnimPropEase(self,sequence,PropColor,nil,nil,nil,animType,EaseType,duration,delay,rStart,rEnd,gStart,gEnd,bStart,bEnd);
end

DrawingBase.addPropTransparencyEase = function(self, sequence, animType,EaseType, duration, delay, startValue, endValue)
	return DrawingBase.addAnimPropEase(self,sequence,PropTransparency,nil,nil,nil,animType,EaseType,duration,delay,startValue,endValue);
end

DrawingBase.addPropScaleEase = function(self, sequence, animType,EaseType, duration, delay, startX, endX, startY, endY, center, x, y)
	local layoutScale = System.getLayoutScale();
	x = x and x * layoutScale or x;
	y = y and y * layoutScale or y;
	return DrawingBase.addAnimPropEase(self,sequence,PropScale,center, x, y,animType,EaseType,duration,delay,startX,endX,startY,endY)
end 

DrawingBase.addPropRotateEase = function(self, sequence, animType, EaseType,duration, delay, startValue, endValue, center, x, y)
	local layoutScale = System.getLayoutScale();
	x = x and x * layoutScale or x;
	y = y and y * layoutScale or y;
	return DrawingBase.addAnimPropEase(self,sequence,PropRotate,center, x, y,animType,EaseType,duration,delay,startValue,endValue);
end

DrawingBase.addPropTranslateEase = function(self,sequence,animType,EaseType,duration,delay,startX,endX,startY,endY)
	local layoutScale = System.getLayoutScale();
	startX = startX and startX * layoutScale or startX;
	endX = endX and endX * layoutScale or endX;
	startY = startY and startY * layoutScale or startY;
	endY = endY and endY * layoutScale or endY;
	return DrawingBase.addAnimPropEase(self,sequence,PropTranslate,nil,nil,nil,animType,EaseType,duration,delay,startX,endX,startY,endY)
end 

DrawingBase.addPropTranslateJump = function(self,sequence,animType,duration,delay,startX,endX,startY,endY,times,height)
	local layoutScale = System.getLayoutScale();
	startX = startX and startX * layoutScale or startX;
	endX = endX and endX * layoutScale or endX;
	startY = startY and startY * layoutScale or startY;
	endY = endY and endY * layoutScale or endY;
	height = height and height * layoutScale or height;
	return DrawingBase.addAnimPropJump(self,sequence,PropTranslate,animType,duration,delay,startX,endX,startY,endY,times,height)
end 

DrawingBase.addAnimPropJump = function(self,sequence,propClass,animType,duration,delay,startX,endX,startY,endY,times,height)
	if not DrawingBase.checkAddProp(self,sequence) then 
		return;
	end

	delay = delay or 0;

	local resJump = {};
	local anims = {};

	resJump[1] = new(ResDoubleArrayJumpX,duration,startX,endX,times,height)
	resJump[2] = new(ResDoubleArrayJumpY,duration,startY,endY,times,height)

	anims[1] = new(AnimIndex,animType,1,resJump[1]:getLength(),duration,resJump[1],delay);
	anims[2] = new(AnimIndex,animType,1,resJump[2]:getLength(),duration,resJump[2],delay);

	local prop = new(propClass,anims[1],anims[2]);
	if DrawingBase.doAddPropEase(self,prop,sequence,anims[1],anims[2],resJump[1],resJump[2]) then
		return anims[1],anims[2];
	end
end 


DrawingBase.addPropTranslateEllipse = function(self,sequence,animType,duration,delay,centerX,centerY,axisX,axisY,angle)
	local layoutScale = System.getLayoutScale();
	centerX = centerX and centerX * layoutScale or centerX;
	centerY = centerY and centerY * layoutScale or centerY;
	axisX = axisX and axisX * layoutScale or axisX;
	axisY = axisY and axisY * layoutScale or axisY;
	return DrawingBase.addAnimPropEllipse(self,sequence,PropTranslate,animType,duration,delay,centerX,centerY,axisX,axisY,angle)
end 

DrawingBase.addAnimPropEllipse = function(self,sequence,propClass,animType,duration,delay,centerX,centerY,axisX,axisY,angle)
	if not DrawingBase.checkAddProp(self,sequence) then 
		return;
	end

	delay = delay or 0;

	local resEllipse = {};
	local anims = {};

	resEllipse[1] = new(ResDoubleArrayEllipseX,duration,centerX,axisX,angle)
	resEllipse[2] = new(ResDoubleArrayEllipseY,duration,centerY,axisY,angle)

	anims[1] = new(AnimIndex,animType,1,resEllipse[1]:getLength(),duration,resEllipse[1],delay);
	anims[2] = new(AnimIndex,animType,1,resEllipse[2]:getLength(),duration,resEllipse[2],delay);

	local prop = new(propClass,anims[1],anims[2]);
	if DrawingBase.doAddPropEase(self,prop,sequence,anims[1],anims[2],resEllipse[1],resEllipse[2]) then
		return anims[1],anims[2];
	end
end 


DrawingBase.addPropTranslateCurve = function(self,sequence,animType,duration,delay,startX,endX,startY,endY,controlX,controlY)
	local layoutScale = System.getLayoutScale();
	startX = startX and startX * layoutScale or startX;
	endX = endX and endX * layoutScale or endX;
	startY = startY and startY * layoutScale or startY;
	endY = endY and endY * layoutScale or endY;
	controlX = controlX and controlX * layoutScale or controlX;
	controlY = controlY and controlY * layoutScale or controlY;
	return DrawingBase.addAnimPropCurve(self,sequence,PropTranslate,animType,duration,delay,startX,endX,startY,endY,controlX,controlY)
end 

DrawingBase.addAnimPropCurve = function(self,sequence,propClass,animType,duration,delay,startX,endX,startY,endY,controlX,controlY)
	if not DrawingBase.checkAddProp(self,sequence) then 
		return;
	end

	delay = delay or 0;

	local resCurve = {};
	local anims = {}

	resCurve[1] = new(ResDoubleArrayCurve,duration,startX,endX,controlX);
	resCurve[2] = new(ResDoubleArrayCurve,duration,startY,endY,controlY);

	anims[1] = new(AnimIndex,animType,1,resCurve[1]:getLength(),duration,resCurve[1],delay);
	anims[2] = new(AnimIndex,animType,1,resCurve[2]:getLength(),duration,resCurve[2],delay);

	local prop = new(propClass,anims[1],anims[2]);
	if DrawingBase.doAddPropEase(self,prop,sequence,anims[1],anims[2],resCurve[1],resCurve[2]) then
		return anims[1],anims[2];
	end
end 

DrawingBase.createAnimEase = function(self, animType, EaseType,duration, delay, startValue, endValue)
	local resEase,anim;
	if startValue and endValue then
		resEase = new(EaseType,duration,startValue,endValue);
		anim = new(AnimIndex,animType,1,resEase:getLength(),duration,resEase,delay);
		return resEase,anim; 
	end 
end 

DrawingBase.addAnimPropEase = function(self,sequence,propClass,center,x,y,animType,EaseType,duration,delay,...)
	if not DrawingBase.checkAddProp(self,sequence) then 
		return;
	end

	delay = delay or 0;

	local nAnimArgs = select("#",...);
	local nAnims = math.floor(nAnimArgs/2);

	local anims = {};
	local resEase = {};

	for i=1,nAnims do 
		local startValue,endValue = select(i*2-1,...);
		resEase[i],anims[i] = DrawingBase.createAnimEase(self,animType,EaseType,duration,delay,startValue,endValue);
	end

	if nAnims == 1 then
		local prop = new(propClass,anims[1],center,x,y);
		if DrawingBase.doAddPropEase(self,prop,sequence,anims[1],resEase[1]) then
			return anims[1];
		end
	elseif nAnims == 2 then
		local prop = new(propClass,anims[1],anims[2],center,x,y);
		if DrawingBase.doAddPropEase(self,prop,sequence,anims[1],anims[2],resEase[1],resEase[2]) then
			return anims[1],anims[2];
		end
	elseif nAnims == 3 then
		local prop = new(propClass,anims[1],anims[2],anims[3],center,x,y);
		if DrawingBase.doAddPropEase(self,prop,sequence,anims[1],anims[2],anims[3],resEase[1],resEase[2],resEase[3]) then
			return anims[1],anims[2],anims[3];
		end
	elseif nAnims == 4 then
		local prop = new(propClass,anims[1],anims[2],anims[3],anims[4],center,x,y);
		if DrawingBase.doAddPropEase(self,prop,sequence,anims[1],anims[2],anims[3],anims[4],resEase[1],resEase[2],resEase[3],resEase[4]) then
			return anims[1],anims[2],anims[3],anims[4];
		end
	else
		for _,v in pairs(anims) do 
			delete(v);
		end
		for _,v in pairs(resEase) do
			delete(v);
		end 
		error("There is not such a prop that requests more than 4 anims");
	end

end 

DrawingBase.doAddPropEase = function(self,prop,sequence, ...)
	local nums = select("#",...) / 2;
	local anims = {};
	local reses = {};
	for i = 1,nums do 
		local anim = select(i,...);
		table.insert(anims,anim);
		local res = select(nums + i,...);
		table.insert(reses,res);
	end 
	if DrawingBase.addProp(self,prop,sequence) then 
		self.m_props[sequence] = {["prop"] = prop;["anim"] = anims;["res"] = reses};
		return true;
	else
		delete(prop);
		for _,v in pairs(anims) do 
			delete(v);
		end 
		for _,v in pairs(reses) do 
			delete(v);
		end 
		return false;
	end 
end 

local easing = require("libEffect/easing");
DrawingBase.addPropTransparencyWithEasing = function(self, sequence, animType, duration, delay, easingFunction, b, c)
    if animType == nil then 
        animType = kAnimNormal
    end 

    if duration == nil then 
        duration = 2000
    end 

    if delay == nil then 
        delay = 0
    end 

    local defaultEasingFn = 'easeInOutQuad'

    if easingFunction == nil then 
        easingFunction = defaultEasingFn
    end 

    if b == nil then 
        b = 0
    end 

    if c == nil then 
        c = 1
    end 


    local data = easing.getEaseArray(easingFunction, duration, b, c)
    local res = new(ResDoubleArray, data)

    local anim = new(AnimIndex, animType, 1, #data, duration, res, delay)

    local prop = new(PropTransparency, anim)

    DrawingBase.doAddProp(self,prop,sequence,anim)

	return anim
end

DrawingBase.addPropTranslateWithEasing = function(self, sequence, animType, duration, delay, easingFunctionX, easingFunctionY, bX, cX, bY, cY)
    if animType == nil then 
        animType = kAnimNormal
    end 

    if duration == nil then 
        duration = 1000
    end 

    if delay == nil then 
        delay = 0
    end 

    local currentX, currentY = self:getPos()
    local defaultOffset = 600

    local defaultEasingFn = function (base) 
        return function (...)
            return easing.fns.easeInCirc(...) + base
        end
    end

    if easingFunctionX == nil then 
        easingFunctionX = defaultEasingFn(currentX - defaultOffset)

        if bX == nil then 
            bX = 0
        end 

        if cX == nil then 
            cX = defaultOffset
        end 
    end 

    if easingFunctionY == nil then 
        easingFunctionY = defaultEasingFn(currentY - defaultOffset)

        if bY == nil then 
            bY = 0
        end 

        if cY == nil then 
            cY = defaultOffset
        end 
    end 

     bX = bX * System.getLayoutScale();
     cX = cX * System.getLayoutScale();
     bY = bY * System.getLayoutScale();
     cY = cY * System.getLayoutScale();

    local dataX = easing.getEaseArray(easingFunctionX, duration, bX, cX)
    local resX = new(ResDoubleArray, dataX)

    local dataY = easing.getEaseArray(easingFunctionY, duration, bY, cY)
    local resY = new(ResDoubleArray, dataY)

    local animX = new(AnimIndex, animType, 1, #dataX, duration, resX, delay)
    local animY = new(AnimIndex, animType, 1, #dataY, duration, resY, delay)

    local prop = new(PropTranslate, animX, animY)

    DrawingBase.doAddProp(self,prop,sequence,animX,animY)

	return animX, animY
end

DrawingBase.addPropRotateWithEasing = function(self, sequence, animType, duration, delay, easingFunction, b, c, center, x, y)
    if animType == nil then 
        animType = kAnimNormal
    end 

    if duration == nil then 
        duration = 400
    end 

    if delay == nil then 
        delay = 0
    end 

    local defaultEasingFn = 'easeOutExpo'

    if easingFunction == nil then 
        easingFunction = defaultEasingFn
    end 

    if b == nil then 
        b = 0
    end 

    if c == nil then 
        c = 360
    end 

    if center == nil then 
        center = kCenterDrawing
    end 


    local data = easing.getEaseArray(easingFunction, duration, b, c)
    local res = new(ResDoubleArray, data)

    local anim = new(AnimIndex, animType, 1, #data, duration, res, delay)

    local prop = new(PropRotate, anim, center, x, y)

    DrawingBase.doAddProp(self,prop,sequence,anim)

	return anim
end

DrawingBase.addPropScaleWithEasing = function(self, sequence, animType, duration, delay, easingFunctionX, easingFunctionY, b, c, center, x, y)
    if animType == nil then 
        animType = kAnimNormal
    end 

    if duration == nil then 
        duration = 400
    end 

    if delay == nil then 
        delay = 0
    end 

    local defaultEasingFn = 'easeOutExpo'

    if easingFunctionX == nil then 
        easingFunctionX = defaultEasingFn
    end 

    if easingFunctionY == nil then 
        easingFunctionY = defaultEasingFn
    end 

    if b == nil then 
        b = 0
    end 

    if c == nil then 
        c = 1
    end 

    local dataX = easing.getEaseArray(easingFunctionX, duration, b, c)
    local resX = new(ResDoubleArray, dataX)

    local dataY = easing.getEaseArray(easingFunctionY, duration, b, c)
    local resY = new(ResDoubleArray, dataY)

    local animX = new(AnimIndex, animType, 1, #dataX, duration, resX, delay)
    local animY = new(AnimIndex, animType, 1, #dataY, duration, resY, delay)

    if center == nil then 
        center = kCenterDrawing
    end 

    local prop = new(PropScale, animX, animY, center, x, y)

    DrawingBase.doAddProp(self,prop,sequence,animX,animY)

	return animX, animY
end

DrawingBase.addPropScaleXWithEasing = function(self, sequence, animType, duration, delay, easingFunctionX, easingFunctionY, b, c, center, x, y)
    if animType == nil then 
        animType = kAnimNormal
    end 

    if duration == nil then 
        duration = 400
    end 

    if delay == nil then 
        delay = 0
    end 

    local defaultEasingFn = 'easeOutExpo'

    if easingFunctionX == nil then 
        easingFunctionX = defaultEasingFn
    end 

    if easingFunctionY == nil then 
        easingFunctionY = defaultEasingFn
    end 

    b = b or 0;
    c = c or 1;

    local dataX = easing.getEaseArray(easingFunctionX, duration, b, c)
    local resX = new(ResDoubleArray, dataX)

    local animX = new(AnimIndex, animType, 1, #dataX, duration, resX, delay)
    local animY = nil;

    if center == nil then 
        center = kCenterDrawing
    end 

    local prop = new(PropScale, animX, animY, center, x, y)

    DrawingBase.doAddProp(self,prop,sequence,animX,animY)

	return animX
end
DrawingBase.addPropScaleYWithEasing = function(self, sequence, animType, duration, delay, easingFunctionX, easingFunctionY, b, c,center, x, y)
    if animType == nil then 
        animType = kAnimNormal
    end 

    if duration == nil then 
        duration = 400
    end 

    if delay == nil then 
        delay = 0
    end 

    local defaultEasingFn = 'easeOutExpo'

    if easingFunctionX == nil then 
        easingFunctionX = defaultEasingFn
    end 

    if easingFunctionY == nil then 
        easingFunctionY = defaultEasingFn
    end 

    b = b or 0;
    c = c or 1;

    local dataY = easing.getEaseArray(easingFunctionY, duration, b, c)
    local resY = new(ResDoubleArray, dataY)

    local animX = nil;
    local animY = new(AnimIndex, animType, 1, #dataY, duration, resY, delay);

    if center == nil then 
        center = kCenterDrawing
    end 

    local prop = new(PropScale, animX, animY, center, x, y)

    DrawingBase.doAddProp(self,prop,sequence,animX,animY)

	return animY
end
--[[
	
	actions:{
		{name,from,to,duration,timing},
		{name,from,to,duration,timing},
	}
	pramas:{
		order: "normal" ,--"sequence","spawn"
		loopType: kAnimNormal,--kAnimLoop,kAnimRepeat
		onComplete, --回调
		is_relative, --是不是相对运动
	}
	
]]
	
function DrawingBase:runAction(actions,pramas)
	pramas = pramas or {}
	local order = pramas.order or "normal"
	local loopType = pramas.loopType or kAnimNormal
	local onComplete = pramas.onComplete

	local M = require 'animation'
	local prop_fun
	if pramas.is_relative then
		prop_fun = M.prop_by
	else
		prop_fun = M.prop
	end
	local _prop
	if order=="normal" then
		local action = actions
		_prop = prop_fun(action[1],action[2],action[3],action[4],action[5])
		
	elseif order=="spawn" or order=="sequence" then
		local props = {}
		for i=1,#actions do
			local action = actions[i]
			if #action>=4 then
				local prop = prop_fun(action[1],action[2],action[3],action[4],action[5])
				props[#props+1] = prop
				-- print(prop)
				-- dump(action)
			end
		end
		if order=="sequence" then
			_prop = M.sequence(unpack(props))
		else
			_prop = M.spawn(unpack(props))
		end
	end

    local anim = M.Animator(_prop, M.updator(self:getWidget()), loopType)
    anim.on_stop = function ()
        if onComplete and type(onComplete)=="function" then
        	onComplete()
        end
    end
    anim:start()
    return anim
end

function DrawingBase:roate(_roate)
	local widget = self:getWidget()
	widget.rotation = _roate
	return self
end

function DrawingBase:getRoation()
	local widget = self:getWidget()
	return widget.rotation
end

function DrawingBase:scale(x,y)
	local widget = self:getWidget()
	y =  y or x
	widget.scale_x = x
	widget.scale_y = y
	return self
end

function DrawingBase:anchor(x,y)
	local widget = self:getWidget()
	widget.anchor_x = x
	widget.anchor_y = y
	return self
end

function DrawingBase:_scale_at_anchor_point(bol)
	local widget = self:getWidget()
	widget.scale_at_anchor_point = bol
	return self
end

function DrawingBase:getScale()
	local widget = self:getWidget()
	return widget.scale_x,widget.scale_y
end

function DrawingBase:pos(x,y)
	self:setPos(x,y)
	return self
end

function DrawingBase:size(w,h)
	self:setSize(w,h)
	return self
end

function DrawingBase:name(name)
	self:setName(name)
	return self
end

--要缩放的节点，尽量是宽高都为1的，避免算坐标、锚点
function DrawingBase:roateTo(_roate,_time,callback)
	local now = self:getWidget().rotation
	self:runAction({"rotation",now,_roate,_time},{onComplete = callback})
	return self
end

function DrawingBase:moveTo(x,y,_time,callback)
	local now = self:getWidget().pos
	local toPoint = Point(x,y)
	toPoint:mul(System.getLayoutScale())
	self:runAction({"pos",now,toPoint,_time},{onComplete = callback})
	return self
end