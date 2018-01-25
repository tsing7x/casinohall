local UI = require('byui/basic');
local AL = require('byui/autolayout');
local Layout = require('byui/layout');
local class, mixin, super = unpack(require('byui/class'))
local NativeEvent = require('kefuSystem/common/nativeEvent')
local UserData = require('kefuSystem/conversation/sessionData')
local KefuResMap = require('kefuSystem/qn_res_alias_map')
local ChatMessage = require('kefuSystem/conversation/chatMessage')
local ConstString = require('kefuSystem/common/kefuStringRes')
local platform = require("kefuSystem/platform/platform")
local GKefuOnlyOneConstant = require('kefuSystem/common/kefuConstant')
local GKefuSessionControl = require('kefuSystem/conversation/sessionControl')

local currency
currency = class('currency', nil, {
    __init__ = function(self, root)
        if not root then return end;
        self.m_root = root;
        self.m_imgPath = "";
        self:createImg();
        self:createPicture();
    end,
    createImg = function(self)

        self.m_img = Widget();
        local wh = 105
        self.m_img:add_rules({
            AL.width:eq(wh),
            AL.height:eq(AL.parent('height')),
            AL.top:eq(0);
            AL.left:eq(70);
        })
        self.m_img_btn = UI.Button {
            text = "",
            radius = 0,
            border = 0,
            size = Point(wh, wh),
        }

        TextureCache.instance():get_async(KefuResMap.currencyPickNormal, function(t)
            self.m_img_btn.normal = TextureUnit(t)
        end)
        TextureCache.instance():get_async(KefuResMap.currencyPickDown, function(t)
            self.m_img_btn.down = TextureUnit(t)
        end)


        self.m_img_btn:add_rules({
            AL.top:eq(26),
        })

        self.m_img_btn.on_click = function()
            -- EventDispatcher.getInstance():register(Event.Call,self,self.onNativeEvent);
            self.m_imgPath = Clock.now() .. "_img.jpg"
            local savePath = string.format("%s%s", System.getStorageImagePath(), self.m_imgPath);
            local tab = {};
            tab.savePath = savePath;
            -- local json_data = cjson.encode(tab);
            -- NativeEvent.RequestGallery(json_data);
            platform.getInstance():RequestGallery(savePath, function(ret)
                self:onNativeEvent(ret)
            end)
        end

        self.m_img_tx = Label();
        self.m_img_tx.layout_size = Point(wh, 0)
        self.m_img_tx.align_v = (ALIGN.CENTER - ALIGN.CENTER % 4) / 4
        self.m_img_tx.align_h = ALIGN.CENTER % 4



        local data = {}
        table.insert(data, {
            text = ConstString.upload_img_txt, -- 文本
            color = Color(160, 160, 160, 255), -- 文字颜色
            bg = Color(220, 220, 220, 0), -- 背景色
            size = 23, -- 字号
            weight = 1, -- 字体粗细
        })
        self.m_img_tx:set_data(data)



        self.m_img_tx.x = 0
        self.m_img_tx.y = 150


        self.m_img:add(self.m_img_btn);
        self.m_img:add(self.m_img_tx);
        self.m_root:add(self.m_img);
    end,
    onNativeEvent = function(self, savePath)
        local fullPath = savePath
        local data = UserData.getStatusData() or {}
        local seqId = tostring(tonumber(os.time()) * 1000)
        local message = ChatMessage(seqId, GKefuOnlyOneConstant.MsgType.IMG, self.m_imgPath, data.sessionId or 1, 1)
        --上传图片消息
        print_string('message  = ', message, "  fullPath = ", fullPath, " type = ", message.types)
        GKefuSessionControl.dealwithSendMsg(message, fullPath)
    end,
    createPicture = function(self)
        local wh = 105
        self.m_picture = Widget();

        self.m_picture:add_rules({
            AL.width:eq(wh),
            AL.height:eq(AL.parent('height')),
            AL.top:eq(0);
            AL.left:eq(70 + 60 + wh);
        })

        self.m_picture_btn = UI.Button {
            text = "",
            radius = 0,
            border = 0,
            size = Point(wh, wh),
        }

        TextureCache.instance():get_async(KefuResMap.currencyPictureNormal, function(t)
            self.m_picture_btn.normal = TextureUnit(t)
        end)
        TextureCache.instance():get_async(KefuResMap.currencyPictureDown, function(t)
            self.m_picture_btn.down = TextureUnit(t)
        end)

        self.m_picture_btn:add_rules({
            AL.top:eq(26),
        })

        self.m_picture_btn.on_click = function()
            self.m_imgPath = Clock.now() .. "_img.jpg"
            local savePath = string.format("%s%s", System.getStorageImagePath(), self.m_imgPath);
            local tab = {};
            tab.savePath = savePath;
            local json_data = cjson.encode(tab);
            -- EventDispatcher.getInstance():register(Event.Call,self,self.onNativeEvent);
            -- NativeEvent.RequestCapture(json_data);
            platform.getInstance():RequestCapture(savePath, function(ret)
                self:onNativeEvent(ret)
            end)
        end

        self.m_picture_tx = Label();
        self.m_picture_tx.layout_size = Point(wh, 0)
        self.m_picture_tx.align_v = (ALIGN.CENTER - ALIGN.CENTER % 4) / 4
        self.m_picture_tx.align_h = ALIGN.CENTER % 4
        local data = {}
        table.insert(data, {
            text = ConstString.take_photo_txt, -- 文本
            color = Color(160, 160, 160, 255), -- 文字颜色
            bg = Color(220, 220, 220, 0), -- 背景色
            size = 23, -- 字号
            weight = 1, -- 字体粗细
        })
        self.m_picture_tx:set_data(data)


        self.m_picture_tx.x = 0
        self.m_picture_tx.y = 150

        self.m_picture:add(self.m_picture_btn);
        self.m_picture:add(self.m_picture_tx);
        self.m_root:add(self.m_picture);
    end,
})


return currency