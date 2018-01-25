local UI = require('byui/basic')
local AL = require('byui/autolayout')
local Layout = require('byui/layout')
local class, mixin, super = unpack(require('byui/class'))
local Anim = require('animation')
local baseView = require('kefuSystem/view/baseView')
local BottomCp = require('kefuSystem/view/bottomComponent')
local kefuCommon = require('kefuSystem/kefuCommon')
local EPage = require('kefuSystem/view/evaluatePage')
local LogOutPage = require('kefuSystem/view/logoutTipsPage')
local UserData = require('kefuSystem/conversation/sessionData')
local ConstString = require('kefuSystem/common/kefuStringRes')
local KefuResMap = require('kefuSystem/qn_res_alias_map')
local GKefuOnlyOneConstant = require('kefuSystem/common/kefuConstant')
local GKefuNetWorkControl = require('kefuSystem/conversation/netWorkControl')
local GKefuSessionControl = require('kefuSystem/conversation/sessionControl')

local Widget = Widget
local Label = Label
local Sprite = Sprite

local MyScrollView
MyScrollView = class('MyScrollView', UI.ScrollView, {
    on_touch_up = function(self, p, t)
        self.m_touchUp = true
        super(MyScrollView,self).on_touch_up(self,p,t)
    end,

    on_touch_down = function(self, p, t)
        self.m_touchUp = false
        self.m_autoMove = false
        super(MyScrollView,self).on_touch_down(self,p,t)
    end,

    on_touch_cancel = function(self, p, t)
        self.m_touchUp = true
        self.m_autoMove = true
        super(MyScrollView,self).on_touch_cancel(self,p,t)
    end,

})


