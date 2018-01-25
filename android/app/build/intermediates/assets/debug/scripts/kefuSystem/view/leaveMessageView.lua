local UI = require('byui/basic')
local AL = require('byui/autolayout')
local Layout = require('byui/layout')
local class, mixin, super = unpack(require('byui/class'))
local Anim = require('animation')
local baseView = require('kefuSystem/view/baseView')
local UserData = require('kefuSystem/conversation/sessionData')
local kefuCommon = require('kefuSystem/kefuCommon')
local SelComponent = require('kefuSystem/view/selComponent')
local EPage = require('kefuSystem/view/evaluatePage')
local ReplyPage = require('kefuSystem/view/addReplyPage')
local ConstString = require('kefuSystem/common/kefuStringRes')
local KefuResMap = require('kefuSystem/qn_res_alias_map')
local Log = require('kefuSystem/common/log')
local KefuEmoji = require('kefuSystem/common/kefuEmojiCfg')
local URL = require("kefuSystem/mqttModule/mqttConstants")
local platform = require("kefuSystem/platform/platform")
local GKefuOnlyOneConstant = require('kefuSystem/common/kefuConstant')
local GKefuNetWorkControl = require('kefuSystem/conversation/netWorkControl')
local GKefuViewManager = require('kefuSystem/viewManager')

local inspect = require("byui.inspect")


local leaveMessageView
local page_view
local sliderBlock
local newReplyBg
local newReplyTxt
local newTags = {}


local function getReplysValidCount( data )
    if not data or type(data)~= "table" then
        return 0
    end
    local count = 0;
    for i,v in ipairs(data) do
        if i > 1 then
            if v.from_client ~= data[i-1].from_client then
                count = count + 1
            end
        elseif i == 1 then
            count = count + 1
        end
    end
    return count 
end

local function utfstrlen(str)
    local len = #str;
    local left = len;
    local cnt = 0;
    local arr={0,0xc0,0xe0,0xf0,0xf8,0xfc};
    while left ~= 0 do
        local tmp=string.byte(str,-left);
        local i=#arr;
        while arr[i] do
            if tmp>=arr[i] then left=left-i;break;end
            i=i-1;
        end
        cnt=cnt+1;
    end
    local ret = {}
    for uchar in string.gfind(str, "([%z\1-\127\194-\244][\128-\191]*)") do 
        table.insert(ret,uchar)
    end
    return ret;
end

local function uploadInfo( self )
    local tb = {}
    tb.gid = mqtt_client_config.gameId
    tb.site_id = mqtt_client_config.siteId
    tb.client_id = mqtt_client_config.stationId
    tb.content = self.m_editContent.text
    tb.phone = self.m_editPhone.text
    tb.mail = self.m_selectTxt
    tb.client_info = GKefuNetWorkControl.generateClientInfo("")
    tb.pic = cjson.encode(self.m_imgUrl or {})

    GKefuNetWorkControl.postString(URL.HTTP_SUBMIT_ADVISE_URI, cjson.encode(tb), function (rsp)
        if rsp.errmsg or rsp.code ~= 200 then
            self.m_submitTips.hideTips(ConstString.commit_fail_txt)
        else
            Log.v("=============留言内容发送结果:"..rsp.content)
            local result = cjson.decode(rsp.content)
            if result and result.code == 0 then                   
                self:requireData(true, function ()
                    Clock.instance():schedule_once(function ()                       
                        self.m_submitTips.hideTips(ConstString.commit_success_txt, 1)
                        self:onUpdate(nil, true)
                        self.m_pageView.page_num = 2
                    end, 1)
                end)

                self:resetLeaveInfo()
            else
                self.m_submitTips.hideTips(ConstString.commit_fail_txt)
            end
        end
    end)
end


