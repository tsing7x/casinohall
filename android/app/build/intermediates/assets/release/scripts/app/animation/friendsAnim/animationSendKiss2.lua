--泼水动画
local AnimCurve = require("app.animation/friendsAnim/animCurve");
new(Image, "hongdong/kiss/hddj_kiss_lip_icon.png")
new(Image, "hongdong/kiss/hddj_kiss_heart.png")

animationSendKiss2 =class(Node);

function animationSendKiss2.ctor(self,p1,p2)

        self.m_p1=p1;
        self.m_p2=p2;
        self.m_h=220;
        self.m_pnum=55;
        self.isPlaying=false;
        self.baseSquence=10;

        self:load();

        self.m_animCurve={};
        if math.abs(p1.x-p2.x)<=100 then
            self.m_animCurve=AnimCurve.createLineCurve(self.m_p1,self.m_p2,self.m_pnum);
        else
            self.m_animCurve=AnimCurve.createParabolaCurve(self.m_p1,self.m_p2,self.m_h, self.m_pnum);
        end

end
--加载资源
function animationSendKiss2.load(self)
        --fly png
        self.m_flypng=UIFactory.createImage("hongdong/kiss/hddj_kiss_lip_icon.png",nil,nil,0,0,0,0);
        self:addChild(self.m_flypng);
        self.m_flypng:setVisible(false);
        self.m_flypng:setPos(self.m_p1.x,self.m_p1.y);

       
       --上下移动的egg
     self.m_updownegg=UIFactory.createImage("hongdong/kiss/hddj_kiss_heart.png",nil,nil,0,0,0,0);
     self:addChild( self.m_updownegg);
     self.m_updownegg:setVisible(false);
     self.m_updownegg:setPos(self.m_p2.x,self.m_p2.y);
    -- local tW, tH = self.m_updownegg:getSize();
end

--开始播放动画
function animationSendKiss2.play(self)

    if self.isPlayAnim then
     return;
    end
   
    self.isPlaying=true;
    self:throwTargetAnim();

end


--飞出图片
function animationSendKiss2.throwTargetAnim(self )
 
	    self.m_index = 1;
	    self.m_speed = 50;	-- 速度
	    -- self.m_targetAnim = new(AnimInt, kAnimRepeat, 0, 1, 15, 0);
        self.m_targetAnim =self.m_flypng:addPropRotate(0,kAnimRepeat, 15,0,0,0,kCenterDrawing);
        self.m_targetAnim:setDebugName("animationSendKiss2 || self.m_targetAnim");
 	    kEffectPlayer:play(Effects.PropRose2);
        self.m_flypng:setVisible(true)
	    self.m_targetAnim:setEvent(nil, function()
		if self.m_flypng~=nil then
    		
    		self.m_flypng:setPos(self.m_animCurve[self.m_index].x, self.m_animCurve[self.m_index].y);
    		self.m_index = self.m_index + 1;
    		
    		if self.m_index >= #self.m_animCurve then
    			self.m_index = 1;
    			self.m_flypng:setVisible(false);
    			-- delete(self.m_targetAnim);
                checkAndRemoveOneProp(self.m_flypng,0)
    			self.m_targetAnim = nil;
    			self:playStartAnim();
    		end
        else
            self.m_flypng:setVisible(false);
            -- delete(self.m_targetAnim);
            checkAndRemoveOneProp(self.m_flypng,0)
            self.m_targetAnim = nil;
            self:playStartAnim();
        end 
	end);

end



--动画
function animationSendKiss2.playStartAnim(self)

    kEffectPlayer:play(Effects.AudioKiss);
    self.m_flypng:setPos(self.m_p2.x+33,self.m_p2.y+40);
    self.m_updownegg:setPos(self.m_p2.x+33,self.m_p2.y+50);
    self.m_flypng:setVisible(true);
    self.myIndex = 0;
    self.m_updownegg:setVisible(true);
    self.anim2= self.m_updownegg:addPropTranslate(10,kAnimRepeat,400,0,0,0,0,-100);--self.m_p2.x,self.m_p2.x,self.m_p2.y,self.m_p2.y-50);
    self.anim= self.m_flypng:addPropScale(10,kAnimRepeat,400,0,0,1,0,1,kCenterDrawing, 0, 0)
    self.anim:setEvent(self, self.showStartOnTime);

end

function animationSendKiss2.showStartOnTime(self)
    if self.myIndex > 2 then
        self:stop();
    end

    self.myIndex= self.myIndex + 1;
   
end
--停止动画
function animationSendKiss2.stop(self)

    self.isPlaying=false;
    if self.m_parent then
        self.m_parent:removeChild(self, true);
    end

end

--注销资源
function animationSendKiss2.dtor(self)

end

return animationSendKiss2;


--endregion
