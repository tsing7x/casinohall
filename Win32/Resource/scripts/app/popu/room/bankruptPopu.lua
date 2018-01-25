local BankruptPopu = class(require("app.popu.gameWindow"))
local bankruptItemLayout=require(ViewPath.."view.bankruptItemLayout")
function BankruptPopu:ctor(viewLayout, data)
    EventDispatcher.getInstance():register(Event.Message, self, self.onMessageCallDone)
    HttpModule.getInstance():execute(HttpModule.s_cmds.GET_HALL_BANKRUPT_TAG, {}, false, true)
    self.Items = {}
    self.ItemData = {}
end

function BankruptPopu:dtor()
    EventDispatcher.getInstance():unregister(Event.Message, self, self.onMessageCallDone)
end

function BankruptPopu:initView(data)
    self:findChildByName('btn_close'):setOnClick(self, function(self) 
        self:dismiss()
    end)
    self.loadingView = self:findChildByName("view_loading");
    self.svItemList = self:findChildByName("sv_inner")
    self.svItemList:setDirection(kVertical)
    self.svItemList:setAutoPosition(true)
    self:showLoading(true)
end

function BankruptPopu:showLoading(isShow)
    if not self.toastShadeBg then
        self.toastShadeBg = new(ToastShade,false)
        self.loadingView:addChild(self.toastShadeBg)
        self.toastShadeBg:setVisible(false); 
        local toastLoadingView = self.toastShadeBg:findChildByName("view_loading");
        checkAndRemoveOneProp(toastLoadingView,1);
        toastLoadingView:addPropScaleSolid(1, 0.8, 0.8, kCenterDrawing);
    end
    if isShow then    
        self.toastShadeBg:setVisible(true); 
        self.toastShadeBg:play();
    else
        self.toastShadeBg:setVisible(false);
        self.toastShadeBg:stop();
    end
end

function BankruptPopu:initBankruptActivity(isSuccess,data)
    if app:checkResponseOk(isSuccess, data) then
        for i = 1, #data.data do
            local v=data.data[i]
            local id=v.id
            if not self.Items[id] then
                local tab = SceneLoader.load(bankruptItemLayout)
                self.Items[id] = tab
                self.svItemList:addChild(tab)
                local itemData = setProxy(new(require("app.data.bankruptItemData")));
                itemData:setStatus(v.status)
                itemData:setId(id)
                -- 使用哪种好点？
                -- itemData:setClick(v.btn)
                -- itemData:setContent01(v.title)
                -- itemData:setContent02(v.desc)
                self.ItemData[id] = itemData
                local item = self.Items[id]
                local tv_click = item:findChildByName('tv_click')
                tv_click:setText(v.btn)
                local tv_content01 = item:findChildByName('tv_content01')
                tv_content01:setText(v.title)
                local tv_content02 = item:findChildByName('tv_content02')
                tv_content02:setText(v.desc)
                self:showLoading(false);
                --需要itemData在前后各用一次，应该是必须要在绑定之后用一次要不然没有效果
                UIEx.bind(item, itemData, "status", function(value)
                    item:findChildByName("btn_attend"):setVisible(value == 1)
                    item:findChildByName("img_unclick"):setVisible(value == 0)
            end)
                itemData:setStatus(itemData:getStatus())
                local icon= item:findChildByName('img_icon')
                local imgData = setProxy(new(require("app.data.imgData")));
                local imgUrl = v.icon or "";
                imgData:setImgUrl(imgUrl);
                imgData:setImgName(imgData:getImgName());
                --2017/8/7 20:45:37 LUA res_create_image 1039731 failed:  
                UIEx.bind(icon, imgData, "imgName", function(value)
                    icon:setFile(imgData:getImgName());
                    icon:setSize(icon.m_res.m_width, icon.m_res.m_height);
                end)
                imgData:setImgName(imgData:getImgName());
            end
        end
    end
    --领取补助
    if self.Items[4] then
        local tab=self.Items[4]
        tab:findChildByName("btn_attend"):setOnClick(self,function ( self )
            HttpModule.getInstance():execute(HttpModule.s_cmds.GET_HALL_BANKRUPT, {gameSid = 1017}, true, true)
        end)
    end
    --去转盘
    if self.Items[3] then
        local tab=self.Items[3]
        tab:findChildByName("btn_attend"):setOnClick(self,function ( self )
            self:showLoading(true)
            HttpModule.getInstance():execute(HttpModule.s_cmds.Turntable_GET_TABLE_CFG, {["mid"] = MyUserData:getId()}, false, false)
        end)
    end
    --邀请好友
    if self.Items[1] then
        local tab=self.Items[1]
        tab:findChildByName("btn_attend"):setOnClick(self,function ( self )
            WindowManager:showWindow(WindowTag.FbInvitePopu, {}, WindowStyle.POPUP)    
        end)
    end
end

function BankruptPopu:onMessageCallDone(param, data)
    local viewItems = self:findChildByName("view_inner")
    if param == 'hallBankrupt' then
        --领取破产补助的选项要变灰
        if self.Items[4] then
            self.ItemData[4]:setStatus(0);
        end 
    end   
end

function BankruptPopu:onTurntableGetTableCfg2(isSuccess,data)
    self:showLoading(false)
    if not app:checkResponseOk(isSuccess,data) then
    end
    if data.data.isCanAward > 0 then
        WindowManager:showWindow(WindowTag.WheelPopu, data.data, WindowStyle.POPUP)
    end
end
function BankruptPopu:onTurned(isSuccess,data)
    if app:checkResponseOk(isSuccess,data) then
        if self.Items[3] then
            self.ItemData[3]:setStatus(0);
        end
    end
end
BankruptPopu.s_severCmdEventFuncMap = {
    [HttpModule.s_cmds.GET_HALL_BANKRUPT_TAG]   = BankruptPopu.initBankruptActivity,
    [HttpModule.s_cmds.Turntable_GET_TABLE_CFG] = BankruptPopu.onTurntableGetTableCfg2,
    [HttpModule.s_cmds.Turntable_LOTTERY] = BankruptPopu.onTurned,

}

return BankruptPopu