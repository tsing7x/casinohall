System.getOldLayoutScale = function ()
	local xScale = System.getScreenWidth() / System.getLayoutWidth();
  	local yScale = System.getScreenHeight() / System.getLayoutHeight();
  	local scale = xScale > yScale and yScale or xScale;
  	return scale
end


