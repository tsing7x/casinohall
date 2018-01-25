--线上的错误列表，如果在这些错误范围内，客户端会删除update目录下的所有文件，
--然后重新启动的时候会扫描SD卡上updateV1的文件夹，将新的脚本文件解压进去
local errorList = 
{
	"gameTab.lua:%d+: attempt to call method 'playRecord' %(a nil value%)",
	"roomController.lua:%d+: attempt to concatenate global 'STR_PRIVATE_ROOM_LEFT_TIME' %(a nil value%)",
	"basePlatform.lua:%d+: attempt to call method 'getLocation' %(a nil value%)",

}

return errorList