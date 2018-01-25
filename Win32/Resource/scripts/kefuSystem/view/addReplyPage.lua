local UI = require('byui/basic')
local AL = require('byui/autolayout')
local Layout = require('byui/layout')
local class, mixin, super = unpack(require('byui/class'))
local ConstString = require('kefuSystem/common/kefuStringRes')
local KefuResMap = require('kefuSystem/qn_res_alias_map')
local GKefuOnlyOneConstant = require('kefuSystem/common/kefuConstant')

local addReplyPage

addReplyPage = class('addReplyPage', nil, {
	__init__ = function (self, root)
		self.m_root = root

		self.m_background = Widget()
		self.m_background:add_rules{
            AL.width:eq(AL.parent('width')),
            AL.height:eq(AL.parent('height')),
        }
        self.m_background.background_color = Colorf(50/255, 50/255, 50/255, 0.6)
        self.m_root:add(self.m_background)
        UI.init_simple_event(self.m_background, function ()
    		
        end)

        self.m_container = Widget()
        self.m_container:add_rules{
			AL.width:eq(AL.parent('width')-80),
			AL.height:eq(480),
			AL.left:eq(40),
		}
		self.m_originY = (self.m_root.height - 480)/2
		self.m_container.y = self.m_originY
		self.m_container.background_color = Colorf(1.0,1.0,1.0, 1.0)
		self.m_root:add(self.m_container)



		self.m_cancelBg = BorderSprite(TextureUnit(TextureCache.instance():get(KefuResMap.chatVoice9BtnUp)))
		self.m_cancelBg.v_border = {18,18,18,18}
     	self.m_cancelBg.t_border = {18,18,18,18}
     	self.m_container:add(self.m_cancelBg)

     	self.m_cancelBg:add_rules{
    		AL.width:eq(AL.parent('width')/2-75),
    		AL.height:eq(90),
    		AL.bottom:eq(AL.parent('height')-30),
    		AL.centerx:eq(AL.parent('width')/2),
    	}

    	self.m_cancelBtn = UI.Button{
			image =
            {
                normal = Colorf(1.0,0.0,0.0,0.0),
                down = Colorf(0.3,0.3,0.3,0.4)
            },
           	border = true,
            text = string.format("<font color=#000000 bg=#00000000 size=35>%s</font>", ConstString.cancel_txt),

		}
		-- self.m_cancelBtn.focus = false

		self.m_cancelBg:add(self.m_cancelBtn)
		self.m_cancelBtn:add_rules{
			AL.width:eq(AL.parent('width')),
			AL.height:eq(AL.parent('height')),
		}


		self.m_cancelBtn.on_click = function ()
			self:hide()
		end

		self.m_editBox = UI.MultilineEditBox{
			expect_height = 300,
			margin = {18,12,10,10},
			text = string.format('<font color=#000000 size=32></font>'),
            hint_text = string.format('<font color=#c3c3c3 size=32>%s</font>', ConstString.user_reply_tips),			
		}
		self.m_editBox.max_length = GKefuOnlyOneConstant.MAX_INPUT_LENGTH 
		self.m_editBox.keyboard_return_type = Application.ReturnKeySend

		self.m_editBox:add_rules{
			AL.width:eq(AL.parent('width')-40),
			AL.height:eq(300),
			AL.top:eq(20),
			AL.left:eq(20),
		}
		self.m_container:add(self.m_editBox)


		--todo 需要改变位置，防止软键盘挡住该界面
		self.m_editBox.on_keyboard_show = function (args)
			local pos = Window.instance().drawing_root:from_world(Point(args.x,args.y))
			if self.m_originY + 480 > pos.y then
				self.m_container.y = self.m_originY - (self.m_originY + 480 - pos.y)
			end

		end

		self.m_editBox.on_keyboard_hide = function (args)
			self.m_container.y = self.m_originY
		end

	end,

	show = function (self, callback)
		self.m_background.visible = true
		self.m_container.visible = true
		
		self.m_editBox.on_return_click = function (  )
			self.m_editBox.mode = "normal"
			self.m_editBox:detach_ime()
			if callback then
				callback(self.m_editBox.text)
			end
			self:hide()
		end
	end,

	hide = function (self)
		self.m_editBox.text = string.format('<font color=#000000 size=32>%s</font>', "")
		self.m_editBox.hint_text = string.format('<font color=#c3c3c3 size=32>%s</font>',ConstString.user_reply_tips)
		self.m_background.visible = false
		self.m_container.visible = false
		self.m_editBox:detach_ime()
	end,

	isVisible = function (self)
		return self.m_container.visible
	end,

})

return addReplyPage