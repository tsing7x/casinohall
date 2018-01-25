local UI = require('byui/basic')
local AL = require('byui/autolayout')
local Layout = require('byui/layout')
local class, mixin, super = unpack(require('byui/class'))
local Am = require('animation')
local KefuResMap = require('kefuSystem/qn_res_alias_map')
local Record = require('kefuSystem/conversation/record')
local ConstString = require('kefuSystem/common/kefuStringRes')


local voiceUpPage
voiceUpPage = class('evalutePage', nil, {
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

		

		local leftIcon = Sprite(TextureUnit(TextureCache.instance():get(KefuResMap.chat_kefu_voice_rcd_hint)))
		self.m_container:add(leftIcon)
		leftIcon:add_rules{
			AL.width:eq(72),
			AL.height:eq(114),
			AL.top:eq(50),
			AL.left:eq(73),
		}

		self.m_voiceIcons = {}
		for i=1,7 do
			local path = string.format("chat_kefu_voice_rcd_hint_amp%d", i)
			self.m_voiceIcons[i] = Sprite(TextureUnit(TextureCache.instance():get(KefuResMap[path])))
			self.m_container:add(self.m_voiceIcons[i])
			self.m_voiceIcons[i]:add_rules{
				AL.width:eq(22),
				AL.height:eq(78),
				AL.top:eq(86),
				AL.right:eq(AL.parent('height') - 72),
			}
			self.m_voiceIcons[i].visible = false
		end

		local title = Label()
		title.align_v = (ALIGN.CENTER - ALIGN.CENTER % 4)/4		
		title:set_rich_text(string.format("<font color=#FFFFFF bg=#00000000 size=24>%s</font>", ConstString.up_to_cancel_txt))
		self.m_container:add(title)
		title:update()
		title.x = (size - title.width)/2
		title.y = size - 55


	end,


	show = function (self)
		Record.getInstance():setOnEvent(Record.EVENT.RECORD_VOLUME, function (duration)
			local idx = 1
			if duration < 1 then
				idx = 1
			elseif duration < 2 then
				idx = 2
			elseif duration < 3 then
				idx = 3
			elseif duration < 4 then
				idx = 4
			elseif duration < 5 then
				idx = 5
			elseif duration < 6 then
				idx = 6
			else
				idx = 7
			end

			self:updateVoiceStatus(idx)
		end)
		self.m_container.visible = true
	end,

	hide = function (self)
		self.m_container.visible = false
	end,

	updateVoiceStatus = function (self, idx)
		for i=1, 7 do
			self.m_voiceIcons[i].visible = false
		end

		self.m_voiceIcons[idx].visible = true
	end,
})


return voiceUpPage