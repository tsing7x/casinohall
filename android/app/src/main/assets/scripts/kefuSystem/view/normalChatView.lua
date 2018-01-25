local UI = require('byui/basic')
local AL = require('byui/autolayout')
local Layout = require('byui/layout')
local class, mixin, super = unpack(require('byui/class'))
local Am = require('animation')
local baseView = require('kefuSystem/view/baseView')
local kefuCommon = require('kefuSystem/kefuCommon')
local vipChatView = require('kefuSystem/view/vipChatView')
local UserData = require('kefuSystem/conversation/sessionData')
local LogOutPage = require('kefuSystem/view/logoutTipsPage')
local KefuResMap = require('kefuSystem/qn_res_alias_map')
local ConstString = require('kefuSystem/common/kefuStringRes')
local GKefuSessionControl = require('kefuSystem/conversation/sessionControl')

local normalChatView
normalChatView = class('normalChatView', vipChatView, {
	__init__ = function (self)
		super(normalChatView,self).__init__(self)
		self.m_topBg.background_color = Colorf(0.0, 0.0, 0.0,1.0)
		self.m_title:set_rich_text(string.format("<font color=#ffffff bg=#00000000 size=34 weight=3>%s</font>", ConstString.boyaa_kefu_center_txt))
		self.m_backBtn.text = string.format("<font color=#ffffff bg=#00000000 size=28>%s</font>", ConstString.back_txt)
		-- self.m_backImg.unit = TextureUnit(TextureCache.instance():get(KefuResMap.chatBack))
		self.m_backImg.colorf = Colorf(1,1,1)

		self.m_backBtn.on_click = function ()
			self:onBackEvent()		
		end

	end,

	onBackEvent = function (self)
		--人工服务需要评分
		if GKefuSessionControl.isHumanService() then
			if self.m_evalutePage and self.m_evalutePage:isVisible() then           
	            --表示已经处在评论界面，这时再点击按钮就直接退出了
	            self:hideEvalutePage()
	            GKefuSessionControl.logout()
	        else
	            if not self.m_logOutTips then
	                self.m_logOutTips = LogOutPage(self.m_root)
	                self.m_logOutTips:showLogoutTips()
	            end
	            self.m_logOutTips:show(function ()
	                if GKefuSessionControl.isShouldGrade() then
	                    self:showEvalutePage(function ()
	                        self:hideEvalutePage()
	                        GKefuSessionControl.logout()
	                    end)
	                else
	                    GKefuSessionControl.logout()
	                end
	                
	            end)
	        end
		else
			GKefuSessionControl.logout()
		end
	end,
})

return normalChatView