local CURRENT_MODULE_NAME = ...   -- require的参数
local PACKAGE_NAME = string.sub(CURRENT_MODULE_NAME, 1, -6)  
require("core/system")

display = {}

-- 分辨率
display.resolution = System.getResolution()
local tb = string.split(display.resolution, "x")
display.sizeInPixels = {width = tb[1] or 0, height = tb[2] or 0}

System.setLayoutWidth(CONFIG_SCREEN_WIDTH);
System.setLayoutHeight(CONFIG_SCREEN_HEIGHT);

local winSize = { width = System.getScreenWidth(), height = System.getScreenHeight() }
display.winSize            = {width = winSize.width, height = winSize.height}
display.width              = System.getScreenScaleWidth()
display.height             = System.getScreenScaleHeight()
display.cx                 = display.width / 2
display.cy                 = display.height / 2
display.left               = 0
display.right              = display.width
display.top                = 0
display.bottom             = display.height
display.c_left             = -display.width / 2
display.c_right            = display.width / 2
display.c_top              = -display.height / 2
display.c_bottom           = display.height / 2

display.WHITE 	= c3b(255, 255, 255)
display.BLACK 	= c3b(0, 0, 0)
display.RED   	= c3b(255, 0, 0)
display.GREEN   = c3b(0, 255, 0)
display.BLUE   	= c3b(0, 0, 255)