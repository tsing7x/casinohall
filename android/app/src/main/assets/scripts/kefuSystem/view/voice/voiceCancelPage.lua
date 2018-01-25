local UI = require('byui/basic')
local AL = require('byui/autolayout')
local Layout = require('byui/layout')
local class, mixin, super = unpack(require('byui/class'))
local Am = require('animation')
local KefuResMap = require('kefuSystem/qn_res_alias_map')
local ConstString = require('kefuSystem/common/kefuStringRes')

local voiceCancelPage
voiceCancelPage = class('evalutePage', nil, {
	__init__ = function (self, root)
		self.m_root = root
		self.m_container = Widget()
		self.m_root:add(self.m_container)

		local size = 260
		self.m_container:add_rules{
			AL.width:eq(size),
			AL.height:eq(size),
			AL.left:eq((AL.parent('width')-size)/2),
			AL.top:eq((AL.parent('height')-size)/2),
		}

		self.m_container.visible = false

		local bg = BorderSprite(TextureUnit(TextureCache.instance():get(KefuResMap.chat_kefu_voice_rcd_hint_bg)))
    	bg.v_border = {15,15,15,15}
    	bg.t_border = {15,15,15,15}
    	self.m_container:add(bg)

    	bg:add_rules{
	        AL.width:eq(AL.parent('width')),
	        AL.height:eq(AL.parent('height')),
	    }

	    local txtWg = Widget()
	    self.m_container:add(txtWg)

	    txtWg:add_rules{
			AL.width:eq(size-26),
			AL.height:eq(38),
			AL.left:eq(13),
			AL.bottom:eq(size-14),
		}

		local redBg = BorderSprite(TextureUnit(TextureCache.instance():get(KefuResMap.chat_kefu_rcd_cancel_bg)))
		redBg.v_border = {10,10,10,10}
    	redBg.t_border = {10,10,10,10}
    	txtWg:add(redBg)
    	redBg:add_rules{
	        AL.width:eq(AL.parent('width')),
	        AL.height:eq(AL.parent('height')),
	    }

	    local txt = Label()
	    txt:set_rich_text(string.format("<font color=#FFFFFF bg=#00000000 size=24>%s</font>", ConstString.cancel_to_send_txt))
	    txtWg:add(txt)
	    txt.absolute_align = ALIGN.CENTER

	    local icon = Sprite(TextureUnit(TextureCache.instance():get(KefuResMap.chat_kefu_rcd_cancel_icon)))
	    self.m_container:add(icon)
		icon:add_rules{
			AL.width:eq(82),
			AL.height:eq(114),
			AL.top:eq(50),
			AL.left:eq(84),
		}

	end,

	show = function (self)
		self.m_container.visible = true
	end,

	hide = function (self)
		self.m_container.visible = false
	end,
})


return voiceCancelPage