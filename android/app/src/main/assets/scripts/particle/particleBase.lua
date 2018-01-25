require("particle/particleSystem");
--ParticleBase --粒子类

ParticleBase = class();

ParticleBase.liveTime = 4;	--粒子生命时长

ParticleBase.ctor = function(self, fileName)
    self.m_FileName = fileName;
end

ParticleBase.init = function(self)
end

ParticleBase.update = function(self)
end

ParticleBase.doActive = function (self, isActive)
	self.m_active = isActive;
	if self.m_Image then
		self.m_Image:setVisible(isActive);
	end
end

ParticleBase.dtor = function (self)
    if self.m_Image then 
        delete(self.m_Image);
        self.m_Image = nil;
    end
end
