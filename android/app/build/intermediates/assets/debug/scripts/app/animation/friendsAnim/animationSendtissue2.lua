--泼水动画
local AnimCurve = require("app.animation/friendsAnim/animCurve");

animationSendtissue2 =class(Node);

function animationSendtissue2.ctor(self,p1,p2)

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
function animationSendtissue2.load(self)
        --fly png
        self.m_flypng=UIFactory.createImage("hongdong/tissue/hddj_tissue_icon.png",nil,nil,0,0,0,0);
        self:addChild(self.m_flypng);
        self.m_flypng:setVisible(false);
        self.m_flypng:setPos(self.m_p1.x,self.m_p1.y);

      
         --上下移动的pic
         self.m_updownegg=UIFactory.createImage("hongdong/tissue/hddj_tissue.png",nil,nil,0,0,0,0);
         self:addChild( self.m_updownegg);
         self.m_updownegg:setVisible(false);
         self.m_updownegg:setPos(self.m_p2.x,self.m_p2.y);
      

end

--开始播放动画
function animationSendtissue2.play(self)

    if self.isPlayAnim then
     return;
    end
   
    self.isPlaying=true;
    self:throwTargetAnim();

end


--飞出图片
function animationSendtissue2.throwTargetAnim(self )
 
	    self.m_index = 1;
	    self.m_speed = 50;	-- 速度
	    -- self.m_targetAnim = new(AnimInt, kAnimRepeat, 0, 1, 15, 0);
        self.m_targetAnim =self.m_flypng:addPropRotate(0,kAnimRepeat, 15,0,0,0,kCenterDrawing);
        self.m_targetAnim:setDebugName("animationSendtissue2 || self.m_targetAnim");
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
    		   self:showm_flypngs();
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




--由上向下移动
function animationSendtissue2.showm_flypngs(self)
 kEffectPlayer:play(Effects.AudioTissure);

        self.m_updownegg:setVisible(true);
        self.anim= self.m_updownegg:addPropRotate(0,kAnimRepeat, 20,0,0,0,kCenterDrawing);
        self.anim:setDebugName("animationSendtissue2 || self.showm_flypngs");
	    self.anim:setEvent(self, self.showStartOnTime);
        self.myIndex=0;
        self.myIndex2=0;
        self.z=true;
end

function animationSendtissue2.showStartOnTime(self)

    if self.myIndex>50*4 then
        self:stop();
    else

       --处理向左向右情况 
        if self.z then
            self.myIndex2=self.myIndex2+1;
            if self.myIndex2>=50 then
                self.z =false;
            end
        else
            self.myIndex2=self.myIndex2-1;
             if self.myIndex2<=1 then
                self.z =true;
             end
        end

       local rindex=self.myIndex2;
       self.m_updownegg:setPos(self.m_p2.x+rindex,self.m_p2.y+30);
    end
  
  
  self.myIndex=self.myIndex+1;

end


--停止动画
function animationSendtissue2.stop(self)

    self.isPlaying=false;
    if self.m_parent then
        self.m_parent:removeChild(self, true);
    end

end

--注销资源
function animationSendtissue2.dtor(self)

end

return animationSendtissue2;


--endregion
