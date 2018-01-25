local UI = require('byui/basic')
local AL = require('byui/autolayout')
local Layout = require('byui/layout')
local class, mixin, super = unpack(require('byui/class'))
local Am = require('animation')
local UserData = require('kefuSystem/conversation/sessionData')
local ConstString = require('kefuSystem/common/kefuStringRes')
local KefuResMap = require('kefuSystem/qn_res_alias_map')
local URL = require("kefuSystem/mqttModule/mqttConstants")
local GKefuNetWorkControl = require('kefuSystem/conversation/netWorkControl')
local GKefuSessionControl = require('kefuSystem/conversation/sessionControl')

local MyCheckBox = class('MyCheckBox', UI.ToggleButton, {
	on_touch_up = function(self, p, t)
	    self.checked = true
	    if self.callback then
	        self.callback()
	    end
    end,

})

local satisfactionTxt = {
	ConstString.even_not_satisfy_txt,
	ConstString.not_satisfy_txt,
	ConstString.normal_satisfy_txt,
	ConstString.satisfy_txt,
	ConstString.even_satisfy_txt,
}

local evalutePage
evalutePage = class('evalutePage', nil, {
	__init__ = function (self, root)
		self.m_root = root

		self.m_evPageBackground = Widget()
		self.m_evPageBackground:add_rules{
            AL.width:eq(AL.parent('width')),
            AL.height:eq(AL.parent('height') - 100),
            AL.top:eq(100),
        }
        self.m_evPageBackground.background_color = Colorf(50/255, 50/255, 50/255, 0.6)
        self.m_root:add(self.m_evPageBackground)
        UI.init_simple_event(self.m_evPageBackground, function ()
    
        end)

		self.m_container = Widget()
		self.m_container.background_color = Colorf(1.0, 1.0, 1.0, 1.0)
		self.m_height = 530
		self.m_root:add(self.m_container)
		self.m_container:add_rules{
			AL.width:eq(AL.parent('width')),
			AL.height:eq(self.m_height),
			AL.left:eq(0),
		}

		self.m_container.y = self.m_root.height
		self.m_container.visible = false

		self.m_topCn = Widget()
		self.m_container:add(self.m_topCn)
		self.m_topCn:add_rules{
			AL.width:eq(AL.parent('width')),
			AL.height:eq(90),
		}
		self.m_topCn.background_color = Colorf(230/255,230/255,230/255, 1.0)
		local title = Label()
		title.absolute_align = ALIGN.CENTER
		title:set_rich_text(string.format("<font color=#000000 bg=#00000000 size=34>%s</font>", ConstString.satisfy_evalute_txt))
		self.m_topCn:add(title)

---------------------
		--提示文字
		local txtWg = Widget()
		self.m_container:add(txtWg)
		txtWg:add_rules{
			AL.width:eq(AL.parent('width')),
			AL.height:eq(30),
			AL.left:eq(0),
			AL.bottom:eq(AL.parent('height')-150),
		}

		local txt = Label()
		txtWg:add(txt)
		txt:set_rich_text(ConstString.evalute_tips)
		txt.absolute_align = ALIGN.CENTER


		self.m_submitBtn = UI.Button{
			radius = 10,
            margin = { 10, 10, 10, 10 },
            image =
            {
                normal= Colorf(0.43,0.8,0.17,1),
                down= Colorf(0.43,0.73,0.17,1.0),
                disabled = Colorf(0.77,0.77,0.77,1),
            },
            text = string.format("<font color=#FEFEFE bg=#00000000 size=38>%s</font>", ConstString.sumbit_txt),

        }

        self.m_submitBtn:add_rules{
        	AL.width:eq(AL.parent('width')-60),
        	AL.height:eq(100),
        	AL.left:eq(30),
        	AL.bottom:eq(AL.parent('height')-30),
    	}
    	self.m_container:add(self.m_submitBtn)

	end,

	initSpeedItem = function (self)
		-----------响应速度
		local bw, bh = 44*1.1, 36*1.1
		local startY = 128
		local space = 38
		self.m_speedWg = Widget()
		self.m_speedWg:add_rules{
			AL.width:eq(AL.parent('width')-100),
			AL.height:eq(bh),
			AL.top:eq(startY),
			AL.left:eq(50),
		}
		self.m_container:add(self.m_speedWg)

		local txtSpeed = Label()
		self.m_speedWg:add(txtSpeed)
		txtSpeed.absolute_align = ALIGN.LEFT
		txtSpeed:set_rich_text(string.format("<font color=#000000 bg=#00000000 size=32>%s</font>", ConstString.kefu_reply_speed_txt))
		txtSpeed:update()


		self.m_speedBoxs = {}
		for i=1, 5 do
			self.m_speedBoxs[i] = MyCheckBox{
	            image = {
	                checked_enabled = TextureUnit(TextureCache.instance():get(KefuResMap.chatRedstar)),
	                unchecked_enabled = TextureUnit(TextureCache.instance():get(KefuResMap.chatNostar)),

	            },
	            checked = false,
	            radius = 0,
	        }

	        self.m_speedWg:add(self.m_speedBoxs[i])
	        self.m_speedBoxs[i]:add_rules{
	        	AL.width:eq(bw),
	        	AL.height:eq(bh),
	        	AL.right:eq(AL.parent('width') - (AL.parent('width')-txtSpeed.width)/5*(i-1) ),
	        	AL.bottom:eq(AL.parent('height')+1),
	    	}
	    	self.m_speedBoxs[i]:set_pick_ext(10,10,10,10)
		
		end
		self.m_speedGrade = 0
		for i=1, 5 do
			self.m_speedBoxs[i].callback = function ()
				self.m_speedGrade = i
				for j=i+1, 5 do
	    			self.m_speedBoxs[j].checked = true
	    		end

	    		for n=1, i-1 do
	    			self.m_speedBoxs[n].checked = false
	    		end
			end
			
		end
	end,

	initAttitudeItem = function (self)
		local bw, bh = 44*1.1, 36*1.1
		local startY = 128
		local space = 38
		--------服务态度
		self.m_serviceWg = Widget()
		self.m_serviceWg:add_rules{
			AL.width:eq(AL.parent('width')-100),
			AL.height:eq(bh),
			AL.top:eq(startY+bh+space),
			AL.left:eq(50),
		}

		self.m_container:add(self.m_serviceWg)

		local txtService = Label()
		self.m_serviceWg:add(txtService)
		txtService.absolute_align = ALIGN.LEFT
		txtService:set_rich_text(string.format("<font color=#000000 bg=#00000000 size=32>%s</font>", ConstString.kefu_service_txt))
		txtService:update()
		self.m_txtService = txtService

		self.m_serviceBoxs = {}

		for i=1, 5 do
			self.m_serviceBoxs[i] = MyCheckBox{
	            image = {
	                checked_enabled = TextureUnit(TextureCache.instance():get(KefuResMap.chatRedstar)),
	                unchecked_enabled = TextureUnit(TextureCache.instance():get(KefuResMap.chatNostar)),

	            },
	            checked = false,
	            radius = 0,
	        }

	        self.m_serviceWg:add(self.m_serviceBoxs[i])
	        self.m_serviceBoxs[i]:add_rules{
	        	AL.width:eq(bw),
	        	AL.height:eq(bh),
	        	AL.right:eq(AL.parent('width') - (AL.parent('width')-txtService.width)/5*(i-1) ),
	        	AL.bottom:eq(AL.parent('height')+1),
	    	}

	    	self.m_serviceBoxs[i]:set_pick_ext(5,10,5,10)
			
		end

		self.m_serviceGrade = 0
		for i=1, 5 do
			self.m_serviceBoxs[i].callback = function ()
				self.m_serviceGrade = i
				for j=i+1, 5 do
	    			self.m_serviceBoxs[j].checked = true
	    		end

	    		for n=1, i-1 do
	    			self.m_serviceBoxs[n].checked = false
	    		end
			end
			
		end
	end,

	initExperienceItem = function (self)
		local bw, bh = 44*1.1, 36*1.1
		local startY = 128
		local space = 38
		---------体验
		self.m_experienceWg = Widget()
		self.m_experienceWg:add_rules{
			AL.width:eq(AL.parent('width')-100),
			AL.height:eq(bh),
			AL.top:eq(startY+(bh+space)*2),
			AL.left:eq(50),
		}

		self.m_container:add(self.m_experienceWg)

		local txtExperience = Label()
		self.m_experienceWg:add(txtExperience)
		txtExperience.absolute_align = ALIGN.LEFT
		txtExperience:set_rich_text(string.format("<font color=#000000 bg=#00000000 size=32>%s</font>", ConstString.product_experience_txt))
		txtExperience:update()
		self.m_experienceBoxs = {}

		for i=1, 5 do
			self.m_experienceBoxs[i] = MyCheckBox{
	            image = {
	                checked_enabled = TextureUnit(TextureCache.instance():get(KefuResMap.chatRedstar)),
	                unchecked_enabled = TextureUnit(TextureCache.instance():get(KefuResMap.chatNostar)),

	            },
	            checked = false,
	            radius = 0,
	        }

	        self.m_experienceWg:add(self.m_experienceBoxs[i])
	        self.m_experienceBoxs[i]:add_rules{
	        	AL.width:eq(bw),
	        	AL.height:eq(bh),
	        	AL.right:eq(AL.parent('width') - (AL.parent('width')-self.m_txtService.width)/5*(i-1) ),
	        	AL.bottom:eq(AL.parent('height')+1),
	    	}

	    	self.m_experienceBoxs[i]:set_pick_ext(5,10,5,10)
			
		end

		self.m_experienceGrade = 0
		for i=1, 5 do
			self.m_experienceBoxs[i].callback = function ()
				self.m_experienceGrade = i
				for j=i+1, 5 do
	    			self.m_experienceBoxs[j].checked = true
	    		end

	    		for n=1, i-1 do
	    			self.m_experienceBoxs[n].checked = false
	    		end
			end
			
		end
	end,

	initLeaveItem = function (self)
		self.m_leaveWg = Widget()
		self.m_leaveWg:add_rules{
			AL.width:eq(AL.parent('width')),
			AL.height:eq(160),
			AL.top:eq(170),
			AL.left:eq(0),
		}

		self.m_container:add(self.m_leaveWg)

		self.m_leaveBoxs = {}
		local bw, bh = 44*1.2, 36*1.2
		local space = 18
		local allW = bw*5 + space*4

		for i=1, 5 do
			self.m_leaveBoxs[i] = MyCheckBox{
	            image = {
	                checked_enabled = TextureUnit(TextureCache.instance():get(KefuResMap.chatRedstar)),
	                unchecked_enabled = TextureUnit(TextureCache.instance():get(KefuResMap.chatNostar)),

	            },
	            checked = false,
	            radius = 0,
	        }

	        self.m_leaveWg:add(self.m_leaveBoxs[i])
	        self.m_leaveBoxs[i]:add_rules{
	        	AL.width:eq(bw),
	        	AL.height:eq(bh),
	        	AL.left:eq( (AL.parent('width')-allW)/2 + (i-1)*(bw+space)),
	        	AL.top:eq(2),
	    	}

	    	self.m_leaveBoxs[i]:set_pick_ext(5,10,5,10)
			
		end

		self.m_leaveGrade = 5

		self.m_satisfactLabel = Label()
		self.m_satisfactLabel.absolute_align = ALIGN.CENTER
		self.m_leaveWg:add(self.m_satisfactLabel)
		self.m_satisfactLabel:set_rich_text(string.format("<font color=#000000 bg=#00000000 size=32>%s</font>", satisfactionTxt[self.m_leaveGrade]))
		
		for i=1, 5 do
			self.m_leaveBoxs[i].callback = function ()
				self.m_leaveGrade = i
				self.m_satisfactLabel:set_rich_text(string.format("<font color=#000000 bg=#00000000 size=32>%s</font>", satisfactionTxt[self.m_leaveGrade]))
				for j=i+1, 5 do
	    			self.m_leaveBoxs[j].checked = false
	    		end

	    		for n=1, i-1 do
	    			self.m_leaveBoxs[n].checked = true
	    		end
			end
			
		end

	end,

	updateChatItem = function (self, callback)
		self.m_speedGrade = 5
		self.m_serviceGrade = 5
		self.m_experienceGrade = 5

		for i=1, 5 do
			self.m_experienceBoxs[i].checked = true
			self.m_speedBoxs[i].checked = true
			self.m_serviceBoxs[i].checked = true
		end

		self.m_submitBtn.on_click = function ()
   		
    		local data = UserData.getStatusData() 
    		local tb = {}
    		tb.gid = mqtt_client_config.gameId
    		tb.site_id = mqtt_client_config.siteId
    		tb.client_id = mqtt_client_config.stationId
    		tb.session_id = tostring(data.sessionId)
    		tb.service_fid = GKefuSessionControl.getCurrentServiceFid()

    		tb.respond_rating = self.m_speedGrade
    		tb.attitude_rating = self.m_serviceGrade
    		tb.experience_rating = self.m_experienceGrade

    		local str = cjson.encode(tb)
    		GKefuNetWorkControl.postString(URL.HTTP_SUBMIT_RATING_URI, str, function (rsp)
    			-- local content = rsp.content
    			-- local contentTb = cjson.decode(content)
    		end)
    		self:hide()

    		if callback then
    			callback()
    		end
    	end


	end,

	updateLeaveItem = function (self, callback)
		self.m_leaveGrade = 5

		for i=1, 5 do
			self.m_leaveBoxs[i].checked = true
		end

		self.m_submitBtn.on_click = function ()
    		self:hide()

    		if callback then
    			callback(self.m_leaveGrade)
    		end
    	end

	end,

	show = function (self)
		self.m_evPageBackground.visible = true
		self.m_container.visible = true
		local ac = Am.value(self.m_root.height, self.m_root.height - self.m_height)

        Am.Animator(Am.timing(Am.linear, Am.duration(0.2,ac)), function (v)
            self.m_container.y = v
        end):start()

	end,

	hide = function (self)
		self.m_evPageBackground.visible = false
        self.m_container.y = self.m_root.height
        self.m_container.visible = false
	end,

	isVisible = function (self)
		return self.m_container.visible
	end,

})


return evalutePage