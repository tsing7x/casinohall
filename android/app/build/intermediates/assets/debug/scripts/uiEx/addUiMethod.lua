
--拓展Ui、core中 基类方法
--这种写法不好，是为了兼容老的代码
--今后要拓展基类方法，直接继承再拓展即可

ResText.setFontAndSize = function(self, fontName, fontSize)
    ResText.dtor(self);
    ResText.ctor(self, self.m_str, 0, 0, self.m_align, fontName or self.m_font, fontSize or self.m_fontSize, self.m_r, self.m_g, self.m_b, self.m_multiLines)
end


Text.setFontAndSize = function(self, fontName, fontSize)
    self.m_res:setFontAndSize(fontName, fontSize)
    Text.setSize(self, self.m_res:getWidth(), self.m_res:getHeight())
end