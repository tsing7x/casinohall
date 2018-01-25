Image.setIsGray = function(self, flag, enable)
	local format = self.m_res and self.m_res.m_format;
	-- 已经支持 kRGBGray
	if format == kRGBGray then 
		self:setGray(flag and 1 or nil);
		if not enable then
			self:setPickable(not flag);
		else
			self:setPickable(true);
		end
	elseif format then  -- 没有支持 kRGBGray
		-- 拿到 图片名
		local fileName = self.m_res and self.m_res.m_file;
		if not fileName then return end;
		if flag then
			self:setFile(fileName, kRGBGray);
			self:setGray(1);
		else
			self:setGray();
		end
		if not enable then
			self:setPickable(not flag);
		else
			self:setPickable(true);
		end
	end
end