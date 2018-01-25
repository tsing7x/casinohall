
--玫瑰花动画
local AnimCurve = require("app.animation/friendsAnim/animCurve");
require("app.animation/friendsAnim/friendAnim_pin");
require("pintu.hongdong.rowse")
new(Image, "hongdong/rowse.png")

local AnimationSendRose2=class(Node);

--p1是起点坐标,p2终点坐标
function AnimationSendRose2.ctor(self,p1,p2)
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
function AnimationSendRose2.load(self)

    --从起点飞动的花
     self.flower=UIFactory.createImage(rowse_map["rowse.png"]);
     self:addChild( self.flower);
     self.flower:setVisible(false);
     self.flower:setPos(self.m_p1.x,self.m_p1.y);
     local tW, tH = self.flower:getSize();

    self.dirs={};
    for i=1, 14 do
        if i<10 then
        table.insert(self.dirs,i,rowse_map[string.format("hddj-3-000%d.png",i)]);
        else
         table.insert(self.dirs,i,rowse_map[string.format("hddj-3-00%d.png",i)]);
        end
    end
    self.flowers=UIFactory.createImages(self.dirs);
    self:addChild(self.flowers);
    self.flowers:setVisible(false);
    --local fsW,fsH=self.flowers:getSize(); 暂时用不到
    self.flowers:setPos(self.m_p2.x-25,self.m_p2.y-15);
    
end



-- 播放动画
function AnimationSendRose2.play(self)
if self.isPlaying then
return;
end
self.isPlaying=true;
self:playStartAnim();
end

-- 播放动画
function AnimationSendRose2.playStartAnim(self)
--self.flower:setVisible(true);
self:throwTargetAnim();
--self.flowers:setVisible(true);

end


function AnimationSendRose2.throwTargetAnim( self )

	self.m_index = 1;
	self.m_speed = 50;	-- 速度
	-- self.m_targetAnim = new(AnimInt, kAnimRepeat, 0, 1, 15, 0);
    self.m_targetAnim =self.flower:addPropRotate(0,kAnimRepeat, 15,0,0,0,kCenterDrawing);
    self.m_targetAnim:setDebugName("AnimationSendRose2 || self.m_targetAnim");
    self.flower:setVisible(true)
	self.m_targetAnim:setEvent(nil, function()
		if self.flower~=nil then
    		self.flower:setPos(self.m_animCurve[self.m_index].x, self.m_animCurve[self.m_index].y);
    		self.m_index = self.m_index + 1;
    		if self.m_index >= #self.m_animCurve then
    			self.m_index = 1;
    			self.flower:setVisible(false);
    			-- delete(self.m_targetAnim);
                checkAndRemoveOneProp(self.flower,0)
    			self.m_targetAnim = nil;
    			self:showFlowers();
    		end
        else
            self.flower:setVisible(false);
            -- delete(self.m_targetAnim);
            checkAndRemoveOneProp(self.flower,0)
            self.m_targetAnim = nil;
            self:showFlowers();
        end 
	end);
end

--显示花环动画
function AnimationSendRose2.showFlowers(self)

        kEffectPlayer:play(Effects.AudioFlower);

        self.flowers:setVisible(true);
        self.imgIndex = 0;
        self.anim= self.flowers:addPropRotate(0,kAnimRepeat, 200,0,0,0,kCenterDrawing);
        self.anim:setDebugName("AnimationSendRose2 || self.anim");
        self.anim:setEvent(self, self.showStartOnTime);
end
function AnimationSendRose2.showStartOnTime(self)

    if self.flowers.m_reses then
            local index = self.imgIndex;
            if index > 14 then
                index = 14;
                self.flowers:setVisible(false);
            else
                self.flowers:setImageIndex(index);
                self.flowers:setVisible(true);
            end
        else
            delete(self.flowers);
            self.flowers = nil;
            self:stop();
            return;
        end

     
        self.imgIndex = self.imgIndex + 1;
        if self.imgIndex > 17 then
            delete(self.flowers);
            self.flowers = nil;
        end
   
end

--停止动画
function AnimationSendRose2.stop(self)

    self.m_isPlaying=false;
    self:dtor();

end

--函数注销
function AnimationSendRose2.dtor(self)

    if self.m_targetAnim then
	    delete(self.m_targetAnim);
	    self.m_targetAnim = nil;
	end	
    if self.anim then
        delete(self.anim);
        self.anim = nil;
    end 


    if self.flower then
        delete(self.flower);
        self.flower=nil;
    end;

    if self.flowers then
        delete(self.flowers);
        self.flowers=nil;
    end;

    if self.m_root then
        delete(self.m_root);
        self.m_root=nil;
    end;

end


return AnimationSendRose2;
--endregion
