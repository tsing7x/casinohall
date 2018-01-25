-- Author: 
--   Xiaofeng Yang      2015
--   Vicent.Gong        2013
-- Last modification : 2015-04-21
-- Description: 
--   A `VerticalSlider' control.


require("core/constants");
require("core/object");
require("ui/node");
require("ui/image");

VerticalSlider = class(Node);

VerticalSlider.s_defaultBgImage = "ui/VerticalSliderBg.png";
VerticalSlider.s_defaultFgImage = "ui/VerticalSliderFg.png";
VerticalSlider.s_defaultButtonImage = "ui/VerticalSliderBtn.png";

VerticalSlider.setDefaultImages = function(bgImage, fgImage, buttonImage)
    VerticalSlider.s_bgImage = bgImage or VerticalSlider.s_defaultBgImage;
    VerticalSlider.s_fgImage = fgImage or VerticalSlider.s_defaultFgImage;
    VerticalSlider.s_buttonImage = buttonImage or VerticalSlider.s_defaultButtonImage;
end
--isHorizon是不是水平方向
VerticalSlider.ctor = function(self, width, height, bgImage, fgImage, buttonImage, leftWidth, rightWidth, topWidth, bottomWidth)
    self.m_bgImage = bgImage or VerticalSlider.s_bgImage or VerticalSlider.s_defaultBgImage;
    self.m_fgImage = fgImage or VerticalSlider.s_fgImage or VerticalSlider.s_defaultFgImage;
    self.m_buttonImage = buttonImage or VerticalSlider.s_buttonImage or VerticalSlider.s_defaultButtonImage;

    self.m_bg = new(Image,self.m_bgImage,nil,nil,leftWidth,rightWidth,topWidth,bottomWidth);
    width = (width and width >= 1) and width or self.m_bg:getSize();
    height = (height and height >= 1) and height or select(2,self.m_bg:getSize());
    
    VerticalSlider.setSize(self,width,height);
    
    VerticalSlider.addChild(self,self.m_bg);
    self.m_bg:setFillParent(true,true);
    self.m_bg:setEventTouch(self,self.onBackgroundEventTouch);

    self.m_fg = new(Image,self.m_fgImage,nil,nil,leftWidth,rightWidth,topWidth,bottomWidth);

    VerticalSlider.addChild(self,self.m_fg);
    self.m_fg:setFillParent(true,true);    
    
    self.m_button = new(Image,self.m_buttonImage);
    VerticalSlider.addChild(self,self.m_button);
    -- self.m_button:setAlign(kAlignLeft);
    self.m_button:setAlign(kAlignBottom);
    self.m_button:setPos(0,0);
    self.m_button:setEventTouch(self,self.onEventTouch);
    
    self.m_width = width;
    self.m_height = height;
    self.m_minProgress = 0
    self.m_maxProgress = 1
    VerticalSlider.setProgress(self,1.0);

    self.m_changeCallback = {};
    self.m_btnCallback = {}
end

VerticalSlider.setImages = function(self, bgImage, fgImage, buttonImage)
    self.m_bgImage = bgImage or VerticalSlider.s_bgImage or VerticalSlider.s_defaultBgImage;
    self.m_fgImage = fgImage or VerticalSlider.s_fgImage or VerticalSlider.s_defaultFgImage;
    self.m_buttonImage = buttonImage or VerticalSlider.s_buttonImage or VerticalSlider.s_defaultButtonImage;

    self.m_bg:setFile(self.m_bgImage);
    self.m_fg:setFile(self.m_fgImage);
    self.m_button:setFile(self.m_buttonImage);
end

VerticalSlider.setMinProgress = function(self,minProgress)
    self.m_minProgress = minProgress
end

VerticalSlider.setMaxProgress = function(self,maxProgress)
    self.m_maxProgress = maxProgress
end

VerticalSlider.setProgress = function(self, progress)
    progress = progress > self.m_maxProgress and self.m_maxProgress or progress;
    progress = progress < self.m_minProgress and self.m_minProgress or progress;
    self.m_progress = progress;
    
    local buttonW,buttonH = self.m_button:getSize();
    local buttonY = self.m_progress*self.m_height - buttonH/2;
    self.m_button:setPos(0, buttonY);
    self.m_fg:setClip(0,self.m_height*(1-self.m_progress),buttonW,self.m_height);
end

VerticalSlider.getProgress = function(self)
    return self.m_progress;
end

VerticalSlider.setEnable = function(self, enable)
    self.m_button:setPickable(enable);
end

VerticalSlider.setButtonVisible = function(self, visible)
    self.m_button:setVisible(visible);
end

VerticalSlider.setOnChange = function(self, obj, func)
    self.m_changeCallback.obj = obj;
    self.m_changeCallback.func = func;
end

VerticalSlider.setBtnOnClick = function (self,obj,func)
    self.m_btnCallback.obj=obj
    self.m_btnCallback.func=func
end

VerticalSlider.dtor = function(self)
    
end

---------------------------------private functions-----------------------------------------

VerticalSlider.onEventTouch = function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
    if finger_action == kFingerDown then
        self.m_dragingX = x;
        self.m_dragingY = y;
        self.m_button:setColor(128,128,128);
    else 
        local bgX, bgY = self:getAbsolutePos();

        local notifyChange = function ()
            if self.m_changeCallback.func then
                self.m_changeCallback.func(self.m_changeCallback.obj,self.m_progress);
            end 
        end

         if (bgY <= y) and (self.m_height + bgY >= y) then 
            local diffY = self.m_dragingY - y;
            local progress = self.m_progress + diffY/self.m_height;
            VerticalSlider.setProgress(self,progress);
            self.m_dragingY = y;
        
            notifyChange();
        elseif (y < bgY) and (self.m_progress < 1) then --上边界
            -- 移动太快，刚跳出边界时，校正下。
            VerticalSlider.setProgress(self,1);
            self.m_dragingY = bgY;
        
            notifyChange();
        elseif (y > self.m_height + bgY) and (self.m_progress < 1) then --下边界
            -- 移动太快，刚跳出边界时，校正下。
            VerticalSlider.setProgress(self,0);
            self.m_dragingY = self.m_height + bgY;
        
            notifyChange();
        end
        

        if finger_action ~= kFingerMove then
            self.m_button:setColor(255,255,255);
            if self.m_btnCallback.func and self.m_btnCallback.obj then
                self.m_btnCallback.func(self.m_btnCallback.obj,self.m_progress)
            end
        end
    end
end

VerticalSlider.onBackgroundEventTouch = function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
    if finger_action == kFingerDown then
        local bgX, bgY = self:getAbsolutePos();
        local deltaY = y-bgY;
        local progress = deltaY/self.m_height;
        VerticalSlider.setProgress(self,progress);
    end 

    self:onEventTouch(finger_action, x, y, drawing_id_first, drawing_id_current);
end

return VerticalSlider;