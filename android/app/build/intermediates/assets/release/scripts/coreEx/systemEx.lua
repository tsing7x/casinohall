System.getFrameRate = function()
	return math.round(Clock.instance().fps) or 0;
end

System.setFrameRate = function(fps)
	--
end

System.getTextureMemory = function()
	return MemoryMonitor.instance().texture_size;
end

System.getLuaError = function()
	return sys_get_string("last_lua_error");
end