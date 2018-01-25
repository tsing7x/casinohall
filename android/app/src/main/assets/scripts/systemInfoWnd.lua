require("core/system");
require("app.common.uiFactory");
require("app.common.animFactory");

SystemInfoWnd = class();

SystemInfoWnd.ctor = function()
	
	SystemInfoWnd.m_root = UIFactory.createNode();
	SystemInfoWnd.m_root:setLevel(199);
	local memoryStr = "Mer:" .. System.getTextureMemory() or "0"; 
	local animNumStr= "Ainm:" .. System.getAnimNum() or "0";
	local fpsStr    = "FPS:" .. System.getFrameRate() or "0";

	--SystemInfoWnd.m_info_bg = UIFactory.createButton("ui/spinner_bg.png");
	SystemInfoWnd.m_info_bg = UIFactory.createImage("ui/spinner_bg.png");
	SystemInfoWnd.m_animNum = UIFactory.createText({ text = animNumStr, size = 22,color = {r= 155 ,g = 0,b = 0} });
	SystemInfoWnd.m_memory  = UIFactory.createText({ text = memoryStr, size = 22,color = {r= 155 ,g = 0,b = 0} });
	SystemInfoWnd.m_fps     = UIFactory.createText({ text = fpsStr, size = 22, color = {r= 155 ,g = 0,b = 0} });

	SystemInfoWnd.m_root:addChild(SystemInfoWnd.m_info_bg);
	SystemInfoWnd.m_root:addChild(SystemInfoWnd.m_animNum);
	SystemInfoWnd.m_root:addChild(SystemInfoWnd.m_memory);
	SystemInfoWnd.m_root:addChild(SystemInfoWnd.m_fps);

	SystemInfoWnd.m_root:addToRoot();
	SystemInfoWnd:setPos();

	-- SystemInfoWnd.m_info_bg:setOnClick(self,function(self)

 --      WindowManager:showWindow(WindowTag.TestToolPopu)

	-- end);
end

SystemInfoWnd.setPos = function()
	SystemInfoWnd.m_root:setPos(0,0);
	SystemInfoWnd.m_info_bg:setPos(20,15);
	SystemInfoWnd.m_info_bg:setSize(320,50);
	SystemInfoWnd.m_animNum:setPos(25, 30);
	SystemInfoWnd.m_memory:setPos(120, 30);
	SystemInfoWnd.m_fps:setPos(270, 30);
	SystemInfoWnd.m_root:setVisible(true);
	if SystemInfoWnd.m_animRepeat then
		delete(SystemInfoWnd.m_animRepeat);
		SystemInfoWnd.m_animRepeat = nil;
	end
	SystemInfoWnd.m_animRepeat = AnimFactory.createAnimInt(kAnimRepeat, 0, 1, 1000, 0);
	SystemInfoWnd.m_animRepeat:setDebugName("SystemInfoWnd.m_animRepeat");
	SystemInfoWnd.m_animRepeat:setEvent(SystemInfoWnd, SystemInfoWnd.updateInfo);
end

SystemInfoWnd.updateInfo = function()

    
    local memoryNum=System.getTextureMemory();
    local M=System.getTextureMemory()/(1024*1024);
    local K=(System.getTextureMemory()%(1024*1024))/1024;
	local memoryStr = "Mer:" .. ToolKit.getIntPart(M).."M"..ToolKit.getIntPart(K).."K"; 
	local animNumStr = "Ainm:" .. System.getAnimNum();
	local fpsStr = "FPS:" .. System.getFrameRate();
	SystemInfoWnd.m_animNum:setText(animNumStr);
	SystemInfoWnd.m_memory:setText(memoryStr);
	SystemInfoWnd.m_fps:setText(fpsStr); 
end

SystemInfoWnd.dtor = function()
	if SystemInfoWnd.m_animRepeat then
		delete(SystemInfoWnd.m_animRepeat);
		SystemInfoWnd.m_animRepeat = nil;
	end
	delete(SystemInfoWnd);
	print_string("SystemInfoWnd is dtor");
end