local ctor = Button.ctor;
Button.ctor = function(self, normalFile, disableFile, fmt, filter, leftWidth, rightWidth, topWidth, bottomWidth)
	ctor(self, normalFile, disableFile, fmt, filter, leftWidth, rightWidth, topWidth, bottomWidth);
	self.m_animFlag = true
	self.m_downX = 0;
	self.m_downY = 0;
	self.m_enableEvent = true;
	self.m_soundFlag = true
end

Button.getEventCallback = function(self)
	return self.m_eventCallback
end

Button.enableShow = function(self, enable)
	if not enable then
		self.m_showEnbaleFunc = function()
			-- body
		end
	end
end

Button.getEnable = function(self)
	return self.m_enable;
end

Button.enableAnim = function(self, flag)
	self.m_animFlag = flag
end

Button.enableSound = function(self, flag)
	self.m_soundFlag = flag
end

Button.setScaleOffset = function(self,offset)
	self._scaleOffset = offset
end

--virtual
Button.showEnableWithoutDisableImage = function(self, enable, anim)
	if enable then
		self:setColor(255,255,255);
	else
		self:setColor(220,220,220);
	end
	self._scaleOffset = self._scaleOffset or 1.05
	if anim and self.m_animFlag then
		local startScale = enable and self._scaleOffset or 1.0
		local endScale = enable and 1.0 or self._scaleOffset
		local sequence = enable and 1234 or 4321 -- 避免影响其他
		local releaseSequence = enable and 4321 or 1234 -- 避免影响其他
		if self.m_props[releaseSequence] then
			self:removeProp(releaseSequence)
		end
		if self.m_props[sequence] then
			self:removeProp(sequence)
		end
		local scaleAnim = self:addPropScale(sequence, kAnimNormal, 200, 0, startScale, endScale, startScale, endScale, kCenterDrawing)
		if scaleAnim then
			scaleAnim:setEvent(nil, function()
				if enable then
					if self.m_props[releaseSequence] then
						self:removeProp(releaseSequence)
					end
					if self.m_props[sequence] then
						self:removeProp(sequence)
					end
				end
			end)
		end
	end
end	

--virtual
Button.onClick = function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
	if not self.m_enable then
		return;
	end

	if finger_action == kFingerDown then
		self.onceFlag = false
	   	self.m_showEnbaleFunc(self,false,true);

	   	self.m_downX, self.m_downY = self:getAbsolutePos();
	   	self.m_enableEvent = true;

	elseif finger_action == kFingerMove then
		if not self.onceFlag then
			if not (self.m_responseType == kButtonUpInside and drawing_id_first ~= drawing_id_current) then
				self.m_showEnbaleFunc(self,false);
			else
				self.m_showEnbaleFunc(self,true);
			end
			self.onceFlag = true
		end
		local downX, 	downY 	= self:getAbsolutePos();
		if self.m_enableEvent then
        	self.m_enableEvent 	= math.abs(self.m_downX - downX) < 50 and math.abs(self.m_downY - downY) < 50;
       	end
	elseif finger_action == kFingerUp then
		self.m_showEnbaleFunc(self,true,true);
		
		local responseCallback = function()
			if self.m_eventCallback.func then
				if self.m_soundFlag then
					kEffectPlayer:play(Effects.AudioButtonClick)
					kEffectPlayer:setVolume(GameSetting:getSoundVolume())
				end

				local downX, downY = self:getAbsolutePos();
				if  self.m_enableEvent 					and
					math.abs(self.m_downX - downX) < 50 and 
					math.abs(self.m_downY - downY) < 50 then
                	self.m_eventCallback.func(self.m_eventCallback.obj,finger_action,x,y,
                		drawing_id_first,drawing_id_current);
               	end
            end	
		end

		if self.m_responseType == kButtonUpInside then
			if drawing_id_first == drawing_id_current then
				responseCallback();
			end
	    elseif self.m_responseType == kButtonUpOutside then
	    	if drawing_id_first ~= drawing_id_current then
				responseCallback();
			end
		else
			responseCallback();
		end
	elseif finger_action==kFingerCancel then
		self.m_showEnbaleFunc(self,true,true);
	end
end