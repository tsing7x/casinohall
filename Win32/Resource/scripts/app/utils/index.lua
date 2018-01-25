local cIndex = 0
local function getIndex()
	cIndex = cIndex + 1
	return cIndex
end

local function reset()
	cIndex = 0
	return getIndex
end

return reset