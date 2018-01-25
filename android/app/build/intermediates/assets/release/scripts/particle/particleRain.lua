require("particle/particleBase");

--ParticleRain --粒子类
ParticleRain = class(ParticleBase);

ParticleRain.liveTime = 6;    --粒子生命时长

ParticleRain.init = function(self, len, index, node)

    if self.m_Image then
        delete(self.m_Image);
        self.m_Image = nil;
    end

    self.m_Image = new(Image, self.m_FileName);
    node:addChild(self.m_Image);

    local moredata = node:getMoreData();

   self.m_orgRot = moredata.rotation;
    if self.m_orgRot and math.random()>0.5 then
        self.m_orgRot=-self.m_orgRot;
    end

    self.m_fade = math.random()/50.0+0.05; --衰减速度
    self:doActive(true);                   --是否激活状态

    self.m_live = moredata.liveTime or ParticleRain.liveTime;--粒子生命
    self.m_frame = math.ceil(self.m_live/self.m_fade);

    --移动速度
    self.m_yi = 3.5;
     self.m_xi = math.random()*0.2*(math.random()>0.5 and 1 or -1);
    -- 加速度
    self.m_xg = math.random()*0.1*(math.random()>0.5 and 1 or -1);
    self.m_yg = -math.random()*0.02;
    self.m_alpha = 1.0;
    --移动速度/方向
    self.m_y0 = math.random(h/3)-30;
    self.m_x = math.random(w);
    self.m_y = self.m_y0;
    self.m_scale = moredata.scale or 1.0;
    self.m_tick = 0;
    self.m_rotation = 0;

    self.m_Image:setVisible(false);
end

ParticleRain.update = function(self)
    if self.m_active then
        self.m_Image:setVisible(true);
        self.m_tick = self.m_tick + 1;
        if self.m_tick>self.m_frame then self.m_tick = self.m_frame;end
        self.m_alpha = 1.2-self.m_tick/self.m_frame;
        --重新设定粒子在屏幕的位置
        self.m_x = self.m_x + self.m_xi;
    	self.m_y = self.m_y + self.m_yi; 

        -- 更新X,Y轴方向速度大小
        self.m_xi = self.m_xi + self.m_xg;
        self.m_yi = self.m_yi + self.m_yg;
        if self.m_xi>2 then self.m_xg = -0.1;end
        if self.m_xi< -2 then self.m_xg = 0.1;end

        -- 减少粒子的生命值
        self.m_live = self.m_live - self.m_fade;
        -- 如果粒子生命小于0
        if self.m_live < 0.0 then
            self:doActive(false);
            self.m_scale = 0;
        end
        self.m_rotation = self.m_rotation+(tonumber(self.m_orgRot) or 0);

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
