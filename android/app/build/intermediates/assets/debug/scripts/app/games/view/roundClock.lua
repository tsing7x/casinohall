local RoundClock = class(CircleProgress)

local numPath = "games/number/countDown/"

function RoundClock:setNumFile(file)
	numPath = file
end

function RoundClock:createNumText()
	local numText = new(ImageNumber,{
		['0'] = numPath.."0.png",
		['1'] = numPath.."1.png",
		['2'] = numPath.."2.png",
		['3'] = numPath.."3.png",
		['4'] = numPath.."4.png",
		['5'] = numPath.."5.png",
		['6'] = numPath.."6.png",
		['7'] = numPath.."7.png",
		['8'] = numPath.."8.png",
		['9'] = numPath.."9.png",
		})
		:addTo(self)
		:align(kAlignCenter)
		:pos(0,0)
	return numText
end

function RoundClock:setBg(bgFileName,size)
    local bg = self:findChildByName("bg")
    if bg then
    	bg:removeSelf()
    end
    bg = new(Image,bgFileName)
    	:addTo(self)
    	:align(kAlignCenter)

   	if size then
   		bg:setSize(size.w,size.h)
   	end
end


function RoundClock:hideText(isHide)
	self.m_isTextHide = isHide
	return self
end

function RoundClock:setBgFile(filePath)

end

function RoundClock:play(total,left,func)
	self:show()
	self.m_text = self.m_text or self:createNumText()
	self.m_text:setNumber(left)
	self.m_text:setVisible(not self.m_isTextHide)

	local progress = left/total
	self:setProgressPecent(1-progress,true)

	local acc = 0
	local diff = 0.05--修改刷新频率
	local callback = function()
		acc = acc + diff
		left = left - diff
		if math.abs(acc-1)<0.000001 then
			acc = 0
			local second = math.floor(left)
			self.m_text:setNumber(second)
			if func then
				func(second)
			end
		end
		progress = left/total
		self:setProgressPecent(1-progress,true)
		if math.abs(left-0)<0.000001 then
			self:stop()
		end
	end
	self.m_handler = Clock.instance():schedule(callback,diff)
end

function RoundClock:stop()
	self:hide()
	if self.m_handler then
		self.m_handler:cancel()
		self.m_handler = nil
	end
end

return RoundClock