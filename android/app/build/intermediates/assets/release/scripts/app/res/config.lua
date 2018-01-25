local CHINA 	= 'chn'
local THAILAND  = 'tpe'

if LANGUAGE == CHINA then
	return require('app.res.string.string_chn')
elseif LANGUAGE == THAILAND then
	return require('app.res.string.string_tpe')
end
--拼图
-- require("pintu.lobby")
-- require("pintu.chip")
-- require("pintu.chipNumber")
-- require("pintu.expNumber")
-- require("pintu.popu")
-- require("pintu.room")
-- require("pintu.user")
-- require("pintu.buddyRoom")