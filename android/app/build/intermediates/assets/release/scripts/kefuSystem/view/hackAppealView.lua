local UI = require('byui/basic')
local AL = require('byui/autolayout')
local Layout = require('byui/layout')
local class, mixin, super = unpack(require('byui/class'))
local Anim = require('animation')
local baseView = require('kefuSystem/view/baseView')
local SelComponent = require('kefuSystem/view/selComponent')
local kefuCommon = require('kefuSystem/kefuCommon')
local UserData = require('kefuSystem/conversation/sessionData')
local ConstString = require('kefuSystem/common/kefuStringRes')
local KefuResMap = require('kefuSystem/qn_res_alias_map')
local Log = require('kefuSystem/common/log')
local KefuEmoji = require('kefuSystem/common/kefuEmojiCfg')
local URL = require("kefuSystem/mqttModule/mqttConstants")
-- local NativeEvent = require('kefuSystem/common/nativeEvent)
local platform = require("kefuSystem/platform/platform")
local GKefuOnlyOneConstant = require('kefuSystem/common/kefuConstant')
local GKefuNetWorkControl = require('kefuSystem/conversation/netWorkControl')
local GKefuViewManager = require("kefuSystem/viewManager")

local page_view
local sliderBlock
local newReplyBg
local newReplyTxt
local newTags = {}


local transformType = function (str)
    if ConstString.tong_pai_zuo_bi == str then
        return 1
    elseif ConstString.lan_fa_guan_gao == str then
        return 2
    elseif ConstString.shua_fen_bao_bi == str then
        return 3
    elseif ConstString.dao_luan_you_xi == str then
        return 4
    elseif ConstString.bu_ya_yong_yu == str then
        return 5
    end

    return 6
end

local hackAppealView

local rules = {
    top_container =
    {
        AL.width:eq(AL.parent('width')),
        AL.height:eq(100),
    },
    top_title =
    {
        AL.width:eq(200),
        AL.height:eq(30),
        AL.centerx:eq(AL.parent('width') * 0.5),
        AL.centery:eq(AL.parent('height') * 0.5),
    },
    btn_back =
    {
        AL.width:eq(160),
        AL.height:eq(AL.parent('height')),
    },
    arrow_icon =
    {
        AL.width:eq(24),
        AL.height:eq(42),
        AL.top:eq(26),
        AL.left:eq(17),
    },

}



local createHistoryItem = function(data)
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
    btnItem:add_rules( {
        AL.width:eq(AL.parent('width')),
        AL.height:eq(90),
        AL.centerx:eq(AL.parent('width') * 0.5),
        AL.top:eq(0),
    } )
    container:add(btnItem)



    local txtTitle = Label()
    local titleStr = data.title
    if string.len(data.title) > 15 then
        titleStr = string.format("%s/...",kefuCommon.subUTF8String(data.title, 15))
    end
    -- txtTitle:set_rich_text(string.format('<font color=#000000 size=30>%s</font>', titleStr))
    txtTitle:set_data{
        {
            color = Color(0,0,0);
            size = 30;
            text = titleStr;
        }
    }
    txtTitle:add_rules{
        AL.width:eq(150),
        AL.height:eq(20),
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
        AL.left:eq(AL.parent('width') - 30),
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
    for i = 1, 3 do
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

    lines[1].y = posY + space + 30

    local posX = 30
----------编号
    local txtNo = Label()
    txtNo:add_rules{
        AL.width:eq(60),
        AL.height:eq(20),
        AL.left:eq(posX),
        AL.top:eq(posY),
    }
    contentCon:add(txtNo)
    txtNo:set_rich_text(string.format('<font color=#9b9b9b size=30>%s</font>', ConstString.number_txt))

    posX = posX + txtNo.width +5
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
        AL.width:eq(60),
        AL.height:eq(20),
        AL.left:eq(posX),
        AL.top:eq(posY),
    }
    contentCon:add(labelNo)


----------------id
    posX = posX + labelNo.width + 20
    local txtID = Label()
    txtID:set_rich_text('<font color=#9b9b9b size=30>ID:</font>')
    txtID:add_rules{
        AL.width:eq(60),
        AL.height:eq(20),
        AL.left:eq(posX),
        AL.top:eq(posY),
    } 
    contentCon:add(txtID)

    posX = posX + txtID.width
    local labelID = Label()
    if #tostring(data.mid) > 7 then
        data.mid = string.sub(data.mid,1,7) .. "..."
    end

    -- labelID:set_rich_text(string.format('<font color=#000000 size=30>%s</font>', data.mid))
    labelID:set_data{
        {
            color = Color(0,0,0);
            size = 30;
            text = data.mid;
        }
    }
    labelID:add_rules{
        AL.width:eq(60),
        AL.height:eq(20),
        AL.left:eq(posX),
        AL.top:eq(posY),
    }
    contentCon:add(labelID)
    labelID:update()


-----------类型
    posX = posX  +20+ labelID.width   
    local txtType = Label()
    txtType:set_rich_text(string.format('<font color=#9b9b9b size=30>%s:</font>', ConstString.types_tips))
    txtType:add_rules{
        AL.width:eq(60),
        AL.height:eq(20),
        AL.left:eq(posX),
        AL.top:eq(posY),
    }
    contentCon:add(txtType)


    posX = posX + txtType.width
    local labelType = Label()
    -- labelType:set_rich_text(string.format('<font color=#000000 size=30>%s</font>', data.typeStr))
    labelType:set_data{
        {
            color = Color(0,0,0);
            size = 30;
            text = data.typeStr;
        }
    }
    labelType:add_rules{
        AL.width:eq(60),
        AL.height:eq(20),
        AL.left:eq(posX),
        AL.top:eq(posY),
    }
    contentCon:add(labelType)


---------举报内容
    posY = posY + space*2 + 30          --30为文字高
    local txtContent = Label()
    txtContent:set_rich_text(string.format('<font color=#9b9b9b size=30>%s:</font>', ConstString.ju_bao_content_txt))
    txtContent:add_rules{
        AL.width:eq(60),
        AL.height:eq(20),
        AL.left:eq(30),
        AL.top:eq(posY),
    } 
    contentCon:add(txtContent)

    local labelContent = Label()
    labelContent.layout_size = Point(GKefuOnlyOneConstant.SCREENWIDTH - 250, 0)
    -- labelContent:set_rich_text(string.format('<font color=#000000 size=30>%s</font>', data.title))
    labelContent:set_data{
        {
            color = Color(0,0,0);
            size = 30;
            text = data.title;
        }
    }
    labelContent:add_rules{
        AL.left:eq(180),
        AL.top:eq(posY),
    }
    contentCon:add(labelContent)
    labelContent:update()

    lines[2].y = posY + space + labelContent.height
--------------客服回复
    posY = posY + space*2 + labelContent.height
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
    labelReply.multiline = true
    labelReply:add_rules{
        AL.height:eq(20),
        AL.left:eq(180),
        AL.top:eq(posY),
    }
    labelReply.layout_size = Point(GKefuOnlyOneConstant.SCREENWIDTH - 250, 0)
    
    local cts = string.gsub(data.reply, "%[(.-)%]", function (char)
        if KefuEmoji.NameToId[char] then
            return kefuCommon.unicodeToChar(KefuEmoji.NameToId[char])
        else
            return string.format("[%s]", char)
        end
    end)
    
    -- labelReply:set_rich_text(string.format('<font color=#000000 size=30>%s</font>', cts))
    labelReply:set_data{
        {
            color = Color(0,0,0);
            size = 30;
            text = cts;
        }
    }
    contentCon:add(labelReply)
    labelReply:update()

    posY = posY + labelReply.height+space
    contentCon.height_hint = posY

    lines[3].y = posY - 1


    btnItem.on_click = function()
        arrowIcon.visible = contentCon.visible
        arrowIcon1.visible = not contentCon.visible
        contentCon.visible = not contentCon.visible

       if contentCon.visible then
            container.height_hint = contentCon.height_hint + 90
            newTags[data.id].visible = false
            if data.hasNewReport == GKefuOnlyOneConstant.HasNewReport.yes then
                local hackData = UserData.getHackAppealViewData() or {}
                local dictData = hackData.dictData or {}
                hackData.hasNewReport = hackData.hasNewReport - 1
                dictData[data.id].hasNewReport = GKefuOnlyOneConstant.HasNewReport.no
                UserData.updateHackMsg(dictData[data.id])
                UserData.setHackAppealViewData(hackData)

                newReplyTxt:set_rich_text(string.format("<font color=#ffffff bg=#00000000 size=24 weight=1>%d</font>", hackData.hasNewReport))
                if hackData.hasNewReport <= 0 and newReplyBg then
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
end



local function reportInfo( self )
    local tb = {}
    tb.gid = mqtt_client_config.gameId
    tb.site_id = mqtt_client_config.siteId
    tb.client_id = mqtt_client_config.stationId
    tb.report_mid = self.m_editHackId.text
    tb.report_data = ""
    tb.report_type = GKefuOnlyOneConstant.HackMsg2NumType[self.m_selectTxt]
    tb.report_content = self.m_eidtContent.text
    tb.report_pics = cjson.encode(self.m_imgUrl or {})
    tb.client_info = GKefuNetWorkControl.generateClientInfo("")

    GKefuNetWorkControl.postString(URL.HTTP_SUBMIT_REPORT_URI, cjson.encode(tb), function (rsp)
        if rsp.errmsg or rsp.code ~= 200 then
            self.m_submitTips.hideTips(ConstString.commit_fail_txt)
        else
            Log.v("postString:", "submit hack result", rsp.content)
            local result = cjson.decode(rsp.content)
            if result and result.code == 0 then
                self:requireData(true, function ()
                    Clock.instance():schedule_once(function ()                       
                        self.m_submitTips.hideTips(ConstString.commit_success_txt, 1)
                        self:onUpdate(nil, true)
                        self.m_pageView.page_num = 2
                    end, 1)

                    self:resetHackInfo()

                end)
            else
                self.m_submitTips.hideTips(ConstString.commit_fail_txt)
            end

        end

    end)
end
hackAppealView = class('hackAppealView', baseView, {
    __init__ = function(self)
        super(hackAppealView, self).__init__(self)
        self.m_status = {}

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
        topContainer:add_rules(rules.top_container)
        
        self.m_topContainer = topContainer

        local txtTitle = Label()
        txtTitle:set_rich_text(string.format("<font color=#F4C392 bg=#00000000 size=34 weight=3>%s</font>", ConstString.players_report_title))
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
        btnBack:add_rules(rules.btn_back)
        topContainer:add(btnBack)
        self.m_btnBack = btnBack

        -- 创建箭头图标
        local arrowIcon = Sprite(TextureUnit(TextureCache.instance():get(KefuResMap.chatBackVip)))
        arrowIcon:add_rules(rules.arrow_icon)
        btnBack:add(arrowIcon)
        self.m_arrowIcon = arrowIcon

        -- ==============================================tab=========================================================
        local buttomContainer = Widget()
        buttomContainer.background_color = Colorf(1.0, 1.0, 1.0, 1.0)
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
            text = string.format('<font color=#f4c493 size=30>%s</font>', ConstString.wo_yao_ju_bao),
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
            text = string.format('<font color=#9b9b9b size=30>%s</font>', ConstString.ju_bao_history_txt),
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

        btnAppealAgainst.on_click = function()
            if page_view.page_num == 1 then return end            
            page_view.page_num = 1
            
        end

        btnAppealHistory.on_click = function()
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
        
        self.m_pageView = page_view
        self.m_pageViewY = 240
        page_view.y = self.m_pageViewY 

        page_view.background_color = Colorf.white
        page_view:add_rules{
            AL.width:eq(AL.parent('width') -40),
            AL.height:eq(AL.parent('height') -255),
            AL.centerx:eq(AL.parent('width') * 0.5),
        }
        self.m_root:add(page_view)

        page_view.create_cell = function(pageView, i)
            local page = self:initPage(i)
            return page
        end
        page_view.focus = true

        page_view:update_data()

        self.m_hideCallBack = function ()
            self.m_pageView.page_num = 1
        end

        self.m_pageView.on_page_change = function ()
            if self.m_pageView.page_num == 1 then
                btnAppealAgainst.text = string.format('<font color=%s size=30>%s</font>', self.m_txtColor, ConstString.wo_yao_ju_bao)
                btnAppealHistory.text = string.format('<font color=#9b9b9b size=30>%s</font>', ConstString.ju_bao_history_txt)

            else
                UI.share_keyboard_controller().keyboard_status = false
                btnAppealAgainst.text = string.format('<font color=#9b9b9b size=30>%s</font>', ConstString.wo_yao_ju_bao)
                btnAppealHistory.text = string.format('<font color=%s size=30>%s</font>', self.m_txtColor, ConstString.ju_bao_history_txt)
            
            end

        end

        self.m_pageView.on_scroll = function ( _, p,d,v)
            if sliderBlock then
                sliderBlock.x = -(sliderBlock.width / self.m_pageView.width)*p.x
            end
        end
        
        self.m_root:add(topContainer)

        self.m_hackId = UserData.getHackId()
        self.m_selectTxt = UserData.getHackTypes()
        self.m_content = UserData.getHackContent()
        self.m_imgPath = UserData.getHackImgPath()
        self.m_imgUrl = {}
        local url = UserData.getHackImgUrl()
        if url and url ~= "" then
            table.insert(self.m_imgUrl, url)
        end
    end,

    setNormalItem = function (self)
        local data = UserData.getStatusData()
        if not data.isVip then
            self.m_topContainer.background_color = Colorf(0.0, 0.0, 0.0,1.0)
            self.m_txtTitle:set_rich_text(string.format("<font color=#ffffff bg=#00000000 size=34 weight=3>%s</font>", ConstString.players_report_title))
            self.m_arrowIcon.unit = TextureUnit(TextureCache.instance():get(KefuResMap.chatBack))
            self.m_btnBack.text = string.format("<font color=#ffffff bg=#00000000 size=28>%s</font>", ConstString.back_txt)
            sliderBlock.background_color = Colorf(111/255, 188/255, 44/255, 1)
        else
            self.m_topContainer.background_color = Colorf(0.227, 0.188, 0.31, 1.0)
            self.m_txtTitle:set_rich_text(string.format("<font color=#F4C392 bg=#00000000 size=34 weight=3>%s</font>", ConstString.players_report_title))
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

        self.m_pageView.page_num = 1
        --标记是否可以提交
        self.m_status = {}

        self:setNormalItem()
        -- self.m_editHackId.text = string.format('<font color=#000000 size=30>%s</font>', self.m_hackId)
        self.m_editHackId.text = {
            {
                color = Color(0,0,0);
                size = 30;
                text = self.m_hackId;
            }
        }
        if self.m_hackId == "" then
            self.m_editHackId.hint_text = string.format("<font color=#9b9b9b size=30>%s</font>", ConstString.input_ju_bao_id_txt)
        else
            self.m_status[1] = true
        end 
        
        if self.m_selectTxt == "" then
            self.m_typeLabel:set_rich_text(string.format("<font color=#9b9b9b size=30>%s</font>", ConstString.input_ju_bao_types))
        else
            self.m_typeLabel:set_rich_text(string.format('<font color=#000000 size=30>%s</font>', self.m_selectTxt))
            self.m_status[2] = true
        end

        self.m_eidtContent.text = {
            {
                color = Color(0,0,0);
                size = 30;
                text = self.m_content;
            }
        }
        -- string.format('<font color=#000000 size=30>%s</font>',self.m_content)
        if self.m_content == "" then
            self.m_eidtContent.hint_text = string.format('<font color=#9b9b9b size=30>%s</font>', ConstString.ju_bao_show_tips)
        else
            self.m_status[3] = true
        end

        local allPath = string.format("%s%s",System.getStorageImagePath(), self.m_imgPath)

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
        
        
        self.m_buttomContainer.y = self.m_buttomContainerY
        self.m_pageView.y = self.m_pageViewY
        self.m_selComp:hide()

        local hackData = UserData.getHackAppealViewData() or {}                
        newReplyTxt:set_rich_text(string.format("<font color=#ffffff bg=#00000000 size=24 weight=1>%d</font>", hackData.hasNewReport))
        if hackData.hasNewReport <= 0 then
            newReplyBg.visible = false
        else
            newReplyBg.visible = true
        end
       
        if not arg2 then
            self:requireData()
        end

        self:resetCommitBtnState()

    end,

    requireData = function (self, isRequire, callback)
        --不需要向服务器拉数据
        if not isRequire then
            local hackData = UserData.getHackAppealViewData() or {}
            if hackData.historyData then
                self.m_noRecordLabel.visible = false
                if self.m_replyData then
                    --如果新旧数据一致，则不更新界面
                    if #self.m_replyData == #hackData.historyData then
                        for i, v in ipairs(self.m_replyData) do
                            if v.reply ~= hackData.historyData[i].reply then
                                self.m_listViewReply.data = hackData.historyData
                                break
                            end
                        end
                    else
                        self.m_listViewReply.data = hackData.historyData
                    end
                else
                    self.m_listViewReply.data = hackData.historyData
                end
                self.m_replyData = hackData.historyData
            else
                self.m_noRecordLabel.visible = #self.m_listViewReply.data == 0
                self.m_replyData = nil
            end

            return
        end

        GKefuNetWorkControl.obtainUserTabHistroy(0, 50, URL.HTTP_SUBMIT_REPORT_HISTORY_URI, function (content)
            local tb = cjson.decode(content)
            if tb.code == 0 and tb.data then

                table.sort(tb.data, function (v1,v2)
                    if v1.id > v2.id then
                        return true
                    end
                    return false
                end)

                self.m_replyData = self.m_replyData or {}
                for i, v in ipairs(tb.data) do
                    local data = {}
                    data.id = v.id
                    data.title = v.report_content
                    data.time = v.clock
                    data.reply = v.reply
                    data.typeStr = GKefuOnlyOneConstant.HackNum2MsgType[v.report_type]
                    data.mid = v.report_mid
                    data.reply = string.format(ConstString.replay_default,mqtt_client_info.hotline)
                    data.hasNewReport = GKefuOnlyOneConstant.HasNewReport.no
                    table.insert(self.m_replyData, 1, data)
                    break
                end

                          
                self.m_noRecordLabel.visible = false               
                self.m_listViewReply.data = self.m_replyData

                if callback then
                    callback() 
                end


            else
                Log.w("obtainUserTabHistroy", "举报内容获取失败")
            end
        end)
    end,

    initPage = function (self, i)
        if i == 1 then
            local content = self:addFirstPage()
            return content
        elseif i == 2 then
            local container = Widget()
            container:add_rules{
                AL.width:eq(AL.parent('width')),
                AL.height:eq(AL.parent('height')),
            }

            local listviewHistory = UI.ListView {
                create_cell = function(data)
                    local container = createHistoryItem(data)
                    return container
                end,
            }
            listviewHistory.shows_vertical_scroll_indicator = true
            listviewHistory:add_rules{
                AL.width:eq(AL.parent('width')),
                AL.height:eq(AL.parent('height')),
                AL.left:eq(1),
            }
            container:add(listviewHistory)
            listviewHistory.velocity_factor = 3.1

            self.m_listViewReply = listviewHistory
            self.m_noRecordLabel = Label()
            self.m_noRecordLabel:set_rich_text(string.format("<font color=#9b9b9b bg=#00000000 size=44 weight=3>%s</font>", ConstString.no_anyrecord_tips))
            container:add(self.m_noRecordLabel)
            self.m_noRecordLabel.absolute_align = ALIGN.CENTER
            self.m_listViewReply.background_color = Colorf(244/255, 244/255, 244/255, 1)

            return container
        end
        
    end,

    addFirstPage = function(self)
        local container = Widget()
        container:add_rules{
            AL.width:eq(AL.parent('width')-1),
            AL.height:eq(AL.parent('height')),
        }

        self.m_firstPage = container

        local itemsData = {
            { title = ConstString.ju_bao_id_txt, hint_text = ConstString.input_ju_bao_id_txt, ui_type = "edit" },
            { title = ConstString.ju_bao_types_txt, hint_text = ConstString.input_ju_bao_types, ui_type = "label", icon = KefuResMap.commonMore },
        }

        local lineH = 2
        local height = 100
        for i = 1, 2 do
            local item = Widget()
            item:add_rules{
                AL.width:eq(AL.parent('width')),
                AL.height:eq(height),
                AL.centerx:eq(AL.parent('width') * 0.5),
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

            local title = Label()
            title.align = Label.CENTER
            -- title:set_rich_text(string.format('<font color=#000000 size=30>%s</font>', itemsData[i].title))
            title:set_data{
                {
                    color = Color(0,0,0);
                    size = 30;
                    text = itemsData[i].title;
                }
            }
            title.pos = Point(30,(height - title.height) /2)

            item:add(title)

            local tips = Label()
            tips:set_data{{text = "*",color = Color.red}}
            tips.pos = Point((30 -tips.width)/2 ,(height - tips.height) /2)
            item:add(tips)

            if itemsData[i].ui_type == "edit" then
                local edit = UI.EditBox {
                    background_style = KTextBorderStyleNone,
                    icon_style = KTextIconNone,
                    text = string.format('<font color=#000000 size=30>%s</font>', ""),
                    hint_text = string.format('<font color=#9b9b9b size=30>%s</font>',itemsData[i].hint_text),
                }
                edit.need_capture = true

                self.m_editHackId = edit
                self.m_editHackId.max_length = 20
                self.m_editHackId.keyboard_type = Application.KeyboardTypeNumberPad

                self.m_editHackId.on_text_changed = function (txt)
                    self.m_hackId = txt
                    UserData.saveHackId(self.m_hackId)
                    UserData.saveHackMsg()
                    if self.m_hackId == "" then
                        self.m_status[1] = false
                    else
                        self.m_status[1] = true
                    end

                    self:resetCommitBtnState()

                end
                edit:add_rules{
                    AL.width:eq(AL.parent('width')-250),
                    AL.height:eq(80),
                    AL.left:eq(250),
                    AL.top:eq(34),
                }
              
                -- edit.keyboard_type = Application.KeyboardTypeNumberPad
                edit.inspection_insert = function ( str )
                    if tonumber(str) then
                        return str
                    end
                    return ""
                end
                item:add(edit)
            elseif itemsData[i].ui_type == "label" then
                local label = Label()
                self.m_typeLabel = label
                -- label:set_rich_text(string.format('<font color=#9b9b9b size=30>%s</font>', itemsData[i].hint_text))
                label:set_data{
                    {
                        color = Color(0x9b,0x9b,0x9b);
                        size = 30;
                        text = itemsData[i].hint_text;
                    }
                }
                label:add_rules{
                    AL.width:eq(500),
                    AL.height:eq(20),
                    AL.left:eq(251),
                }
                label.y = (100 - label.height) /2
            
                item:add(label)

                if i == 2 then
                    local wg = Widget()
                    wg:add_rules{
                        AL.width:eq(AL.parent('width')-240),
                        AL.height:eq(AL.parent('height')),
                        AL.left:eq(240),
                    }
 
                    item:add(wg)
                    wg.need_capture = true

                    local selcomp = SelComponent(self.m_root, {title = ConstString.ju_bao_types_txt, action = ConstString.finish_tag_txt, ui_type = 2 })
                    selcomp.btn_callback = function(str)
                        str = str or ConstString.tong_pai_zuo_bi
                        -- label:set_rich_text(string.format('<font color=#000000 size=30>%s</font>', str))
                        label:set_data{
                            {
                                color = Color(0,0,0);
                                size = 30;
                                text = str;
                            }
                        }
                        self.m_selectTxt = str
                        self.m_status[2] = true
                        UserData.saveHackTypes(self.m_selectTxt)
                        UserData.saveHackMsg()

                        self:resetCommitBtnState()

                    end
                    self.m_selComp = selcomp
                  
                    UI.init_simple_event(wg, function ()
                        UI.share_keyboard_controller().keyboard_status = false
                        selcomp:pop_up()
                    end)
                end
            end

            if itemsData[i].icon then
                local icon = Sprite(TextureUnit(TextureCache.instance():get(itemsData[i].icon)))
                icon:add_rules{
                    AL.right:eq(AL.parent('width') - 20),
                    AL.centery:eq(height/2),
                }
                
                item:add(icon)
            end
        end

        local itemWg = Widget()
        itemWg:add_rules{
            AL.width:eq(AL.parent('width')),
            AL.height:eq(220),
        }
        itemWg.y = height*2
        container:add(itemWg)


        local tips = Label()
        tips:set_data{{text = "*",color = Color.red}}
        tips.pos = Point((30 -tips.width)/2 ,(height - tips.height) /2)
        itemWg:add(tips)

        local line3 = Sprite(TextureUnit.default_unit())
        line3:add_rules( {
            AL.width:eq(AL.parent('width')),
            AL.height:eq(kefuCommon.getLineRealHeight(lineH)),
            AL.bottom:eq(AL.parent('height')),
        } )
        line3.colorf = Colorf(0.77, 0.77, 0.77, 1)
        itemWg:add(line3)

        local editContent = UI.MultilineEditBox { expect_height = 170 }
        editContent.text = string.format('<font color=#000000 size=30>%s</font>', "")
        editContent.style = KTextBorderStyleNone
        editContent.background_style = KTextBorderStyleNone
        editContent:add_rules( {
            AL.width:eq(AL.parent('width') -48),
            AL.height:eq(170),
            AL.left:eq(30),
            AL.top:eq(28),
        }
        )
        editContent.need_capture = true
        editContent.max_height = 170
        editContent._hint_label.layout_size = Point(GKefuOnlyOneConstant.SCREENWIDTH-92, 0)
        editContent.hint_text = string.format('<font color=#9b9b9b size=30>%s</font>', ConstString.ju_bao_show_tips)
        itemWg:add(editContent)
        self.m_eidtContent = editContent

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

        
        container:add(self.m_contentBtn)
        self.m_contentBtn.visible = false


        self.m_eidtContent.on_keyboard_show = function (args)
            self.m_contentBtn.visible = true
            local linePos = itemWg:to_world(Point(0, 220))
            local disY = linePos.y - args.y
            if disY > 0 then
                self.m_buttomContainer.y = self.m_buttomContainerY - disY
                self.m_pageView.y = self.m_pageViewY - disY
            end

        end

        self.m_eidtContent.on_keyboard_hide = function (args)
            self.m_contentBtn.visible = false
            self.m_buttomContainer.y = self.m_buttomContainerY
            self.m_pageView.y = self.m_pageViewY
        end

        self.m_eidtContent.on_text_changed = function ( txt )
            self.m_content = txt 
            if self.m_content == "" then
                self.m_status[3] = false
            else
                self.m_status[3] = true
            end
            self:resetCommitBtnState()
            UserData.saveHackContent(self.m_content)
            UserData.saveHackMsg()
        end



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
            AL.top:eq(height*2+252),
        }
        
        container:add(btnUpgrade)
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
                self:onNativeEvent(ret)
            end)
        end

        local labelTip = Label()
        self.m_pictureTips = labelTip
        labelTip.layout_size = Point(GKefuOnlyOneConstant.SCREENWIDTH-250, 0)
        labelTip:set_rich_text(string.format('<font color=#9b9b9b size=30>%s</font>', ConstString.tong_pai_must_have_img))
        labelTip:add_rules{
            AL.width:eq(450),
            AL.height:eq(20),
            AL.left:eq(200),
            AL.top:eq(height*2+280),
        }
        
        container:add(labelTip)

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
                    if rsp.errmsg or rsp.code ~= 200 then
                        Log.v("uploadRequest" ,"failed:", rsp.errmsg, rsp.code)
                        self.m_submitTips.hideTips(ConstString.commit_fail_txt)
                    else
                        local content = cjson.decode(rsp.content)
                        if content.code == 0 then

                            self.m_imgUrl = {}
                            local imgUrl = URL.FILE_UPLOAD_HOST..content.file
                            table.insert(self.m_imgUrl, imgUrl)



                            UserData.saveHackImgUrl(imgUrl)
                            UserData.saveHackImgPath(self.m_imgPath)
                            UserData.saveHackMsg()
                            
                            reportInfo(self)
                        else
                            Log.v("uploadRequest" ,"返回结果不正确", content.code)
                            self.m_submitTips.hideTips(ConstString.commit_fail_txt)
                        end
                      
                    end
                end,"image/jpeg")
            else
                reportInfo(self)
            end


            
        end

        return container
    end,
    
    resetHackInfo = function (self)
        self.m_hackId = ""
        self.m_selectTxt = ""
        self.m_content = ""
        self.m_imgPath = ""
        self._fullPath = nil;
        self.m_status = {}
        self.m_imgUrl = {}

        UserData.saveHackId(self.m_hackId)
        UserData.saveHackTypes(self.m_selectTxt)
        UserData.saveHackContent(self.m_content)
        UserData.saveHackImgPath(self.m_imgPath)
        UserData.saveHackImgUrl("")

    end,

    onNativeEvent = function(self,savePath)
        -- EventDispatcher.getInstance():unregister(Event.Call, self, self.onNativeEvent);
        -- local param, status, jsonTable = NativeEvent.getNativeCallResult()
        -- self._fullPath = jsonTable.savePath or self._fullPath;

        self._fullPath = savePath or self._fullPath
        self.m_imgPath = self.m_imgPrePath
        self.m_pictureTips.visible = false
        self:createUpLoadImg()
        self.m_status[4] = true
        self:resetCommitBtnState()
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
            AL.top:eq(440),
            AL.right:eq(AL.parent("width")-30),
        }

        self.m_firstPage:add(self.m_uploadImg)
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
    end,

    resetCommitBtnState = function (self)
        if self.m_selectTxt == ConstString.tong_pai_zuo_bi then
            if self.m_status[1] and self.m_status[2] and self.m_status[3] and self.m_status[4] then
                if not self.m_btnCommit.enabled then
                    self.m_btnCommit.enabled = true
                    self.m_btnCommit.state = "normal"
                end
            elseif self.m_btnCommit.enabled then
                self.m_btnCommit.enabled = false
                self.m_btnCommit.state = "disabled"
            end
        else
            if self.m_status[1] and self.m_status[2] and self.m_status[3] then
                if not self.m_btnCommit.enabled then
                    self.m_btnCommit.enabled = true
                    self.m_btnCommit.state = "normal"
                end
            elseif self.m_btnCommit.enabled then
                self.m_btnCommit.enabled = false
                self.m_btnCommit.state = "disabled"
            end
        end
    end,

    onDelete = function (self)
        newReplyBg = nil
        newReplyTxt = nil
        newTags = {}
        super(hackAppealView, self).onDelete(self)
    end,

} )

return hackAppealView