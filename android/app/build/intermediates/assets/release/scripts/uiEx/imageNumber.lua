ImageNumber = class(Node, false);

function ImageNumber:ctor(uiPath, ...)
	self.mUiPath = uiPath
	super(self, ...)
 	-- body
 end
function ImageNumber:dtor()

end

function ImageNumber:setNumber( formatNumber, offdw, align)
	formatNumber = tostring(formatNumber)
	if not formatNumber then return end
	self:removeAllChildren();

	offdw = offdw or 0
	local x, y = 0, 0;
	for i = 1, string.len(formatNumber) do
		local c = string.sub(formatNumber, i, i);
		if self.mUiPath[c] then
			local numImg 	= new(Image, self.mUiPath[c]);
			if numImg then
				local w, h = numImg:getSize();
                numImg:setAlign(align or kAlignLeft);
				numImg:setPos(x, y);
				x = x + w + offdw;
				self:addChild(numImg);
				self:setSize(x, h);

			end
		end
	end
end

return ImageNumber