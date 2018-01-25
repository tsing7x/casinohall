
require("core.load")()

print = print_string

function event_lua_error(  )
	local errorTips = System.getLuaError() or "";
    NativeEvent.getInstance():ReportLuaError(errorTips);
    if DEBUG_MODE == true then
		WindowManager:showWindow(WindowTag.ErrorTipBox, errorTips, WindowStyle.POPUP)
	end
end

LOADED = {}
function loadHall()
	local isReload = true
	if isReload then
		for i=1,#LOADED do
			package.loaded[LOADED[i]] = nil
		end
	end

	LOADED = {}
	local function record()
		local _require = require
		require = function(file,...)
			table.insert(LOADED,file)
			return _require(file,...)
		end
		
		require("app.config")
		require("ex")
		require("app.init")

		require = _require
	end

	record()

	-- dump(LOADED)
end

function event_load(width, height)
	loadHall()

	appEntry()
end

function appEntry()
	System.setImageFilterPicker(function(filename) return kFilterLinear end)

    new(require("app.app")):run()
end

