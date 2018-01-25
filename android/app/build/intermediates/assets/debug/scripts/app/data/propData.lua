local PropData = class(require("app.data.dataList"))

function PropData:getConfigByLevel(level)
	for i=1, self:count() do
		local data = self:get(i)
		if level == data:getLevel() then
			return data
		end
	end
end

return PropData