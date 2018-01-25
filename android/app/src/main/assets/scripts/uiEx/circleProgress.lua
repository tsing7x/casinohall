
CircleProgress = class(Node);

local scan = require("libEffect.shaders.circleScan")

function CircleProgress:ctor(fileName)
    self.colorR = 0
    self.colorG = 249
    self.colorB = 0
    self.m_image = new(Image, fileName, nil, 1)
        :addTo(self)
        :align(kAlignCenter)

    self.m_image:setLevel(1)
end

function CircleProgress:initColor()
	self.colorR = 0
    self.colorG = 249
    self.colorB = 0
end

function CircleProgress:setSize(w, h)
	self.m_image:setSize(w, h);
    CircleProgress.super.setSize(self, w, h);
end

--设置圈的切割百分比 
function CircleProgress:setProgressPecent(rate, notColor)   
	
    local angle = 360 * rate;

    if not notColor then
        --  开始颜色变化 
	     -- 一开始从 Red 0 -255 后面 Green 249 - 172 达到黄色
	    if (angle > 135 and angle < 260) then
            if self.colorR  < 255 then
                self.colorR = math.floor( ((angle - 135) / 45) * 255 );
            else
                self.colorR = 255
                self.colorG = 249  -  math.floor( (angle - 135) / 45 *  (249 - 170) );
            end
	    end

	    -- 从 260开始 Green 172 - 52 达到红色
	    if angle > 260 then	
            self.colorR = 255	
            self.colorG = 172  -  math.floor( (angle - 135) / 45 *  (172 - 52) );          
	    end

        self:setColor(self.colorR,self.colorG,self.colorB);
    end
    
   scan.applyToDrawing(self.m_image,{startAngle = angle,endAngle = 360, displayClockWiseArea = -1})
end

return CircleProgress;