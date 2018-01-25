local UI = require('byui/basic')
local AL = require('byui/autolayout')
local class, mixin, super = unpack(require('byui/class'))
local Layout = require('byui/layout')
local Anim = require('animation')
local baseView = require('kefuSystem/view/baseView')
local SelComponent = require('kefuSystem/view/selComponent')
local UserData = require('kefuSystem/conversation/sessionData')
local kefuCommon = require('kefuSystem/kefuCommon')
local ConstString = require('kefuSystem/common/kefuStringRes')
local KefuResMap = require('kefuSystem/qn_res_alias_map')
local Log = require('kefuSystem/common/log')
local KefuEmoji = require('kefuSystem/common/kefuEmojiCfg')
local URL = require("kefuSystem/mqttModule/mqttConstants")
local GKefuOnlyOneConstant = require('kefuSystem/common/kefuConstant')
local GKefuNetWorkControl = require('kefuSystem/conversation/netWorkControl')
local GKefuViewManager = require('kefuSystem/viewManager')

local page_view
local sliderBlock
local newReplyBg = nil
local newReplyTxt = nil
local newTags = {}


local playerReportView
playerReportView = class('playerReportView', baseView, {
    __init__ = function(self)
        super(playerReportView, self).__init__(self)
        self.m_firstStatus = {}
        self.m_secondStatus = {}
        local data = UserData.getStatusData()
        if data.isVip then
            self.m_txtColor = "#f4c493"
        else
            self.m_txtColor = "#6fba2c"
        end

        self.m_root.background_color = Colorf(235/255,235/255,235/255,1)
        -- ==============================================top=========================================================
        local topContainer = Widget()
        topContainer.background_color = Colorf(0.227, 0.188, 0.31, 1.0)
        topContainer:add_rules{
            AL.width:eq(AL.parent('width')),
            AL.height:eq(100),
        }
        self.m_root:add(topContainer)
        self.m_topContainer = topContainer

        local txtTitle = Label()
        txtTitle:set_rich_text(string.format("<font color=#F4C392 bg=#00000000 size=34 weight=3>%s</font>", ConstString.lose_account_appeal))
        txtTitle.absolute_align = ALIGN.CENTER
        topContainer:add(txtTitle)
        self.m_txtTitle = txtTitle

        local btnBack = UI.Button {
            text = string.format("<font color=#F4C392 bg=#00000000 size=28>%s</font>", ConstString.back_txt),
            margin = { 10, 10, 10, 10 },
            image =
            {
                normal = Colorf(1.0,0.0,0.0,0.0),
                down = Colorf(0.81,0.81,0.81,0.6),
                disabled = Colorf(0.2,0.2,0.2,1),
            },
            border = true,
            on_click = function()
                self:onBackEvent()
            end
        }
        btnBack:add_rules{
            AL.width:eq(160),
            AL.height:eq(AL.parent('height')),
        }
        topContainer:add(btnBack)
        self.m_btnBack = btnBack

        -- 创建箭头图标
        local arrowIcon = Sprite(TextureUnit(TextureCache.instance():get(KefuResMap.chatBackVip)))
        arrowIcon:add_rules{
            AL.width:eq(24),
            AL.height:eq(42),
            AL.top:eq(26),
            AL.left:eq(17),
        }
        btnBack:add(arrowIcon)
        self.m_arrowIcon = arrowIcon

        -- ==============================================tab=========================================================
        local buttomContainer = Widget()
        buttomContainer.background_color = Colorf(1, 1, 1, 1.0)
        buttomContainer:add_rules{
            AL.width:eq(AL.parent('width')-40),
            AL.height:eq(120),
            AL.centerx:eq(AL.parent('width') * 0.5),

        }
        self.m_root:add(buttomContainer)

        self.m_buttomContainer = buttomContainer
        self.m_buttomContainerY = 120
        buttomContainer.y = self.m_buttomContainerY


        -- tab 的灰色背景条
        local tabBg = Widget()
        tabBg:add_rules{
            AL.width:eq(AL.parent('width')),
            AL.height:eq(10),
            AL.centerx:eq(AL.parent('width') * 0.5),
            AL.top:eq(0),
        }
        tabBg.background_color = Colorf(0.68, 0.68, 0.68, 1)
        buttomContainer:add(tabBg)

        sliderBlock = Widget()
        sliderBlock:add_rules{
            AL.width:eq(AL.parent('width') / 2),
            AL.height:eq(10),
        }

        sliderBlock.background_color = Colorf(0.9568, 0.7647, 0.572, 1)
        tabBg:add(sliderBlock)

        

        local btnAppealAgainst = UI.Button {
            text = string.format('<font color=#f4c493 size=30>%s</font>', ConstString.report_appeal_txt),
            margin = { 10, 10, 10, 10 },
            image =
            {
                normal = Colorf(1.0,1.0,1.0,0.0),
                down = color_to_colorf(Color(173,225,245,140)),
                disabled = Colorf(0.2,0.2,0.2,1),
            },
        }

        btnAppealAgainst:add_rules{
            AL.width:eq(AL.parent('width') / 2),
            AL.height:eq(AL.parent('height')-10),
            AL.left:eq(0),
            AL.top:eq(10),
        }
        buttomContainer:add(btnAppealAgainst)

        local btnAppealHistory = UI.Button {
            text = string.format('<font color=#9b9b9b size=30>%s</font>', ConstString.appeal_history_txt),
            margin = { 10, 10, 10, 10 },
            image =
            {
                normal = Colorf(1.0,1.0,1.0,0.0),
                down = color_to_colorf(Color(173,225,245,140)),
                disabled = Colorf(0.2,0.2,0.2,1),
            },
        }
        btnAppealHistory:add_rules{
            AL.width:eq(AL.parent('width') / 2),
            AL.height:eq(AL.parent('height')-10),
            AL.top:eq(10),
            AL.right:eq(AL.parent('width')),
        }
        buttomContainer:add(btnAppealHistory)

        btnAppealAgainst.on_click = function()
            if page_view.page_num == 1 then return end           
            page_view.page_num = 1
        end

        btnAppealHistory.on_click = function()
            if page_view.page_num == 2 then return end           
            page_view.page_num = 2
        end

        btnAppealAgainst.text = string.format('<font color=%s size=30>%s</font>', self.m_txtColor, ConstString.report_appeal_txt)
        btnAppealHistory.text = string.format('<font color=#9b9b9b size=30>%s</font>', ConstString.appeal_history_txt)

        self.m_newReplyBg = Sprite(TextureUnit(TextureCache.instance():get(KefuResMap.redCircleBig)))
        self.m_newReplyBg:add_rules{
            AL.width:eq(35),
            AL.height:eq(35),
            AL.top:eq((AL.parent('height')-45)/2 + 9),
            AL.right:eq(AL.parent('width') - (AL.parent('width')/2-150)/2 + 25),
        }
        buttomContainer:add(self.m_newReplyBg)
        newReplyBg = self.m_newReplyBg
        self.m_newReplyTxt = Label()
        self.m_newReplyTxt:set_rich_text(string.format("<font color=#ffffff bg=#00000000 size=22 weight=1>1</font>"))
        self.m_newReplyTxt.absolute_align = ALIGN.CENTER
        self.m_newReplyBg:add(self.m_newReplyTxt)
        newReplyTxt = self.m_newReplyTxt

        -- tapTOp 分界线
        local partLine = Sprite(TextureUnit.default_unit())
        partLine:add_rules{
            AL.width:eq(AL.parent('width')),
            AL.height:eq(5.5),
            AL.bottom:eq(AL.parent('height')),
        }
        partLine.colorf = Colorf(0.7, 0.7, 0.7, 1)
        buttomContainer:add(partLine)

        page_view = UI.PageView {
            dimension = kHorizental,
            max_number = 2,
        }

        
        page_view.background_color = Colorf.white
        page_view:add_rules{
            AL.width:eq(AL.parent('width') -40),
            AL.height:eq(AL.parent('height') -255),
            AL.centerx:eq(AL.parent('width') * 0.5),
        }
        self.m_root:add(page_view)
        self.m_pageViewY = 240
        page_view.y = self.m_pageViewY
        page_view.focus = true 

        self.m_pageContainers = {}

        page_view.create_cell = function(pageView, i)
            local page = self:initPage(i)
            self.m_pageContainers[i] = page
            return page
        end
        page_view:update_data()
        self.m_pageView = page_view

        self.m_hideCallBack = function ()
            self.m_pageView.page_num = 1
        end

        self.m_pageView.on_page_change = function ()
            if self.m_pageView.page_num == 1 then
                btnAppealAgainst.text = string.format('<font color=%s size=30>%s</font>', self.m_txtColor, ConstString.report_appeal_txt)
                btnAppealHistory.text = string.format('<font color=#9b9b9b size=30>%s</font>', ConstString.appeal_history_txt)
            
            else
                btnAppealAgainst.text = string.format('<font color=#9b9b9b size=30>%s</font>', ConstString.report_appeal_txt)
                btnAppealHistory.text = string.format('<font color=%s size=30>%s</font>', self.m_txtColor, ConstString.appeal_history_txt)
            
            end
        end
        self.m_pageView.on_scroll = function ( _, p,d,v)
            if sliderBlock then
                sliderBlock.x = -(sliderBlock.width / self.m_pageView.width)*p.x
            end
        end

        self.m_root:add(topContainer)

        self:resetReportInfo()
    end,

    initPage = function (self, i)
        local container = Widget()
        if i == 1 then
            local container = Widget()
            container:add_rules{
                AL.width:eq(AL.parent('width')-1),
                AL.height:eq(AL.parent('height')),
            }

            self.m_pageSub1 = self:addPageSub1()
            container:add(self.m_pageSub1)

            return container
        elseif i == 2 then
            local container = Widget()
            container:add_rules{
                AL.width:eq(AL.parent('width')),
                AL.height:eq(AL.parent('height')),
            }

            self.m_listview = UI.ListView {
                size = container.size,
                create_cell = function(data)
                    local container = self:createHistoryItem(data)
                    return container
                end,
            }
            self.m_listview.shows_vertical_scroll_indicator = true
            self.m_listview:add_rules{
                AL.width:eq(AL.parent('width')),
                AL.height:eq(AL.parent('height')),
                AL.left:eq(1),
            }
            container:add(self.m_listview)
            self.m_listview.velocity_factor = 3.1

            self.m_noRecordLabel = Label()
            self.m_noRecordLabel:set_rich_text(string.format("<font color=#9b9b9b bg=#00000000 size=44 weight=3>%s</font>", ConstString.no_anyrecord_tips))
            container:add(self.m_noRecordLabel)
            self.m_noRecordLabel.absolute_align = ALIGN.CENTER
            self.m_listview.background_color = Colorf(244/255, 244/255, 244/255, 1)

            return container
        end

    end,

    createHistoryItem = function(self, data)
        local container = Widget()
        container:add_rules{
            AL.width:eq(AL.parent('width')),
            AL.centerx:eq(AL.parent('width') * 0.5),
        }
        container.height_hint = 90

        local btnItem = UI.Button {
            text = "",
            margin = { 10, 10, 10, 10 },
            image =
            {
                normal = Colorf(1.0,1.0,1.0,0.0),
                down = Colorf(0.996,0.7411,0.1411,1.0),
                disabled = Colorf(0.2,0.2,0.2,1),
            },
            border = true,

        }
        btnItem.zorder = 1
        btnItem:add_rules{
            AL.width:eq(AL.parent('width')),
            AL.height:eq(90),
            AL.centerx:eq(AL.parent('width') * 0.5),
            AL.top:eq(0),
        }
        container:add(btnItem)


        local txtTitle = Label()
        txtTitle:set_rich_text(string.format('<font color=#000000 size=30>%s</font>', ConstString.lose_account_appeal1))
        txtTitle:add_rules{
            AL.left:eq(30),
            AL.top:eq(30),
        }

        btnItem:add(txtTitle)

        local txtTime = Label()
        local timeStr = os.date("%Y-%m-%d %H:%M", data.time)
        txtTime:set_rich_text(string.format('<font color=#9b9b9b size=30>%s</font>', timeStr))
        btnItem:add(txtTime)
        txtTime:update()

        txtTime:add_rules{
            AL.width:eq(150),
            AL.height:eq(20),
            AL.left:eq(AL.parent('width') - txtTime.width - 70),
            AL.centery:eq(AL.parent('height') * 0.44),
        }

        -- 创建箭头图标
        local arrowIcon = Sprite(TextureUnit(TextureCache.instance():get(KefuResMap.commonUnfold)))
        arrowIcon:add_rules{
            AL.left:eq(AL.parent('width') - 30),
            AL.centery:eq(AL.parent('height') * 0.5),
        }
        btnItem:add(arrowIcon)

        -- 创建箭头图标
        local arrowIcon1 = Sprite(TextureUnit(TextureCache.instance():get(KefuResMap.commonRetract)))
        arrowIcon1:add_rules{
            AL.left:eq(AL.parent('width') -30),
            AL.centery:eq(AL.parent('height') * 0.5),
        }
        arrowIcon1.visible = false
        btnItem:add(arrowIcon1)

        local topLine = Widget() 
        topLine:add_rules{
            AL.width:eq(AL.parent('width')),
            AL.height:eq(kefuCommon.getLineRealHeight(1)),
            AL.bottom:eq(AL.parent('height')),
        } 
        topLine.background_color = Colorf(0.0, 0.0, 0.0, 1)
        btnItem:add(topLine)

        if not newTags[data.id] then
            newTags[data.id] = Sprite(TextureUnit(TextureCache.instance():get(KefuResMap.redCircle)))
            newTags[data.id]:add_rules{
                AL.width:eq(18),
                AL.height:eq(18),
                AL.top:eq(14),
                AL.right:eq(AL.parent('width')-50),
            }
        else
            newTags[data.id]:remove_from_parent()
        end
        btnItem:add(newTags[data.id])
        if data.hasNewReport == GKefuOnlyOneConstant.HasNewReport.yes then
            newTags[data.id].visible = true
        else
            newTags[data.id].visible = false
        end



        local contentCon = Widget()
        contentCon:add_rules{
            AL.width:eq(AL.parent('width')),
            AL.top:eq(90),
        }
        contentCon.background_color = color_to_colorf(Color(224, 224, 224, 255))
        contentCon.visible = false
        container:add(contentCon)

        local lines = {}
        for i = 1, 2 do
            lines[i] = Widget()
            lines[i]:add_rules{
                AL.width:eq(AL.parent('width')),
                AL.height:eq(kefuCommon.getLineRealHeight(1)), 
            }
            lines[i].background_color = Colorf(0.1, 0.1, 0.1, 1.0)
            contentCon:add(lines[i])
        end



        local space = 30
        local posY = space
        

    ----------编号    
        local txtNo = Label()
        txtNo:set_rich_text(string.format('<font color=#9b9b9b size=30>%s</font>', ConstString.number_txt))
        txtNo:add_rules{
            AL.left:eq(30),
            AL.top:eq(posY),
        }
        contentCon:add(txtNo)
        txtNo:update()
        local labelHeight = txtNo.height - 8

        local labelNo = Label()
        labelNo:set_rich_text(string.format('<font color=#000000 size=30>%s</font>', data.id))
        labelNo:add_rules{
            AL.width:eq(60),
            AL.height:eq(20),
            AL.left:eq(112),
            AL.top:eq(posY),
        }
        contentCon:add(labelNo)

        --已经回复了并且标明有错误信息，需要显示再次申诉按钮，错误信息在err_info中
        if data.reply ~= string.format(ConstString.replay_default,mqtt_client_info.hotline) and data.errInfo ~= "" then
            local againBtn = UI.Button{
                text = string.format('<font color=#329bdd size=30 weight=1>%s</font>', ConstString.again_to_report_txt),
                image =
                {
                    normal = Colorf(0.43,0.73,0.17,0.0),
                    down = Colorf(0.77,0.77,0.77, 0.0),
                },
            }

            againBtn.label:set_underline(Color(50,155,221))
            againBtn:add_rules{
                AL.width:eq(170),
                AL.height:eq(space + labelHeight),
                AL.right:eq(AL.parent('width') - 25),
                AL.top:eq(space/2),
            }
            contentCon:add(againBtn)
            --如果是错误的项，则留空白，让用户自己填；正确的项不需要用户填
            againBtn.on_click = function ()
                local showPage1 = nil
                self:resetReportInfo()

                --处理Mid
                if string.find(data.errInfo, "lost_mid") then
                    showPage1 = true
                else
                    self.m_MId = data.mid
                end

                self.m_editId.text = string.format('<font color=#000000 size=30>%s</font>', self.m_MId)
                if self.m_MId ~= "" then
                    self.m_firstStatus[1] = true
                end

                --处理loseTime
                if string.find(data.errInfo, "lost_time") then                   
                    showPage1 = true
                else
                    self.m_loseTimeTxt = data.lostTimeStr
                end

                if self.m_loseTimeTxt == "" then
                    self.m_typeLabel:set_rich_text(string.format('<font color=#9b9b9b size=30>%s</font>', ConstString.lose_account_time_hint))
                else
                    self.m_typeLabel:set_rich_text(string.format('<font color=#000000 size=30>%s</font>', self.m_loseTimeTxt))
                    self.m_firstStatus[2] = true
                end

                --处理LostMoney
                if string.find(data.errInfo, "lost_chip") then
                    showPage1 = true
                else
                    self.m_lostMoney = data.lostChip
                end

                self.m_editLostMoney.text = string.format('<font color=#000000 size=30>%s</font>', self.m_lostMoney)
                if self.m_lostMoney ~= "" then
                    self.m_firstStatus[3] = true
                end

                self:setFirstNextBtnStatus()

                
            
                if not self.m_pageSub2 then
                    self.m_pageSub2 = self:addPageSub2()
                    self.m_pageContainers[1]:add(self.m_pageSub2)
                end

                self.m_secondStatus = {}
                --处理ip地址
                if not string.find(data.errInfo, "ip") then
                    self.m_ipTxt = data.ip
                end

                self.m_IPEdit.text = string.format('<font color=#000000 size=30>%s</font>', self.m_ipTxt)
                if self.m_ipTxt ~= "" then
                    self.m_secondStatus[1] = true 
                end

                --处理lastMoney
                if not string.find(data.errInfo, "last_chip") then
                    self.m_lastMoney = data.lastChip
                end

                self.m_lastMoneyEdit.text = string.format('<font color=#000000 size=30>%s</font>', self.m_lastMoney)
                if self.m_lastMoney ~= "" then
                    self.m_secondStatus[2] = true 
                end

                --处理joinTime
                if not string.find(data.errInfo, "first_login_time") then
                    self.m_joinTimeTxt = data.firstLoginTime
                end

                if self.m_joinTimeTxt == "" then
                    self.m_joinTimeLabel:set_rich_text(string.format('<font color=#9b9b9b size=30>%s</font>', ConstString.input_first_time_hint))
                else
                    self.m_secondStatus[3] = true
                    self.m_joinTimeLabel:set_rich_text(string.format('<font color=#000000 size=30>%s</font>', self.m_joinTimeTxt))
                end


                --处理lastTime
                if not string.find(data.errInfo, "last_login_time") then
                    self.m_lastTimeTxt = data.lastLoginTime
                end

                if self.m_lastTimeTxt == "" then
                    self.m_lastTimeLabel:set_rich_text(string.format('<font color=#9b9b9b size=30>%s</font>', ConstString.input_last_time_hint))
                else
                    self.m_secondStatus[4] = true
                    self.m_lastTimeLabel:set_rich_text(string.format('<font color=#000000 size=30>%s</font>', self.m_lastTimeTxt))
                end

                --处理safeBox
                if not string.find(data.errInfo, "bank") then
                    self.m_safeBoxMoney = data.bank 
                
                end

                self.m_safeBoxEdit.text = string.format('<font color=#000000 size=30>%s</font>', self.m_safeBoxMoney)
                if self.m_safeBoxMoney ~= "" then
                    self.m_secondStatus[5] = true
                end

                self:setSecondNextBtnStatus()
                

                if showPage1 then
                    self.m_pageSub1.visible = true
                    self.m_pageSub2.visible = false
                else
                    self.m_pageSub1.visible = false
                    self.m_pageSub2.visible = true
                end       
                page_view.page_num = 1
                self.m_submitUrl = URL.HTTP_SUBMIT_APPEAL_URI.."/"..data.id
                self.m_onBackMustReset = true

            end
        end

        lines[1].y = posY + space + labelHeight 

    --回复
        posY = posY + space*2 + labelHeight          --30为文字高    
        local txtReply = Label()
        txtReply:set_rich_text(string.format('<font color=#9b9b9b size=30>%s</font>', ConstString.servicer_reply_tips))
        txtReply:add_rules{
            AL.width:eq(60),
            AL.height:eq(20),
            AL.left:eq(30),
            AL.top:eq(posY),
        }
        contentCon:add(txtReply)


        local labelReply = Label()
        labelReply:add_rules{
            AL.height:eq(20),
            AL.left:eq(180),
            AL.top:eq(posY),
        }
        labelReply.layout_size = Point(GKefuOnlyOneConstant.SCREENWIDTH - 250, 0)
        contentCon:add(labelReply)

        local cts = string.gsub(data.reply, "%[(.-)%]", function (char)
            if KefuEmoji.NameToId[char] then
                return kefuCommon.unicodeToChar(KefuEmoji.NameToId[char])
            else
                return string.format("[%s]", char)
            end
        end)


        labelReply:set_rich_text(string.format('<font color=#000000 size=30>%s</font>', cts))
        labelReply:update()
        posY = posY + labelReply.height+space - 8
        contentCon.height_hint = posY
        lines[2].y = posY - 1


        btnItem.on_click = function()
            arrowIcon.visible = contentCon.visible
            arrowIcon1.visible = not contentCon.visible
            contentCon.visible = not contentCon.visible

            if contentCon.visible then
                container.height_hint = contentCon.height_hint + 90
                newTags[data.id].visible = false
                if data.hasNewReport == GKefuOnlyOneConstant.HasNewReport.yes then
                    local appealData = UserData.getPlayerReportViewData() or {}
                    local dictData = appealData.dictData or {}
                    appealData.hasNewReport = appealData.hasNewReport - 1
                    dictData[data.id].hasNewReport = GKefuOnlyOneConstant.HasNewReport.no
                    UserData.updateAppealMsg(dictData[data.id])
                    UserData.setPlayerReportViewData(appealData)

                    newReplyTxt:set_rich_text(string.format("<font color=#ffffff bg=#00000000 size=24 weight=1>%d</font>", appealData.hasNewReport))
                    if appealData.hasNewReport <= 0 and newReplyBg then
                        newReplyBg.visible = false
                    end
                end
            else
                container.height_hint = 90
            end
            container:update_constraints()
        end  

        return container
    end,

    addPageSub1 = function (self)
        local container = Widget()
        container:add_rules(AL.rules.fill_parent)

        local itemsData = {
            { title = ConstString.lose_account_id, hint_text = ConstString.lose_account_id_hint, ui_type = "edit" },
            { title = ConstString.lose_account_time, hint_text = ConstString.lose_account_time_hint, ui_type = "label", icon = KefuResMap.commonMore },
            { title = ConstString.lose_account_money, hint_text = ConstString.lose_account_money_hint, ui_type = "edit" }
        }

        self.m_Items = {}
        local height = 110
        local lineH = 2

        for i = 1, 3 do
            local item = Widget()
            item:add_rules{
                AL.width:eq(AL.parent('width')),
                AL.height:eq(height),
                AL.centerx:eq(AL.parent('width') * 0.5),
                AL.top:eq(height*(i-1)),
            }
            container:add(item)
            self.m_Items[i] = item

            local line = Widget()
            line:add_rules{
                AL.width:eq(AL.parent('width')),
                AL.height:eq(kefuCommon.getLineRealHeight(lineH)),
                AL.bottom:eq(AL.parent('height')),
            }
            line.background_color = Colorf(0.77, 0.77, 0.77, 1)
            item:add(line)

            local title = Label()
            title.align = Label.CENTER
            title:set_rich_text(string.format('<font color=#000000 size=30>%s</font>', itemsData[i].title))
            title.pos = Point(30  ,(height - title.height) /2)
            
            item:add(title)

            local tips = Label()
            tips:set_data{{text = "*",color = Color.red}}
            tips.pos = Point((30 -tips.width)/2 ,(height - tips.height) /2)
            item:add(tips)

            if itemsData[i].ui_type == "edit" then
                local edit = UI.EditBox {
                    background_style = KTextBorderStyleNone,
                    icon_style = KTextIconNone,
                    text = string.format('<font color=#000000 size=30>%s</font>',""),
                    hint_text = string.format('<font color=#9b9b9b size=30>%s</font>',itemsData[i].hint_text),
                }
                edit:add_rules{
                    AL.width:eq(AL.parent('width')-250),
                    AL.height:eq(80),
                    AL.left:eq(250),
                    AL.top:eq(30),
                }

                edit.keyboard_type = Application.KeyboardTypeNumberPad
                item:add(edit)
                if i == 1 then
                    self.m_editId = edit
                    self.m_editId.on_keyboard_hide = function ()
                        if self.m_editId.text == "" then
                            self.m_firstStatus[1] = nil
                        else
                            self.m_firstStatus[1] = true
                        end
                        self.m_MId = self.m_editId.text
                        
                        self:setFirstNextBtnStatus()
                    end
                else
                    self.m_editLostMoney = edit
                    self.m_editLostMoney.on_keyboard_hide = function ()
                        self.m_firstBgBtn.visible = false
                        self.m_buttomContainer.y = self.m_buttomContainerY
                        self.m_pageView.y = self.m_pageViewY

                        if self.m_editLostMoney.text == "" then
                            self.m_firstStatus[3] = nil
                        else
                            self.m_firstStatus[3] = true
                        end
                        self.m_lostMoney = self.m_editLostMoney.text

                        self:setFirstNextBtnStatus()
                    end

                    self.m_editLostMoney.on_keyboard_show = function (args)
                        self.m_firstBgBtn.visible = true
                        local linePos = self.m_Items[3]:to_world(Point(0, height))
                        local disY = linePos.y - args.y
                        if disY > 0 then
                            self.m_buttomContainer.y = self.m_buttomContainerY - disY
                            self.m_pageView.y = self.m_pageViewY - disY
                        end
                    end
                end
            elseif itemsData[i].ui_type == "label" then
                local typeWg = Widget()
                typeWg:add_rules{
                    AL.width:eq(AL.parent('width')-251),
                    AL.height:eq(AL.parent('height')),
                    AL.left:eq(251),
                }
                item:add(typeWg)

                local label = Label()
                label:set_rich_text(string.format('<font color=#9b9b9b size=30>%s</font>', itemsData[i].hint_text))
                label.absolute_align = ALIGN.LEFT
                typeWg:add(label)
                self.m_typeLabel = label

                self.m_selComp = SelComponent(self.m_root, {title = ConstString.choose_time_title, action = ConstString.sure_other_txt, ui_type = 1})

                UI.init_simple_event(typeWg, function ()
                    self.m_selComp.btn_callback = function(str)
                        self.m_loseTimeTxt = str
                        self.m_typeLabel:set_rich_text(string.format('<font color=#000000 size=30>%s</font>', self.m_loseTimeTxt))
                        self.m_firstStatus[2] = true
                        self:setFirstNextBtnStatus()
                    end

                    self.m_selComp:pop_up()
                end)
            end

            if itemsData[i].icon then
                local icon = Sprite(TextureUnit(TextureCache.instance():get(itemsData[i].icon)))
                icon:add_rules{
                    AL.left:eq(AL.parent('width') -30),
                    AL.centery:eq(50),
                }
                item:add(icon)
            end
        end

        local btnNext = UI.Button {
            text = string.format('<font color=#ffffff size=34>%s</font>', ConstString.next_step_txt),
            radius = 10,
            margin = { 10, 10, 10, 10 },
            image =
            {
                normal = Colorf(0.43,0.73,0.17,1.0),
                down = Colorf(0.77,0.77,0.77,1),
                disabled = Colorf(0.77,0.77,0.77,1),
            },
        }
        btnNext:add_rules{
            AL.width:eq(AL.parent('width') * 0.88),
            AL.height:eq(100),
            AL.centerx:eq(AL.parent('width') * 0.5),
            AL.bottom:eq(AL.parent('height')-30),
        }
        container:add(btnNext)

        btnNext.state = "disabled"
        btnNext.enabled = false
        btnNext.on_click = function()
            self.m_pageSub1.visible = false
            if not self.m_pageSub2 then
                self.m_pageSub2 = self:addPageSub2()
                self.m_pageContainers[1]:add(self.m_pageSub2)
            end

            self.m_secondStatus = {}
            self.m_IPEdit.text = string.format('<font color=#000000 size=30>%s</font>', self.m_ipTxt)
            if self.m_ipTxt ~= "" then
                self.m_secondStatus[1] = true 
            end

            self.m_lastMoneyEdit.text = string.format('<font color=#000000 size=30>%s</font>', self.m_lastMoney)
            if self.m_lastMoney ~= "" then
                self.m_secondStatus[2] = true 
            end

            if self.m_joinTimeTxt == "" then
                self.m_joinTimeLabel:set_rich_text(string.format('<font color=#9b9b9b size=30>%s</font>', ConstString.input_first_time_hint))
            else
                self.m_secondStatus[3] = true
                self.m_joinTimeLabel:set_rich_text(string.format('<font color=#000000 size=30>%s</font>', self.m_joinTimeTxt))
            end

            if self.m_lastTimeTxt == "" then
                self.m_lastTimeLabel:set_rich_text(string.format('<font color=#9b9b9b size=30>%s</font>', ConstString.input_last_time_hint))
            else
                self.m_secondStatus[4] = true
                self.m_lastTimeLabel:set_rich_text(string.format('<font color=#000000 size=30>%s</font>', self.m_lastTimeTxt))
            end

            self.m_safeBoxEdit.text = string.format('<font color=#000000 size=30>%s</font>', self.m_safeBoxMoney)
            if self.m_safeBoxMoney ~= "" then
                self.m_secondStatus[5] = true
            end

            self:setSecondNextBtnStatus()
            self.m_pageSub2.visible = true

        end
        self.m_firstNextBtn = btnNext

        self.m_firstBgBtn = UI.Button{
            text = "",
            image =
            {
                normal= Colorf(0.43,0.8,0.17,0.0),
                down= Colorf(0.43,0.73,0.17,0.0),
                disabled = Colorf(0.77,0.77,0.77,0.0),
            },
        }

        self.m_firstBgBtn:add_rules{
            AL.width:eq(AL.parent('width')),
            AL.height:eq(AL.parent('height')),
        }
        container:add(self.m_firstBgBtn)
        self.m_firstBgBtn.visible = false

        return container
    end,

    addPageSub2 = function (self)
        local container = Widget()
        container:add_rules(AL.rules.fill_parent)
        local height = 110
        local lineH = 2

        local config = {
            {hintText = ConstString.input_id_area_hint, uiType = "edit", },
            {hintText = ConstString.input_money_amount_hint, uiType = "edit"},
            {hintText = ConstString.input_first_time_hint, uiType = "label", icon = KefuResMap.commonMore},
            {hintText = ConstString.input_last_time_hint, uiType = "label", icon = KefuResMap.commonMore},
            {hintText = ConstString.input_safebox_money_hint, uiType = "edit"},
        }
        for i = 1, 5 do
            local item = Widget()
            item:add_rules{
                AL.width:eq(AL.parent('width')),
                AL.height:eq(height),
                AL.top:eq(height *(i - 1)),
            } 
            container:add(item)

            local line = Widget()
            line:add_rules{
                AL.width:eq(AL.parent('width')),
                AL.height:eq(kefuCommon.getLineRealHeight(lineH)),
                AL.bottom:eq(AL.parent('height')),
            }
            line.background_color = Colorf(0.77, 0.77, 0.77, 1)
            item:add(line)


            local tips = Label()
            tips:set_data{{text = "*",color = Color.red}}
            tips.pos = Point((30 -tips.width)/2 ,(height - tips.height) /2)
            item:add(tips)


            if config[i].uiType == "edit" then
                local edit = UI.EditBox {
                    background_style = KTextBorderStyleNone,
                    icon_style = KTextIconNone,
                    text = string.format('<font color=#000000 size=30>%s</font>',""),
                    hint_text = string.format('<font color=#9b9b9b size=30>%s</font>', config[i].hintText),
                }
                edit:add_rules{
                    AL.width:eq(AL.parent('width')-100),
                    AL.height:eq(80),
                    AL.left:eq(30),
                    AL.top:eq(30),
                }
                item:add(edit)

                if i == 1 then
                    self.m_IPEdit = edit
                    self.m_IPEdit.on_keyboard_hide = function ()
                        self.m_ipTxt = self.m_IPEdit.text
                        if self.m_ipTxt == "" then
                            self.m_secondStatus[1] = nil
                        else
                            self.m_secondStatus[1] = true
                        end
                        self:setSecondNextBtnStatus()
                    end

                elseif i == 2 then
                    self.m_lastMoneyEdit = edit
                    self.m_lastMoneyEdit.keyboard_type = Application.KeyboardTypeNumberPad
                    self.m_lastMoneyEdit.on_keyboard_hide = function ()
                        self.m_lastMoney = self.m_lastMoneyEdit.text
                        if self.m_lastMoney == "" then
                            self.m_secondStatus[2] = nil
                        else
                            self.m_secondStatus[2] = true
                        end
                        
                        self:setSecondNextBtnStatus()
                    end
                elseif i == 5 then
                    self.m_safeBoxEdit = edit
                    self.m_safeBoxEdit.keyboard_type = Application.KeyboardTypeNumberPad
                    self.m_safeBoxEdit.on_keyboard_hide = function ()
                        self.m_secondBgBtn.visible = false
                        self.m_buttomContainer.y = self.m_buttomContainerY
                        self.m_pageView.y = self.m_pageViewY

                        self.m_safeBoxMoney = self.m_safeBoxEdit.text 
                        if self.m_safeBoxMoney == "" then
                            self.m_secondStatus[5] = nil
                        else
                            self.m_secondStatus[5] = true
                        end
                        self:setSecondNextBtnStatus()
                    end

                    self.m_safeBoxEdit.on_keyboard_show = function (args)
                        self.m_secondBgBtn.visible = true
                        local linePos = item:to_world(Point(0, height))
                        local disY = linePos.y - args.y
                        if disY > 0 then
                            self.m_buttomContainer.y = self.m_buttomContainerY - disY
                            self.m_pageView.y = self.m_pageViewY - disY
                        end
                    end
                end 
            else
                local label = Label()
                label:set_rich_text(string.format('<font color=#9b9b9b size=30>%s</font>', config[i].hintText))
                label:add_rules{
                    AL.width:eq(600),
                    AL.height:eq(80),
                    AL.left:eq(31),
                    AL.top:eq(30),
                }
                item:add(label)

                if i == 3 then
                    self.m_joinTimeLabel = label
                    UI.init_simple_event(item, function ()
                        self.m_selComp.btn_callback = function(str)
                            self.m_joinTimeTxt = str
                            label:set_rich_text(string.format('<font color=#000000 size=30>%s</font>', self.m_joinTimeTxt))
                            self.m_secondStatus[3] = true
                            self:setSecondNextBtnStatus()
                        end

                        self.m_selComp:pop_up()
                    end)

                    

                elseif i == 4 then
                    self.m_lastTimeLabel = label
                    UI.init_simple_event(item, function ()
                        self.m_selComp.btn_callback = function(str)
                            self.m_lastTimeTxt = str
                            label:set_rich_text(string.format('<font color=#000000 size=30>%s</font>', self.m_lastTimeTxt))
                            self.m_secondStatus[4] = true
                            self:setSecondNextBtnStatus()
                        end
                    
                        self.m_selComp:pop_up()
                    end)

                    

                end 
            end

            if config[i].icon then
                local icon = Sprite(TextureUnit(TextureCache.instance():get(config[i].icon)))
                icon:add_rules{
                    AL.right:eq(AL.parent('width') - 20),
                    AL.centery:eq(height/2),
                }
                item:add(icon)
            end

        end

        local btnNext = UI.Button {
            text = string.format('<font color=#ffffff size=34>%s</font>', ConstString.next_step_txt),
            radius = 10,
            margin = { 10, 10, 10, 10 },
            image =
            {
                normal = Colorf(0.43,0.73,0.17,1.0),
                down = Colorf(0.77,0.77,0.77,1),
                disabled = Colorf(0.77,0.77,0.77,1),
            },
        }
        btnNext:add_rules{
            AL.width:eq(AL.parent('width') * 0.88),
            AL.height:eq(100),
            AL.centerx:eq(AL.parent('width') * 0.5),
            AL.bottom:eq(AL.parent('height')-30),
        }
    
        container:add(btnNext)
        self.m_secondNextBtn = btnNext
        btnNext.enable = false
        btnNext.state = "disabled"
        btnNext.on_click = function()
            self.m_pageSub2.visible = false
        
            if not self.m_pageSub3 then
                self.m_pageSub3 = self:addPageSub3()
                self.m_pageContainers[1]:add(self.m_pageSub3)
            end
            self.m_pageSub3.visible = true
            self.m_radioGroup.current = 2

        end

        self.m_secondBgBtn = UI.Button{
            text = "",
            image =
            {
                normal= Colorf(0.43,0.8,0.17,0.0),
                down= Colorf(0.43,0.73,0.17,0.0),
                disabled = Colorf(0.77,0.77,0.77,0.0),
            },
        }
        

        self.m_secondBgBtn:add_rules{
            AL.width:eq(AL.parent('width')),
            AL.height:eq(AL.parent('height')),
        }
        container:add(self.m_secondBgBtn)
        self.m_secondBgBtn.visible = false



        return container
    end,

    addPageSub3 = function (self)
        local container = Widget()
        container:add_rules(AL.rules.fill_parent)

        local labelTitle = Label()
        labelTitle:set_rich_text(string.format('<font color=#000000 size=50>%s</font>', ConstString.report_protocal_title))
        labelTitle:add_rules{
            AL.centerx:eq(AL.parent('width') * 0.5),
            AL.top:eq(70),
        }
        labelTitle:update(false)
        container:add(labelTitle)

        local labelContent = Label()
        labelContent.multiline = true
        labelContent:set_rich_text(string.format(ConstString.report_protocal_tips, mqtt_client_config.stationId))
        labelContent:add_rules{
            AL.centerx:eq(AL.parent('width') * 0.5),
            AL.top:eq(180),
        }
        
        labelContent:update(false)
        labelContent.layout_size = Point(600, 80)
        container:add(labelContent)

        local btnCommit = UI.Button {
            text = string.format('<font color=#ffffff size=34>%s</font>', ConstString.sumbit_txt),
            radius = 10,
            margin = { 10, 10, 10, 10 },
            image =
            {
                normal = Colorf(0.43,0.73,0.17,1.0),
                down = Colorf(0.77,0.77,0.77,1),
                disabled = Colorf(0.77,0.77,0.77,1),
            },
        }
        btnCommit:add_rules{
            AL.width:eq(AL.parent('width') * 0.88),
            AL.height:eq(100),
            AL.centerx:eq(AL.parent('width') * 0.5),
            AL.bottom:eq(AL.parent('height')-30),
        }
        
        container:add(btnCommit)

        self.m_btnCommit = btnCommit

        local radioAgree = UI.RadioButton {
            size = Point(55,55),
            checked = true,
            image =
            {
                checked_enabled = TextureUnit(TextureCache.instance():get(KefuResMap.radioButton2)),
                unchecked_enabled = TextureUnit(TextureCache.instance():get(KefuResMap.radioButton1)),
            }
        }
        radioAgree:add_rules{
            AL.left:eq(155),
            AL.top:eq(500),
        }
        container:add(radioAgree)

        local labelAgree = Label()
        labelAgree:set_rich_text(string.format('<font color=#000000 size=33>%s</font>', ConstString.agree_txt))
        labelAgree:add_rules{
            AL.width:eq(200),
            AL.height:eq(40),
            AL.left:eq(AL.parent('width') + 17),
            AL.top:eq(10),
        }
        
        labelAgree:update(false)
        radioAgree:add(labelAgree)

        local radioAgainst = UI.RadioButton {
            size = Point(55,55),
            checked = false,
            image =
            {
                checked_enabled = TextureUnit(TextureCache.instance():get(KefuResMap.radioButton2)),
                unchecked_enabled = TextureUnit(TextureCache.instance():get(KefuResMap.radioButton1)),
            }
        }
        radioAgainst:add_rules{
            AL.left:eq(AL.parent('width') - 315),
            AL.top:eq(500),
        }
        container:add(radioAgainst)

        local labelAgainst = Label()
        labelAgainst:set_rich_text(string.format('<font color=#000000 size=33>%s</font>', ConstString.disagree_txt))
        labelAgainst:add_rules{
            AL.width:eq(200),
            AL.height:eq(40),
            AL.left:eq(AL.parent('width') + 17),
            AL.top:eq(10),
        }
        
        labelAgainst:update(false)
        radioAgainst:add(labelAgainst)


        local radioGroup = UI.RadioGroup {}
        self.m_radioGroup = radioGroup

        radioGroup.on_change = function(radio, id)
            if id == 1 then
                self.m_btnCommit.state = "normal"
                self.m_btnCommit.enabled = true
            else
                self.m_btnCommit.state = "disabled"
                self.m_btnCommit.enabled = false
            end
        end

        radioAgree.group = radioGroup
        radioAgainst.group = radioGroup


        self.m_btnCommit.on_click = function()
            local tb = {}
            tb.gid = mqtt_client_config.gameId
            tb.site_id = mqtt_client_config.siteId
            tb.client_id = mqtt_client_config.stationId
            tb.device_type = 2
            tb.lost_mid = tonumber(self.m_MId)
            tb.lost_time = self.m_loseTimeTxt
            tb.lost_chip = tonumber(self.m_lostMoney)
            tb.first_login_time = self.m_joinTimeTxt
            tb.last_login_time = self.m_lastTimeTxt
            tb.ip = self.m_ipTxt
            tb.last_chip = tonumber(self.m_lastMoney)
            tb.bank = tonumber(self.m_safeBoxMoney)
            tb.client_info = GKefuNetWorkControl.generateClientInfo("")

            local content = cjson.encode(tb)
            Log.v("=====","盗号内容:" ,content);
            if not self.m_submitTips then
                self.m_submitTips, bg = kefuCommon.createSubmitTips()
                self.m_root:add(self.m_submitTips)
                self.m_root:add(bg)
            end
            self.m_submitTips.showTips()
            Log.v("=====self.m_submitUrl:"..self.m_submitUrl)

            GKefuNetWorkControl.postString(self.m_submitUrl or URL.HTTP_SUBMIT_APPEAL_URI, content, function (rsp)
                if rsp.errmsg or rsp.code ~= 200 then
                    self.m_submitTips.hideTips("提交失败")
                else
                    Log.v("postString:", "submit report result", rsp.content)
                    local result = cjson.decode(rsp.content)
                    if result and result.code == 0 then
                        self:requireData(true, function ()
                            Clock.instance():schedule_once(function ()                       
                                self.m_submitTips.hideTips("提交成功!", 1)
                                self:onUpdate(true)
                                self.m_pageView.page_num = 2
                            end, 1)

                            self:resetReportInfo()

                        end)
                    else
                        self.m_submitTips.hideTips("提交失败")
                    end

                end

            end)

        end

        return container
    end,

    -- 需要重载该函数
    onUpdate = function(self, arg1)
        local data = UserData.getStatusData()
        if data.isVip then
            self.m_txtColor = "#f4c493"
        else
            self.m_txtColor = "#6fba2c"
        end

        self.m_submitUrl = URL.HTTP_SUBMIT_APPEAL_URI
        
        self.m_pageView.page_num = 1
        local data = UserData.getStatusData()
        self:setNormalItem()
        if self.m_pageSub2 then
            self.m_pageSub2.visible = false
        end
        if self.m_pageSub3 then
            self.m_pageSub3.visible = false
        end
        self.m_pageSub1.visible = true



        Clock.instance():schedule_once(function()
            self.m_selComp:hide()
        end)
        self.m_buttomContainer.y = self.m_buttomContainerY
        self.m_pageView.y = self.m_pageViewY
        self.m_firstStatus = {}

        self.m_editId.text = string.format('<font color=#000000 size=30>%s</font>', self.m_MId)
        if self.m_MId ~= "" then
            self.m_firstStatus[1] = true
        end
        
        if self.m_loseTimeTxt == "" then
            self.m_typeLabel:set_rich_text(string.format('<font color=#9b9b9b size=30>%s</font>', ConstString.lose_account_time_hint))
        else
            self.m_typeLabel:set_rich_text(string.format('<font color=#000000 size=30>%s</font>', self.m_loseTimeTxt))
            self.m_firstStatus[2] = true
        end

        self.m_editLostMoney.text = string.format('<font color=#000000 size=30>%s</font>', self.m_lostMoney)
        if self.m_lostMoney ~= "" then
            self.m_firstStatus[3] = true
        end

        self:setFirstNextBtnStatus()

        local appealData = UserData.getPlayerReportViewData() or {}
        appealData.hasNewReport = appealData.hasNewReport or 0                 
        newReplyTxt:set_rich_text(string.format("<font color=#ffffff bg=#00000000 size=24 weight=1>%d</font>", appealData.hasNewReport))
        if appealData.hasNewReport <= 0 then
            newReplyBg.visible = false
        else
            newReplyBg.visible = true
        end

        if not arg1 then
            self:requireData()
        end

    end,

    requireData = function (self, isRequire, callback)
        if not isRequire then
            local appealData = UserData.getPlayerReportViewData() or {}
            if appealData.historyData then
                self.m_noRecordLabel.visible = false
                
                if self.m_replyData then
                    if #self.m_replyData == #appealData.historyData then
                        for i, v in ipairs(self.m_replyData) do
                            if v.reply ~= appealData.historyData[i].reply then
                                --self.m_listview:update_item(i, v)
                                self.m_listview.data = appealData.historyData
                                break 
                            end
                        end
                    else
                        self.m_listview.data = appealData.historyData                        
                    end
                else
                    self.m_listview.data = appealData.historyData
                end
                self.m_replyData = appealData.historyData
            else
                self.m_noRecordLabel.visible = #self.m_listview.data == 0
                self.m_replyData = nil
            end
            return 
        end

        GKefuNetWorkControl.obtainUserTabHistroy(0, 50, URL.HTTP_SUBMIT_APPEAL_HISTORY_URI, function (content)
            local tb = cjson.decode(content)
            if tb.code == 0 and tb.data then
                self.m_replyData = {}
                for i, v in ipairs(tb.data) do
                    local data = {}
                    data.id = v.id
                    data.reply = (v.reply == "" and string.format(ConstString.replay_default,mqtt_client_info.hotline) or v.reply)
                    data.time = v.clock
                    data.hasNewReport = GKefuOnlyOneConstant.HasNewReport.no
                    data.errInfo = v.err_info       --新增了错误信息
                    data.mid = v.lost_mid
                    data.lostTimeStr = v.lost_time
                    data.lostChip = v.lost_chip
                    data.ip = v.ip
                    data.lastChip = v.last_chip
                    data.firstLoginTime = v.first_login_time
                    data.lastLoginTime = v.last_login_time
                    data.bank = v.bank
                    table.insert(self.m_replyData, data)
                end
                
                           
                self.m_noRecordLabel.visible = false
                self.m_listview.data = self.m_replyData
                --self.m_listview:insert(data, 1)

                if callback then
                    callback() 
                end

            else
                Log.w("obtainAppealReport", "盗号内容获取失败")
            end
        end)
    end,

    resetReportInfo = function (self)
        self.m_MId = ""
        self.m_loseTimeTxt = ""
        self.m_lostMoney = ""
        self.m_joinTimeTxt = ""
        self.m_lastTimeTxt = ""
        self.m_ipTxt = ""
        self.m_lastMoney = ""
        self.m_safeBoxMoney = ""
    end,

    setFirstNextBtnStatus = function (self)
        if self.m_firstStatus[1] and self.m_firstStatus[2] and self.m_firstStatus[3] then
            if not self.m_firstNextBtn.enabled then
                self.m_firstNextBtn.enabled = true
                self.m_firstNextBtn.state = "normal"
            end
        elseif self.m_firstNextBtn.enabled then
            self.m_firstNextBtn.enabled = false
            self.m_firstNextBtn.state = "disabled"
        end
    end,

    setSecondNextBtnStatus = function (self)
        if self.m_secondStatus[1] and self.m_secondStatus[2] and self.m_secondStatus[3] and
            self.m_secondStatus[4] and self.m_secondStatus[5] then
            if not self.m_secondNextBtn.enabled then
                self.m_secondNextBtn.enabled = true
                self.m_secondNextBtn.state = "normal"
            end
        elseif self.m_secondNextBtn.enabled then
            self.m_secondNextBtn.enabled = false
            self.m_secondNextBtn.state = "disabled" 
        end
    end,

    onBackEvent = function (self)
        if self.m_submitTips and self.m_submitTips.visible then
            return
        end
        
        local data = UserData.getStatusData() or {}
        if data.isVip then
            GKefuViewManager.showVipChatView(GKefuOnlyOneConstant.LTOR)
        else
            GKefuViewManager.showNormalChatView(GKefuOnlyOneConstant.LTOR)
        end
        if self.m_onBackMustReset then
            self:resetReportInfo()
        end
        self.m_onBackMustReset = nil
    end,

    setNormalItem = function (self)
        local data = UserData.getStatusData()
        if not data.isVip then
            self.m_topContainer.background_color = Colorf(0.0, 0.0, 0.0,1.0)
            self.m_txtTitle:set_rich_text(string.format("<font color=#ffffff bg=#00000000 size=34 weight=3>%s</font>", ConstString.lose_account_appeal))
            self.m_arrowIcon.unit = TextureUnit(TextureCache.instance():get(KefuResMap.chatBack))
            self.m_btnBack.text = string.format("<font color=#ffffff bg=#00000000 size=28>%s</font>", ConstString.back_txt)
            sliderBlock.background_color = Colorf(111/255, 188/255, 44/255, 1)
        else
            self.m_topContainer.background_color = Colorf(0.227, 0.188, 0.31, 1.0)
            self.m_txtTitle:set_rich_text(string.format("<font color=#F4C392 bg=#00000000 size=34 weight=3>%s</font>", ConstString.lose_account_appeal))
            self.m_arrowIcon.unit = TextureUnit(TextureCache.instance():get(KefuResMap.chatBackVip))
            self.m_btnBack.text = string.format("<font color=#F4C392 bg=#00000000 size=28>%s</font>", ConstString.back_txt)
            sliderBlock.background_color = Colorf(0.9568, 0.7647, 0.572, 1)

        end
    end,

    onDelete = function (self)
        newReplyBg = nil
        newReplyTxt = nil
        newTags = {}
        super(playerReportView, self).onDelete(self)
    end,
} )


return playerReportView