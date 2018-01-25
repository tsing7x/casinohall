local UI = require('byui/basic')
local AL = require('byui/autolayout')
local class, mixin, super = unpack(require('byui/class'))
local Am = require('animation')
local FaceView  = require('kefuSystem/view/face/faceView')
local AddView = require('kefuSystem/view/currency/currency')
local VoiceUpPage = require('kefuSystem/view/voice/voiceUpPage')
local VoiceCancelPage = require('kefuSystem/view/voice/voiceCancelPage')
local VoiceLeavePage = require('kefuSystem/view/voice/voiceLeavePage')
local kefuCommon = require('kefuSystem/kefuCommon')
local UserData = require('kefuSystem/conversation/sessionData')
local KefuResMap = require('kefuSystem/qn_res_alias_map')
local ChatMessage = require('kefuSystem/conversation/chatMessage')
local Record = require('kefuSystem/conversation/record')
local NativeEvent = require('kefuSystem/common/nativeEvent')
local KefuEmoji = require('kefuSystem/common/kefuEmojiCfg')
local ConstString = require('kefuSystem/common/kefuStringRes')
local platform = require("kefuSystem/platform/platform")
local GKefuOnlyOneConstant = require('kefuSystem/common/kefuConstant')
local GKefuSessionControl = require('kefuSystem/conversation/sessionControl')
local GKefuViewManager = require('kefuSystem/viewManager')
local GKefuNetWorkControl = require('kefuSystem/conversation/netWorkControl')

local LongButton
LongButton = class('LongButton', UI.Button, {
    on_touch_up = function(self, p, t)
        if self.upCallBack then
        	self.upCallBack()
        end
        self.m_time = Clock.now() - self.m_start
        if self.m_time < 1 and self.tooSmallCallback then
        	self.tooSmallCallback()
        end

        super(LongButton,self).on_touch_up(self,p,t)
    end,

    on_touch_move = function(self, p, t)

        if self.moveCallback then
        	self.moveCallback(self:point_in(p))
        end

        super(LongButton,self).on_touch_move(self,p,t)
    end,

    on_touch_down = function(self, p, t)

        self.m_start = Clock.now()
        super(LongButton,self).on_touch_down(self,p,t)

        if self.downCallback then
        	self.downCallback()
        end
    end,

})



