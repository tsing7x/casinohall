local UI = require('byui/basic')
local AL = require('byui/autolayout')
local class, mixin, super = unpack(require('byui/class'))
local baseView = require('kefuSystem/view/baseView')
local UserData = require('kefuSystem/conversation/sessionData')
local KefuResMap = require('kefuSystem/qn_res_alias_map')
local ConstString = require('kefuSystem/common/kefuStringRes')
local URL = require("kefuSystem/mqttModule/mqttConstants")
local GKefuOnlyOneConstant = require('kefuSystem/common/kefuConstant')
local GKefuNetWorkControl = require('kefuSystem/conversation/netWorkControl')
local GKefuViewManager = require('kefuSystem/viewManager')


local startView
startView = class('startView', baseView, {
    __init__ = function (self)
    	super(startView,self).__init__(self)

---------GameId
        local labelGId = Label()
        labelGId:set_rich_text("<font color=#000000 size=36>GameId:</font>")
        self.m_root:add(labelGId)
        labelGId:add_rules{
            AL.top:eq(90),
            AL.left:eq(10),
        }

        self.m_editGId = UI.EditBox {
            background_style = KTextBorderStyleNone,
            icon_style = KTextIconNone,
            align_v = Label.MIDDLE,
            text = '<font color=#000000 size=36></font>',
            hint_text = string.format('<font color=#9b9b9b size=36>%s%s</font>', ConstString.startview_default_txt, mqtt_client_config.gameId),
        }
        self.m_editGId.keyboard_type = Application.KeyboardTypeNumberPad

        self.m_editGId:add_rules{
            AL.width:eq(AL.parent('width')-100),
            AL.height:eq(80),
            AL.top:eq(90),
            AL.left:eq(200),
        }
        self.m_root:add(self.m_editGId)

---------SiteId
        local labelSId = Label()
        labelSId:set_rich_text("<font color=#000000 size=36>SiteId:</font>")
        self.m_root:add(labelSId)
        labelSId:add_rules{
            AL.top:eq(180),
            AL.left:eq(10),
        }

        self.m_editSId = UI.EditBox {
            background_style = KTextBorderStyleNone,
            icon_style = KTextIconNone,
            align_v = Label.MIDDLE,
            text = '<font color=#000000 size=36></font>',
            hint_text = string.format('<font color=#9b9b9b size=36>%s%s</font>', ConstString.startview_default_txt, mqtt_client_config.siteId),
        }
        self.m_editSId.keyboard_type = Application.KeyboardTypeNumberPad

        self.m_editSId:add_rules{
            AL.width:eq(AL.parent('width')-100),
            AL.height:eq(80),
            AL.top:eq(180),
            AL.left:eq(200),
        }
        self.m_root:add(self.m_editSId)

---------StationId
        local label = Label()
        label:set_rich_text("<font color=#000000 size=36>StationId:</font>")
        self.m_root:add(label)
        label:add_rules{
            AL.top:eq(270),
            AL.left:eq(10),
        }

        self.m_edit = UI.EditBox {
            background_style = KTextBorderStyleNone,
            icon_style = KTextIconNone,
            align_v = Label.MIDDLE,
            text = '<font color=#000000 size=36></font>',
            hint_text = string.format('<font color=#9b9b9b size=36>%s%s</font>', ConstString.startview_default_txt, mqtt_client_config.stationId),
        }
        self.m_edit.keyboard_type = Application.KeyboardTypeNumberPad

        self.m_edit:add_rules{
            AL.width:eq(AL.parent('width')-100),
            AL.height:eq(80),
            AL.top:eq(270),
            AL.left:eq(200),
        }
        self.m_root:add(self.m_edit)

    	local str = string.format("<font color=#000000 size=36>%s</font>", ConstString.vip_chat_tips)
    	self.m_vipBtn = UI.Button{
            image ={
                normal = TextureUnit(TextureCache.instance():get(KefuResMap.chatVoice9BtnUp)),
                down = TextureUnit(TextureCache.instance():get(KefuResMap.chatVoice9BtnDw)),
            },
                          
            border = false,
            text = str,
        }

        self.m_root:add(self.m_vipBtn)
        self.m_vipBtn:add_rules{
            AL.width:eq(AL.parent('width')-20),
            AL.height:eq(80),
            AL.top:eq(400),
            AL.left:eq(10),
        }

        self.m_vipBtn.on_click = function ()
            local data = UserData.getStatusData() or {}
            data.isOut = false
            data.isVip = true
            data.connectCallbackStatus = false
            UserData.setStatusData(data)
            mqtt_client_config.role = "3"
            mqtt_client_config.stationId = self.m_edit.text~="" and self.m_edit.text or mqtt_client_config.stationId
            mqtt_client_info.userID = mqtt_client_config.stationId
            mqtt_client_config.gameId = self.m_editGId.text ~= "" and self.m_editGId.text or mqtt_client_config.gameId
            mqtt_client_config.siteId = self.m_editSId.text ~= "" and self.m_editSId.text or mqtt_client_config.siteId
            UserData.initLeaveDict()
            UserData.initHackDict()
            UserData.initAppealDict()
            
            EventDispatcher.getInstance():register(Event.Back, GKefuViewManager, GKefuViewManager.onBackEvent)
            local view = GKefuViewManager.showVipChatView(GKefuOnlyOneConstant.No)
            if view then          
                view:showExceptionTips(GKefuOnlyOneConstant.DELAY_CONNECT_DEADLINE)
                view:resetBottom()
                view:contentPreUpdate()
            end
            
            --显示界面后再connect
            GKefuNetWorkControl.init()
        end

        str = string.format("<font color=#000000 size=36>%s</font>", ConstString.custom_chat_tips)
        self.m_customBtn = UI.Button{
            image ={
                normal = TextureUnit(TextureCache.instance():get(KefuResMap.chatVoice9BtnUp)),
                down = TextureUnit(TextureCache.instance():get(KefuResMap.chatVoice9BtnDw)),
            },
                          
            border = false,
            text = str,
        }

        self.m_customBtn.on_click = function ()
            local data = UserData.getStatusData() or {}
            data.isOut = false
            data.isVip = false
            data.connectCallbackStatus = false
            UserData.setStatusData(data)
            mqtt_client_config.role = "2"
            mqtt_client_config.stationId = self.m_edit.text~="" and self.m_edit.text or mqtt_client_config.stationId
            mqtt_client_info.userID = mqtt_client_config.stationId
            mqtt_client_config.gameId = self.m_editGId.text ~= "" and self.m_editGId.text or mqtt_client_config.gameId
            mqtt_client_config.siteId = self.m_editSId.text ~= "" and self.m_editSId.text or mqtt_client_config.siteId
            
            UserData.initLeaveDict()
            UserData.initHackDict()
            UserData.initAppealDict()
            EventDispatcher.getInstance():register(Event.Back, GKefuViewManager, GKefuViewManager.onBackEvent)
            local view = GKefuViewManager.showNormalChatView(GKefuOnlyOneConstant.No)
            if view then
                view:showExceptionTips(GKefuOnlyOneConstant.DELAY_CONNECT_DEADLINE)
                view:resetBottom()
                view:contentPreUpdate()
            end
            

            GKefuNetWorkControl.init()
        end

        self.m_root:add(self.m_customBtn)


        self.m_customBtn:add_rules{
            AL.width:eq(AL.parent('width')-20),
            AL.height:eq(80),
            AL.top:eq(600),
            AL.left:eq(10),
        }

        
        self.m_firstTime = true
        self:createEnvironmentSelect()

        self:createOffMsgTags()
    end,

    createEnvironmentSelect = function (self)
        --测试
        local radioTest = UI.RadioButton {
            size = Point(55,55),
            checked = true,
            image =
            {
                checked_enabled = TextureUnit(TextureCache.instance():get(KefuResMap.radioButton2)),
                unchecked_enabled = TextureUnit(TextureCache.instance():get(KefuResMap.radioButton1)),
            }
        }

        radioTest:add_rules{
            AL.left:eq(50),
            AL.top:eq(800),
        }

        self.m_root:add(radioTest)

        local labelTest = Label()
        labelTest:set_rich_text(string.format('<font color=#000000 size=33>%s</font>', "测试服"))
        labelTest:add_rules{
            AL.width:eq(200),
            AL.height:eq(40),
            AL.left:eq(AL.parent('width') + 17),
            AL.top:eq(10),
        }
        
        labelTest:update(false)
        radioTest:add(labelTest)

        --正式服
        local radioForm = UI.RadioButton {
            size = Point(55,55),
            checked = true,
            image =
            {
                checked_enabled = TextureUnit(TextureCache.instance():get(KefuResMap.radioButton2)),
                unchecked_enabled = TextureUnit(TextureCache.instance():get(KefuResMap.radioButton1)),
            }
        }

        radioForm:add_rules{
            AL.left:eq(270),
            AL.top:eq(800),
        }

        self.m_root:add(radioForm)


        local labelForm = Label()
        labelForm:set_rich_text(string.format('<font color=#000000 size=33>%s</font>', "正式服"))
        labelForm:add_rules{
            AL.width:eq(200),
            AL.height:eq(40),
            AL.left:eq(AL.parent('width') + 17),
            AL.top:eq(10),
        }
        
        labelForm:update(false)
        radioForm:add(labelForm)

        --预发布
        local radioPre = UI.RadioButton {
            size = Point(55,55),
            checked = true,
            image =
            {
                checked_enabled = TextureUnit(TextureCache.instance():get(KefuResMap.radioButton2)),
                unchecked_enabled = TextureUnit(TextureCache.instance():get(KefuResMap.radioButton1)),
            }
        }

        radioPre:add_rules{
            AL.left:eq(500),
            AL.top:eq(800),
        }
        self.m_root:add(radioPre)

        local labelPre = Label()
        labelPre:set_rich_text(string.format('<font color=#000000 size=33>%s</font>', "预发布"))
        labelPre:add_rules{
            AL.width:eq(200),
            AL.height:eq(40),
            AL.left:eq(AL.parent('width') + 17),
            AL.top:eq(10),
        }
        
        labelPre:update(false)
        radioPre:add(labelPre)

        --临时环境
        local radioTemp = UI.RadioButton {
            size = Point(55,55),
            checked = true,
            image =
            {
                checked_enabled = TextureUnit(TextureCache.instance():get(KefuResMap.radioButton2)),
                unchecked_enabled = TextureUnit(TextureCache.instance():get(KefuResMap.radioButton1)),
            }
        }

        radioTemp:add_rules{
            AL.left:eq(50),
            AL.top:eq(930),
        }
        self.m_root:add(radioTemp)

        local labelTemp = Label()
        labelTemp:set_rich_text(string.format('<font color=#000000 size=33>%s</font>', "临时"))
        labelTemp:add_rules{
            AL.width:eq(200),
            AL.height:eq(40),
            AL.left:eq(AL.parent('width') + 17),
            AL.top:eq(10),
        }
        
        labelTemp:update(false)
        radioTemp:add(labelTemp)


        local radioGroup = UI.RadioGroup {}
        radioTest.group = radioGroup
        radioForm.group = radioGroup
        radioPre.group = radioGroup
        radioTemp.group = radioGroup

        radioGroup.on_change = function(radio, id)
            URL.setURLPrefix(id, self.m_isAboard)
            if id == 1 then
                mqtt_client_config.host = URL.CONNECT_TCP_HOST_TEST
            elseif id == 2 then
                if not self.m_isAboard then
                    mqtt_client_config.host = URL.CONNECT_TCP_HOST
                else
                    mqtt_client_config.host = URL.CONNECT_TCP_HOST_ABROAD
                end
            elseif id == 3 then
                mqtt_client_config.host = URL.CONNECT_TCP_HOST_PRE_Release
                mqtt_client_config.port = URL.CONNECT_TCP_TEST_PORT
            elseif id == 4 then
                if not self.m_isAboard then
                    mqtt_client_config.host = URL.CONNECT_TCP_HOST_TEMP
                else
                    mqtt_client_config.host = URL.CONNECT_TCP_HOST_TEMP_ABROAD
                end
            end
            --获取模块配置信息
            GKefuNetWorkControl.abtainModuleInfoCfg()

            GKefuNetWorkControl.getOffMsgNum(function (num)
                if num > 0 then
                    self.m_offMsgTag[1].visible = true
                    self.m_offMsgTag[2].visible = true
                else
                    self.m_offMsgTag[1].visible = false
                    self.m_offMsgTag[2].visible = false
                end
                local data = UserData.getStatusData() or {}
                data.offMsgNum = num
                UserData.setStatusData(data)
            end)
        end
        radioGroup.current = 1

        local aboardCheckBox = UI.Checkbox{
            image = {
                checked_enabled = TextureUnit(TextureCache.instance():get(KefuResMap.checkBox2)),
                unchecked_enabled = TextureUnit(TextureCache.instance():get(KefuResMap.checkBox1)),
                checked_disabled = TextureUnit(TextureCache.instance():get(KefuResMap.checkBox2)),
                unchecked_disabled = TextureUnit(TextureCache.instance():get(KefuResMap.checkBox1)),
            },
            size = Point(52, 52),
            checked = false,
            radius = 0,
        }
        aboardCheckBox:add_rules{
            AL.left:eq(270),
            AL.top:eq(930),
        }
        self.m_root:add(aboardCheckBox)

        local labelAboard = Label()
        labelAboard:set_rich_text(string.format('<font color=#000000 size=33>%s</font>', "海外线"))
        labelAboard:add_rules{
            AL.width:eq(200),
            AL.height:eq(40),
            AL.left:eq(AL.parent('width') + 17),
            AL.top:eq(10),
        }
        aboardCheckBox:add(labelAboard)
        aboardCheckBox.on_change = function (cbox)
            if cbox.checked then
                self.m_isAboard = true
            else
                self.m_isAboard = nil
            end
        end

    end,

    setBtnStatus = function (self, enable)
        self.m_customBtn.enabled = enable
        self.m_vipBtn.enabled = enable
    end,

    --需要重载该函数
    onUpdate = function (self, ...)
        if not self.m_firstTime then
        	-- GKefuNetWorkControl.getOffMsgNum(function (num)
         --        if num > 0 then
         --            self.m_offMsgTag[1].visible = true
         --            self.m_offMsgTag[2].visible = true
         --        else
         --            self.m_offMsgTag[1].visible = false
         --            self.m_offMsgTag[2].visible = false
         --        end
         --        local data = UserData.getStatusData() or {}
         --        data.offMsgNum = num
         --        UserData.setStatusData(data)
         --    end)
        end

        self.m_firstTime = nil

    end,

    createOffMsgTags = function (self)
        self.m_offMsgTag = {}
        for i = 1, 2 do
            self.m_offMsgTag[i] = Sprite(TextureUnit(TextureCache.instance():get(KefuResMap.redCircle)))
            self.m_offMsgTag[i]:add_rules{
                AL.width:eq(18),
                AL.height:eq(18),
                AL.top:eq(30),
                AL.right:eq(AL.parent("width") - 50),
            }
            self.m_offMsgTag[i].visible = false
        end

        self.m_vipBtn:add(self.m_offMsgTag[1])
        self.m_customBtn:add(self.m_offMsgTag[2])

    end,

})


return startView