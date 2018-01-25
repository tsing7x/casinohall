local ProgressBar = require("uiEx.progressBar")


local LoadScene = class(GameScene)

local cIndex = 0
local function getIndex()
	cIndex = cIndex + 1
	return cIndex
end

LoadScene.s_controls = 
{
    view_loading = getIndex(),
    img_loading_tip = getIndex(),
    text_loading_tip = getIndex(),

    view_update = getIndex(),
    progress_bg = getIndex(),
    progress_fg = getIndex(),
    text_progress = getIndex(),
    text_loadtip = getIndex(),
    text_speed = getIndex(),
}

LoadScene.s_controlConfig = 
{
    [LoadScene.s_controls.view_loading] = {"view_loading"},
    [LoadScene.s_controls.img_loading_tip] = {"view_loading","img_loading_tip"},
    [LoadScene.s_controls.text_loading_tip] = {"view_loading","text_loading_tip"},

    [LoadScene.s_controls.view_update] = {"view_update"},
    [LoadScene.s_controls.progress_bg] = {"view_update","progress_bg"},
	[LoadScene.s_controls.progress_fg] = {"view_update","progress_bg","progress_fg"},
    [LoadScene.s_controls.text_progress] = {"view_update","text_progress"},
    [LoadScene.s_controls.text_loadtip] = {"view_update","text_loadtip"},
    [LoadScene.s_controls.text_speed] = {"view_update","text_speed"},
    
}


function LoadScene:ctor(viewConfig,controller,...)
	print("LoadScene:ctor")

    local text_loading_tip = self:getControl(self.s_controls.text_loading_tip)
    text_loading_tip:setText(Hall_string.STR_LOAING)

    local text_loginTip = self:findChildByName("text_tip")
    -- text_loginTip:setText(Hall_string.STR_LOGIN_FB_SAFE);

	local progressBar = new(ProgressBar)
            :setImg(self:getControl(self.s_controls.progress_bg),self:getControl(self.s_controls.progress_fg))
            :addTo(self)
    self:findChildByName("text_loading_tip"):setText(Hall_string.STR_LOAING_2)
    self:findChildByName("text_tip"):setText(Hall_string.STR_FB_LOGIN_HINT)

    local img_loading_tip = self:getControl(LoadScene.s_controls.img_loading_tip)
    -- img_loading_tip:addPropRotate(1,kAnimRepeat, 2000,0,0,360,kCenterDrawing);

    img_loading_tip:runAction({{'rotation',0,360,2},{}},{loopType=kAnimRepeat,order="spawn",onComplete=function ( ... )
            print("动画播放完了")
        end})
	
	local jsonData  	= json.decode_node(NativeEvent.getInstance():GetInitValue() or '');
    local packageName 	= GetStrFromJsonTable(jsonData, "packageName", "com.boyaa.hallgame3h_vtn")

    local gameStatus = app:getGameStatus(0)
    UIEx.bind(self, gameStatus, "totalSize", function(value)
        self:getControl(self.s_controls.text_loadtip):setText(Hall_string.STR_LOAD_UPDATING..string.format(Hall_string.str_update_size.."%sKB", value))
    end)
    UIEx.bind(self, gameStatus, "speed", function(value)
        self:getControl(self.s_controls.text_speed):setText(string.format(Hall_string.STR_DOWNLOAD_SPEED, value))
    end)

    local view_update = self:getControl(self.s_controls.view_update):hide()
    local view_loading = self:getControl(self.s_controls.view_loading):show()
    UIEx.bind(self, gameStatus, "progress", function(value)
        if value > 0 then
            view_update:show()
            view_loading:hide()
        end
        if math.floor(value)==100 then
            view_update:hide()
            view_loading:show()
        end
        progressBar:setProgress(value)
    end)
    gameStatus:setTotalSize(gameStatus:getTotalSize())
    gameStatus:setSpeed(gameStatus:getSpeed())
    gameStatus:setProgress(gameStatus:getProgress())
    
    --安卓增加apk更新检查
    if NativeEvent.s_platform == kPlatformIOS then
        MyGameVerManager:checkAndUpdateHall()
    else
        MyGameVerManager:checkAndUpdateAPK()
    end
    self:preLoadRes()
	return 
end

function LoadScene:resume(bundleData)
	print_string("zyh LoadScene:resume")
	LoadScene.super.resume(self)
	--关闭android的启动页
	NativeEvent.getInstance():CloseStartScreen()

end

----
function LoadScene:preLoadRes()
	print_string("zyh reLoadRes")
	local path = {

        "old/common/task_progress.png",
        "old/common/task_progress_bg.png",

        string.format('old/login/%s.png', PhpManager:getPackageName()),
        string.format('old/login/%s.title.png', PhpManager:getPackageName()),
        "ui/blank.png",
        "ui/shade.png",
	}

	for _, p in pairs(path) do
		local image = new(Image, p)
	end
end

function LoadScene:initView()
	
end


LoadScene.s_controlFuncMap = 
{
	
}

return LoadScene