local bottomControl
bottomControl = class('bottomControl', nil, {
	__init__ = function (self, root, data, delegate)
		self.m_root = root
		self.m_data = data
		self.m_delegate = delegate
		self.m_scrollView = delegate.m_scrollView



		self.m_delegate.m_scrollBtn.visible = false

		--记录每次输入的表情字符
		self.m_faceChars = {}
		self.m_topHeight = delegate.m_topHeight
		self.keyboard_height = 0

		self.m_realLineH = 1
		local layoutScale = System.getOldLayoutScale()
    	if layoutScale < 1 then      
        	self.m_realLineH = 1/layoutScale
    	end

		self._task = {}

		self:createSelectComponent()
		self:createChatComponent()
		
		
		self:createFacePage()
		self:createTakePhotoPage()

		self.m_delegate:setScrollViewBtnEvent(function ()
			self.m_scrollView.height = self.m_root.height - self.m_topHeight - self.m_chatPage.height_hint		
			self.m_chatPage.y = self.m_scrollView.height + self.m_topHeight
			self.m_showAddPage = false
			self.m_showBehavierPage = false
			self:updatePageStatus()
		end)
		self:run_task()
	end,
	add_task = function ( self,task )
		table.insert(self._task,task)
	end,
	run_task = function ( self )
		self._taskHandle = Clock.instance():schedule(function (  )
			if self.m_root.running and self._task[1] and type(self._task[1]) == "function" then
				self._task[1]()
				table.remove(self._task,1)
			else
				self._taskHandle = nil
				if self.m_delegate and self.m_delegate.on_load_succ then
					self.m_delegate.on_load_succ()
				end
				return true
			end
		end)
	end,
	--创建表形page
	createFacePage = function (self)
		self:add_task(function ( ... )
			self.m_faceWg = Widget()
			self.m_faceWg.background_color = Colorf(243/255, 243/255, 243/255,1.0)
			self.m_faceWg:add_rules{
				AL.width:eq(AL.parent("width")),
				AL.height:eq(370),
				AL.left:eq(0),
				AL.bottom:eq(AL.parent("height")),
			}

			self.m_root:add(self.m_faceWg)
			self.m_faceWg.visible = false
		
		end)

		self:add_task(function ( ... )
			local faceView = FaceView(self.m_faceWg)
			self.m_showBehavierPage = false

			faceView:setIconEvent(function (idx)
			
			local r = kefuCommon.unicodeToChar(KefuEmoji.StartIdx+idx-1)
				UI.share_keyboard_controller():insert(r)
				table.insert(self.m_faceChars, r)
			end)

			faceView:setDelIconEvent(function ()
				UI.share_keyboard_controller():delete()
			end)
			faceView:setSendEvent(function (  )
				if self.m_editText.text == "" then
					return 
				end
				local data = UserData.getStatusData()

	    		--os.time是秒级,seqId是毫秒级
	    		local seqId = tostring(tonumber(os.time())*1000)
	    		local message = ChatMessage(seqId, GKefuOnlyOneConstant.MsgType.TXT, self.m_editText.text, data.sessionId or 1, 1)
	    		message.faceChars = self.m_faceChars
	    		--处理消息的发送，存储在本地
	    		GKefuSessionControl.dealwithSendMsg(message)

	    		self.m_faceChars = {}
	    		--界面展示
	    		self.m_editText:reset_text()
			end)
		end)
		

		self:add_task(function ( ... )
			local line = Widget()
			line:add_rules{
				AL.width:eq(AL.parent('width')),
				AL.height:eq(self.m_realLineH),
			}
			line.background_color = Colorf(224/255,224/255,224/255,1.0)		
			self.m_faceWg:add(line)
		end)
	end,

	--创建拍照和上传图片page
	createTakePhotoPage = function (self)
		self:add_task(function ( ... )
			self.m_photoWg = Widget()
			self.m_photoWg.background_color = Colorf(243/255, 243/255, 243/255,1.0)
			self.m_photoWg:add_rules{
				AL.width:eq(AL.parent("width")),
				AL.height:eq(180),
				AL.left:eq(0),
				AL.bottom:eq(AL.parent("height")),
			}
			self.m_photoWg.visible = false

			self.m_root:add(self.m_photoWg)
			self.m_showAddPage = false
			AddView(self.m_photoWg)
		end)

		self:add_task(function ( ... )
			local line = Widget()
			line:add_rules{
				AL.width:eq(AL.parent('width')),
				AL.height:eq(self.m_realLineH),
			}
			line.background_color = Colorf(224/255,224/255,224/255,1.0)
			self.m_photoWg:add(line)
		end)
	end,

	createChatComponent = function (self)
		self.m_editSHeight = 64
		self.m_pageSHeight = 100


		self:add_task(function ( ... )
			-- body
			--聊天输入容器
			self.m_chatPage = Widget()
			self.m_chatPage.background_color = Colorf(0.956, 0.956, 0.956, 1.0)
			self.m_root:add(self.m_chatPage)
			self.m_chatPage:add_rules{
				AL.width:eq(AL.parent('width')),
				--AL.height:eq(100),
				AL.left:eq(0),
			}
			--设置了AL_MASK_TOP, AL.top就不起作用了，需要指定初始化y坐标点
			self.m_chatPage.autolayout_mask = Widget.AL_MASK_TOP
			--设置了height_hint就不能设置AL.height:eq
	        self.m_chatPage.height_hint = self.m_pageSHeight
	        self.m_chatPage.visible = false

	        self.m_changeBg = Sprite()
			TextureCache.instance():get_async(KefuResMap.chat_change,function ( t )
				self.m_changeBg.unit = TextureUnit(t)
			end)
			self.m_chatPage:add(self.m_changeBg)
			self.m_changeBg:add_rules{
				AL.width:eq(44),
				AL.height:eq(48),
				--AL.bottom:eq(AL.parent("height")-20),
			    AL.top:eq(32),
				AL.left:eq(28),
			}

			--转换按钮
			self.m_changeBtn = UI.Button{
				image =
	            {
	                normal = Colorf(1.0,1.0,0.0,0.0),
	                down = Colorf(0.6,0.6,0.6,0.3),
	            },
	           	border = false,
	            text = "",
	           	radius = 1,
			}
			self.m_chatPage:add(self.m_changeBtn)
			self.m_changeBtn:add_rules{
				AL.width:eq(100),
				AL.height:eq(AL.parent('height')),
				AL.top:eq(0),
				AL.left:eq(0),
			}

			--语音按钮
			self.m_yuyinBtn = UI.Button{
	           	border = false,
	            text = "",
	           	radius = 0,
	           	size = Point(56,56)
			}
			TextureCache.instance():get_async(KefuResMap.chatVoiceBgUp,function ( t )
				self.m_yuyinBtn.normal = TextureUnit(t)
			end)
			TextureCache.instance():get_async(KefuResMap.chatVoiceBgDown,function ( t )
				self.m_yuyinBtn.down = TextureUnit(t)
			end)

			self.m_yuyinBtn.pos = Point(120,24)
			self.m_chatPage:add(self.m_yuyinBtn)


			self.m_yuyinBtn.on_click = function ()
				self.m_editText:detach_ime()

				self.m_keyBoardBtn.visible = true
				self.m_voiceBtn.visible = true
				self.m_yuyinBtn.visible = false
				self.m_editText.visible = false
				self.m_behavierBtn.visible = false

				--点击语音按钮需要把表情和add page隐藏，chatPage位置回初始化点
				--m_scrollView高度需要改变
				self.m_scrollView.height = self.m_root.height - self.m_topHeight - self.m_chatPage.height_hint
				self.m_chatPage.y = self.m_scrollView.height+self.m_topHeight
				self.m_showBehavierPage = false
				self.m_showAddPage = false
				self:updatePageStatus()

			end

			--键盘按钮
			self.m_keyBoardBtn = UI.Button{
	           	border = false,
	            text = "",
	           	radius = 0,
			}	

			TextureCache.instance():get_async(KefuResMap.chatKeyboardBgUp,function ( t )
				self.m_keyBoardBtn.normal = TextureUnit(t)
			end)
			TextureCache.instance():get_async(KefuResMap.chatKeyboardBgDw,function ( t )
				self.m_keyBoardBtn.down = TextureUnit(t)
			end)


			self.m_keyBoardBtn:add_rules{
				AL.width:eq(56),
				AL.height:eq(56),
				AL.top:eq(24),
				--AL.bottom:eq(AL.parent("height")-20),
				AL.left:eq(120),
			}

			self.m_chatPage:add(self.m_keyBoardBtn)

			self.m_keyBoardBtn.on_click = function ()
				self.m_keyBoardBtn.visible = false
				self.m_voiceBtn.visible = false
				self.m_yuyinBtn.visible = true
				self.m_editText.visible = true
				self.m_behavierBtn.visible = true

				
			end

			self.m_keyBoardBtn.visible = false
		end)

		self:add_task(function ( ... )
			--语音按钮
			self.m_voiceBtn = LongButton{
	            border = true,
	            text = "",
	           	radius = 0,
	           	v_border = {30,30,30,30},
	           	t_border = {30,30,30,30},
			}

			TextureCache.instance():get_async(KefuResMap.chatVoice9BtnUp,function ( t )
				self.m_voiceBtn.normal = TextureUnit(t)
			end)
			TextureCache.instance():get_async(KefuResMap.chatVoice9BtnDw,function ( t )
				self.m_voiceBtn.down = TextureUnit(t)
			end)

			--语音长按按钮
			self.m_voiceBtn:add_rules{
				AL.width:eq(AL.parent("width") - 100-20-56-20-40-56),
				AL.height:eq(72),
				AL.top:eq(15),
				--AL.bottom:eq(AL.parent("height")-13),
				AL.left:eq(120+56+20),
			}

			--按下说话按钮
			self.m_voiceBtn.downCallback = function ()
	            self.m_voiceDown = true;
				if not self.m_voiceUpPage then
					self.m_voiceUpPage = VoiceUpPage(self.m_root)
				end

				if self.m_voiceCancelPage then
					self.m_voiceCancelPage:hide()
				end

				if self.m_voiceLeavePage then
					self.m_voiceLeavePage:hide()
				end
				-- EventDispatcher.getInstance():register(Event.Call, self, self.onNativeEvent);
				local fileName = "audio_"..tostring(os.time())..".amr" --录制语音文件
				self.m_fullPath = System.getStorageUserPath()..fileName --录制语音文件全路径

				--语音录制需要判断平台
				if kPlatformIOS == System.getPlatform() then
					self.m_voiceUpPage:hide()
	            	-- NativeEvent.canRecord()
	            	platform.getInstance():canRecord(function(ret)
	            			self:onNativeEvent(ret)
	            		end)
	            else
	            	self.m_canRecord = true
	            	self.m_voiceUpPage:show()
	                Record.getInstance():startRecord(self.m_fullPath); --开始录制
	            end
			end
			--说话太短
			self.m_voiceBtn.tooSmallCallback = function ()
				if not self.m_canRecord then return end

				Record.getInstance():stopRecord();--录制完毕
				if not self.m_voiceLeavePage then
					self.m_voiceLeavePage = VoiceLeavePage(self.m_root)
				end

				self.m_voiceLeavePage:show()

				if self.m_voiceCancelPage then
					self.m_voiceCancelPage:hide()
				end

				if self.m_voiceUpPage then
					self.m_voiceUpPage:hide()
				end

			end

			--移动回调
			self.m_voiceBtn.moveCallback = function (isIn)
				if not self.m_canRecord then return end

				if isIn then
					if not self.m_voiceUpPage then
						self.m_voiceUpPage = VoiceUpPage(self.m_root)
					end
					self.m_voiceUpPage:show()

					if self.m_voiceCancelPage then
						self.m_voiceCancelPage:hide()
					end

					if self.m_voiceLeavePage then
						self.m_voiceLeavePage:hide()
					end
				else
					if not self.m_voiceCancelPage then
						self.m_voiceCancelPage = VoiceCancelPage(self.m_root)
					end
					self.m_voiceCancelPage:show()

					if self.m_voiceLeavePage then
						self.m_voiceLeavePage:hide()
					end

					if self.m_voiceUpPage then
						self.m_voiceUpPage:hide()
					end

				end
			end

			--松开说话按钮
			self.m_voiceBtn.upCallBack = function ()
	            self.m_voiceDown = false;
				if not self.m_canRecord then return end

				Record.getInstance():stopRecord();--录制完毕
				if self.m_voiceLeavePage then
					self.m_voiceLeavePage:hide()
				end

				if self.m_voiceCancelPage then
					self.m_voiceCancelPage:hide()
				end

				if self.m_voiceUpPage then
					self.m_voiceUpPage:hide()
				end
			end


			--发送语音
			self.m_voiceBtn.on_click = function ()
				if not self.m_canRecord then return end

				local time = Record.getInstance():getAudioDuration(self.m_fullPath)
				if time > 0 and self.m_voiceBtn.m_time > 1 then
					local data = UserData.getStatusData() or {}
	    			local seqId = tonumber(os.time())*1000
	    			local message = ChatMessage(seqId, GKefuOnlyOneConstant.MsgType.VOICE, self.m_fullPath, data.sessionId or 1, 1)
	    			message.time = time
	    			GKefuSessionControl.dealwithSendMsg(message, self.m_fullPath)
				end
			end


			self.m_chatPage:add(self.m_voiceBtn)


			self.m_voiceTxt = Label()
			self.m_voiceTxt:set_rich_text(string.format("<font color=#000000 bg=#00000000 size=30 weight=1>%s</font>", ConstString.take_down_to_talk))
			self.m_voiceBtn:add(self.m_voiceTxt)
			-- self.m_voiceTxt.absolute_align = ALIGN.CENTER

			self.m_voiceBtn.on_size_changed = function (  )
				self.m_voiceTxt.pos = Point((self.m_voiceBtn.width - self.m_voiceTxt.width) / 2 ,(self.m_voiceBtn.height - self.m_voiceTxt.height) / 2 )
			end

			self.m_voiceBtn.visible = false
		end)
		

		
		


		
		self:add_task(function ( ... )
			--输入框
			self.m_editText = UI.MultilineEditBox {
	            align_v = Label.MIDDLE,
	            border = 1,
	          	expect_height = self.m_editSHeight,
	          	margin = {10,15,10,5},
	        }
	        self.m_editText.max_length = GKefuOnlyOneConstant.MAX_INPUT_LENGTH 
	        local data = UserData.getStatusData()

	        if data.isVip then
		        self.m_editText:add_rules{
		            AL.width:eq(AL.parent("width") - 100-20-56-20-40-56-18-54),
		        	AL.top:eq((self.m_pageSHeight-self.m_editSHeight)/2),
					AL.left:eq(120+56+20),
		        }
		    else
		    	self.m_editText:add_rules{
	            	AL.width:eq(AL.parent("width") - 100-20-40-56-18-54),
	            	AL.top:eq((self.m_pageSHeight-self.m_editSHeight)/2),
					AL.left:eq(120),
	        	}
	        	self.m_yuyinBtn.visible = false
		    end

	        self.m_editText.height_hint = self.m_editSHeight
	        self.m_editText.max_height = 170
	        self.m_editText.hint_text = string.format("<font size=30 color=#c3c3c3>%s</font>", ConstString.input_your_problem_txt)
	        self.m_chatPage:add(self.m_editText)
		end)
		
		


        

        self:add_task(function (  )
			--输入框
			--表情按钮
	        self.m_behavierBtn = UI.Button{
	            border = false,
	            text = "",
	           	radius = 0,       
	           	size = Point(54,54)   	
			}

			TextureCache.instance():get_async(KefuResMap.chatBehavierBtnUp,function ( t )
				self.m_behavierBtn.normal = TextureUnit(t)
			end)
			TextureCache.instance():get_async(KefuResMap.chatBehavierBtnDw,function ( t )
				self.m_behavierBtn.down = TextureUnit(t)
			end)

			self.m_behavierBtn.focus = false

			self.m_behavierBtn:add_rules{
				AL.top:eq(24),
				--AL.bottom:eq(AL.parent("height")-21),
				AL.right:eq(AL.parent("width")-20-56-19),
			}
			self.m_chatPage:add(self.m_behavierBtn)


	        -- +按钮
	        self.m_addBtn = UI.Button{
	            border = false,
	            text = "",
	           	radius = 0,          	
			}

			TextureCache.instance():get_async(KefuResMap.chatAddBtnUp,function ( t )
				self.m_addBtn.normal = TextureUnit(t)
			end)
			TextureCache.instance():get_async(KefuResMap.chatAddBtnDw,function ( t )
				self.m_addBtn.down = TextureUnit(t)
			end)

			self.m_addBtn.focus = false
			
			self.m_addBtn:add_rules{
				AL.width:eq(56),
				AL.height:eq(56),
				AL.top:eq(23),
				--AL.bottom:eq(AL.parent('height') - 21),
				AL.right:eq(AL.parent("width")-20),
			}

			self.m_chatPage:add(self.m_addBtn)


			-- --发送文字按钮
			-- self.m_sendBtn = UI.Button{
	  --           image ={
	  --               normal= Colorf(111/255, 186/255, 44/255,1.0),
	  --               down= Colorf(100/255, 167/255, 40/255,1.0),
	  --           },                          
	  --           --border = false,
	  --           margin = { 5, 5, 5, 5 },
	  --           text = string.format("<font color=#ffffff size=26 weight=2>%s</font>", ConstString.btn_send_txt),
	  --           radius = 5,
	  --       }

	  --       self.m_sendBtn.focus = false

	  --       self.m_sendBtn:add_rules{
	  --       	AL.width:eq(71),
			-- 	AL.height:eq(66),
			-- 	AL.top:eq(17),
			-- 	AL.right:eq(AL.parent("width")-13),
	  --   	}
	  --   	self.m_sendBtn.visible = false
	  --   	self.m_chatPage:add(self.m_sendBtn)

	  --   	--发送文本消息入口
	  --   	self.m_sendBtn.on_click = function ()
	  --   		local data = UserData.getStatusData()

	  --   		--os.time是秒级,seqId是毫秒级
	  --   		local seqId = tostring(tonumber(os.time())*1000)
	  --   		local message = ChatMessage(seqId, GKefuOnlyOneConstant.MsgType.TXT, self.m_editText.text, data.sessionId or 1, 1)
	  --   		message.faceChars = self.m_faceChars
	  --   		--处理消息的发送，存储在本地
	  --   		GKefuSessionControl.dealwithSendMsg(message)

	  --   		self.m_faceChars = {}
	  --   		--界面展示
	  --   		self.m_sendBtn.visible = false
	  --   		self.m_editText:reset_text()
	  --   	end

		end)



        self:add_task(function (  )
        	-------------线
			self.m_topLine = Widget()
			self.m_topLine.background_color = Colorf(0.76, 0.76, 0.76, 1.0)
			self.m_chatPage:add(self.m_topLine)
			self.m_topLine:add_rules{
				AL.width:eq(AL.parent('width')),
				AL.height:eq(self.m_realLineH),
				AL.top:eq(0),
				AL.left:eq(0),

			}
			self.m_leftLine = Widget()
			self.m_leftLine.background_color = Colorf(0.76, 0.76, 0.76, 1.0)
			self.m_chatPage:add(self.m_leftLine)
			self.m_leftLine:add_rules{
				AL.width:eq(self.m_realLineH),
				AL.height:eq(AL.parent('height')),
				AL.top:eq(0),
				AL.left:eq(100),
			}
        end)

        self:add_task(function (  )
        	--动画效果
			--需要考虑键盘打开的时候
			--需要考虑m_chatPage和scrollview大小变化
			self.m_changeBtn.focus = false
			self.m_changeBtn.on_click = function ()
				--记下selectPage的初始化y坐标
				self.m_selectPage.autolayout_mask = Widget.AL_MASK_TOP
				
				--关闭键盘
				self.m_editText:detach_ime()

				--改变状态
				self.m_showAddPage = false
				self.m_showBehavierPage = false
				self:updatePageStatus()

				self.m_scrollView.height = self.m_root.height - self.m_topHeight - self.m_selectPage.height
				self.m_chatPage.y = self.m_root.height - self.m_chatPage.height_hint
				local ac = Am.value(self.m_chatPage.y, self.m_chatPage.y+self.m_chatPage.height_hint)
				local anim = Am.Animator(Am.timing(Am.linear, Am.duration(0.25, ac)), function (v)
					self.m_chatPage.y = v
	            end)
	            anim:start()

	            anim.on_stop = function ()
	            	Clock.instance():schedule_once(function()
		            	self.m_chatPage.visible = false
		            	self.m_selectPage.visible = true

		            	local oc = Am.value(self.m_root.height , self.m_root.height - self.m_selectPage.height)
		            	local animOther = Am.Animator(Am.timing(Am.linear, Am.duration(0.25, oc)), function (v)
							self.m_selectPage.y = v
		            	end)
		            	animOther:start()
	            	end)
	        	end

			end


			self.m_addBtn.on_click = function ()
				
				if not self.m_showAddPage then
					--记下selectPage的初始化y坐标
					self.m_selectPage.autolayout_mask = Widget.AL_MASK_TOP

					--如果这时打开了表情page，则需要隐藏该page，并且还原位置
					self.m_showBehavierPage = false		
					self.m_showAddPage = true

					--m_scrollView变小
					self.m_scrollView.height = self.m_root.height - self.m_topHeight - self.m_chatPage.height_hint - self.m_photoWg.height
					
					local data = UserData.getStatusData()
					--还需要改变其他ui状态
					self.m_editText.visible = true
					if data.isVip then					
						self.m_yuyinBtn.visible = true
					end

					self.m_behavierBtn.visible = true
					self.m_keyBoardBtn.visible = false
					self.m_voiceBtn.visible = false

					Clock.instance():schedule_once(function ()
						Clock.instance():schedule_once(function ()	                
		                	self.m_scrollView:scroll_to_bottom(0.25)
		                end)
		            end)


				else
					self.m_scrollView.height = self.m_root.height - self.m_topHeight - self.m_chatPage.height_hint
					self.m_showAddPage = false
				end
				self.m_editText:detach_ime()
				self.m_chatPage.y = self.m_scrollView.height + self.m_topHeight
				self:updatePageStatus()
			end

			self.m_behavierBtn.on_click = function ()
				
				if not self.m_showBehavierPage then
					--记下selectPage的y坐标
					self.m_selectPage.autolayout_mask = Widget.AL_MASK_TOP

					--显示facePage
					self.m_showBehavierPage = true
					self.m_showAddPage = false
					
					--m_scrollView变小
					self.m_scrollView.height = self.m_root.height - self.m_topHeight - self.m_faceWg.height - self.m_chatPage.height_hint

					Clock.instance():schedule_once(function ()	                
	                	self.m_scrollView:scroll_to_bottom(0.25)
	                end)

					
				else
					self.m_scrollView.height = self.m_root.height - self.m_topHeight - self.m_chatPage.height_hint
					self.m_showBehavierPage = false

				end

				--移动m_chatPage
				self.m_chatPage.y = self.m_scrollView.height + self.m_topHeight
				self:updatePageStatus()
				--关闭软键盘
				self.m_editText:detach_ime()
				self.m_editText:registered_keyboard()

			end

			self.m_editText.on_content_size_change  = function ()
				--根据self.m_editText高度改变m_chatPage高度
	            self.m_chatPage.height_hint = self.m_editText.height_hint+(100-self.m_editSHeight)
	            self.m_chatPage:update_constraints()

	            --m_scrollView高度计算方法
	           
	            if self.m_showAddPage then
	            	self.m_scrollView.height = self.m_root.height - self.m_photoWg.height - self.m_chatPage.height_hint - self.m_topHeight
	            elseif self.m_showBehavierPage then
	            	self.m_scrollView.height = self.m_root.height - self.m_faceWg.height - self.m_chatPage.height_hint - self.m_topHeight            	
	            else
	            	self.m_scrollView.height = self.m_root.height - self.keyboard_height- self.m_chatPage.height_hint - self.m_topHeight
	            end

	            --m_chatPage的y坐标计算方法
	            self.m_chatPage.y = self.m_scrollView.height + self.m_topHeight



	            Clock.instance():schedule_once(function ()
	            	self.m_scrollView:scroll_to_bottom(0.0)            	
	            end)

	        end
	        self.m_editText.keyboard_return_type = Application.ReturnKeySend
	        self.m_editText.on_return_click = function (  )
	        	if self.m_editText.text == "" then
					return 
				end
	        	local data = UserData.getStatusData()

	    		--os.time是秒级,seqId是毫秒级
	    		local seqId = tostring(tonumber(os.time())*1000)
	    		local message = ChatMessage(seqId, GKefuOnlyOneConstant.MsgType.TXT, self.m_editText.text, data.sessionId or 1, 1)
	    		message.faceChars = self.m_faceChars
	    		--处理消息的发送，存储在本地
	    		GKefuSessionControl.dealwithSendMsg(message)

	    		self.m_faceChars = {}
	    		--界面展示
	    		self.m_editText:reset_text()
	        end


	        self.m_editText.on_keyboard_show = function (args)

	            local real_pos = Window.instance().drawing_root:from_world(Point(args.x,args.y))
	            local x = real_pos.x
	            local y = real_pos.y
	            self.keyboard_height  = Window.instance().drawing_root.height - y
	            self.m_scrollView.height = self.m_root.height - self.keyboard_height - self.m_chatPage.height_hint - self.m_topHeight   
	           	self.m_chatPage.y = self.m_scrollView.height + self.m_topHeight
	           	self.m_showBehavierPage = false
	           	self.m_showAddPage = false
	           	self:updatePageStatus()
	            Clock.instance():schedule_once(function ()
	                Clock.instance():schedule_once(function ()
	                    self.m_scrollView:scroll_to_bottom(0.25)
	                end)
	            end)
	        end
	        
	        self.m_editText.on_keyboard_hide = function (args)
	            self.keyboard_height = 0

	            --当表情和add page都没有显示时
	            if not self.m_showBehavierPage and not self.m_showAddPage then
	            	self.m_scrollView.height = self.m_root.height - self.keyboard_height- self.m_chatPage.height_hint - self.m_topHeight  
	            	self.m_chatPage.y = self.m_scrollView.height + self.m_topHeight            	
	            end

	            Clock.instance():schedule_once(function (  )
	                Clock.instance():schedule_once(function (  )
	                    self.m_scrollView:scroll_to_bottom(0.25)
	                end)
	            end)
	        end


	        self.m_editText.on_text_changed = function ()
	            if self.m_editText.text == "" then
	                self.m_faceChars = {}
	            end
	        end
        end)

		


		

	end,

	createSelectComponent = function (self)
---------------------选择容器-----------------

		self.m_selectPage = Widget()
		self.m_selectPage.background_color = Colorf(0.956, 0.956, 0.956, 1.0)
		self.m_root:add(self.m_selectPage)
		self.m_selectPage:add_rules{
			AL.width:eq(AL.parent('width')),
			AL.height:eq(100),
			AL.bottom:eq(AL.parent('height')),
			AL.left:eq(0),
		}

		self.m_keyboardBg = Sprite()
		self.m_selectPage:add(self.m_keyboardBg)
		self.m_keyboardBg:add_rules{
			AL.width:eq(44),
			AL.height:eq(48),
			AL.top:eq(20),
			AL.left:eq(28),
		}
		TextureCache.instance():get_async(KefuResMap.chatKeyboardChange,function ( t )
			self.m_keyboardBg.unit = TextureUnit(t)
		end)
		--转换按钮
		self.m_keyboarChangeBtn = UI.Button{
			image =
            {
                normal = Colorf(1.0,1.0,0.0,0.0),
                down = Colorf(0.6,0.6,0.6,0.3),
            },
           	border = false,
            text = "",
           	radius = 1,
		}
		self.m_selectPage:add(self.m_keyboarChangeBtn)
		self.m_keyboarChangeBtn:add_rules{
			AL.width:eq(100),
			AL.height:eq(AL.parent('height')),
		}

		--获取模块配置信息
        GKefuNetWorkControl.abtainModuleInfoCfg(function(succ)
        	self.m_data = {}
    		if GKefuOnlyOneConstant.showReportModule == 1 then
	            table.insert(self.m_data, ConstString.lose_account_appeal)
	        end
	        if GKefuOnlyOneConstant.showHackModule == 1 then
	            table.insert(self.m_data, ConstString.players_report_title)        
	        end
	        if GKefuOnlyOneConstant.showLeaveModule == 1 then
	            table.insert(self.m_data, ConstString.leave_msg_reply_title)    
	        end

	        local num = #self.m_data
			self.m_selectItem = {}
			local space = (GKefuOnlyOneConstant.SCREENWIDTH-100)/num

			self.m_selectTag = {}
			for i=1, num do
				self.m_selectItem[i] = UI.Button{
					image =
		            {
		                normal = Colorf(1.0,1.0,0.0,0.0),
		                down = Colorf(0.4,0.4,0.4,0.3),
		            },
		           	border = false,
		            text = string.format("<font color=#646464 bg=#00000000 size=30>%s</font>", self.m_data[i]),
		           	radius = 1,
				}
				
				
				self.m_selectItem[i]:add_rules{
					AL.width:eq(space-1),
					AL.height:eq(AL.parent('height')),
					-- AL.top:eq(0),
					AL.left:eq(100+space*(i-1)+1),
				}
				self.m_selectPage:add(self.m_selectItem[i])

				self.m_selectTag[i] = Sprite()
				TextureCache.instance():get_async(KefuResMap.redCircle,function ( t )
					self.m_selectTag[i].unit = TextureUnit(t)
				end)
				self.m_selectTag[i].size = Point(18,18)
				self.m_selectTag[i].pos = Point(space - (space-150)/2 - 18,17)

				self.m_selectItem[i]:add(self.m_selectTag[i])
				self.m_selectTag[i].visible = false

				if self.m_data[i] == ConstString.lose_account_appeal then
					self.m_appealTag = self.m_selectTag[i]
	            elseif self.m_data[i] == ConstString.players_report_title then
	            	self.m_reportTag = self.m_selectTag[i]
	            elseif self.m_data[i] == ConstString.leave_msg_reply_title then
	            	self.m_leaveTag = self.m_selectTag[i]
	            end


				self.m_selectItem[i].on_click = function()
					if self.m_data[i] == ConstString.lose_account_appeal then
						Record.getInstance():stopTrack() 
		            	GKefuViewManager.showPlayerReportView()
		            elseif self.m_data[i] == ConstString.players_report_title then
		            	Record.getInstance():stopTrack()
		            	GKefuViewManager.showHackAppealView()
		            elseif self.m_data[i] == ConstString.leave_msg_reply_title then
		            	Record.getInstance():stopTrack()
		            	GKefuViewManager.showLeaveMessageView()
		            end 
		        end
				
			end

			-------------线
			for i=1, num do
				local line = Widget()
				line.background_color = Colorf(0.76, 0.76, 0.76, 1.0)
				self.m_selectPage:add(line)
				line:add_rules{
					AL.width:eq(self.m_realLineH),
					AL.height:eq(AL.parent('height')),
					AL.top:eq(0),
					AL.left:eq(100+space*(i-1)),

				}
				
			end

        end)

		

		local topLine = Widget()
		topLine.background_color = Colorf(0.76, 0.76, 0.76, 1.0)
		self.m_selectPage:add(topLine)
		topLine:add_rules{
			AL.width:eq(AL.parent('width')),
			AL.height:eq(self.m_realLineH),
			AL.top:eq(0),
			AL.left:eq(0),

		}
		self.m_keyboarChangeBtn.on_click = function ()
			self.m_selectPage.autolayout_mask = Widget.AL_MASK_TOP
	
			local ac = Am.value(self.m_root.height - self.m_selectPage.height, self.m_root.height)
			local anim = Am.Animator(Am.timing(Am.linear, Am.duration(0.25, ac)), function (v)
				self.m_selectPage.y = v
            end)
            anim:start()

            anim.on_stop = function ()
            	Clock.instance():schedule_once(function()
	            	self.m_chatPage.visible = true
	            	self.m_selectPage.visible = false

	            	local oc = Am.value(self.m_root.height, self.m_root.height - self.m_chatPage.height_hint)
	            	local animOther = Am.Animator(Am.timing(Am.linear, Am.duration(0.25, oc)), function (v)
						self.m_chatPage.y = v
	            	end)
	            	animOther:start()
	            end)
        	end

		end
	end,

	--更新表情和照相page状态
	updatePageStatus = function (self)
		if self.m_faceWg then
			self.m_faceWg.visible = self.m_showBehavierPage
		end
		if self.m_photoWg then
			self.m_photoWg.visible = self.m_showAddPage
		end

		if self.m_showAddPage or self.m_showBehavierPage then
			self.m_delegate.m_scrollBtn.visible = true
		else
			self.m_delegate.m_scrollBtn.visible = false
		end 
	end,

	reset = function (self)
		self.m_scrollView.height = self.m_root.height - self.m_selectPage.height - self.m_topHeight  
        self.m_chatPage.y = self.m_scrollView.height + self.m_topHeight
        self.m_showAddPage = false
        self.m_showBehavierPage = false
        self:updatePageStatus()
        if self.m_editText then
        	self.m_editText.text = string.format('<font color=#000000 size=30>%s</font>', "")
        end
	end,

	onResume = function (self)
		self.m_scrollView.height = self.m_root.height - self.m_selectPage.height - self.m_topHeight  
        self.m_chatPage.y = self.m_scrollView.height + self.m_topHeight
        self.m_showAddPage = false
        self.m_showBehavierPage = false
        self:updatePageStatus()
	end,

	updateLeaveItem = function (self, hasNewReport)
		if not self.m_leaveTag then return end 

		if hasNewReport > 0 then
			--显示小红点
			self.m_leaveTag.visible = true
			
		else
			--隐藏小红点
			self.m_leaveTag.visible = false
		end
	end,

	updateHackItem = function (self, hasNewReport)
		if not self.m_reportTag then return end

		if hasNewReport > 0 then
			--显示小红点
			self.m_reportTag.visible = true
			
		else
			--隐藏小红点
			self.m_reportTag.visible = false
		end
	end,

	updateAppealItem = function (self, hasNewReport)
		if not self.m_appealTag then return end
		
		if hasNewReport > 0 then
			self.m_appealTag.visible = true
		else
			self.m_appealTag.visible = false
		end
	end,

	onNativeEvent = function (self,canRecord)
		-- EventDispatcher.getInstance():unregister(Event.Call,self,self.onNativeEvent)

		-- local param, status, jsonTable = NativeEvent.getNativeCallResult()
		-- if param == "canRecord" then
    	self.m_canRecord = canRecord == "1";
    	--可以录制
    	if self.m_canRecord and self.m_voiceDown then
    		self.m_voiceUpPage:show()
            Record.getInstance():startRecord(self.m_fullPath); --开始录制
    	end       	
    	-- end

	end,
	onBackEvent = function ( self )
		if self._taskHandle then
			if self.m_delegate and self.m_delegate.on_load_succ then
				self.m_delegate.on_load_succ()
			end
			self._taskHandle:cancel()
			self._taskHandle = nil
		end
	end,

})


return bottomControl