leaveMessageView = class('leaveMessageView', baseView, {
    __init__ = function(self)
        super(leaveMessageView, self).__init__(self)
        self.m_status = {}
        self.m_solveItems = {}

        local data = UserData.getStatusData()
        if data.isVip then
            self.m_txtColor = "#f4c493"
        else
            self.m_txtColor = "#6fba2c"
        end

        self.m_root.background_color = Colorf(235/255,235/255,235/255,1)
        self.m_topHeight = 100
        -- ==============================================top=========================================================
        local topContainer = Widget()
        topContainer.background_color = Colorf(0.227, 0.188, 0.31, 1.0)
        topContainer:add_rules{
            AL.width:eq(AL.parent('width')),
            AL.height:eq(self.m_topHeight),
        }
        
        self.m_topContainer = topContainer

        local txtTitle = Label()
        txtTitle:set_rich_text(string.format("<font color=#F4C392 bg=#00000000 size=34 weight=3>%s</font>", ConstString.leave_msg_reply_title))
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

        -- 创建必填图标
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
        tabBg:add(sliderBlock)


    
        local btnLeaveMessage = UI.Button {
            text = string.format('<font color=#f4c493 size=30>%s</font>', ConstString.i_want_to_reply_txt),
            margin = { 10, 10, 10, 10 },
            image =
            {
                normal = Colorf(1.0,1.0,1.0,0.0),
                down = color_to_colorf(Color(173,225,245,140)),
                disabled = Colorf(0.2,0.2,0.2,1),
            },

        }

        btnLeaveMessage:add_rules{
            AL.width:eq(AL.parent('width') / 2),
            AL.height:eq(AL.parent('height')-10),
            AL.left:eq(0),
            AL.top:eq(10),
        }
        buttomContainer:add(btnLeaveMessage)

        local btnReplyMessage = UI.Button {
            text = string.format('<font color=#9b9b9b size=30>%s</font>', ConstString.leave_msg_reply_title),
            margin = { 10, 10, 10, 10 },
            image =
            {
                normal = Colorf(1.0,1.0,1.0,0.0),
                down = color_to_colorf(Color(173,225,245,140)),
                disabled = Colorf(0.2,0.2,0.2,1),
            },
      
        }
        btnReplyMessage:add_rules{
            AL.width:eq(AL.parent('width') / 2),
            AL.height:eq(AL.parent('height')-10),
            AL.top:eq(10),
            AL.right:eq(AL.parent('width')),
        }
        buttomContainer:add(btnReplyMessage)

    
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
        self.m_newReplyTxt:set_rich_text(string.format("<font color=#ffffff bg=#00000000 size=24 weight=1>1</font>"))
        self.m_newReplyTxt.absolute_align = ALIGN.CENTER
        self.m_newReplyBg:add(self.m_newReplyTxt)
        self.m_newReplyBg.visible = false
        newReplyTxt = self.m_newReplyTxt

        btnLeaveMessage.on_click = function()
            if page_view.page_num == 1 then return end           
            page_view.page_num = 1

        end

        btnReplyMessage.on_click = function()
            if page_view.page_num == 2 then return end
            page_view.page_num = 2
           
        end

        

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


        page_view.create_cell = function(pageView, i)
            local page = self:initPage(i)
            return page
        end
        page_view.focus = true
        page_view:update_data()
        self.m_pageView = page_view

        self.m_hideCallBack = function ()
            self.m_pageView.page_num = 1
        end

        self.m_pageView.on_page_change = function ()
            if not self.m_root.running then return end
            if not sliderBlock then return end
            if self.m_pageView.page_num == 1 then
                if self.m_PageNum and self.m_PageNum == 1 then return end
                self.m_PageNum = 1
                btnLeaveMessage.text = string.format('<font color=%s size=30>%s</font>', self.m_txtColor, ConstString.i_want_to_reply_txt)
                btnReplyMessage.text = string.format('<font color=#9b9b9b size=30>%s</font>', ConstString.leave_msg_reply_title)

            elseif self.m_pageView.page_num == 2 then
                UI.share_keyboard_controller().keyboard_status = false
                if self.m_PageNum and self.m_PageNum == 2 then return end
                self.m_PageNum = 2

                btnLeaveMessage.text = string.format('<font color=#9b9b9b size=30>%s</font>', ConstString.i_want_to_reply_txt)
                btnReplyMessage.text = string.format('<font color=%s size=30>%s</font>', self.m_txtColor, ConstString.leave_msg_reply_title)
                for _,v in pairs(self.m_solveItems) do
                    v.solveBtn1.visible = true
                    v.solveBtn2.visible = true
                    v.solveLabel.visible = true
                    v.notSolveLabel.visible = false
                    v.notSolveBtn.visible = false                
                end
            end
        end
        self.m_pageView.on_scroll = function ( _, p,d,v)
            if sliderBlock then
                sliderBlock.x = -(sliderBlock.width / self.m_pageView.width)*p.x
            end
        end

        self.m_root:add(topContainer)

        --获取文件保存的留言信息
        self.m_phoneNumber = UserData.getLeavePhoneNumber()
        self.m_selectTxt = UserData.getLeaveTypes()
        self.m_content = UserData.getLeaveContent()
        self.m_imgPath = UserData.getLeaveImgPath()
        self.m_imgUrl = {}
        local url = UserData.getLeaveImgUrl()
        if url and url ~= "" then
            table.insert(self.m_imgUrl, url)
        end

    end,

    setNormalItem = function (self)
        local data = UserData.getStatusData()
        if not data.isVip then
            self.m_topContainer.background_color = Colorf(0.0, 0.0, 0.0,1.0)
            self.m_txtTitle:set_rich_text(string.format("<font color=#ffffff bg=#00000000 size=34 weight=3>%s</font>", ConstString.leave_msg_reply_title))
            self.m_arrowIcon.unit = TextureUnit(TextureCache.instance():get(KefuResMap.chatBack))
            self.m_btnBack.text = string.format("<font color=#ffffff bg=#00000000 size=28>%s</font>", ConstString.back_txt)
            sliderBlock.background_color = Colorf(111/255, 188/255, 44/255, 1)
        else
            self.m_topContainer.background_color = Colorf(0.227, 0.188, 0.31, 1.0)
            self.m_txtTitle:set_rich_text(string.format("<font color=#F4C392 bg=#00000000 size=34 weight=3>%s</font>", ConstString.leave_msg_reply_title))
            self.m_arrowIcon.unit = TextureUnit(TextureCache.instance():get(KefuResMap.chatBackVip))
            self.m_btnBack.text = string.format("<font color=#F4C392 bg=#00000000 size=28>%s</font>", ConstString.back_txt)
            sliderBlock.background_color = Colorf(0.9568, 0.7647, 0.572, 1)

        end
    end,

    -- 需要重载该函数
    onUpdate = function(self, arg1, arg2)
        local data = UserData.getStatusData()
        if data.isVip then
            self.m_txtColor = "#f4c493"
        else
            self.m_txtColor = "#6fba2c"
        end
        --标记是否可以提交
        self.m_status = {}

        self:setNormalItem()
        self.m_pageView.page_num = 1
        
        -- self.m_editContent.text = string.format('<font color=#000000 size=30>%s</font>', self.m_content)
        self.m_editContent.text = {
            {
                color = Color(0,0,0);
                size = 30;
                text = self.m_content or ""
            }
        }
        if self.m_content == "" then
            self.m_editContent.hint_text = string.format('<font color=#c3c3c3 size=30>%s</font>', ConstString.leave_msg_content_txt)
        else
            self.m_status[3] = true
        end

        -- self.m_editPhone.text = string.format('<font color=#000000 size=30>%s</font>', self.m_phoneNumber)
        self.m_editPhone.text = {
            {
                color = Color(0,0,0);
                size = 30;
                text = self.m_phoneNumber or ""
            }
        }
        if self.m_phoneNumber == "" then
            self.m_editPhone.hint_text = string.format('<font color=#9b9b9b size=30>%s</font>', ConstString.input_phone_number_txt)
        else
            self.m_status[1] = true
        end

        if self.m_selectTxt == "" then
            self.m_typeLabel:set_rich_text(string.format("<font color=#9b9b9b size=30>%s</font>", ConstString.select_leave_content_txt))
        else
            self.m_status[2] = true
            self.m_typeLabel:set_rich_text(string.format('<font color=#000000 size=30>%s</font>', self.m_selectTxt))
        end

        self.m_selComp:hide()
        

        self.m_buttomContainer.y = self.m_buttomContainerY
        self.m_pageView.y = self.m_pageViewY

        local leaveData = UserData.getLeaveMessageViewData() or {}

        newReplyTxt:set_rich_text(string.format("<font color=#ffffff bg=#00000000 size=22 weight=1>%d</font>", leaveData.hasNewReport))
        if leaveData.hasNewReport <= 0 then
            newReplyBg.visible = false
        else
            newReplyBg.visible = true
        end       
        
        if not arg2 then
            self:requireData()
        end

        self.m_Items[2].visible = false
        self:updateItemPos()
        if self.m_evalutePage then
            self.m_evalutePage:hide()
        end

        local allPath = string.format("%s%s", System.getStorageImagePath(), self.m_imgPath)

        if self.m_imgPath == "" or not os.isexist(allPath) then
            self.m_pictureTips.visible = true
            if self.m_uploadImg then
                self.m_uploadImg:remove_from_parent()
                self.m_uploadImg = nil
            end
        else
            self.m_pictureTips.visible = false
            self.m_status[4] = true
            if not self.m_uploadImg then
                self:createUpLoadImg() 
            end
        end

        self:resetCommitBtnState()
    end,

    requireData = function (self, isRequire, callback)
        --不需要向服务器拉数据
        if not isRequire then
            local leaveData = UserData.getLeaveMessageViewData() or {}
            if leaveData.historyData then
                self.m_noRecordLabel.visible = false
                if self.m_replyData then
                    if #self.m_replyData == #leaveData.historyData then
                        for i, v in ipairs(self.m_replyData) do
                            if v.reply ~= leaveData.historyData[i].reply then
                                self.m_listViewReply.data = leaveData.historyData
                                break
                            end
                        end
                    else
                        self.m_listViewReply.data = leaveData.historyData
                    end
                else
                    --第一次数据更新
                    self.m_listViewReply.data = leaveData.historyData
                end

                self.m_replyData = leaveData.historyData
            else
                --没有留言
                self.m_noRecordLabel.visible = #self.m_listViewReply.data == 0
                self.m_replyData = nil
            end

            return 
        end

        GKefuNetWorkControl.obtainUserTabHistroy(0, 50, URL.HTTP_SUBMIT_ADVISE_HISTORY_URI, function (content)

            local tb = cjson.decode(content)

            --0表示成功
            if tb.code == 0 then
                --没有留言历史记录
                if not tb.data then return end


                table.sort(tb.data, function (v1,v2)
                    if v1.id > v2.id then
                        return true
                    end
                    return false
                end)

                self.m_replyData = self.m_replyData or {}
                for i, v in ipairs(tb.data) do
                    local data = {}
                    data.title = v.content
                    data.time = v.clock
                    data.id = v.id
                    data.mail = v.mail
                    data.phone = v.phone
                    data.hasNewReport = GKefuOnlyOneConstant.HasNewReport.no
                    data.reply = string.format(ConstString.replay_default,mqtt_client_info.hotline)
                    data.isResolved = true
                    
                    table.insert(self.m_replyData, 1, data)
                    break

                end
                self.m_noRecordLabel.visible = false               
                self.m_listViewReply.data = self.m_replyData

                if callback then
                    callback()                   
                end
                
            else            --获取失败
                Log.w("obtainUserTabHistroy", "留言内容获取失败")
            end

        end)
    end,

    initPage = function(self, i)
        if i == 1 then
            local content = self:addFirstPage()
            return content
        elseif i == 2 then

            local container = Widget()
            container:add_rules{
                AL.width:eq(AL.parent('width')),
                AL.height:eq(AL.parent('height')),              
            }

            local listviewReply = UI.ListView {

                create_cell = function(data)
                    local container = self:createReplyItem(data)
                    return container
                end,
            }
            listviewReply.shows_vertical_scroll_indicator = true
            listviewReply:add_rules{
                AL.width:eq(AL.parent('width')),
                AL.height:eq(AL.parent('height')),
                AL.left:eq(1),
            }
            container:add(listviewReply)
            listviewReply.velocity_factor = 3.1


            self.m_listViewReply = listviewReply

            self.m_noRecordLabel = Label()
            self.m_noRecordLabel:set_rich_text(string.format("<font color=#9b9b9b bg=#00000000 size=44 weight=3>%s</font>", ConstString.no_anyrecord_tips))
            container:add(self.m_noRecordLabel)
            self.m_noRecordLabel.absolute_align = ALIGN.CENTER
            self.m_listViewReply.background_color = Colorf(244/255, 244/255, 244/255, 1)

            return container
        end

    end,


    createReplyItem = function(self, data)
        self.m_solveItems[data.id] = nil
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
            AL.height:eq(89),
            AL.centerx:eq(AL.parent('width') * 0.5),
            AL.top:eq(1),
        } 
        container:add(btnItem)

        local txtTitle = Label()
        local titleStr = data.title
        if string.len(data.title) > 15 then
            titleStr =  string.format("%s...",kefuCommon.subUTF8String(data.title, 15))
        end


        -- txtTitle:set_rich_text(string.format('<font color=#000000 size=%d>%s</font>', 30, titleStr))
        txtTitle:set_data{
            {
                color = Color(0,0,0);
                size = 30;
                text = titleStr;
            }
        }
        txtTitle:add_rules{
            AL.left:eq(30),
            AL.top:eq(30),
        }
        btnItem:add(txtTitle)

        local txtTime = Label()
        local timeStr = os.date("%Y-%m-%d %H:%M", data.time)
        txtTime:set_rich_text(string.format('<font color=#9b9b9b size=%d>%s</font>', 30, timeStr))
        btnItem:add(txtTime)
        txtTime:update()

        txtTime:add_rules{
            AL.left:eq(AL.parent('width') - txtTime.width - 70),
            AL.top:eq(30),
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
            AL.left:eq(AL.parent('width') - 30),
            AL.centery:eq(AL.parent('height') * 0.5),
        }
        arrowIcon1.visible = false
        btnItem:add(arrowIcon1)

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

        local topLine = Widget() 
        topLine:add_rules{
            AL.width:eq(AL.parent('width')),
            AL.height:eq(kefuCommon.getLineRealHeight(1)),
            AL.bottom:eq(AL.parent('height')),
        } 
        topLine.background_color = Colorf(0.0, 0.0, 0.0, 1)
        btnItem:add(topLine)

        local lines = {}
        for i = 1, 4 do
            lines[i] = Widget()
            --lines[i].v_border = {0,4,0,4}
            --lines[i].t_border = {0,4,0,4}
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
        -- txtNo:set_rich_text(string.format('<font color=#9b9b9b size=30>%s</font>', ConstString.number_txt))
        txtNo:set_data{
            {
               color = Color(0x9b,0x9b,0x9b);
               size = 30;
               text =  ConstString.number_txt
            }
        }
        txtNo:add_rules{
            AL.left:eq(30),
            AL.top:eq(posY),
        }
        contentCon:add(txtNo)

        local labelNo = Label()
        -- labelNo:set_rich_text(string.format('<font color=#000000 size=30>%s</font>', data.id))
        labelNo:set_data{
            {
                color = Color(0,0,0);
                size = 30;
                text = data.id;
            }
        }
        labelNo:add_rules{
            AL.left:eq(115),
            AL.top:eq(posY),
        }
        contentCon:add(labelNo)

        lines[1].y = posY + space + 30
    -------类型
        local txtMail = Label()
        txtMail:set_rich_text(string.format('<font color=#9b9b9b size=30>%s:</font>', ConstString.types_tips))
        txtMail:add_rules{
            AL.left:eq(280),
            AL.top:eq(posY),
        }
        contentCon:add(txtMail)

        local labelMail = Label()
        labelMail:set_rich_text(string.format('<font color=#000000 size=30>%s</font>', data.mail))
        labelMail:set_data{
            {
                color = Color(0,0,0);
                size = 30;
                text = data.mail;
            }
        }
        labelMail:add_rules{
            AL.left:eq(363),
            AL.top:eq(posY),
        }
        contentCon:add(labelMail)


    ------------手机号码
        posY = posY + space*2 + 30          --30为文字高
        local txtPhone = Label()
        txtPhone:set_rich_text(string.format('<font color=#9b9b9b size=30>%s:</font>', ConstString.phone_number_txt))
        txtPhone:add_rules{
            AL.left:eq(30),
            AL.top:eq(posY),
        }
        contentCon:add(txtPhone)

        local labelPhone = Label()

        -- labelPhone:set_rich_text(string.format('<font color=#000000 size=30>%s</font>', data.phone))
        
        labelPhone:set_data{
            {
                color = Color(0,0,0);
                size = 30;
                text = data.phone;
            }
        }

        local MAX_WIDTH = Window.instance().drawing_root.width - 180 - 40
        if labelPhone.width > MAX_WIDTH then
            local cursor,_ = labelPhone:get_cursor_by_position(Point(MAX_WIDTH - 20,0)) 

            local ret = utfstrlen(data.phone)
            local MAX_LASTCHAR_LENGTH = cursor
            if #ret > MAX_LASTCHAR_LENGTH then
                ret[MAX_LASTCHAR_LENGTH  +1] = "..."
                local str = table.concat( ret, "", 1, MAX_LASTCHAR_LENGTH +1)
                -- labelPhone:set_rich_text(string.format('<font color=#000000 size=30>%s</font>', str))
                labelPhone:set_data{
                    {
                        color = Color(0,0,0);
                        size = 30;
                        text = str;
                    }
                }
            else
                -- labelPhone:set_rich_text(string.format('<font color=#000000 size=30>%s</font>', data.phone))
                labelPhone:set_data{
                    {
                        color = Color(0,0,0);
                        size = 30;
                        text = data.phone;
                    }
                }
            end
        end

        labelPhone:add_rules{
            AL.left:eq(180),
            AL.top:eq(posY),
        } 
        contentCon:add(labelPhone)

        lines[2].y = posY + space + 30


    --------------内容
        posY = posY + space*2 + 30          --30为文字高
        local txtContent = Label()
        txtContent:set_rich_text(string.format('<font color=#9b9b9b size=30>%s:</font>', ConstString.content_tags_txt))
        txtContent:add_rules{
            AL.left:eq(30),
            AL.top:eq(posY),
        }
        contentCon:add(txtContent)

        
        local labelContent = Label()
        labelContent:add_rules{
            AL.left:eq(115),
            AL.top:eq(posY),
        }
        contentCon:add(labelContent)

        labelContent.layout_size = Point(GKefuOnlyOneConstant.SCREENWIDTH - 250, 0)
        -- labelContent:set_rich_text(string.format('<font color=#000000 size=30>%s</font>', data.title))
        labelContent:set_data{
                    {
                        color = Color(0,0,0);
                        size = 30;
                        text = data.title;
                    }
                }
        labelContent:update()

        lines[3].y = posY + space + labelContent.height

    ----------客服回复
        posY = posY + space*2 + labelContent.height
        local createFunc = function (head, content, itemPosY)
            local headReply = Label()
            -- headReply:set_rich_text(string.format('<font color=#9b9b9b size=30>%s</font>', head))
            headReply:set_data{
                    {
                        color = Color(0x9b,0x9b,0x9b);
                        size = 30;
                        text = head;
                    }
                }
            headReply:add_rules{
                AL.left:eq(30),
                AL.top:eq(itemPosY or posY),
            }
            contentCon:add(headReply)

            local contentReply = Label()
            contentReply:add_rules{
                AL.left:eq(180),
                AL.top:eq(itemPosY or posY),
            }
            contentReply.layout_size = Point(GKefuOnlyOneConstant.SCREENWIDTH - 250, 0)
            contentCon:add(contentReply)
            --转换表情
            local cts = string.gsub(content, "%[(.-)%]", function (char)
                if KefuEmoji.NameToId[char] then
                    return kefuCommon.unicodeToChar(KefuEmoji.NameToId[char])
                else
                    return string.format("[%s]", char)
                end
            end)

            -- contentReply:set_rich_text(string.format('<font color=#000000 size=30>%s</font>', cts))
            contentReply:set_data{
                    {
                        color = Color(0x00,0x00,0x00);
                        size = 30;
                        text = cts;
                    }
                }
            contentReply:update()
            if not itemPosY then
                posY = posY + contentReply.height+space
            end

            return contentReply
        end

        
        if data.reply == string.format(ConstString.replay_default,mqtt_client_info.hotline) then
            local txtReply = Label()
            txtReply:set_rich_text(string.format('<font color=#9b9b9b size=30>%s</font>', ConstString.servicer_reply_tips))
            txtReply:add_rules{
                AL.left:eq(30),
                AL.top:eq(posY),
            }
            contentCon:add(txtReply)

            
            local labelReply = Label()
            labelReply:add_rules{
                AL.left:eq(180),
                AL.top:eq(posY),
            }
            labelReply.layout_size = Point(GKefuOnlyOneConstant.SCREENWIDTH - 250, 0)
            contentCon:add(labelReply)
            -- labelReply:set_rich_text(string.format('<font color=#000000 size=30>%s</font>', data.reply))
            labelReply:set_data{
                    {
                        color = Color(0x00,0x00,0x00);
                        size = 30;
                        text = data.reply;
                    }
                }
            labelReply:update()

            posY = posY + labelReply.height+space
            
        else
            --多项回复
            for i, v in ipairs(data.replies) do
                --用户回复的留言
                if v.from_client == 1 and i > 1 then
                    local headTips = {ConstString.servicer_reply_tips, ConstString.user_reply_tips}
                    local contentTips = {data.replies[i-1].reply, data.replies[i].reply}
                    for n = 1, 2 do
                        createFunc(headTips[n], contentTips[n])
                    end

                end

            end
            --最后一条消息是客服发过来的，需要显示
            if data.replies[#data.replies].from_client == 0 then
                createFunc(ConstString.servicer_reply_tips, data.replies[#data.replies].reply)
            end

        end

        lines[4].y = posY

        
    -----问题是否解决
        local solveWg = Widget()
        solveWg:add_rules{
            AL.width:eq(AL.parent('width')),
            AL.height:eq(space*5),
            AL.top:eq(posY),
            AL.left:eq(0),
        }
        contentCon:add(solveWg)

        solveWg.visible = false
        
        local solveIsVisible = true
        --如果问题已经解决或者replies为空
        if data.isResolved or not data.replies then
            solveIsVisible = nil
        end
        --最后一条消息是用户的，就不需要显示solveWg
        if data.replies and data.replies[#data.replies].from_client == 1 then
            solveIsVisible = nil
        end

        --最后一条消息是用户的，就不需要显示solveWg
        if data.replies and getReplysValidCount(data.replies) > GKefuOnlyOneConstant.MAX_REPLYS_VALID_COUNT then
            solveIsVisible = nil
        end

        if data.reply == string.format(ConstString.replay_default,mqtt_client_info.hotline) then
            solveIsVisible = nil
        end

        if solveIsVisible then
            solveWg.visible = true
            local sline = Widget()
            sline:add_rules{
                AL.width:eq(AL.parent('width')),
                AL.height:eq(kefuCommon.getLineRealHeight(1)),
                AL.bottom:eq(AL.parent('height')),
            }
            sline.background_color = Colorf(0.1, 0.1, 0.1, 1.0)    
            solveWg:add(sline)


            local solveLabel = Label()
            solveLabel:add_rules{
                AL.height:eq(30),
                AL.left:eq(30),
                AL.top:eq(space),
            }
            solveWg:add(solveLabel)
            solveLabel:set_rich_text(string.format('<font color=#000000 size=31>%s</font>', ConstString.ask_solve_tips))

            local solveIcons = {}
            solveIcons[1] = Sprite(TextureUnit(TextureCache.instance():get(KefuResMap.chat_kefu_satisfacted_heart)))
            solveIcons[2] = Sprite(TextureUnit(TextureCache.instance():get(KefuResMap.chat_kefu_notsatisfacted_heart)))

            local solveBtns = {}
            local solveLbs = {}
            local solveTxt = {
                [1] = ConstString.solve_str,
                [2] = ConstString.unsolve_str,
            }

            for i=1, 2 do
                solveLbs[i] = Label()
                solveLbs[i].absolute_align = ALIGN.CENTER
                solveLbs[i]:set_rich_text(string.format("<font color=#329bdd bg=#00000000 size=29>%s</font>", solveTxt[i]))
                solveLbs[i]:set_underline(Color(50,155,221))
                solveLbs[i]:update()



                solveBtns[i] = UI.Button{
                    image =
                    {
                        normal = Colorf(1.0,0.0,0.0,0.0),
                        down = Colorf(0.81,0.81,0.81,0.0),
                    },
                    border = false,
                    text = "",

                }
                solveWg:add(solveBtns[i])
                solveBtns[i]:add(solveLbs[i])
                solveBtns[i]:add(solveIcons[i])

                local w = solveLbs[i].width+15
                local h = solveLbs[i].height+15
                local iconW, iconH = 30*1.2, 24*1.2

                solveBtns[i]:add_rules{
                    AL.width:eq(w),
                    AL.height:eq(h),
                    AL.top:eq(space+48),
                    AL.left:eq(35 + (i-1)*(w+100) + i*iconW ),
                }

                solveIcons[i]:add_rules{
                    AL.width:eq(iconW),
                    AL.height:eq(iconH),
                    AL.top:eq((h-iconH)/2),
                    AL.left:eq(-iconW),
                }
            end

            local notSolveLabel = Label()
            notSolveLabel:add_rules{
                AL.top:eq(30),
                AL.left:eq(30),
            }

            notSolveLabel:set_rich_text(string.format("<font color=#000000 size=30>%s</font>", ConstString.no_solve_tips))
            solveWg:add(notSolveLabel)
            notSolveLabel.visible = false

            --追加回复
            local notSolveBtn = UI.Button{
                image =
                {
                    normal = Colorf(1.0,0.0,0.0,0.0),
                    down = Colorf(0.81,0.81,0.81,0.2),
                },
                border = false,
                align = ALIGN.LEFT,
                text = string.format("<font color=#329bdd bg=#00000000 size=30>%s</font>", ConstString.again_reply_tips),
            }
            notSolveBtn:add_rules{
                AL.width:eq(170),
                AL.height:eq(50),
                AL.top:eq(75),
                AL.left:eq(30),
            }
            solveWg:add(notSolveBtn)
            notSolveBtn.visible = false
            notSolveBtn.label:set_underline(Color(50,155,221))

            
            solveBtns[1].on_click = function ()
            
                if not self.m_evalutePage then
                    self.m_evalutePage = EPage(self.m_root)
                    self.m_evalutePage:initLeaveItem()
                end

                --留言回复评分提交
                self.m_evalutePage:updateLeaveItem(function (grade)
                    if not data.replies then return end

                    local tb = {}
                    
                    local adviseId = data.replies[#data.replies].advise_id
                    local replyId = data.replies[#data.replies].reply_id

                    tb.reply_id = replyId
                    tb.advise_id = adviseId
                    tb.is_resolved = 1
                    tb.rating = grade

                    local jsonStr = cjson.encode(tb)
                    local url = string.format("%s/%d/%d", URL.HTTP_SUBMIT_COMMENT_RATING_URI, adviseId, replyId)
                   
                    GKefuNetWorkControl.putString(url, jsonStr, function (content)
                        local contentTb = cjson.decode(content)
                        if contentTb.code == 0 then
                            Log.v("putString","success", content);
                            solveWg.visible = false
                            contentCon.height_hint = contentCon.height_hint - space*5
                            container.height_hint = contentCon.height_hint + 90
                            contentCon:update_constraints()
                            container:update_constraints()
                        end
                    end)

                end)
                self.m_evalutePage:show()
            end
            self.m_solveItems[data.id] = {}
            self.m_solveItems[data.id].solveBtn1 = solveBtns[1]
            self.m_solveItems[data.id].solveBtn2 = solveBtns[2]
            self.m_solveItems[data.id].solveLabel = solveLabel
            self.m_solveItems[data.id].notSolveLabel = notSolveLabel
            self.m_solveItems[data.id].notSolveBtn = notSolveBtn

            solveBtns[2].on_click = function ()
                solveBtns[1].visible = false
                solveBtns[2].visible = false
                solveLabel.visible = false
                notSolveLabel.visible = true
                notSolveBtn.visible = true
            end

            notSolveBtn.on_click = function ()
                if not self.m_addReplyPage then
                    self.m_addReplyPage = ReplyPage(self.m_root)
                end
                self.m_addReplyPage:show(function (replyContent)
                    local replyId = data.replies[#data.replies].reply_id
                    local url = URL.HTTP_SUBMIT_ADDITION_COMMENT__URI.."/"..replyId
                    local adviseId = data.replies[#data.replies].advise_id

                    local tb = {}
                    tb.reply = replyContent
                    tb.advise_id = adviseId
                    tb.from_client = 1
                    local jsonStr = cjson.encode(tb)

                    GKefuNetWorkControl.postString(url, jsonStr, function (rsp)
                        if rsp.errmsg or rsp.code ~= 200 then
                            Log.w("postString:", "addReply fail!")
                        else
                            local result = cjson.decode(rsp.content)
                            --追加留言成功，需要改变界面
                            if result and result.code == 0 then
                                Log.v("postString:", "addReply success!")
                                local contentWg = createFunc(ConstString.user_reply_tips, replyContent, lines[4].y)
                                lines[4].y = lines[4].y + space + contentWg.height
                                solveWg.visible = false
                                contentCon.height_hint = lines[4].y
                                container.height_hint = contentCon.height_hint + 90
                                contentCon:update_constraints()
                                container:update_constraints()
                            else
                                Log.w("postString:", "addReply fail!")
                            end

                        end
                    end)

                end)
            end
        end

        if solveWg.visible then
            contentCon.height_hint = posY + space*5
        else
            contentCon.height_hint = posY
        end

        

        btnItem.on_click = function()
            arrowIcon.visible = contentCon.visible
            arrowIcon1.visible = not contentCon.visible
            contentCon.visible = not contentCon.visible

            if contentCon.visible then
                container.height_hint = contentCon.height_hint + 90
                newTags[data.id].visible = false
                if data.hasNewReport == GKefuOnlyOneConstant.HasNewReport.yes then

                    local leaveData = UserData.getLeaveMessageViewData() or {}
                    local dictData = leaveData.dictData or {}
                    dictData[data.id].hasNewReport = GKefuOnlyOneConstant.HasNewReport.no
                    leaveData.hasNewReport = leaveData.hasNewReport - 1
                    UserData.updateLeaveMsg(dictData[data.id])
                    UserData.setLeaveMessageViewData(leaveData)

                    newReplyTxt:set_rich_text(string.format("<font color=#ffffff bg=#00000000 size=24 weight=1>%d</font>", leaveData.hasNewReport))
                    if leaveData.hasNewReport <= 0 and newReplyBg then
                        newReplyBg.visible = false
                    end

                end

                data.hasNewReport = GKefuOnlyOneConstant.HasNewReport.no
            else
                container.height_hint = 90
            end
            container:update_constraints()
        end

        return container
    end,

    addFirstPage = function(self)
        local container = Widget()
        container:add_rules{
            AL.width:eq(AL.parent('width')-1),
            AL.height:eq(AL.parent('height')),
        }
        self.m_firstPage = container
        self.m_Items = {}
        local height = 100
        local lineH = 2

        local txtConfig = {
            {title = ConstString.phone_number_txt, color = "#000000"},
            {title = ConstString.input_correct_phone_numer_txt, color = "#ff1010"},
            {title = ConstString.leave_types_txt, color = "#000000"},
        }

        for i=1, 3 do
            self.m_Items[i] = Widget()
            self.m_Items[i]:add_rules{
                AL.width:eq(AL.parent('width')),
                AL.height:eq(height),
            }

            self.m_Items[i].y = height*(i-1)
            container:add(self.m_Items[i])

            local line = Widget()
            line:add_rules{
                AL.width:eq(AL.parent('width')),
                AL.height:eq(kefuCommon.getLineRealHeight(lineH)),
                AL.bottom:eq(AL.parent('height')),
            }

            line.background_color = Colorf(0.77, 0.77, 0.77, 1)
            self.m_Items[i]:add(line)

            local title = Label()
            title.align = Label.CENTER
            title:set_rich_text(string.format('<font color=%s size=30>%s</font>', txtConfig[i].color, txtConfig[i].title))

            title.pos = Point(30 ,(height - title.height) /2)
            self.m_Items[i]:add(title)

            if i ~= 2 then
                local tips = Label()
                tips:set_data{{text = "*",color = Color.red}}
                tips.pos = Point((30 -tips.width)/2 ,(height - tips.height) /2)
                self.m_Items[i]:add(tips)  
            end
            
        end
        self.m_Items[2].background_color = Colorf(233/255, 233/255, 233/255, 1)


        --手机号码
        self.m_editPhone = UI.EditBox {
            background_style = KTextBorderStyleNone,
            icon_style = KTextIconNone,
            text = string.format('<font color=#000000 size=30>%s</font>',""),
            hint_text = string.format('<font color=#9b9b9b size=30>%s</font>', ConstString.input_phone_number_txt),
        
        }
        self.m_editPhone.need_capture = true
        self.m_editPhone:add_rules{
            AL.width:eq(AL.parent('width')-250),
            AL.height:eq(80),
            AL.left:eq(250),
            AL.top:eq(34),
        }

        self.m_editPhone.keyboard_type = Application.KeyboardTypeEmailAddress
        self.m_Items[1]:add(self.m_editPhone)


        --留言类型
        self.m_typeLabel = Label()
        self.m_typeLabel:set_rich_text(string.format("<font color=#9b9b9b size=30>%s</font>", ConstString.select_leave_content_txt))
        self.m_typeLabel:add_rules{
            AL.width:eq(500),
            AL.height:eq(20),
            AL.left:eq(251),
            AL.top:eq(35),
        }

        self.m_Items[3]:add(self.m_typeLabel)

        local typeWg = Widget()
        typeWg:add_rules{
            AL.width:eq(AL.parent('width')-240),
            AL.height:eq(AL.parent('height')),
            AL.left:eq(240),
        }
        typeWg.need_capture = true
        self.m_Items[3]:add(typeWg)


        local moreIcon = Sprite(TextureUnit(TextureCache.instance():get(KefuResMap.commonMore)))
        moreIcon:add_rules{
            AL.right:eq(AL.parent('width') - 20),
            AL.centery:eq(height/2),
        }
        typeWg:add(moreIcon)



        self.m_selComp = SelComponent(self.m_root, {title = ConstString.leave_types_txt, action = ConstString.finish_tag_txt, ui_type = 2 })
        UI.init_simple_event(typeWg, function ()
            UI.share_keyboard_controller().keyboard_status = false
            self.m_selComp:pop_up()
        end)

        self.m_selComp.btn_callback = function(str)
            str = str or ConstString.cannot_login_txt
            self.m_typeLabel:set_rich_text("<font color=#000000 size=30>"..str.."</font>")
            self.m_status[2] = true
            self.m_selectTxt = str
            UserData.saveLeaveTypes(str)
            UserData.saveLeaveMsg()

            self:resetCommitBtnState()

        end


        self.m_editPhone.on_text_changed = function (txt)
            if txt ~= "" then
                self.m_status[1] = true
                self.m_phoneNumber = txt
                UserData.saveLeavePhoneNumber(self.m_phoneNumber)
                UserData.saveLeaveMsg()    
            else
                self.m_status[1] = false        
            end
            self:resetCommitBtnState()
        end

        self.m_editPhone.on_keyboard_show = function ()
            self:updateItemPos()
        end


        self.m_Items[4] = Widget()
        self.m_Items[4]:add_rules{
            AL.width:eq(AL.parent('width')),
            AL.height:eq(220),
        }
        self.m_Items[4].y = height*3
        container:add(self.m_Items[4])

        self.m_contentBtn = UI.Button{
            text = "",
            image =
            {
                normal= Colorf(0.43,0.8,0.17,0.0),
                down= Colorf(0.43,0.73,0.17,0.0),
                disabled = Colorf(0.77,0.77,0.77,0.0),
            },
        }
        self.m_contentBtn:add_rules{
            AL.width:eq(AL.parent('width')),
            AL.height:eq(AL.parent('height')),
        }        
        self.m_contentBtn.visible = false


        local editContent = UI.MultilineEditBox { expect_height = 170 }
        editContent.text = string.format('<font color=#000000 size=30>%s</font>', "")
        editContent.style = KTextBorderStyleNone
        editContent.background_style = KTextBorderStyleNone
        editContent:add_rules{
            AL.width:eq(AL.parent('width') -48),
            AL.height:eq(170),
            AL.left:eq(30),
            AL.top:eq(28),
        }
        editContent.need_capture = true

        editContent.max_height = 170
        editContent.hint_text = string.format('<font color=#c3c3c3 size=30>%s</font>', ConstString.leave_msg_content_txt)
        self.m_Items[4]:add(editContent)
        container:add(self.m_contentBtn)


        local tips = Label()
        tips:set_data{{text = "*",color = Color.red}}
        tips.pos = Point((30 -tips.width)/2 ,(height - tips.height) /2)
        self.m_Items[4]:add(tips) 

        local line1 = Widget()

        line1:add_rules{
            AL.width:eq(AL.parent('width')),
            AL.height:eq(kefuCommon.getLineRealHeight(lineH)),
            AL.bottom:eq(AL.parent('height')),
        }
        line1.background_color = Colorf(0.77, 0.77, 0.77, 1)
        self.m_Items[4]:add(line1)

        self.m_editContent = editContent

        self.m_editContent.on_keyboard_show = function (args)
            self.m_contentBtn.visible = true
            local linePos = self.m_Items[4]:to_world(Point(0, 245))
            local disY = linePos.y - args.y
            if disY > 0 then
                self.m_buttomContainer.y = self.m_buttomContainerY - disY
                self.m_pageView.y = self.m_pageViewY - disY
            end

        end

        self.m_editContent.on_keyboard_hide = function (args)
            self.m_contentBtn.visible = false
        end

        self.m_editContent.on_text_changed = function (txt)
            self.m_buttomContainer.y = self.m_buttomContainerY
            self.m_pageView.y = self.m_pageViewY

            self.m_content = txt
            UserData.saveLeaveContent(self.m_content)
            UserData.saveLeaveMsg()

            if self.m_content == "" then
                self.m_status[3] = false
            else
                self.m_status[3] = true
            end

            self:resetCommitBtnState()
        end

        self.m_Items[5] = Widget()
        self.m_Items[5]:add_rules{
            AL.width:eq(AL.parent('width')),
            AL.height:eq(500),
        }
        self.m_Items[5].y = height*2+220
        container:add(self.m_Items[5])

        local btnUpgrade = UI.Button {
            text = "",
            radius = 0,
            margin = { 10, 10, 10, 10 },
            image =
            {
                normal = TextureUnit(TextureCache.instance():get(KefuResMap.commonUpgradeUp)),
                down = TextureUnit(TextureCache.instance():get(KefuResMap.commonUpgradeDown)),
                disabled = Colorf(0.2,0.2,0.2,1),
            },
        }
        btnUpgrade:add_rules{
            AL.width:eq(150),
            AL.height:eq(150),
            AL.left:eq(30),
            AL.top:eq(32),
        }

        self.m_Items[5]:add(btnUpgrade)
        self.m_btnUpgrade = btnUpgrade

        btnUpgrade.on_click = function()
            -- EventDispatcher.getInstance():unregister(Event.Call, self, self.onNativeEvent);
            -- EventDispatcher.getInstance():register(Event.Call, self, self.onNativeEvent);
            self.m_imgPrePath = Clock.now() .. "_Upgrade_img.jpg";
            local savePath = string.format("%s%s",System.getStorageImagePath(), self.m_imgPrePath);
            -- local tab = {};
            -- tab.savePath = savePath;
            -- local json_data = cjson.encode(tab);
            -- NativeEvent.RequestGallery(json_data);
            platform.getInstance():RequestGallery(savePath,function ( ret )
                Log.v("platform.getInstance():RequestGallery",ret)
                self:onNativeEvent(ret)
            end)
        end

        local labelTip = Label()
        self.m_pictureTips = labelTip
        labelTip.layout_size = Point(GKefuOnlyOneConstant.SCREENWIDTH-250, 0)
        labelTip:set_rich_text(string.format('<font color=#9b9b9b size=30>%s</font>', ConstString.can_upload_spot_img_txt))
        labelTip:add_rules{
            AL.width:eq(450),
            AL.height:eq(20),
            AL.left:eq(200),
            AL.top:eq(60),
        }
        
        self.m_Items[5]:add(labelTip)


        local btnCommit = UI.Button {
            text = string.format("<font color=#FEFEFE bg=#00000000 size=38>%s</font>", ConstString.sumbit_txt),
            radius = 10,
            margin = { 10, 10, 10, 10 },
            image =
            {
                normal= Colorf(0.43,0.8,0.17,1),
                down= Colorf(0.43,0.73,0.17,1.0),
                disabled = Colorf(0.77,0.77,0.77,1),
            },
        }
        self.m_btnCommit = btnCommit
        btnCommit:add_rules{
            AL.width:eq(AL.parent('width') * 0.88),
            AL.height:eq(100),
            AL.centerx:eq(AL.parent('width') * 0.5),
            AL.bottom:eq(AL.parent('height')-20),
        }
        
        container:add(btnCommit)
        btnCommit.on_click = function()
            if not self.m_submitTips then
                self.m_submitTips, bg = kefuCommon.createSubmitTips()
                self.m_root:add(self.m_submitTips)
                self.m_root:add(bg)
            end
            self.m_submitTips.showTips()

            if self._fullPath then
                GKefuNetWorkControl.upLoadFile(self._fullPath,function ( rsp )
                    Log.v("----------------------btnCommit upload img",inspect(rsp))
                    if rsp.errmsg or rsp.code ~= 200 then
                        self.m_submitTips.hideTips(ConstString.commit_fail_txt)
                    else
                        local content = cjson.decode(rsp.content)
                        if content.code == 0 then

                            self.m_imgUrl = {}
                            local imgUrl = URL.FILE_UPLOAD_HOST..content.file
                            table.insert(self.m_imgUrl, imgUrl)
                            -- self.m_submitTips.hideTips(ConstString.upload_img_success_txt,1)                      

                            UserData.saveLeaveImgPath(self.m_imgPath)
                            UserData.saveLeaveImgUrl(imgUrl)
                            UserData.saveLeaveMsg()

                            uploadInfo(self)
                        
                        else
                            self.m_submitTips.hideTips(ConstString.commit_fail_txt)
                        end
                      
                    end
                end,"image/jpeg")
            else
                uploadInfo(self)
            end
            


            
        end

        return container
    end,

    onNativeEvent = function(self,savePath)
        -- EventDispatcher.getInstance():unregister(Event.Call, self, self.onNativeEvent);
        -- local param, status, jsonTable = NativeEvent.getNativeCallResult()


        -- self._fullPath = jsonTable.savePath or self._fullPath;

        -- self.m_imgPath = self.m_imgPrePath
        -- self.m_pictureTips.visible = false
        -- self:createUpLoadImg()
        Log.v("onNativeEvent",savePath,os.isexist(savePath),os.filesize(savePath))

        self._fullPath = savePath or self._fullPath
        
        self.m_imgPath = self.m_imgPrePath
        self.m_pictureTips.visible = false
        self:createUpLoadImg()
    end,

    createUpLoadImg = function (self)
        if self.m_uploadImg then
            self.m_uploadImg:remove_from_parent()
            self.m_uploadImg = nil
        end

        local allPath = string.format("%s%s",System.getStorageImagePath(), self.m_imgPath);
        if not os.isexist(allPath) then return end

        --显示图片
        self.m_uploadImg = Sprite(TextureUnit(TextureCache.instance():get(self.m_imgPath)))
        local imgH = self.m_pageView.height - 460 - 120
        if imgH < 0 then
            imgH = 400
        end

        if self.m_uploadImg.height > imgH then
            self.m_uploadImg.width = self.m_uploadImg.width * (imgH/self.m_uploadImg.height)
            self.m_uploadImg.height = imgH
        end

        if self.m_uploadImg.width > GKefuOnlyOneConstant.SCREENWIDTH*0.5 then
            self.m_uploadImg.height = self.m_uploadImg.height * (GKefuOnlyOneConstant.SCREENWIDTH*0.5/self.m_uploadImg.width)
            self.m_uploadImg.width = GKefuOnlyOneConstant.SCREENWIDTH*0.5
        end


        self.m_uploadImg:add_rules{
            AL.width:eq(self.m_uploadImg.width),
            AL.height:eq(self.m_uploadImg.height),
            AL.top:eq(20),
            AL.right:eq(AL.parent("width")-30),
        }

        self.m_Items[5]:add(self.m_uploadImg)
    end,



    resetLeaveInfo = function (self)
        self.m_phoneNumber = ""
        self.m_selectTxt = ""
        self.m_content = ""
        self.m_imgPath = ""
        self.m_imgUrl = {}
        UserData.saveLeavePhoneNumber(self.m_phoneNumber)
        UserData.saveLeaveTypes(self.m_selectTxt)
        UserData.saveLeaveContent(self.m_content)
        UserData.saveLeaveImgPath(self.m_imgPath)
        UserData.saveLeaveImgUrl("")
        UserData.saveLeaveMsg()

        self.m_status = {}
        self._fullPath = nil
    end,

    resetCommitBtnState = function (self)
        if self.m_status[1] and  self.m_status[2] and self.m_status[3] then
            if not self.m_btnCommit.enabled then
                self.m_btnCommit.enabled = true
                -- self.m_btnCommit.state = "normal"
            end
        elseif self.m_btnCommit.enabled then
            self.m_btnCommit.enabled = false
            -- self.m_btnCommit.state = "disabled"
        end
    end,

    onBackEvent = function (self)
        if self.m_submitTips and self.m_submitTips.visible then
            return
        end
        local data = UserData.getStatusData() or {}
        if self.m_evalutePage and self.m_evalutePage:isVisible() then
            self.m_evalutePage:hide()
            return
        end

        if  self.m_addReplyPage and self.m_addReplyPage:isVisible() then
            self.m_addReplyPage:hide()
            return
        end

        if data.isVip then
            GKefuViewManager.showVipChatView(GKefuOnlyOneConstant.LTOR)
        else
            GKefuViewManager.showNormalChatView(GKefuOnlyOneConstant.LTOR)
        end
    end,

    updateItemPos = function (self)
        local height = 100
        if self.m_Items[2].visible then
            self.m_Items[3].y = height*2
            self.m_Items[4].y = height*3
            self.m_Items[5].y = height*3+220
        else
            self.m_Items[3].y = height*1
            self.m_Items[4].y = height*2
            self.m_Items[5].y = height*2+220
        end
    end,

    onDelete = function (self)
        page_view = nil
        sliderBlock = nil
        newReplyBg = nil
        newReplyTxt = nil
        newTags = {}
        self.m_solveItems = nil
        super(leaveMessageView, self).onDelete(self)
    end,

} )

return leaveMessageView