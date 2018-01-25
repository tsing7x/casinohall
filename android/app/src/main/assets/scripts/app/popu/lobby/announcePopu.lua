local GameWindow = require("app.popu.gameWindow")
local AnnouncePopu = class(GameWindow)


function AnnouncePopu:ctor(viewLayout, data)
	self.data=data
end

function AnnouncePopu:dtor()
end

function AnnouncePopu:initView(data)
    self:findChildByName("btn_confirm"):setOnClick(self,function ()
    	self:showResult()
    	AnimationParticles.play(AnimationParticles.DropCoin)
		kEffectPlayer:play('audio_get_gold')
    end)

    if data.pic==1 then
    	self:findChildByName("text_line03"):setText("รวมสินทรัพย์กับ"..data.name or "รวมสินทรัพย์กับไพ่ดัมมี่")
    	self:findChildByName("text_line04"):setText("รวมเป็นบัญชีเดียวกันกับ"..data.name or "รวมเป็นบัญชีเดียวกันกับไพ่ดัมมี่")

    	self:findChildByName("img_notice02"):setVisible(true)
    else
    	self:findChildByName("img_notice01"):setVisible(true)
    end
    -- self.notice=self:findChildByName("view_inner")
end



function AnnouncePopu:showResult()
	local shadow =self:findChildByName("btn_shadow")
	local bg = self:findChildByName("img_popuBg")
	bg:setVisible(false)
	shadow:setVisible(true)
	shadow:setOnClick(self,function ( self )
		self:dismiss()
		WindowManager:showWindow(WindowTag.MsgContPopu,{msgType = 3,title=self.data.title or "",content=self.data.content or ""},WindowStyle.POPUP)
		checkAndRemoveOneProp(self,1)
	end)
	local anim=self:addPropTranslate(1,kAnimNormal,0,1300,0,0,0,0)
	anim:setEvent(self,function ()
		checkAndRemoveOneProp(self,1)
		self:dismiss()
		WindowManager:showWindow(WindowTag.MsgContPopu,{msgType = 3,title=self.data.title or "",content=self.data.content or ""},WindowStyle.POPUP)	
	end)
end


return AnnouncePopu