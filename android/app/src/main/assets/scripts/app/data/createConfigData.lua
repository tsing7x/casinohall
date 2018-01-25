--[[
	建房参数列表
]]

local List = require('app.data.dataList')

addProperty(List, "gameId", 0)


function List:getConfigByLevel(level)
	for i=1, self:count() do
		if self:get(i):getLevel() == level then
			return self:get(i)
		end
	end
end

function List:init(gameConfig)
	self:setGameId(gameConfig.gameId)

	for i=1,#gameConfig.config do
		local info = gameConfig.config[i]
		local config = self:getConfigByLevel(info.level)
		if not config then
			config = new(require("app.data.createConfig")):setLevel(info.level)
			self:add(config)
		end

		config:init(info)
		-- dump(config,"==========")
	end
end

local createConfigData = class(require('app.data.dataList'))


function createConfigData:getConfigByGameId(gameId)
	for i=1, self:count() do
		if self:get(i):getGameId() == gameId then
			return self:get(i)
		end
	end
end

function createConfigData:addNew(gameId)
	local list = new(List):setGameId(gameId)
	self:add(list)
	return list
end

return createConfigData