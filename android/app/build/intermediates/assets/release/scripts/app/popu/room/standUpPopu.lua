local StandUpPopu = class(require("app.popu.gameWindow"))

function StandUpPopu:ctor()
   
end

function StandUpPopu:dtor()
  
end

function StandUpPopu:initView(data)
	self:findChildByName("btn_close"):setOnClick(self, function ()
		self:dismiss();
	end);
	self.btnCancel = self:findChildByName("btn_cancel");
	self.btnCancel:setOnClick(self,function ()
		self:dismiss();
	end)	

	self.btnConfirm = self:findChildByName("btn_confirm");
	self.btnConfirm:setOnClick(self,function ()	
		if data.goLowFunc then
			data.goLowFunc();
		end
		self:dismiss();
	end)
end


return StandUpPopu