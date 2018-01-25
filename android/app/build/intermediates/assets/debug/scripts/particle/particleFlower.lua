require("particle/particleBase");

--ParticleFlower --粒子类
ParticleFlower = class(ParticleBase);

ParticleFlower.liveTime = 4;    --粒子生命时长

ParticleFlower.init = function(self, len, index, node)
    
    if self.m_Image then
        delete(self.m_Image);
        self.m_Image = nil;
    end

    self.m_Image = new(Image, self.m_FileName);
    node:addChild(self.m_Image);

    local moredata = node:getMoreData();
    self.m_fade = math.random()/10.0+0.05; --衰减速度
    self:doActive(true);                   --是否激活状态

    self.m_live = moredata.liveTime or ParticleFlower.liveTime;--粒子生命
    self.m_frame = math.ceil(self.m_live/self.m_fade);

     --初始位置
    local h = moredata.h;
    local w = moredata.w;
    local yi = 0;--h/self.m_frame/20;
 	local xi = 0;--w/self.m_frame/20;
    --移动速度/方向
	local pos = len/node:getMaxNum();
    if pos>1 then pos = pos-1;end
	if pos<0.25 then--left
		self.m_xi = -xi;
		self.m_yi = 0;
		self.m_x = 0;
		self.m_y = h*pos*4;
	elseif pos<0.5 then--top
		self.m_xi = 0;
		self.m_yi = -yi;
		self.m_x = w*(pos-0.25)*4;
		self.m_y = 0;
	elseif pos<0.75 then--rights
		self.m_xi = xi;
		self.m_yi = 0;
		self.m_x = w;
		self.m_y = h*(pos-0.5)*4;
	else
		self.m_xi = 0;
		self.m_yi = yi;
		self.m_x = w*(pos-0.75)*4;
		self.m_y = h;
	end
    if math.random(10) > 5 then self.m_yi = -self.m_yi;end 
    if math.random(10) > 5 then self.m_xi = -self.m_xi;end 
    --移动速度/方向
    self.m_scale = math.random();
	if self.m_scale<0.2 then self.m_scale=0.2;end
    self.m_tick = 0;
    self.m_rotation = 0;
    self.m_orgRot = moredata.rotation;
    self.m_Image:setVisible(false);
end

ParticleFlower.update = function(self)
    if self.m_active then
        self.m_Image:setVisible(true);
        self.m_rotation = self.m_rotation+self.m_orgRot;
        self.m_tick = self.m_tick + 1;
        if self.m_tick>self.m_frame then self.m_tick = self.m_frame;end

        --重新设定粒子在屏幕的位置
        self.m_x = self.m_x + self.m_xi;
    	self.m_y = self.m_y + self.m_yi; 

        -- 减少粒子的生命值
        self.m_live = self.m_live - self.m_fade;
        -- 如果粒子生命小于0
        if self.m_live < 0.0 then
            self:doActive(false);
            self.m_scale = 0;
        end

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
