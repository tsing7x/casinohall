local  kefuStringRes = require("kefuSystem/common/kefuStringRes")

return function (  )
	local curPlatform = System.getPlatform();
	local cache_config = nil;

	if curPlatform ~= kPlatformIOS then
		local temp = {}
		for k,v in pairs(kefuStringRes) do
			table.insert( temp, v )
		end
		local str = table.concat( temp, "" )
		str = (string.gsub(str, "\n", ""))
		cache_config = {
		        version = 1,
		        all_cache_char = {
		            {
		                font_style = Label.STYLE_NORMAL,
		                outline = 0,
		                char_list = str,
		            },
		        },
		    }
	end
	
    Label.config{
        content_scale =  1,
        font_size = 48,
        enable_distance_field = false,
        texture_size_x = 1024,
        texture_size_y = 1024,
        cache = cache_config
    }
end