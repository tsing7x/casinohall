local loadingLayout = require(ViewPath .. "view.loadingLayout")
ToastShade = class(Node)
new(Image, "loading.png")

ToastShade.s_level = 51

ToastShade.ctor = function(self, isShowBg, loadingText, isTextAnim)
	self.shadeNode = new(BaseLayer, loadingLayout)
    self:addChild(self.shadeNode)
	self.shadeNode:setLevel(ToastShade.s_level)
    local w, h = self.shadeNode:getSize()

    self.shadeNode:findChildByName("shade_bg"):setVisible(isShowBg or false)
    local textLoading = self.shadeNode:findChildByName("text_loading_tip")
    if loadingText then
        textLoading:setText(loadingText)
        textLoading:setVisible(true)
    else
        textLoading:setVisible(false)
    end
    if isTextAnim then
        self.loadingTextAnim = true
    end
    self:setAlign(kAlignCenter)

end

function ToastShade.setIsShowBg(self,isShowBg)
    self.shadeNode:findChildByName("shade_bg"):setVisible(isShowBg or false)
end

ToastShade.dtor = function(self)
    self:stop();
end

ToastShade.setLevel = function(self, level)
	self.shadeNode:setLevel(level or ToastShade.s_level)
end

ToastShade.play = function(self)
    self:stop();
    self:setVisible(true);
    self.shadeNode:setVisible(true)

    local img_loading_tip = self:findChildByName("img_loading_tip")
    img_loading_tip:runAction({'rotation',0,360,2},{loopType=kAnimRepeat,onComplete=function ( ... )
            print("动画播放完了")
        end})

    if self.loadingTextAnim then  
        local text = self.shadeNode:findChildByName("text_loading_tip")
        text:removeProp(100)
        local timer = text:addPropTranslate(100, kAnimRepeat, 200, 0, 0, 0, 0, 0)
        text:setText(Hall_string.STR_LOAING)
        local pcount = 0
        timer:setEvent(timer, function()
            pcount = pcount + 1
            if pcount > 6 then
                pcount = 0
            end
            local pstr = ""
            for i = 1, pcount do
                 pstr = pstr .. '.'
            end
            text:setText(Hall_string.STR_LOAING..pstr);
        end)
    end 
end

ToastShade.stop = function(self)
	self.shadeNode:setVisible(false)
end

ToastShade.setLoadingText = function(self, str)
    self.shadeNode:findChildByName("text_loading_tip"):setText(str)
end
