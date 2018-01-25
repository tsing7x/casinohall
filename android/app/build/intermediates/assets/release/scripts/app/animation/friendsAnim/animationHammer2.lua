--锤子动画
require("app.atomAnim/atomAnimManager");
local AnimCurve = require("app.animation/friendsAnim/animCurve");
require("pintu.hongdong.hammer")
new(Image, "hongdong/hammer.png")

animationHammer2 =class(Node);

function animationHammer2.ctor(self,p1,p2)

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
function animationHammer2.load(self)
        --fly png
        self.m_flypng=UIFactory.createImage(hammer_map["hammer.png"]);
        self:addChild(self.m_flypng);
        self.m_flypng:setVisible(false);
        self.m_flypng:setPos(self.m_p1.x,self.m_p1.y);

        --添加pngs
        self.dirs={};
        for i=1, 15 do
            if i<10 then
                table.insert(self.dirs,i,hammer_map[string.format("hddj-8-000%d.png",i)]);
            else
                table.insert(self.dirs,i,hammer_map[string.format("hddj-8-00%d.png",i)]);
            end
        end

        self.m_pngs=UIFactory.createImages(self.dirs);
        self:addChild(self.m_pngs);
        self.m_pngs:setVisible(false);
        --local fsW,fsH=self.flowers:getSize(); 暂时用不到
        self.m_pngs:setPos(self.m_p2.x-120,self.m_p2.y);

end

--开始播放动画
function animationHammer2.play(self)

  --   AtomAnimManager.getInstance():playAnim("atomAnimTable/test/dd", self.m_root, 0, 0, true);
 
    if self.isPlayAnim then
     return;
    end
   
    self.isPlaying=true;
    self:throwTargetAnim();
 
end


--飞出图片
function animationHammer2.throwTargetAnim(self )

	    self.m_index = 1;
	    self.m_speed = 50;	-- 速度
	    -- self.m_targetAnim = new(AnimInt, kAnimRepeat, 0, 1, 15, 0);
        self.m_targetAnim =self.m_flypng:addPropRotate(0,kAnimRepeat, 15,0,0,0,kCenterDrawing);
        self.m_targetAnim:setDebugName("animationHammer2 || self.m_targetAnim");
 	    kEffectPlayer:play(Effects.AudioHammer);
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
function animationHammer2.playStartAnim(self)

       kEffectPlayer:play(Effects.AudioHammer);
    -- print_string("playStartAnim---------------------------");
       self.m_pngs:setVisible(true);
       self.imgIndex = 0;
       self.anim= self.m_pngs:addPropRotate(0,kAnimRepeat, 90,0,0,0,kCenterDrawing);
       self.anim:setDebugName("animationHammer2 || self.anim");
	   self.anim:setEvent(self, self.showStartOnTime);

end

function animationHammer2.showStartOnTime(self)

    if self.m_pngs.m_reses then
		local index = self.imgIndex;
		if index > 15 then
			index = 15;
			self.m_pngs:setVisible(false);
		else
			self.m_pngs:setImageIndex(index);
			self.m_pngs:setVisible(true);
		end
	else
		self:stop();
		return;
	end

    self.imgIndex = self.imgIndex + 1;
   
end
--停止动画
function animationHammer2.stop(self)

    self.isPlaying=false;
    if self.m_parent then
        self.m_parent:removeChild(self, true);
    end

end

--注销资源
function animationHammer2.dtor(self)

end

return animationHammer2;


--endregion
