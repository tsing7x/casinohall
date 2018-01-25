
--玫瑰花动画
local AnimCurve = require("app/animation/friendsAnim/animCurve");
require("app/animation/friendsAnim/friendAnim_pin");
require("app/atomAnim/resEx")

local animationAddFriend=class(Node);

--p1是起点坐标,p2终点坐标
function animationAddFriend.ctor(self,p1,p2)
    self.m_p1=p1;
    self.m_p2=p2;
    self.m_h = 220;	--弧线高度
    self.m_pnum = 55;
    self.isPlaying = false;
    self.baseSequence = 10;

    self:load();

    self.m_animCurve={};
    if math.abs(p1.x-p2.x)<=100 then
        self.m_animCurve=AnimCurve.createLineCurve(self.m_p1,self.m_p2,self.m_pnum);
    else
        self.m_animCurve=AnimCurve.createParabolaCurve(self.m_p1,self.m_p2,self.m_h,self.m_pnum);
    end
   
end



--加载资源
function animationAddFriend.load(self)

    --从起点飞动的
     -- self.m_flypng=UIFactory.createImage("hongdong/addfriend/mail.png",nil,nil,0,0,0,0);
      self.m_flypng= new(Image,"hongdong/addfriend/mail.png")
     self:addChild( self.m_flypng);
     self.m_flypng:setVisible(false);
     self.m_flypng:setPos(self.m_p1.x,self.m_p1.y);
     local tW, tH = self.m_flypng:getSize();

     self.m_p2.x=self.m_p2.x+12;
     self.m_p2.y=self.m_p2.y+26;
     --上下移动的egg
     self.m_scaleMail=UIFactory.createImage("hongdong/addfriend/mail.png",nil,nil,0,0,0,0);
     self:addChild( self.m_scaleMail);
     self.m_scaleMail:setVisible(false);
     self.m_scaleMail:setPos(self.m_p2.x,self.m_p2.y);

    
end



-- 播放动画
function animationAddFriend.play(self)
if self.isPlaying then
return;
end
self.isPlaying=true;
self:playStartAnim();
end

-- 播放动画
function animationAddFriend.playStartAnim(self)
--self.m_flypng:setVisible(true);
self:throwTargetAnim();
--self.m_flypngs:setVisible(true);

end


function animationAddFriend.throwTargetAnim( self )

	self.m_index = 1;
	self.m_speed = 50;	-- 速度
	-- self.m_targetAnim = new(AnimInt, kAnimRepeat, 0, 1, 15, 0);
    self.m_targetAnim =self.m_flypng:addPropRotate(0,kAnimRepeat, 15,0,0,0,kCenterDrawing);
    self.m_targetAnim:setDebugName("animationAddFriend || self.m_targetAnim");
    self.m_flypng:addPropRotate(1, kAnimRepeat,1000,-1, 0, 360, kCenterDrawing,0,180);
    self.m_flypng:setVisible(true)
	self.m_targetAnim:setEvent(nil, function()
		if self.m_flypng~=nil then
    		self.m_flypng:setPos(self.m_animCurve[self.m_index].x, self.m_animCurve[self.m_index].y);
    		self.m_index = self.m_index + 1;
    		if self.m_index >= #self.m_animCurve then
    			self.m_index = 1;
    			self.m_flypng:setVisible(false);
                checkAndRemoveOneProp(self.m_flypng,0);
                checkAndRemoveOneProp(self.m_flypng,1);
    			-- delete(self.m_targetAnim);
    			self.m_targetAnim = nil;
    			self:showm_flypngs();
    		end
        else
            self.m_flypng:setVisible(false);
            -- delete(self.m_targetAnim);
            checkAndRemoveOneProp(self.m_flypng,0);
            checkAndRemoveOneProp(self.m_flypng,1);
            self.m_targetAnim = nil;
            self:playStartAnim();
        end 
	end);
end

--由上向下移动
function animationAddFriend.showm_flypngs(self)
 
        kEffectPlayer:play(Effects.AudioEgg);
        self.m_scaleMail:setVisible(true);
        self.m_scaleMail:addPropScaleEase(1, kAnimNormal, ResDoubleArraySinIn, 500, 0, 1, 2.0, 1, 2.0, kCenterDrawing);
        self.m_scaleMail:addPropTransparency(2, kAnimNormal, 500, 0, 1.0, 0)
        self.anim= self.m_scaleMail:addPropRotate(0,kAnimRepeat, 40,0,0,0,kCenterDrawing);
        self.anim:setDebugName("animationAddFriend || self.showm_flypngs");
	    self.anim:setEvent(self, self.showStartOnTime);
        self.myIndex=0;
    
     
end

function animationAddFriend.showStartOnTime(self)

  if self.myIndex>40 then
     self:stop();
  end
  self.myIndex=self.myIndex+1;

end
--停止动画
function animationAddFriend.stop(self)

    self.m_isPlaying=false;
    if self.m_parent then
        self.m_parent:removeChild(self, true);
    end

end

--函数注销
function animationAddFriend.dtor(self)
end


return animationAddFriend;
--endregion
