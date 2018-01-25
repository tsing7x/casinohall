local UI = require('byui/basic')
local AL = require('byui/autolayout')
local class, mixin, super = unpack(require('byui/class'))
local PV = require('kefuSystem/view/pickerView')
local Anim = require('animation')
local kefuCommon = require('kefuSystem/kefuCommon')
local ConstString = require('kefuSystem/common/kefuStringRes')

local CONTENT_HEIGHT = 530

local selComponent
selComponent = class('selComponent', nil, {
    __init__ = function(self, root, data)
        self.root = root
        self.m_spaceBtn = UI.Button{
            text = "",
            margin = { 10, 10, 10, 10 },
            image =
            {
                normal = Colorf(1.0,0.0,0.0,0.0),
                down = Colorf(0.81,0.81,0.81,0.0),
                disabled = Colorf(0.2,0.2,0.2,0.0),
            },
            border = true,
            on_click = function()
                self:pop_back()
            end
        }
        self.root:add(self.m_spaceBtn)
        self.m_spaceBtn:add_rules{
            AL.width:eq(AL.parent('width')),
            AL.height:eq(AL.parent('height')-530),          
        }

        self.m_spaceBtn.visible = false

        self.container = Widget()
        self.container:add_rules{
            AL.width:eq(AL.parent('width')),
            
            AL.top:eq(AL.parent('height')),
            AL.centerx:eq(AL.parent('width') * 0.5),
        }
        self.container.height = CONTENT_HEIGHT
        self.container.background_color = Colorf.white

        root:add(self.container)

        local topContainer = Widget()
        topContainer:add_rules{
            AL.width:eq(AL.parent('width')),
            AL.height:eq(90),
            AL.centerx:eq(AL.parent('width') * 0.5),
        }
        topContainer.background_color = color_to_colorf(Color(230, 230, 230)),
        self.container:add(topContainer)

        UI.init_simple_event(self.container, function ()
            -- body
        end)

        local labelTitle = Label()
        labelTitle:set_rich_text(string.format('<font color=#000000 size=%d>%s</font>', 34, data.title))
        labelTitle.absolute_align = ALIGN.CENTER
        topContainer:add(labelTitle)

        self.m_finishBtn = UI.Button{
            image =
            {
                normal = Colorf(1.0,0.0,0.0,0.0),
                down = Colorf(0.5,0.5,0.5,0.3),
            },
            border = false,
            text = string.format('<font color=#000000 size=34>%s</font>', data.action),
        }

        self.m_finishBtn:add_rules{
            AL.width:eq(130),
            AL.height:eq(AL.parent('height')),
            AL.right:eq(AL.parent('width')),
        }

        topContainer:add(self.m_finishBtn)

        if data.ui_type == 1 then
            self:createTimePacker()
        elseif data.ui_type == 2 then
            self:createTypePacker(data.title)   
        end

        for i = 1, 2 do
            local line = Widget()
            line.zorder = 3
            line:add_rules( {
                AL.width:eq(AL.parent('width') -80),
                AL.height:eq(2.5),

                AL.left:eq(40),
                AL.top:eq(280 +(i - 1) * 60),
            } )
            line.background_color = Colorf(106/255, 106/255, 106/255, 1)
            self.container:add(line)
        end

        self.anim = Anim.Animator()
    end,
    pop_up = function(self)
        self.container.visible = true
        self.m_spaceBtn.visible = true
        self.anim.on_stop = nil
        self.container.autolayout_mask = Widget.AL_MASK_TOP
        local action = Anim.keyframes {
            -- 关键帧位置, 属性, 时间函数，这里取得Anim.linear，你可以通过取不同的时间函数得到不同的动画效果。
            { 0.0, { y = self.root.height }, Anim.anticipate_overshoot() },
            { 1.0, { y = (self.root.height - self.container.height) }, nil },
        }

        local move = Anim.duration(0.7, action)

        self.anim:start(move,
        function(v)
            self.container.y = v.y
        end)

    end,

    pop_back = function(self)
        self.container.autolayout_mask = Widget.AL_MASK_TOP
        local action = Anim.keyframes {
            -- 关键帧位置, 属性, 时间函数，这里取得Anim.linear，你可以通过取不同的时间函数得到不同的动画效果。
            { 0.0, { y = self.root.height - self.container.height }, Anim.anticipate_overshoot() },
            { 1.0, { y = self.root.height }, nil },
        }

        local move = Anim.duration(0.7, action)

        -- 使用 Animator 来运行动画, 第三个参数表示循环播放，Anim.updator为默认的更新widget属性的函数。
        self.anim:start(move,
        function(v)
            self.container.y = v.y
        end)

        self.m_spaceBtn.visible = false
        self.anim.on_stop = function ()
            self.container.visible = false
        end
    end,

    hide = function (self)
        -- self.m_spaceBtn.visible = false
        -- self.container.visible = false
    end,

    createTypePacker = function(self, title)
        local data = {
            ConstString.tong_pai_zuo_bi,
            ConstString.lan_fa_guan_gao,
            ConstString.shua_fen_bao_bi,
            ConstString.dao_luan_you_xi,
            ConstString.bu_ya_yong_yu,
        }

        local leaveData = {
            ConstString.cannot_login_txt,
            ConstString.cannot_to_pay_txt,
            ConstString.cannot_to_play_txt,
            ConstString.game_problem_txt,
            ConstString.other_txt,
        }
        if title == ConstString.leave_types_txt then
            data = leaveData
        end


        local pickerType = PV.PickerView {
            size = Point(300,100),
            row_height = 440 / 7
        }
        pickerType.data = data
        pickerType.background_color = Colorf(1.0, 1.0, 1.0, 0.0)
        pickerType:add_rules( {
            AL.width:eq(300),
            -- AL.height:eq(AL.parent('height') -90),

            AL.centerx:eq(AL.parent('width')*0.5),
            AL.top:eq(90),
        } )
        pickerType.height = self.container.height - 90
        self.container:add(pickerType)

        pickerType.on_change_select = function(index)
            self.result = data[index]
        end

        self.m_finishBtn.on_click = function ()
            self:pop_back()
            if self.btn_callback then
                self.btn_callback(self.result)
            end
        end

        pickerType.showing_index = 1

    end,

    createTimePacker = function(self)
        self.m_finishBtn.on_click = function ()
            self:pop_back()
            local result = string.format("%d-%s-%s %s:%s", self.m_year, self.m_strMonth, self.m_strDay, self.m_strHour, self.m_strMin)
            if self.btn_callback then
                self.btn_callback(result)
            end
        end

        local year = os.date("%Y", os.time())
        local month = os.date("%m", os.time())
        local day = os.date("%d", os.time())
        local hour = os.date("%H", os.time())
        local min = os.date("%M", os.time())

        --数字
        self.m_year = tonumber(year)
        self.m_month = tonumber(month)
        self.m_day = tonumber(day)
        self.m_hour = tonumber(hour)
        self.m_min = tonumber(min)

        --string
        self.m_strMonth = self.m_month >= 10 and tostring(self.m_month) or "0"..self.m_month
        self.m_strDay = self.m_day >= 10 and tostring(self.m_day) or "0"..self.m_day
        self.m_strHour = self.m_hour >= 10 and tostring(self.m_hour) or "0"..self.m_hour
        self.m_strMin = self.m_min >= 10 and tostring(self.m_min) or "0"..self.m_min

        self.m_numYear = self.m_year - 2003
        self.m_numDay = kefuCommon.getDayNum(self.m_year, self.m_month)


        local listYearData = {}

        for i = 1, self.m_numYear do
            listYearData[i] = tostring(2003 + i) .. ConstString.time_year_txt
        end

        local listMonthData = {}
        for i = 1, 12 do
            listMonthData[i] = (i < 10 and "0" .. tostring(i) or tostring(i)) .. ConstString.time_month_txt
        end

        local listDayData = {}
        for i = 1, 31 do
            listDayData[i] = (i < 10 and "0" .. tostring(i) or tostring(i)) .. ConstString.time_day_txt
        end

        local listHourData = {}
        for i = 1, 24 do
            listHourData[i] = (i - 1 < 10 and "0" .. tostring(i - 1) or tostring(i - 1)) .. ConstString.time_hour_txt
        end

        local listMinData = {}
        for i = 1, 60 do
            listMinData[i] = (i - 1 < 10 and "0" .. tostring(i-1) or tostring(i-1)) .. ConstString.time_minute_txt
        end

        self.m_pickerYear = PV.PickerView {
            row_height = 440 / 7,
            noNeedScroll = true,
            size = Point(150,CONTENT_HEIGHT - 90),
        }
        self.m_pickerYear.data = listYearData
        self.m_pickerYear.background_color = Colorf(1.0, 1.0, 1.0, 0.0)
        self.m_pickerYear:add_rules{
            AL.left:eq(40),
            AL.top:eq(90),
        }
        self.container:add(self.m_pickerYear)


        local startx = 40 + 135
        local space = 110
        self.m_pickerMonth = PV.PickerView {
            row_height = 440 / 7,
            noNeedScroll = true,
            size = Point(150,CONTENT_HEIGHT - 90),
        }
        self.m_pickerMonth.data = listMonthData
        self.m_pickerMonth.background_color = Colorf(1.0, 1.0, 1.0, 0.0)
        self.m_pickerMonth:add_rules{
            AL.left:eq((AL.parent('width')-startx-40)*0.25-space+startx ),
            AL.top:eq(90),
        } 

        self.container:add(self.m_pickerMonth)


        self.m_pickerDay = PV.PickerView {
            row_height = 440 / 7,
            noNeedScroll = true,
            size = Point(150,CONTENT_HEIGHT - 90),
        }
        self.m_pickerDay.data = listDayData
        self.m_pickerDay.background_color = Colorf(1.0, 1.0, 1.0, 0.0)
        self.m_pickerDay:add_rules( {
            AL.left:eq((AL.parent('width')-startx-40)*0.5-space+startx ),
            AL.top:eq(90),
        } )
        self.container:add(self.m_pickerDay)
        
      
        self.m_pickerHour = PV.PickerView {
            row_height = 440 / 7,
            noNeedScroll = true,
            size = Point(150,CONTENT_HEIGHT - 90),
        }
        self.m_pickerHour.data = listHourData
        self.m_pickerHour.background_color = Colorf(1.0, 1.0, 1.0, 0.0)
        self.m_pickerHour:add_rules( {
            AL.left:eq((AL.parent('width')-startx-40)*0.75-space+startx ),
            AL.top:eq(90),

        } )
        self.container:add(self.m_pickerHour)


        self.m_pickerMin = PV.PickerView {
            row_height = 440 / 7,
            noNeedScroll = true,
            size = Point(150,CONTENT_HEIGHT - 90),
        }
        self.m_pickerMin.data = listMinData
        self.m_pickerMin.background_color = Colorf(1.0, 1.0, 1.0, 0.0)
        self.m_pickerMin:add_rules{
            AL.left:eq(AL.parent('width')-40-space),
            AL.top:eq(90),
        }
        self.container:add(self.m_pickerMin)


        self.m_pickerYear.on_change_select = function(index)
            if index < 1 or index > self.m_numYear then return end 
            self.m_year = tonumber(index + 2003)
            local dayNum = kefuCommon.getDayNum(self.m_year, self.m_month)
            if self.m_numDay == dayNum then return end
            
            if self.m_day > dayNum then
                self.m_pickerDay:scroll_to_bottom(0.0)
                self.m_day = dayNum
            end

            if dayNum > self.m_numDay then
                for i = self.m_numDay + 1, dayNum do
                    self.m_pickerDay.m_items[i].visible = true
                end              
            else
                for i = dayNum + 1, self.m_numDay  do
                    self.m_pickerDay.m_items[i].visible = false
                end
            end    

            self.m_numDay = dayNum

        end           
    

   
        self.m_pickerMonth.on_change_select = function(index)
            if index < 1 or index > 12 then return end 

            self.m_strMonth = index < 10 and "0" .. index or index
            self.m_month = index
            local dayNum = kefuCommon.getDayNum(self.m_year, self.m_month)
            if self.m_numDay == dayNum then return end
            
            if self.m_day > dayNum then
                self.m_day = dayNum
                self.m_pickerDay:scroll_to_bottom(0.0)
            end

            if dayNum > self.m_numDay then
                for i = self.m_numDay + 1, dayNum do
                    self.m_pickerDay.m_items[i].visible = true
                end              
            else
                for i = dayNum + 1, self.m_numDay  do
                    self.m_pickerDay.m_items[i].visible = false
                end
            end            
            self.m_numDay = dayNum 

        end

  
        self.m_pickerDay.on_change_select = function(index)
            if index < 1 or index > self.m_numDay then return end

            self.m_strDay = index < 10 and "0" .. index or index
            self.m_day = index
        end

        self.m_pickerHour.on_change_select = function(index)
            if index < 1 or index > 24 then return end

            self.m_strHour = index - 1 < 10 and "0" .. index - 1 or index - 1
            self.m_hour = index - 1
        end

        self.m_pickerMin.on_change_select = function(index)
            if index < 1 or index > 60 then return end

            self.m_strMin = index - 1 < 10 and "0" .. index - 1 or index - 1
            self.m_min = index - 1
        end

        local scrollTime = 0.0

        -- Clock.instance():schedule_once( function()
            -- self.m_pickerYear:select_item(self.m_year -2003, scrollTime)
            -- self.m_pickerMonth:select_item(self.m_month, scrollTime)
            -- self.m_pickerDay:select_item(self.m_day, scrollTime)
            -- self.m_pickerHour:select_item(self.m_hour+1, scrollTime)
            -- self.m_pickerMin:select_item(self.m_min+1, scrollTime)
        self.m_pickerYear.showing_index = self.m_year -2003
        self.m_pickerMonth.showing_index = self.m_month
        self.m_pickerDay.showing_index = self.m_day
        self.m_pickerHour.showing_index = self.m_hour+1
        self.m_pickerMin.showing_index = self.m_min+1
        -- end)

    end,

} )


return selComponent