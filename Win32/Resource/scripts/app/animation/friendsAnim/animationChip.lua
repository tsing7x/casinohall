--西红柿动画
local AnimCurve = require("app.animation/friendsAnim/animCurve");

animationChip =class(Node);

function animationChip.ctor(self,p1,p2)

        self.m_p1=p1;
        self.m_p2=p2;
        self.m_h=220;
        self.m_pnum=55;
        self.isPlaying=false;
        self.baseSquence=10;

        self:load();

        self.m_animCurve={};
        if (p1.x-p2.x)<=100 then
            self.m_animCurve=AnimCurve.createLineCurve(self.m_p1,self.m_p2,self.m_pnum);
        else
            self.m_animCurve=AnimCurve.createParabolaCurve(self.m_p1,self.m_p2,self.m_h, self.m_pnum);
        end

end
--加载资源
function animationChip.load(self)
        self.m_root=new(Node);
        self.m_root:addToRoot();

        --fly png
        self.m_flypng=UIFactory.createImage("dice/room/playerinfo/chih.png",nil,nil,0,0,0,0);
        self.m_root:addChild(self.m_flypng);
        self.m_flypng:setVisible(false);
        self.m_flypng:setPos(self.m_p1.x,self.m_p1.y);

        --添加pngs
--        self.dirs={};
--        for i=1, 14 do
--            if i<10 then
--                table.insert(self.dirs,i,string.format("hongdong/tomato/hddj-6-000%d.png",i));
--            else
--                table.insert(self.dirs,i,string.format("hongdong/tomato/hddj-6-00%d.png",i));
--            end
--        end

--        self.m_pngs=UIFactory.createImages(self.dirs);
--        self.m_root:addChild(self.m_pngs);
--        self.m_pngs:setVisible(false);
--        --local fsW,fsH=self.flowers:getSize(); 暂时用不到
--        self.m_pngs:setPos(self.m_p2.x,self.m_p2.y);

end

--开始播放动画
function animationChip.play(self)

    if self.isPlayAnim then
     return;
    end
   
    self.isPlaying=true;
    self:throwTargetAnim();

end


--飞出图片
function animationChip.throwTargetAnim(self )
 
     

	    self.m_index = 1;
	    self.m_speed = 50;	-- 速度
	   self.m_targetAnim = new(AnimInt, kAnimRepeat, 0, 1, 20, 0);
                                  -- self,sequence,animType,duration,delay,startValue,endValue,center, x, y
      -- self.m_flypng:addPropRotate(1,kAnimRepeat,10,1,0,0,kCenterDrawing,0,180);
      --DrawingBase.addPropRotate = function(self,sequence,animType,duration,delay,startValue,endValue,center, x, y)
      self.m_flypng:addPropRotate(1, kAnimRepeat,1000,-1, 0, 360, kCenterDrawing,0,180);
      -- self.m_circle:addPropRotate(1, kAnimRepeat,10,-1, 0, 360, kCenterDrawing);
       -- self.m_targetAnim =--0,kAnimRepeat, 300,0,0,0,kCenterDrawing);
        self.m_targetAnim:setDebugName("animationChip || self.m_targetAnim");
 	    kEffectPlayer:play(Effects.PropRose2);
        
	    self.m_targetAnim:setEvent(nil, function()
		
		self.m_flypng:setVisible(true);
       
		self.m_flypng:setPos(self.m_animCurve[self.m_index].x, self.m_animCurve[self.m_index].y);
          

		self.m_index = self.m_index + 1;
		
		if self.m_index >= #self.m_animCurve then
			self.m_index = 1;
			self.m_flypng:setVisible(false);
			delete(self.m_targetAnim);
      checkAndRemoveOneProp(self.m_flypng,1)
			self.m_targetAnim = nil;
			self:playStartAnim();
		end

	end);

end



--动画
function animationChip.playStartAnim(self)

       kEffectPlayer:play(Effects.AudioTomato);
        -- print_string("playStartAnim---------------------------");
        self.m_p2.x=self.m_p2.x+20;
        self.m_p2.y=self.m_p2.y+20;
       self.m_flypng:setPos(self.m_p2.x,self.m_p2.y);
       self.m_flypng:setVisible(true);
      -- self.m_flypng:addPropTransparency(self.baseSquence+1, kAnimNormal, 100, 0, 10, 10);
       self.myIndex = 0;
       self.anim= self.m_flypng:addPropRotate(0,kAnimRepeat, 150,0,0,0,kCenterDrawing);
       self.anim:setDebugName("animationChip || self.anim");
	   self.anim:setEvent(self, self.showStartOnTime);

end

function animationChip.showStartOnTime(self)

     if self.myIndex>3 then
            self.m_flypng:setVisible(false);
            delete( self.anim);
            self.anim=nil;
            self:stop();
      else
           local rindex=self.myIndex;
           self.m_flypng:setPos(self.m_p2.x,self.m_p2.y+rindex);
      end
    self.myIndex=self.myIndex+1;
   
end
--停止动画
function animationChip.stop(self)

    self.isPlaying=false;
    self:dtor();

end

--注销资源
function animationChip.dtor(self)

        if self.m_flypng then
             delete(self.m_flypng);
             self.m_flypng=nil;
         end


         if self.m_animCurve then
             delete(self.m_animCurve);
             self.m_animCurve=nil;
         end

         if self.m_target then
             delete(self.m_target);
             self.m_target=nil;
         end

         if self.anim then
             delete(self.anim);
             self.anim=nil;
         end

        if self.m_root then
             delete(self.m_root);
             self.m_root=nil;
         end

end

return animationChip;


--endregion
