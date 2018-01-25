--用于静态Mask 无锯齿

ImageMask = class(Node);

ImageMask.ctor = function (self, imageFile, imageMask)
    if not (imageFile and imageMask) then return end;
    if imageFile == "" or imageMask == "" then return end;
    self:loadRes(imageFile,imageMask);
end

ImageMask.dtor = function (self)

end

ImageMask.setSize = function (self, width, height)
    if not self.m_image then return end;
    self.m_image:setSize(width, height);
end

-----------------------private function---------------------------------
ImageMask.loadRes = function (self, imageFile,imageMask)
    self.m_image = new(Image, imageFile, nil, 1);
    self:addChild(self.m_image);
    local shader = require("libEffect/shaders/imageMask");
    shader.applyToDrawing(self.m_image, {file = imageMask, position = {0,0}});
end