local vipChatView
vipChatView = class('vipChatView', baseView, {
	__init__ = function (self)
		super(vipChatView,self).__init__(self)
        EventDispatcher.getInstance():register(Event.Resume, self, self.onResume)
        EventDispatcher.getInstance():register(GKefuOnlyOneConstant.connectLost, self, self.connectLost)
        EventDispatcher.getInstance():register(GKefuOnlyOneConstant.msgSendResult, self, self.msgSendResult)
        self.m_root.background_color = Colorf(242/255, 240/255, 235/255,1.0)
		

        self:_initTopView()

		self.m_scrollView = MyScrollView{
            dimension = kVertical,
        }
        --focus = true表示点击会关闭键盘, false表示不关闭键盘
        self.m_scrollView.focus = true  
        self.m_scrollView.viscosity = 0.02           --阻尼系数
        local platform = System.getPlatform()
        if platform == kPlatformIOS then
            self.m_scrollView.velocity_factor = 2
        else
            self.m_scrollView.velocity_factor = 3        --速度系数
        end
        --高度需要动态改变
        self.m_scrollView:add_rules{
            AL.width:eq(AL.parent('width')),
            AL.top:eq(self.m_topHeight),
            AL.left:eq(0),
        }


        self.m_scrollView.autolayout_mask = Widget.AL_MASK_HEIGHT
        self.m_scrollView.background_color = Colorf(242/255, 240/255, 235/255,1.0)

        self.m_spaceH = 0

        self.m_content = Layout.FloatLayout{
            spacing = Point(0,self.m_spaceH),
        }

        self.m_content:add_rules(AL.rules.fill_parent)

        self.m_content.background_color = Colorf(242/255, 240/255, 235/255,1.0)
        self.m_content.relative = true
        self.m_scrollView.content = self.m_content
        self.m_root:add(self.m_scrollView)
        self.m_scrollView.shows_vertical_scroll_indicator = true
        

        self:createUpdateIcon()
        self:createScrollViewBtn()
        local btmData = {}

        if GKefuOnlyOneConstant.showReportModule == 1 then
            table.insert(btmData, ConstString.lose_account_appeal)
        end
        if GKefuOnlyOneConstant.showHackModule == 1 then
            table.insert(btmData, ConstString.players_report_title)        
        end
        if GKefuOnlyOneConstant.showLeaveModule == 1 then
            table.insert(btmData, ConstString.leave_msg_reply_title)    
        end



		self.m_bottomCp = BottomCp(self.m_root, btmData, self)
        
        --复制实现
        self.m_copyBg = Widget()
        self.m_copyBg:add_rules{
            AL.width:eq(AL.parent('width')),
            AL.height:eq(AL.parent('height')),
            AL.top:eq(0),
            AL.left:eq(0),
        }
        self.m_root:add(self.m_copyBg)
        self.m_copyBg.visible = false
        UI.init_simple_event(self.m_copyBg, function ()
            self.m_copyBg.visible = false
            self.m_scrollView.enabled = true
        end)

        self.m_copyBtn = UI.Button{
            text = string.format("<font color=#ffffff bg=#00000000 size=24>%s</font>", ConstString.copyMenu_tips),
            radius = 0,
            size = Point(90,60)
        }
        TextureCache.instance():get_async(KefuResMap.copyMenu,function ( t )
            self.m_copyBtn.normal = TextureUnit(t)
        end)
        TextureCache.instance():get_async(KefuResMap.copyMenu,function ( t )
            self.m_copyBtn.down = TextureUnit(t)
        end)

        self.m_copyBg:add(self.m_copyBtn)
        self.m_copyBtn.label:add_rules{
            AL.centery:eq(AL.parent('centery'))
        }



	end,
    _initTopView = function ( self )
        self.m_topBg = Widget()
        self.m_topBg.background_color = Colorf(58/255, 48/255, 78/255,1.0)
        self.m_root:add(self.m_topBg)
        self.m_topHeight = 100
        local topHeight = self.m_topHeight
        
        self.m_topBg.height = topHeight
        self.m_topBg:add_rules {
            AL.width:eq(AL.parent('width')),
        }

        self.m_title = Label()
        self.m_title:set_rich_text(string.format("<font color=#F4C392 bg=#00000000 size=34 weight=3>%s</font>", ConstString.boyaa_online_kefu_txt))
        self.m_topBg:add(self.m_title)

        


        self.m_backBtn = UI.Button{
            image =
            {
                normal = Colorf(1.0,0.0,0.0,0.0),
                down = Colorf(0.81,0.81,0.81,0.6)
            },
            border = true,
            text = string.format("<font color=#F4C392 bg=#00000000 size=28>%s</font>", ConstString.back_txt),
            size = Point(160,100),
        }

        self.m_topBg:add(self.m_backBtn)

        self.m_backBtn.on_click = function ()
            self:onBackEvent()  
        end

        self.m_backImg = Sprite()
        TextureCache.instance():get_async(KefuResMap.chatBack,function ( t )
            self.m_backImg.unit = TextureUnit(t)
        end)
        self.m_backImg.size = Point(24,42)
        self.m_backImg.pos = Point(17,26)
        self.m_backImg.colorf = Colorf(0xF4/0xFF,0xC3/0xFF,0x92/0xFF)
        self.m_backBtn:add(self.m_backImg)

        self.m_topBg.on_size_changed = function (  )
            local size = self.m_topBg.size
            local lbl_size = self.m_title.size
            self.m_title.pos = Point((size.x - lbl_size.x)/2,(size.y -lbl_size.y)/2)
        end

    end,
    showMidComponent = function (self, y)
        if not self.m_MidBg then
            self.m_MidBg = Widget()
            self.m_MidBg:add_rules{
                AL.width:eq(AL.parent('width')),
                AL.height:eq(AL.parent('height')),
                AL.top:eq(0),
                AL.left:eq(0),
            }

            self.m_root:add(self.m_MidBg)
            UI.init_simple_event(self.m_MidBg, function ()
                self.m_MidBg.visible = false
            end)

            local labelWg = Widget()
            labelWg:add_rules{
                AL.width:eq(AL.parent('width')),
                AL.height:eq(AL.parent('height') - 10),
            }

            local midLabel = Label()
            midLabel:set_rich_text(string.format("<font color=#000000 bg=#00000000 size=27 weight=1>MID:%s</font>", mqtt_client_config.stationId))
            midLabel.absolute_align = ALIGN.CENTER
            midLabel:update()

            labelWg:add(midLabel)

            self.m_midSprite = BorderSprite(TextureUnit(TextureCache.instance():get(KefuResMap.kefu_mid_bg)))
            self.m_midSprite.v_border = {10,0,60,0}
            self.m_midSprite.t_border = {10,0,60,0}
            self.m_midSprite:add_rules{
                AL.width:eq(midLabel.width + 14),
                AL.height:eq(62),
                AL.right:eq(AL.parent('width') - 12),
            }

            self.m_MidBg:add(self.m_midSprite)
            self.m_midSprite:add(labelWg)
        end

        self.m_MidBg.visible = true
        self.m_midSprite.y = y - 70

    end,

    --从后台切换到前台回调
    onResume = function (self)
        self.m_bottomCp:onResume()
    end,

    showEvalutePage = function (self, callbcak)
        if not self.m_evalutePage then           
            self.m_evalutePage = EPage(self.m_root)
            self.m_evalutePage:initSpeedItem()
            self.m_evalutePage:initAttitudeItem()
            self.m_evalutePage:initExperienceItem()
        end

        self.m_evalutePage:updateChatItem(callbcak)
        self.m_evalutePage:show()
    end,

    hideEvalutePage = function (self)
        if self.m_evalutePage then
           self.m_evalutePage:hide()
        end
    end,

    createUpdateIcon = function (self)
        self.m_iconContain = Widget()
        self.m_iconContain.background_color = Colorf(242/255, 240/255, 235/255,1.0)
        self.m_iconContain:add_rules{
            AL.width:eq(AL.parent("width")),
            AL.height:eq(30),
        }
        self.m_iconContain.startY = -30
        self.m_iconContain.y = self.m_iconContain.startY
        self.m_iconContain.x = 0

     --   self.m_iconContain.zorder = -1
        self.m_scrollView:add(self.m_iconContain)


        self.m_hintTxt = Label()
        self.m_iconContain:add(self.m_hintTxt)
        -- self.m_hintTxt.absolute_align = ALIGN.CENTER
        self.m_hintTxt:set_rich_text(string.format("<font color=#C3C3C3 bg=#00000000 size=24>%s</font>", ConstString.down_to_show_history_msg_tips))
        -- self.m_hintTxt:update()


        self.m_hintIcon = Sprite(TextureUnit(TextureCache.instance():get(KefuResMap.chatHintIcon)))
        self.m_hintIcon:add_rules{
            AL.width:eq(18),
            AL.height:eq(10),
            AL.top:eq(2),

        }
        self.m_iconContain:add(self.m_hintIcon)
        self.m_hintIcon.anchor = Point(0.5,0.5)


        self.m_updateItem = kefuCommon.createUpdateIcon()
        self.m_scrollView:add(self.m_updateItem)
        self.m_updateItem.startY = -120
        self.m_updateItem.y = self.m_updateItem.startY
        self.m_updateItem.hide()


        self:scroll2Update()

        self.m_iconContain.on_size_changed = function (  )
            local size = self.m_iconContain.size
            local lbl_size = self.m_hintTxt.size
            self.m_hintTxt.pos = Point((size.x - lbl_size.x)/2,(size.y -lbl_size.y)/2)
        end
    end,

    --下拉刷新
    scroll2Update = function (self)
        local startY = -60
        self.m_iconContain.y = startY

        local updateDis = 130
        local status = true
        local autoMove = nil
        self.m_index = 1
        self.m_scrollView.on_overscroll = function(iself, overscroll)

            --说明是松手后的惯性移动            
            if self.m_scrollView.m_touchUp and overscroll.y <= 0 then
                self.m_scrollView.m_autoMove = true
            end

            if self.m_changeKenitMax and overscroll.y <= self.m_updateItem.height+50 then
                self.m_changeKenitMax = nil
                -- self.m_scrollView.kinetic.y:cancel()
                Clock.instance():schedule_once(function()
                    self.m_scrollView.kinetic.y.max = self.m_updateItem.height                   
                end)
            end               


            --updateIcon位置改变
            if overscroll.y >= 0 then
                self.m_iconContain.y = startY + overscroll.y
                self.m_updateItem.y = self.m_updateItem.startY + overscroll.y

                if not self.m_updateItem.visible then
                    self.m_iconContain.visible = true
                end
            end

            if overscroll.y == self.m_updateItem.height then
                --松手后待scrollview移动回顶端时添加数据
                if self.m_Updating then
                    self.m_Updating = nil
                    Clock.instance():schedule_once(function()
                        if not UserData.isClear() then
                            return;
                        end
                        self:addHistoryMsg(self.m_data) 
                    end, 0.15)                          
                elseif self.m_networkUpdating and not self.m_isloading then
                    Clock.instance():schedule_once(function()
                        if not UserData.isClear() then
                            return;
                        end
                        self.m_networkUpdating = nil
                        self.m_isloading = true

                        local seqId = UserData.getLastMsgSeqId()
                        GKefuNetWorkControl.loadHistoryMsgFromNetwork(seqId, function (rsp)
                            --获取失败了
                            if not UserData.isClear() then
                                return;
                            end
                            if rsp.errmsg or rsp.code ~= 200 then
                                self.m_iconContain.visible = false
                                self.m_updateItem.hide()
                                self.m_scrollView.kinetic.y.max = 0                           
                                return 
                            end

                            local content = rsp.content
                            local contentTb = cjson.decode(content)
                            --获取成功
                            --按时间降序排序
                            if contentTb.code == 0 and contentTb.data then
                                self.m_scrollView.enabled = false

                                table.sort(contentTb.data, function (v1, v2)
                                    if v1.clock > v2.clock then
                                        return true
                                    end
                                    return false
                                end)

                                UserData.addHistoryMsg(contentTb.data)
                                local historyData = UserData.getHistoryMsgFromDB()
                                self:addHistoryMsg(historyData)
                            elseif contentTb.code == 2 or not contentTb.data then     --服务端已经没有消息
                                self.m_hasNoMessage = true
                                self.m_iconContain.visible = false
                                self.m_updateItem.hide()
                                self.m_scrollView.kinetic.y.max = 0
                            end

                            self.m_isloading = nil
                        end)
                    end, 0.15)

                end
            elseif overscroll.y > 0 then  --当移动超过顶端时
                if self.m_scrollView.m_autoMove then
                    --如果是惯性移动，则停止运动，不会刷新历史消息
                    self.m_scrollView:scroll_to_top(0.0)
                    self.m_scrollView.m_autoMove = false
                    return
                end                
            end

            --释放刷新
            if overscroll.y >= updateDis then
                if status then
                    status = false
                    self.m_hintTxt:set_rich_text(string.format("<font color=#C3C3C3 bg=#00000000 size=24>%s</font>", ConstString.post_to_flush_txt))
                    self.m_hintTxt:update()
                    self.m_hintIcon.rotation = -180                                  
                end

                --表示可以刷新了
                if self.m_scrollView.m_touchUp then
                    --请求历史消息
                    if self.m_hasNoMessage then return end
                    local historyData = UserData.getHistoryMsgFromDB()

                    self.m_scrollView.m_touchUp = false
                    self.m_iconContain.visible = false           
                    self.m_updateItem.show()
                    self.m_changeKenitMax = true
                    --本地有数据
                    if historyData then

                        self.m_Updating = true
                        self.m_data = historyData
                        
                        self.m_scrollView.enabled = false
                                                     
                    else
                        self.m_networkUpdating = true
                        
                    end

                end
            else
                if not status then
                    status = true
                    self.m_hintTxt:set_rich_text(string.format("<font color=#C3C3C3 bg=#00000000 size=24>%s</font>", ConstString.down_to_show_history_msg_tips))
                    self.m_hintTxt:update()
                    self.m_hintIcon.rotation = 0
                end
            end

            self.m_hintIcon.x = (self.m_iconContain.width - self.m_hintTxt.width)/2-40

        end
        
    end,

	--需要重载该函数
    onUpdate = function (self, ...)
        local data = UserData.getStatusData()
        self.m_isVip = data.isVip
        self.m_scrollView.enabled = true
        self.m_hasNoMessage = nil
        self.m_updateItem.hide()

        if GKefuOnlyOneConstant.showReportModule == 1 then
            GKefuSessionControl.hasNewAppealReport(function (hasNewReport)
                self.m_bottomCp:updateAppealItem(hasNewReport)
            end)
        end

        if GKefuOnlyOneConstant.showHackModule == 1 then
            GKefuSessionControl.hasNewHackReport(function (hasNewReport)
                self.m_bottomCp:updateHackItem(hasNewReport)
            end)
        end
        
        if GKefuOnlyOneConstant.showLeaveModule == 1 then
            GKefuSessionControl.hasNewLeaveReport(function (hasNewReport)
                self.m_bottomCp:updateLeaveItem(hasNewReport)
            end)
        end


    end,

    --显示发送文本
    sendTxtMsg = function (self, message)
        local msgWg = kefuCommon.createRightChatMsg(message.msg, self.m_isVip)
        self.m_content:add(msgWg)

        Clock.instance():schedule_once(function ()
            kefuCommon.enableItemCopy(message.msg, msgWg.chatBg, self.m_copyBg, self.m_copyBtn, self.m_scrollView)
            Clock.instance():schedule_once(function ()
                self.m_scrollView:scroll_to_bottom(0.25)
            end)
        end)



        return msgWg
        
    end,

    insertSendItem = function (self, msgWg)
        self.m_msgSendList = self.m_msgSendList or {}
        local key = GKefuNetWorkControl.getToken()
        self.m_msgSendList[key] = msgWg
    end,

    
    sendVoice = function (self, time, path)
        local cc = kefuCommon.createRightVoiceItem(time, path, self.m_isVip)
        self:contentAddChild(cc)
        Clock.instance():schedule_once(function ()
            Clock.instance():schedule_once(function (  )
                self.m_scrollView:scroll_to_bottom(0.25)
            end)
        end)

        return cc
    end,

    createScrollViewBtn = function (self)
        self.m_scrollBtn = UI.Button{
            image =
            {
                normal = Colorf(1.0,0.0,0.0,0.0),
                down = Colorf(0.81,0.81,0.81,0.0),
            },
            border = true,
            text = "",
        }

        self.m_scrollView:add(self.m_scrollBtn)
        self.m_scrollBtn:add_rules{
            AL.width:eq(AL.parent('width')),
            AL.height:eq(AL.parent('height')),
        }
        self.m_scrollBtn.visible = false
    end,

    setScrollViewBtnEvent = function (self, func)
        self.m_scrollBtn.on_click = func
    end,

    --清空content，添加空格，历史消息
    contentPreUpdate = function (self)
        if not self.m_root.running then
            return 
        end
        self.m_historyTags = nil
        UserData.resetHistoryIndex()
        self.m_content:remove_all()
        self.m_hasNoMessage = nil
        self.m_msgSendList = {}

        --添加头部的空格
        self.m_topSpaceWg = Widget()
        self.m_topSpaceWg:add_rules{
            AL.width:eq(AL.parent('width')),
            AL.height:eq(30),                 
        }
        self.m_content:add(self.m_topSpaceWg)

        self:addPreHistoryMsg()
       
    end,

    addHistoryTags = function (self)
        self.m_historyTags = Widget()
        self.m_historyTags:add_rules{
            AL.width:eq(AL.parent('width')),
            AL.height:eq(60),
        }
        local labelTags = Label()
        labelTags:set_rich_text(string.format("<font color=#cccccc size=28>%s</font>", ConstString.history_tags_tips))
        labelTags.absolute_align = ALIGN.TOP
        self.m_historyTags:add(labelTags)
        labelTags:update()

        local line1 = Widget()
        line1:add_rules( {
            AL.width:eq((AL.parent('width')-labelTags.width-120)/2),
            AL.height:eq(kefuCommon.getLineRealHeight(2)),
            AL.top:eq(12),
            AL.left:eq(40),
        } )
        line1.background_color = Colorf(0.8, 0.8, 0.8, 1)
        self.m_historyTags:add(line1)

        local line2 = Widget()
        line2:add_rules( {
            AL.width:eq((AL.parent('width')-labelTags.width-120)/2),
            AL.height:eq(kefuCommon.getLineRealHeight(2)),
            AL.top:eq(12),
            AL.right:eq(AL.parent('width') - 40),
        } )
        line2.background_color = Colorf(0.8, 0.8, 0.8, 1)
        self.m_historyTags:add(line2)

        self.m_content:add(self.m_historyTags)
    end,

    --每次进到聊天界面时的历史消息显示，显示一屏
    addPreHistoryMsg = function (self)
        local data = UserData.getHistoryMsgFromDB(2)
        if not data then return end

        local sdata = UserData.getStatusData() or {}
        local offMsgNum = sdata.offMsgNum or 0
        if offMsgNum > 0 then return end

        local historyItem = {}

        for i, v in ipairs(data) do
            local wg = nil
            if v.isClient == 0 then       --左边
                --图片,客服暂时不能发图片和语音
                if v.types == 1 then      --文本
                    wg = kefuCommon.createLeftChatMsg(v.msg)                    
                    local chatBg = wg.chatBg
                    Clock.instance():schedule_once(function ()
                        kefuCommon.enableItemCopy(v.msg, chatBg, self.m_copyBg, self.m_copyBtn, self.m_scrollView)                
                    end)

                end
            else                                --右边
                if v.types == 1 then
                    wg = kefuCommon.createRightChatMsg(v.msg, self.m_isVip)
                    local chatBg = wg.chatBg
                    Clock.instance():schedule_once(function ()
                        kefuCommon.enableItemCopy(v.msg, chatBg, self.m_copyBg, self.m_copyBtn, self.m_scrollView)                
                    end)
                elseif v.types == 2 then
                    -- 本地存在图片资源, v.msg是部分路径
                    local path = System.getStorageImagePath()..v.msg
                    if os.isexist(path) then                        
                        wg = kefuCommon.createRightImageItem(v.msg, self.m_isVip)                 
                    end
                elseif v.types == 3 then
                    --v.msg是全路径
                    local path = v.msg
                    if os.isexist(path) then
                        wg = kefuCommon.createRightVoiceItem(nil, path, self.m_isVip)
                    end
                end
            end

            if wg then
                table.insert(historyItem, wg)
            end
        end

        --添加时间tips
        local txtTips = kefuCommon.getStringTime(data[#data].seqId/1000)
        wg = kefuCommon.createTimeWidget(txtTips)
        self.m_content:add(wg)

        --添加消息
        if next(historyItem) then
            for i=#historyItem, 1, -1 do
                self.m_content:add(historyItem[i])
            end
        end

        --添加以上历史的tips
        self:addHistoryTags()

    end,

    --显示历史消息
    addHistoryMsg = function (self, historyData)
        self.m_historyItem = {}
        for i, v in ipairs(historyData) do
            local wg
            if v.isClient == 0 then       --左边
                --图片,客服暂时不能发图片和语音
                if v.types == 1 then      --文本
                    wg = kefuCommon.createLeftChatMsg(v.msg)
                    table.insert(self.m_historyItem, wg)
                    local chatBg = wg.chatBg
                    Clock.instance():schedule_once(function ()
                        kefuCommon.enableItemCopy(v.msg, chatBg, self.m_copyBg, self.m_copyBtn, self.m_scrollView)                
                    end)

                end
            else                                --右边
                if v.types == 1 then
                    wg = kefuCommon.createRightChatMsg(v.msg, self.m_isVip)
                    local chatBg = wg.chatBg
                    Clock.instance():schedule_once(function ()
                        kefuCommon.enableItemCopy(v.msg, chatBg, self.m_copyBg, self.m_copyBtn, self.m_scrollView)                
                    end)
                    table.insert(self.m_historyItem, wg)
                elseif v.types == 2 then
                    -- 本地存在图片资源, v.msg是部分路径
                    local path = System.getStorageImagePath()..v.msg
                    if os.isexist(path) then                        
                        wg = kefuCommon.createRightImageItem(v.msg, self.m_isVip)
                        table.insert(self.m_historyItem, wg)                  
                    end
                elseif v.types == 3 then
                    --v.msg是全路径
                    local path = v.msg
                    if os.isexist(path) then
                        wg = kefuCommon.createRightVoiceItem(nil, path, self.m_isVip)
                        table.insert(self.m_historyItem, wg)
                    end
                end
            end

            if wg and (i == #historyData or (v.seqId - historyData[i+1].seqId) > GKefuOnlyOneConstant.INTERVAL_IN_MILLISECONDS) then
                local txtTips = kefuCommon.getStringTime(v.seqId/1000)
                wg = kefuCommon.createTimeWidget(txtTips)
                table.insert(self.m_historyItem, wg)
            end

        end

        self.m_iconContain.visible = false
        self.m_updateItem.hide()
        if not next(self.m_historyItem) then return end


        local addFunc
        addFunc = function (lastWg)
            Clock.instance():schedule_once(function()

                self.m_scrollView.kinetic.y.max = 0
                local height = 0
                for i, v in ipairs(self.m_historyItem) do
                    self:contentAddChild(v, lastWg)
                    lastWg = v
                    height = height + v.height
                end

                self.m_topSpaceWg = Widget()
                self.m_topSpaceWg:add_rules{
                    AL.width:eq(AL.parent('width')),
                    AL.height:eq(30),                 
                }
                self:contentAddChild(self.m_topSpaceWg, lastWg)
                    
                height = height + 30
                self.m_content:update()
                self.m_content.y = self.m_content.y - height + self.m_updateItem.height
               
                self.m_scrollView.enabled = true
                self.m_scrollView:update()
               
            end)
        end
        addFunc(self.m_topSpaceWg)
    end,

    addTimeTips = function (self, tips)
        local wg = kefuCommon.createTimeWidget(tips)
        self:contentAddChild(wg)
    end,

    addLeftMsg = function (self, msg)
        local wg = kefuCommon.createLeftChatMsg(msg)
        self.m_content:add(wg)
        Clock.instance():schedule_once(function ()
            kefuCommon.enableItemCopy(msg, wg.chatBg, self.m_copyBg, self.m_copyBtn, self.m_scrollView)
            self.m_scrollView:scroll_to_bottom(0.2)
        end)
              
    end,

    addImage = function (self, path, isleft)
        local wg = nil
        if isleft then
            wg = kefuCommon.createLeftImageItem(path)           
        else
            wg = kefuCommon.createRightImageItem(path, self.m_isVip)
        end
        self.m_content:add(wg)

        Clock.instance():schedule_once(function ()
            self.m_scrollView:scroll_to_bottom(0.2)
        end)

        return wg
    end,

    addRobotMsg = function (self, msg, links)
        local wg = kefuCommon.createRobotChatMsg(msg, links)
        
        self:contentAddChild(wg)
        Clock.instance():schedule_once(function ()
            self.m_scrollView:scroll_to_bottom(0.2)
        end)
    end,

    --添加重连信息
    addReloginMsg = function (self, headTxt, linkTxt)
        local wg = Widget()
        local chatBg = BorderSprite(TextureUnit(TextureCache.instance():get(KefuResMap.chatfrom_bg_normal9)))
        chatBg.v_border = {20,50,18,20}
        chatBg.t_border = {20,50,18,20}
        wg:add(chatBg)

        local txtWg = Widget()
        wg:add(txtWg)

        local txt = Label()
        txtWg:add(txt)
        txt.absolute_align = ALIGN.CENTER
        txt:set_rich_text(string.format("<font color=#000000 bg=#00000000 size=30>%s</font><font color=#0000ff bg=#00000000 size=30><a tag=link> %s</a></font>", headTxt or ConstString.hint_logout_tips, linkTxt or ConstString.again_connect_txt))
        txt:init_link(function (self, tag)
            GKefuNetWorkControl.sendProtocol("login")
        end)
        txtWg:add(txt)
        txt.layout_size = Point(GKefuOnlyOneConstant.SCREENWIDTH*0.6, 0)

        txt:update()

        kefuCommon.createHeadIcon(wg, nil, true)

        local headH = 80
        local w,h = txt.width, txt.height
        local realH = h+40 > headH and h+40 or headH

        chatBg:add_rules{
            AL.width:eq(w+60),
            AL.height:eq(realH),
            AL.top:eq(0),
            AL.left:eq(120),
        }

        txtWg:add_rules{
            AL.width:eq(w+60),
            AL.height:eq(realH),
            AL.top:eq(0),
            AL.left:eq(120),
        }

        wg:add_rules{
            AL.width:eq(AL.parent("width")),
        }
        wg.height = realH+40

        self.m_content:add(wg)
        Clock.instance():schedule_once(function ()
            self.m_scrollView:scroll_to_bottom(0.2)
        end)
    end,

    contentAddChild = function (self, child, lastWg)
        self.m_content:add(child, lastWg)
    end,

    addTips = function (self, str)
        local tips = kefuCommon.showTips(str)
        self.m_content:add(tips)
        Clock.instance():schedule_once(function ()
            self.m_scrollView:scroll_to_bottom(0.2)
        end)
    end,

    connectLost = function (self)
        self:showExceptionTips(0)

        if self.m_reconnectCk then
            self.m_reconnectCk:cancel()
            self.m_reconnectCk = nil
        end

        --重连操作，先判断网络是否好了，之后断掉与服务器的连接，再进行connect
        self.m_reconnectCk = Clock.instance():schedule(function()            
            if GKefuNetWorkControl.MQTT and GKefuNetWorkControl.MQTT:isConnected() then
                self:hideExceptionTips()
                self.m_reconnectCk:cancel()
                self.m_reconnectCk = nil
                GKefuNetWorkControl.sendProtocol("disconnect")

                Clock.instance():schedule_once(function()  
                    GKefuNetWorkControl.sendProtocol("connect")
                end, 0.25)
            end
        end, 1)

    end,

    showExceptionTips = function (self, time)
        if not self.m_exceptionTips then
            self.m_exceptionTips = kefuCommon.createExceptionTip()
            self.m_scrollView:add(self.m_exceptionTips)
            self.m_exceptionTips.visible = false
        end

        if self.m_expCk then
            self.m_expCk:cancel()
            self.m_expCk = nil
        end

        if time > 0 then
            self.m_expCk = Clock.instance():schedule(function()
                self.m_exceptionTips.visible = true  
            end, time)
        else
            self.m_exceptionTips.visible = true
        end
       
    end,

    hideExceptionTips = function (self)
        if self.m_expCk then
            self.m_expCk:cancel()
            self.m_expCk = nil
        end

        if self.m_exceptionTips then
            self.m_exceptionTips.visible = false
        end
    end,

    showSendAgainPage = function (self, callback)
        if not self.m_sendAgainPage then
            self.m_sendAgainPage = LogOutPage(self.m_root)
            self.m_sendAgainPage:showSendMsgAgain()
        end

        self.m_sendAgainPage:show(callback)
    end,

    --文字消息发送结果，result = 1为成功
    msgSendResult = function (self, result, key)
        if not self.m_msgSendList or not next(self.m_msgSendList) then return end

        if result == 1 then
            self.m_msgSendList[key].failBtn.visible = false
            self.m_msgSendList[key] = nil
        else
            self.m_msgSendList[key].failBtn.visible = true
        end
        
    end,

    resetBottom = function (self)
        self.m_bottomCp:reset()
    end,

    --返回键事件回调
    onBackEvent = function (self)

        self.m_bottomCp:onBackEvent()
        local data = UserData.getStatusData()
        if data.conversationStatus ~= ConversationStatus_Map.SESSION then
            GKefuSessionControl.logout()
            return
        end

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
    end,

    
    --销毁方法
    onDelete = function (self)
        self:hideExceptionTips()

        if self.m_reconnectCk then
            self.m_reconnectCk:cancel()
            self.m_reconnectCk = nil
        end
        self.m_msgSendList = nil

        EventDispatcher.getInstance():unregister(Event.Resume, self, self.onResume)
        EventDispatcher.getInstance():unregister(GKefuOnlyOneConstant.connectLost, self, self.connectLost)
        EventDispatcher.getInstance():unregister(GKefuOnlyOneConstant.msgSendResult, self, self.msgSendResult)
        super(vipChatView, self).onDelete(self)
    end,
})


return vipChatView