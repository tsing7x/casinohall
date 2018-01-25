local PlatformFactory = {};
local PATH = "app.platform.branch."
-- [[新平台需在此处配置]]
PlatformFactory.initPlatform = function(platType)
	return new(require(PATH .. "mainPlatform"));
end

return PlatformFactory