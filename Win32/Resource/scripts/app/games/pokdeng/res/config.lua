local CHINA 	= 'chn'
local THAILAND  = 'tpe'

if LANGUAGE == CHINA then
	return require('app.games.pokdeng.res.string_chn')
elseif LANGUAGE == THAILAND then
	return require('app.games.pokdeng.res.string_tpe')
end