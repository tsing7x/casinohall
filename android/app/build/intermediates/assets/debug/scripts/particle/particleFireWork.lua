require("particle/particleBase");

--ParticleFireWork --粒子类
ParticleFireWork = class(ParticleBase);

ParticleFireWork.liveTime = 4;    --粒子生命时长

ParticleFireWork.init = function(self, len, index, node)
    
    if self.m_Image then
        delete(self.m_Image);
        self.m_Image = nil;
    end

    self.m_Image = new(Image, self.m_FileName);
    node:addChild(self.m_Image);

    local moredata = node:getMoreData();
    self.m_fade = math.random()/10.0+0.05; --衰减速度
    self:doActive(true);                   --是否激活状态

    self.m_live = moredata.liveTime or ParticleFireWork.liveTime;--粒子生命
    self.m_frame = math.ceil(self.m_live/self.m_fade);

     --初始位置
    local h = moredata.h;
    local w = moredata.w;

    --移动速度
    self.m_yi = math.random(h)/self.m_frame;
    self.m_xi = math.random(w)/self.m_frame;
    if math.random(10) > 5 then self.m_yi = -self.m_yi;end 
    if math.random(10) > 5 then self.m_xi = -self.m_xi;end 
    self.m_alpha = 1.0;
    --移动速度/方向
    self.m_x, self.m_y = self:getOrgPos();
    self.m_scale = 0;
    self.m_tick = 0;
    

    self.m_Image:setVisible(false);
end

ParticleFireWork.update = function(self)
    if self.m_active then
        self.m_Image:setVisible(true);
        self.m_tick = self.m_tick + 1;
        if self.m_tick>self.m_frame then self.m_tick = self.m_frame;end
        --重新设定粒子在屏幕的位置
        self.m_x = self.m_x + self.m_xi;
    	self.m_y = self.m_y + self.m_yi; 
        self.m_scale = self.m_tick/self.m_frame;
        self.m_alpha = (self.m_frame*1.5 - self.m_tick)/self.m_frame;
        if self.m_alpha > 1.0 then self.m_alpha = 1.0;end

        self.m_rotation = 0;
        -- 减少粒子的生命值
        self.m_live = self.m_live - self.m_fade;
        -- 如果粒子生命小于0
        if self.m_live < 0.0 then
            self:doActive(false);
            self.m_scale = 0;
        end


        self.m_Image:setTransparency(self.m_alpha);

        local rad = math.rad(self.m_rotation or 0);         --角度转弧度
        local cosA = math.cos(rad);
        local sinA = math.sin(rad);

        local w, h = self.m_Image:getSize();
        w = w / 2 * self.m_scale;
        h = h / 2 * self.m_scale;
        -- setForceMatrix的旋转点为父节点位置.如果要绕Image中心点旋转，则需要先平移-w, -h，之后再旋转，再平移w,h
        --下面是x,y最终结果
        local x = -w*cosA + h*sinA + w + self.m_x;
        local y = -w*sinA - h*cosA + h + self.m_y;
    
        self.m_Image:setForceMatrix(self.m_scale*cosA,  self.m_scale*sinA, 0, 0,
                                    -self.m_scale*sinA, self.m_scale*cosA, 0, 0,
                                    0,     0,    1, 0,
                                    x,     y,    0, 1);
    end
end
