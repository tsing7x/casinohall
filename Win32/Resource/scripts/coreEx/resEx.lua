local ctor = ResImage.ctor;

ResImage.ctor = function(self, file, format, filter)
    self.m_file = file;
    ctor(self,file, format, filter)
end