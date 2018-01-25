local AnimSprite = class(Node, false);


function AnimSprite:ctor(pintu, path, deltaTime, ...)
	-- body
	super(self, ...)
	assert(pintu)
	self.mPintu  = pintu;
	self.mPath 	 = path;
	self.mTemp	 = new(Image, pintu[path[1]]);
	self.mSprite = new(Image, pintu and pintu[path[1]] or path[1]);
	self:addChild(self.mSprite);
	self:addChild(self.mTemp);
	self.mTemp:setVisible(false)
	self.mDeltaTime = deltaTime or 5

	self:setSize(self.mSprite.m_res.m_width, self.mSprite.m_res.m_height)
end

function AnimSprite:dtor()
	-- body
end

function AnimSprite:getSprite()
    -- body
    return self.mSprite
end

function AnimSprite:play()
	-- body
	checkAndRemoveOneProp(self, 1);

	local startIndex 	= 1;
    -- local timer = new(AnimInt, kAnimRepeat, 0, 0, self.mDeltaTime, 0);
	local timer 		= self:addPropTransparency(1, kAnimRepeat, self.mDeltaTime, 0, 1, 1);
    
    timer:setEvent(self, function ( self )
    	
    	if startIndex > #self.mPath then
    		startIndex = 1;
    	end

    	if startIndex <= #self.mPath then
    		self.mSprite:setFile(self.mPintu[self.mPath[startIndex]])
    	end
    	startIndex = startIndex + 1;
    end)
    return self;
end

function AnimSprite:playTimeList(timeList, obj, callback)
	-- body
	checkAndRemoveOneProp(self, 1);

    -- local startTime     = os.clock() * 1000
    local startTime     =  sys_get_int("tick_time",0);
	local startIndex 	= 1;
	local timer 		= self:addPropTransparency(1, kAnimRepeat, self.mDeltaTime, 0, 1, 1);
    
    timer:setEvent(self, function ( self )

    	-- local curTime = os.clock() * 1000 - startTime
        local curTime = sys_get_int("tick_time",0) - startTime

        repeat 

            if startIndex > #timeList then break end

            if startIndex <= #self.mPath then
                self.mSprite:setFile(self.mPintu[self.mPath[startIndex]])
            end

            if curTime >= timeList[startIndex] then
                startIndex = startIndex + 1
            end

            return 

        until true
        checkAndRemoveOneProp(self, 1)
        if callback then callback(obj) end
    end)
    return self;
end

function AnimSprite:stop()
	-- body
end

return AnimSprite