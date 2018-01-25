local UI = require('byui/basic')
local AL = require('byui/autolayout')
local Layout = require('byui/layout')
local class, mixin, super = unpack(require('byui/class'))
local Am = require('animation')
local KefuResMap = require('kefuSystem/qn_res_alias_map')
local ConstString = require('kefuSystem/common/kefuStringRes')

local voiceLeavePage
voiceLeavePage = class('evalutePage', nil, {
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

	    local title = Label()
	    title.align_v = (ALIGN.CENTER - ALIGN.CENTER % 4)/4		
		title:set_rich_text(string.format("<font color=#FFFFFF bg=#00000000 size=24>%s</font>", ConstString.speek_too_short))
		self.m_container:add(title)
		title:update()
		title.x = (size - title.width)/2
		title.y = size - 55

		local icon = Sprite(TextureUnit(TextureCache.instance():get(KefuResMap.chatVoiceTooLittle)))
	    self.m_container:add(icon)
		icon:add_rules{
			AL.width:eq(10),
			AL.height:eq(114),
			AL.top:eq(50),
			AL.left:eq((260-10)/2),
		}
	end,

	show = function (self)
		self.m_container.visible = true
		if self.m_clock then
			self.m_clock:cancel()
			self.m_clock = nil
		end

		self.m_clock = Clock.instance():schedule_once(function()
            self.m_container.visible = false   
        end, 2)

	end,

	hide = function (self)
		self.m_container.visible = false
	end,
})

return voiceLeavePage