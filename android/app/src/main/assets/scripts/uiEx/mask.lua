local stencilMask = require("libEffect/shaders/stencilMask");

Mask = class(Node);

Mask.ctor = function (self, imageFile, imageMask)
	if not (imageFile and imageMask) then return end;

   self:loadRes(imageFile,imageMask);
   self:renderMask();
end

Mask.dtor = function (self)
	stencilMask.removeStencilEffect(self, true)

	self.m_prifileImage = nil;
	self.m_maskImage = nil;
end

Mask.setSize = function (self, w, h)  
      self.m_width = w or 0;
      self.m_height = h or 0;
          
      self.m_prifileImage:setSize(self.m_width, self.m_height);
      self.m_maskImage:setSize(self.m_width, self.m_height);
end

Mask.getSize = function (self)
     return self:getRealSize();
end

Mask.setGray = function (self, gray)
    if self.m_widget then
        local val = gray and 0.0 or 1.0;
        self.m_widget.shader = require("shaders.grayScale");
        self.m_widget:set_uniform("timer",Shader.uniform_value_float(val));
    end
end

-----------------------private function---------------------------------
Mask.loadRes = function (self, imageFile, imageMask)

    self.m_prifileImage = new(Image, imageFile, nil, 1);
    self.m_maskImage = new(Image, imageMask, nil, 1);
    self:setSize( self.m_maskImage:getSize() ); --让将源图片设置到遮罩一样的大小
end

Mask.renderMask= function (self)
    if self.m_prifileImage and self.m_maskImage then
        self.m_widget = stencilMask.applyToDrawing(self, self.m_prifileImage, self.m_maskImage)
	end
end

Mask.getRealSize =function(self)
    return self.m_width*System.getLayoutScale(), 
        self.m_height*System.getLayoutScale();
end

Mask.setFile = function(self, ...)
    if self.m_prifileImage then
        self.m_prifileImage:setFile(...)
    end
end



