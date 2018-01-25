local M = class(Node)

function M:ctor(path_bg,path_fg,rect_bg,rect_fg)
	self.m_length = 0
	rect_bg = rect_bg or {}
	rect_fg = rect_fg or {}
	if path_bg and path_fg then
		self.img_bg = new(Image,path_bg,nil,nil,rect_bg[1],rect_bg[2],rect_bg[3],rect_bg[4])
				:addTo(self)
				:align(kAlignLeft)
		self.img_fg = new(Image,path_fg,nil,nil,rect_fg[1],rect_fg[2],rect_fg[3],rect_fg[4])
				:addTo(self)
				:align(kAlignLeft)
	end

end

function M:setImg(img_bg,img_fg)
	self.img_bg = img_bg
	self.img_fg = img_fg
	return self
end

function M:setMaxLength(length)
	self.m_length = length
	local _,h = self.img_bg:getSize()
	self:setSize(self.m_length,h)
	self.img_bg:setSize(self.m_length,h)
	self.img_fg:setSize(self.m_length,h)
	return self
end

function M:setProgress(_progress)
	if not _progress or type(_progress)~="number" then
		return
	end
	_progress = _progress/100
	if self.m_length==0 then
		self.m_length = self.img_bg:getSize()
	end
	local w = self.m_length*_progress
	local _,h = self.img_fg:getSize()
	self.img_fg:setSize(w,h)
end

return M